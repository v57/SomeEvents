//
//  Input.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import CoreLocation
import MobileCoreServices
import Photos
import SomeMap

/*
class Input: DPView {
  var onStartRecording: (()->())?
  var onEndRecording: (()->())?
  var onSendText: ((String)->())?
  var onSendFile: ((FileURL)->())?
  var onSendCoordinate: ((CLLocationCoordinate2D)->())?
  var onResize: ((_ offset: CGFloat)->())?
  var onTyping: (()->())?
  var onError: ((Error)->())?
  
  var recording: Time = 0
  var isRecording = false
  let input: InputView
  lazy var record: VoiceView = { return VoiceView(frame: self.bounds) }()
  
  var minHeight: CGFloat
  var height: CGFloat
  let insets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 34, bottom: 5, right: 41)
  override init(frame: CGRect) {
    minHeight = frame.height - insets.top - insets.bottom
    height = frame.height
    
    let bounds = CGRect(origin: .zero, size: frame.size)
    input = InputView(frame: bounds, insets: insets)
    super.init(frame: frame)
    backgroundColor = .custom(0xF5F5F5)
    
    input.textView.textViewDelegate = self
    input.moreButton.addTarget(self, action: #selector(more), for: .touchUpInside)
    input.recordButton.addTarget(self, action: #selector(startRecording), for: .touchDown)
    input.recordButton.addTarget(self, action: #selector(endRecording), for: .touchUpInside)
    input.recordButton.addTarget(self, action: #selector(cancelRecording), for: .touchDragExit)
    input.recordButton.addTarget(self, action: #selector(cancelRecording), for: .touchCancel)
    input.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
    if settings.sendOnReturn {
      input.textView.returnKeyType = .send
    }
    
    addSubview(input)
    addSubview(record)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK:- Voice functions
extension Input {
  var recordingTime: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return ""
  }
  @objc func startRecording() {
    guard !isRecording else { return }
    Recorder.requestPermissions { granted in
      if granted {
        do {
          try self.record.start()
          self.isRecording = true
          self.animate {
            self.input.alpha = 0.0
          }
        } catch {
          self.onError?(error)
        }
      } else {
        self.onError?(RecorderError.noPermissions)
      }
    }
  }
  @objc func endRecording() {
    guard isRecording else { return }
    isRecording = false
    animate {
      input.alpha = 1.0
    }
    do {
      let file = try record.stop()
      guard file.duration > 1 else { return }
      onSendFile?(file.url.fileURL)
    } catch {
      onError?(error)
    }
  }
 @objc func cancelRecording() {
    guard isRecording else { return }
    isRecording = false
    animate {
      input.alpha = 1.0
    }
    do {
      try record.stop()
    } catch {
      onError?(error)
    }
  }
}

// MARK:- Text functions
extension Input {
  @objc func send() {
    onSendText?(input.textView.text)
    input.textView.text = ""
    input.sendButton.isEnabled = false
    endTyping()
  }
  func type() {
    input.sendButton.isEnabled = !input.textView.text.isEmpty
    onTyping?()
    if input.textView.text.isEmpty {
      endTyping()
    } else {
      startTyping()
    }
  }
  func startTyping() {
    animate {
      input.sendButton.alpha = 1.0
      input.recordButton.alpha = 0.0
    }
  }
  func endTyping() {
    guard input.textView.text.isEmpty else { return }
    //    guard !input.textView.isFirstResponder else { return }
    animate {
      input.sendButton.alpha = 0.0
      input.recordButton.alpha = 1.0
    }
  }
}

// MARK:- More button
extension Input {
  @objc func more() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
      alert.add("Камера") {
        self.openCamera()
      }
    }
    alert.add("Выбрать из галереи") {
      self.openLibrary()
    }
    alert.add("Файл") {
      self.import()
      //      let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      //      let pickers = FilePicker.all
      //      for picker in pickers {
      //        alert.add(picker.title) {
      //          self.import(from: picker.type)
      //        }
      //      }
      //      alert.addCancel()
      //      main.present(alert)
    }
    alert.add("Контакт")
    alert.add("Координаты") {
      MapViewController.show(startCoordinate: nil) { [weak self] coordinate in
        self?.onSendCoordinate?(coordinate)
      }
    }
    alert.addCancel()
    main.present(alert)
  }
}

// MARK:- TextView delegate
extension Input: TextViewDelegate {
  //  func textViewDidBeginEditing(_ textView: UITextView) {
  //
  //  }
  func textViewDidChange(_ textView: UITextView) {
    type()
  }
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    guard settings.sendOnReturn else { return true }
    guard text == "\n" else { return true }
    send()
    return false
  }
  func textViewDidEndEditing(_ textView: UITextView) {
    endTyping()
  }
  func textViewContentSizeChanged(_ textView: TextView, oldValue: CGSize) {
    print("height: \(textView.contentSize.height) fontHeight: \(textView.font!.lineHeight)")
    let height = textView.contentSize.height < minHeight
      ? minHeight : textView.contentSize.height
    let newHeight = height + insets.top + insets.bottom
    let offset = newHeight - self.height
    guard offset != 0.0 else { return }
    self.height = newHeight
    animate {
      resize(Size(frame.width,self.height), .bottom)
      input.frame = bounds
      input.sendButton.frame.y += offset
      input.moreButton.frame.y += offset
      input.recordButton.frame.y += offset
      input.textView.frame.height = height
    }
    onResize?(offset)
  }
}

//MARK:- Import
extension Input {
  func `import`() {
    let vc = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
    vc.delegate = self
    vc.modalPresentationStyle = .formSheet
    main.present(vc)
  }
}


extension Input: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
    self.onSendFile?(url.fileURL)
  }
  
  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    
  }
}

//MARK:- Pick photo
extension Input: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func openCamera() {
    let picker = UIImagePickerController()
    picker.sourceType = UIImagePickerControllerSourceType.camera
    picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String];
    picker.allowsEditing = false
    picker.delegate = self
    main.present(picker)
  }
  
  func openLibrary() {
    let picker = UIImagePickerController()
    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String];
    picker.allowsEditing = false
    picker.delegate = self
    main.present(picker)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    picker.dismiss(animated: true, completion: nil)
    
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
      do {
        var url: FileURL = .temp
        url += UUID().uuidString
        url.create()
        url += "photo.jpg"
        let jpg = image.jpg(settings.compressQuality)
        try jpg.write(to: url)
        
        self.onSendFile?(url)
      } catch {
        main.alert(error: error)
      }
    } else if let url = info[UIImagePickerControllerReferenceURL] as? URL {
      let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
      if let photo = fetchResult.firstObject {
        guard let resource = PHAssetResource.assetResources(for: photo).first else { return }
        let fileName = resource.originalFilename
        var url = URL(fileURLWithPath: NSTemporaryDirectory())
        url.appendPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        url.appendPathComponent(fileName)
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: options, completionHandler: { (error) in
          if let error = error {
            main.alert(error: error)
          } else {
            self.onSendFile?(url.fileURL)
          }
        })
      }
    } else if let url = info[UIImagePickerControllerMediaURL] as? URL {
      onSendFile?(url.fileURL)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}

class InputView: UIView {
  let moreButton: UIButton
  let textView: TextView
  let sendButton: UIButton
  let recordButton: UIButton
  
  init(frame: CGRect, insets: UIEdgeInsets) {
    let w = frame.width
    let h = frame.height
    let h2 = h/2
    let lineHeight: CGFloat = 20
    let textInset = (h - insets.top - insets.bottom - lineHeight) / 2
    
    moreButton = UIButton(pos: Pos(insets.left / 2, h2), anchor: .center, name: "input-more")
    
    textView = TextView(frame: CGRect(insets.left, insets.top, w - (insets.left + insets.right), h - (insets.top + insets.bottom)))
    textView.textContainerInset.top = textInset
    textView.textContainerInset.bottom = textInset
    
    textView.placeholder = "Написать сообщение"
    textView.placeholderLabel!.offset(x: 3)
    textView.layer.cornerRadius = 3
    textView.setBorder(.placeholder, screen.pixel)
    
    sendButton = UIButton(pos: Pos(w - 20, h2), anchor: .center, name: "input-send")
    sendButton.setImage(UIImage(named: "input-send-disabled"), for: .disabled)
    sendButton.isEnabled = false
    sendButton.alpha = 0.0
    
    recordButton = UIButton(pos: Pos(w - 20, h2), anchor: .center, name: "input-record")
    
    super.init(frame: frame)
    addSubviews(moreButton, textView, sendButton, recordButton)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class VoiceView: UIView {
  let timerIcon: UIView
  let timerLabel: UILabel
  let circleView: UIImageView
  let cancelLabel: UILabel
  let cancelIcon: UIImageView
  
  var started: Double = 0
  var timer: Timer?
  
  var recorder: Recorder?
  
  override init(frame: CGRect) {
    let h = frame.height
    let h2 = h/2
    
    timerIcon = UIView(frame: CGRect(Pos(10,h2),.left,Size(6,6)))
    timerIcon.backgroundColor = .red
    timerIcon.circle()
    
    let timerLabelFont = UIFont.normal(14)
    timerLabel = UILabel(frame: CGRect(Pos(24,h2),.left,Size(100,timerLabelFont.lineHeight)))
    timerLabel.text = "00:00:00"
    timerLabel.textColor = .black
    timerLabel.font = timerLabelFont
    
    circleView = UIImageView(frame: .zero)
    circleView.backgroundColor = .orange
    circleView.contentMode = .center
    circleView.image = UIImage(named: "input-record-on")
    
    cancelIcon = UIImageView(image: UIImage(named: "input-record-cancel"))
    cancelIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
    cancelIcon.move(Pos(110,h2), .left)
    
    cancelLabel = UILabel(pos: cancelIcon.frame.right + Pos(7,0), anchor: .left, text: "Влево для отмены", color: .lightGray, font: .normal(14))
    
    super.init(frame: frame)
    alpha = 0.0
    
    hide()
    circleView.circle()
    
    addSubviews(timerIcon, timerLabel, circleView, cancelLabel, cancelIcon)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func start() throws {
    if timer != nil {
      timer!.invalidate()
      timer = nil
    }
    
    started = Time.abs
    tick()
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    
    alpha = 1.0
    animate {
      show()
    }
    circleView.set(cornerRadius: circleView.frame.height / 2)
    
    recorder = Recorder()
    try recorder!.start()
  }
  
  @discardableResult
  func stop() throws -> Voice {
    if timer != nil {
      timer!.invalidate()
      timer = nil
    }
    animate ({
      hide()
    }) {
      if self.circleView.alpha == 0.0 {
        self.alpha = 0.0
      }
    }
    circleView.set(cornerRadius: circleView.frame.height / 2)
    
    guard let recorder = recorder else { throw RecorderError.notStarted }
    return try recorder.stop()
  }
  
  @objc func tick() {
    let secs = Time.abs - started
    timerLabel.text = secs.formatSeconds("HH:mm:ss")
  }
  
  func show() {
    circleView.frame = CGRect(Pos(frame.width - 20,frame.height/2),.center,Size(60,60))
    circleView.alpha = 1.0
    timerLabel.alpha = 1.0
    timerIcon.alpha = 1.0
    cancelIcon.alpha = 1.0
    cancelLabel.alpha = 1.0
  }
  func hide() {
    circleView.frame = CGRect(Pos(frame.width - 20,frame.height/2),.center,Size(40,40))
    circleView.alpha = 0.0
    timerLabel.alpha = 0.0
    timerIcon.alpha = 0.0
    cancelIcon.alpha = 0.0
    cancelLabel.alpha = 0.0
  }
}
*/


extension UIView {
  func set(cornerRadius: CGFloat, duration: Double = atime) {
    let animation = CABasicAnimation(keyPath: "cornerRadius")
    animation.duration = CFTimeInterval(duration)
    animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    animation.fromValue = layer.cornerRadius
    animation.toValue = cornerRadius
    animation.fillMode = kCAFillModeForwards
    animation.isRemovedOnCompletion = false
    layer.add(animation, forKey: "setCornerRadius")
    layer.cornerRadius = cornerRadius
  }
}

extension Double {
  func formatSeconds(_ format: String) -> String {
    let date = Date(timeIntervalSince1970: self)
    let df = DateFormatter()
    df.dateFormat = format
    df.timeZone = TimeZone(secondsFromGMT: 0)
    return df.string(from: date)
  }
}

enum AttachmentType {
  case text(String)
  case image(UIImage)
  case video(FileURL)
  case coordinate(CLLocationCoordinate2D)
}

class InputEvents {
  var height: (()->())?
  var send: ((String)->(Bool))?
  var attachmentSend: (([AttachmentType])->(Bool))?
}

class Input2: DFVisualEffectView, TextViewDelegate {
  let events = InputEvents()
  static var height: CGFloat { return 42 }
  static func dframe() -> CGRect {
    return CGRect(0,screen.bottom-keyboardHeight-Input2.height,screen.width,Input2.height)
  }
  static func dframe(for view: UIView) -> () -> (CGRect) {
    return { [unowned view] in
      return CGRect(.margin, view.frame.height - keyboardInset(for: view) - Input2.height - .miniMargin, view.frame.width - .margin2, Input2.height)
    }
  }
  
  /*
   left: 8
   right: 8
   send: 72
   sendx (68/2)
   
   height: 42
   tfheight: 30
   */
  let textView = CustomTextView(frame: .zero)
  private let sendButton = UIButton(image: #imageLiteral(resourceName: "ChatSend"))
  private let attachmentButton = UIButton(image: #imageLiteral(resourceName: "ChatAdd"))
  
  var isEmpty = true {
    didSet {
      guard isEmpty != oldValue else { return }
      if isEmpty {
        // что я тут хотел сделать??
      } else {
        
      }
    }
  }
  init() {
    let effect = UIBlurEffect(style: .extraLight)
    super.init(effect: effect)
    
    dframe = Input2.dframe
    
//    sendButton.resize(Size(100,100), .center)
    
    textView.textContainerInset.top = (textView.frame.height - UIFont.body.lineHeight) / 2
    textView.textContainerInset.bottom = textView.textContainerInset.top
    textView.textColor = .dark
    textView.alwaysBounceVertical = true
    textView.placeholder = "Message"
    textView.backgroundColor = .clear
//    textView.backgroundColor = .black(0.08)
//    textView.set(cornerRadius: 4)
    textView.textViewDelegate = self
    attachmentButton.center = Pos(21,21)
    
    contentView.addSubview(textView)
    contentView.addSubview(attachmentButton)
    contentView.addSubview(sendButton)
    
    backgroundColor = .white(0.2)
    clipsToBounds = true
    cornerRadius = 12
    setBorder(.lightGray, screen.pixel)
    
    sendButton.add(target: self, action: #selector(send))
    attachmentButton.add(target: self, action: #selector(openMenu))
  }
  
  @objc func openMenu() {
    let menu = UIAlertController()
    if UIDevice.isCameraAvailable {
      menu.add("Camera") {
        self.openCamera()
      }
    }
    menu.add("Photo Library") {
      self.openLibrary()
    }
    menu.add("Map Location") {
      self.openMap()
    }
    menu.addCancel()
    if let controller = menu.popoverPresentationController {
      controller.sourceView = attachmentButton
      controller.sourceRect = attachmentButton.bounds
    }
    main.present(menu)
  }
  func openCamera() {
    let picker = ImagePicker()
    picker.saveToLibrary = false
    picker.imageCaptured = { image, info in
      self.picked(image: image)
    }
    picker.videoCaptured = { url, info in
      self.picked(video: url)
    }
    picker.openCamera()
  }
  
  func openLibrary() {
    let picker = ImagePicker()
    picker.saveToLibrary = false
    picker.imageCaptured = { image, info in
      self.picked(image: image)
    }
    picker.videoCaptured = { url, info in
      self.picked(video: url)
    }
    picker.openLibrary()
  }
  func openMap() {
    MapViewController.show(startCoordinate: nil) { coordinate in
      self.picked(coordinate: coordinate)
    }
  }
  func picked(coordinate: CLLocationCoordinate2D) {
    let attachment = RawCoordinateAttachment(coordinate: coordinate)
    textView.insert(attachment: attachment)
  }
  
  func picked(image: UIImage) {
    let attachment = RawPhotoAttachment(photo: image)
    textView.insert(attachment: attachment)
  }
  
  func picked(video: FileURL) {
    let attachment = RawVideoAttachment(url: video)
    textView.insert(attachment: attachment)
  }
  
//  func append(image: UIImage) {
//    let a = textView.attributedText!
//    let ma = NSMutableAttributedString(attributedString: a)
//
//    let width: CGFloat = 100
//    let scale = image.width / width
//    let height = image.height / scale
//    let textAttachment = NSTextAttachment()
//    textAttachment.image = ImageEditor.roundedCorners(image, radius: 5, size: CGSize(width, height))
//
//    let aimage = NSAttributedString(attachment: textAttachment)
//
//    if !a.string.isEmpty {
//      ma.append(NSAttributedString(string: "\n"))
//    }
//    ma.append(aimage)
//    ma.append(NSAttributedString(string: "\n"))
//    textView.attributedText = ma
//  }
  
  @objc func send() {
    if let send = events.send {
      let text = textView.text.cleaned
      guard !text.isEmpty else { return }
      guard send(text) else { return }
    } else if let send = events.attachmentSend {
      var array = [AttachmentType]()
      for attachment in textView.content {
        switch attachment {
        case .text(let string):
          array.append(.text(string))
        case .attachment(let a):
          if let a = a as? RawPhotoAttachment {
            array.append(.image(a.photo))
          } else if let a = a as? RawVideoAttachment {
            array.append(.video(a.url))
          } else if let a = a as? RawCoordinateAttachment {
            array.append(.coordinate(a.coordinate))
          }
        case .otherAttachment:
          break
        }
      }
      guard !array.isEmpty else { return }
      guard send(array) else { return }
    }
    textView.clear()
  }
  
  func textViewContentSizeChanged(_ textView: TextView, oldValue: CGSize) {
    animate {
      updateSize()
    }
  }
  
  func updateSize() {
    guard let superview = superview else { return }
    var h = max(textView.contentSize.height,tfh)
    
    let view = superview
    let maxHeight = view.frame.height - keyboardInset(for: view) - 70
    
    h = min(h,maxHeight)
    guard textView.frame.height != h else { return }
    textView.frame.h = h
    if textView.frame.height + textView.contentOffset.y > textView.contentSize.height {
      textView.contentOffset.y = textView.contentSize.height - textView.frame.height
    }
    resize(Size(frame.width, h+12), .bottom)
    sendButton.center = sendButtonPos
    attachmentButton.center = attachmentButtonPos
    events.height?()
  }
  
  override func resolutionChanged() {
    textView.frame = textFieldFrame
    if !textView.text.isEmpty {
      updateSize()
    } else {
      sendButton.move(sendButtonPos, .center)
    }
  }
  
  private var tfw: CGFloat {
    return frame.width - 42 - 45
  }
  private let tfh: CGFloat = 32
  var textFieldFrame: CGRect {
    return CGRect(42, 6, tfw, tfh)
  }
  var sendButtonPos: Pos {
    let y = frame.height - min(frame.height / 2, 60)
    return Pos(frame.width - 21, y)
  }
  var attachmentButtonPos: Pos {
    let y = frame.height - min(frame.height / 2, 60)
    return Pos(21, y)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
