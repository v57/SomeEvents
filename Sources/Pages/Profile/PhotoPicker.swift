//
//  Camera.swift
//  Comagic
//
//  Created by Димасик on 25/09/15.
//  Copyright © 2015 Dmitry Kozlov. All rights reserved.
//

import Photos
import Some

class PhotoPicker: Page {
  var picked: ((UIImage)->())?
  var removed: (()->())?
  let view: DCVisualEffectView
  override var isFullscreen: Bool {
    return false
  }
  init(from: UIView, camera: Bool, library: Bool, removable: Bool) {
    var buttons = [FButton]()
    let cameraButton: FButton?
    if camera {
      let button = FButton(text: "Camera", icon: #imageLiteral(resourceName: "EventCamera"))
      buttons.append(button)
      cameraButton = button
    } else {
      cameraButton = nil
    }
    let libraryButton: FButton?
    if library {
      let button = FButton(text: "Library", icon: #imageLiteral(resourceName: "EventLibrary"))
      buttons.append(button)
      libraryButton = button
    } else {
      libraryButton = nil
    }
    let removeButton: FButton?
    if removable {
      let button = FButton(text: "Remove", icon: #imageLiteral(resourceName: "PRemove"))
      buttons.append(button)
      removeButton = button
    } else {
      removeButton = nil
    }
    view = DCVisualEffectView(effect: UIBlurEffect(style: .light))
    view.frame = CGRect(0,0,buttons.count*60+20,76)
    view.clipsToBounds = true
    view.layer.cornerRadius = 18
    for (i,button) in buttons.enumerated() {
      button.move(Pos(CGFloat(i)*60+20,12), .topLeft)
      view.contentView.addSubview(button)
    }
    
    super.init()
    
    transition = .fade
    
    cameraButton?.touch { [unowned self] in
      self.camera()
    }
    libraryButton?.touch { [unowned self] in
      self.library()
    }
    removeButton?.touch { [unowned self] in
      self.remove()
    }
    
    addTap(self, #selector(tap))
    showsBackButton = false
    
    addSubview(view)
    view.center = from.centerPositionOnScreen
    view.scale(0.5)
    jellyAnimation {
      self.view.dcenter = { from.centerPositionOnScreen + Pos(0,100) }
      self.view.scale(1.0)
    }
  }
  
//  override func customTransition(with page: SomePage?, ended: @escaping () -> ()) -> Bool {
//    alpha = 0.0
//    animate {
//      alpha = 1.0
//    }
//    ended()
//    return true
//  }
  
  func camera() {
    ImagePicker.openCamera { image, info in
      self.picked?(image)
    }
    close(move: false)
  }
  
  func library() {
    ImagePicker.openLibrary { image, info in
      self.picked?(image)
    }
    close(move: false)
  }
  
  func remove() {
    self.removed?()
    close(move: false)
  }
  
  @objc func tap() {
    close(move: true)
  }
  
  func close(move: Bool) {
    main.back()
    animationSettings(time: 0.25, curve: .easeOut) {
      view.scale(from: 1.0, to: 0.5, animated: true)
      if move {
        animate {
          view.center.y -= 50
        }
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}



extension UIImage {
  func save() {
    UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
  }
  func save(to album: String) {
    PHPhotoLibrary.create(album: album) { album in
      PHPhotoLibrary.save(image: self, to: album)
    }
  }
}

extension PHPhotoLibrary {
  static func save(image: UIImage, to assetCollection: PHAssetCollection) {
    shared().performChanges({
      let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
      let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
      let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
      let enumeration: NSArray = [assetPlaceHolder!]
      albumChangeRequest!.addAssets(enumeration)
    }, completionHandler: nil)
  }
  static func status(response: @escaping (PHAuthorizationStatus)->()) {
    let status = authorizationStatus()
    if status == .notDetermined {
      requestAuthorization { status in
        guard status == .authorized else { return }
        response(status)
      }
    } else if status == .authorized {
      response(status)
    }
  }
  static func create(album: String, completion: @escaping (PHAssetCollection)->()) {
    status { status in
      if let album = find(album: album) {
        completion(album)
      } else {
        shared().performChanges({
          PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: album)
        }) { success, error in
          if let error = error {
            print("create album error: \(error.localizedDescription)")
          }
          guard success else { return }
          guard let album = find(album: album) else { return }
          completion(album)
        }
      }
    }
  }
  static func find(album: String) -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", album)
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    return collection.firstObject
  }
}

private enum AlbumContentType {
  case photo(UIImage), video(URL)
}

extension SomeSettings {
  static var photoAlbumName = "SomeAlbum"
}

class PhotoLibrary {
  static var main = PhotoAlbum(name: SomeSettings.photoAlbumName)
  init() {
    
  }
  func save(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
  }
  func save(video url: URL) {
    UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
  }
}

class PhotoAlbum: PhotoLibrary {
  private var assetCollection: PHAssetCollection? {
    didSet {
      guard assetCollection != nil else { return }
      isReady = true
    }
  }
  private let name: String
  private var queue = [AlbumContentType]()
  private var isReady = false
  
  init(name: String) {
    self.name = name
    super.init()
    if let assetCollection = findAlbum() {
      self.assetCollection = assetCollection
      return
    }
    
    if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
      create()
      isReady = true
    } else {
      PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
    }
  }
  
  private func requestAuthorizationHandler(status: PHAuthorizationStatus) {
    isReady = true
    if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
      print("trying again to create the album")
      create()
      for type in queue {
        switch type {
        case .photo(let image):
          save(image: image)
        case .video(let url):
          save(video: url)
        }
      }
    } else {
      print("should really prompt the user to let them know it's failed")
    }
    queue.removeAll()
  }
  
  func create() {
    guard assetCollection == nil else { return }
    guard findAlbum() == nil else { return }
    PHPhotoLibrary.shared().performChanges({
      PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.name)
    }) { success, error in
      if let error = error {
        print("create album error: \(error.localizedDescription)")
      }
      guard success else { return }
      self.assetCollection = self.findAlbum()
    }
  }
  
  private func findAlbum() -> PHAssetCollection? {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", name)
    let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
    
    if let _: AnyObject = collection.firstObject {
      return collection.firstObject
    }
    return nil
  }
  
  override func save(image: UIImage) {
    if isReady {
      guard let assetCollection = assetCollection else { return }
      PHPhotoLibrary.shared().performChanges({
        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
        let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
        let enumeration: NSArray = [assetPlaceHolder!]
        albumChangeRequest!.addAssets(enumeration)
      }, completionHandler: nil)
    } else {
      queue.append(.photo(image))
    }
  }
  
  override func save(video url: URL) {
    if isReady {
      guard let assetCollection = assetCollection else { return }
      PHPhotoLibrary.shared().performChanges({
        guard let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) else { return }
        let placeholder = request.placeholderForCreatedAsset
        let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
        let enumeration: NSArray = [placeholder!]
        albumChangeRequest!.addAssets(enumeration)
      }, completionHandler: nil)
    } else {
      queue.append(.video(url))
    }
  }
}

extension SomeSettings {
  static var saveFromCamera = true
}

// MARK:- #ImagePicker
var imagePicker: ImagePicker?
class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var viewController: UIViewController
  var imageCaptured: ((UIImage, [String: Any]) -> ())?
  var videoCaptured: ((FileURL, [String: Any]) -> ())?
  var saveToLibrary = SomeSettings.saveFromCamera
  private lazy var picker = UIImagePickerController()
  
  override init() {
    self.viewController = main
    super.init()
  }
  init(viewController: UIViewController) {
    self.viewController = viewController
    super.init()
  }
  var mediaTypes: [String] {
    var types = [String]()
    if imageCaptured != nil {
      types.append("public.image")
    }
    if videoCaptured != nil {
      types.append("public.movie")
    }
    return types
  }
  
  private var camera = false
  func openCamera() {
    camera = true
    picker.sourceType = UIImagePickerControllerSourceType.camera
    picker.mediaTypes = mediaTypes
    picker.allowsEditing = false
    picker.delegate = self
    viewController.present(picker, animated: true, completion: nil)
    imagePicker = self
  }
  func openLibrary() {
    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    picker.mediaTypes = mediaTypes
    picker.delegate = self
    viewController.present(picker, animated: true, completion: nil)
    imagePicker = self
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    defer {
      picker.dismiss(animated: true, completion: nil)
      imagePicker = nil
    }
    guard let mediaType = info[UIImagePickerControllerMediaType] as? String else { return }
    var info = info
    if mediaType  == "public.image" {
      guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
        print("image picker error: picked image don't have image: \(info)")
        return }
      if picker.sourceType == .photoLibrary,
        let url = info[UIImagePickerControllerReferenceURL] as? URL,
        let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
        if let location = asset.location {
          info["location"] = location
        }
        if let created = asset.creationDate {
          info["created"] = Int(created.timeIntervalSince1970)
        }
      } else if picker.sourceType == .camera && saveToLibrary {
        PhotoLibrary.main.save(image: image)
      }
      imageCaptured?(image, info)
    } else if mediaType == "public.movie" {
      guard let url = info[UIImagePickerControllerMediaURL] as? URL else {
        print("image picker error: picked video don't have url: \(info)")
        return }
      if picker.sourceType == .photoLibrary,
        let url = info[UIImagePickerControllerReferenceURL] as? URL,
        let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject {
        if let location = asset.location {
          info["location"] = location
        }
        if let created = asset.creationDate {
          info["created"] = Int(created.timeIntervalSince1970)
        }
      } else if picker.sourceType == .camera && saveToLibrary {
        PhotoLibrary.main.save(video: url)
      }
      videoCaptured?(url.fileURL,info)
    }
  }
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    imagePicker = nil
  }
}

extension ImagePicker { // main
  static func openCamera(_ handler: @escaping (_ image: UIImage, _ info: [String: Any]?) -> ()) {
    imagePicker = ImagePicker(viewController: main)
    imagePicker!.imageCaptured = handler
    imagePicker!.openCamera()
  }
  static func openLibrary(_ handler: @escaping (_ image: UIImage, _ info: [String: Any]?) -> ()) {
    imagePicker = ImagePicker(viewController: main)
    imagePicker!.imageCaptured = handler
    imagePicker!.openLibrary()
  }
}
