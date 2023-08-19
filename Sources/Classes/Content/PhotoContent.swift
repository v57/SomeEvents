//
//  content-photo.swift
//  Some Events
//
//  Created by Димасик on 7/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class PhotoContent: Content, PhysicalContent {
  override var type: ContentType {
    return .photo
  }
  override var uploadType: UploadLink {
    return PhotoUpload(content: self)
  }
  override var previewUploadType: UploadLink {
    return PhotoPreviewUpload(content: self)
  }
  
  override var downloadType: DownloadType {
    return .photo(content: self)
  }
  override var previewDownloadType: DownloadType {
    return .photoPreview(content: preview)
  }
  var options = PhotoOptions.Set()
  var photoData = PhotoData()
  var password = UInt64()
  
  var link: URL {
    let link = "http://\(address.ip)/events/\(eventid)/\(id)-\(password.hex).jpg"
    return URL(string: link)!
  }
  override var isUploaded: Bool {
    return options[.uploaded]
  }
  override var isPreviewUploaded: Bool {
    return options[.previewUploaded]
  }
  override var size: Int64 {
    return Int64(photoData.size)
  }
  
  override init(eventid: Int64) {
    super.init(eventid: eventid)
  }
  required init(data: DataReader) throws {
    options = try data.next()
    password = try data.next()
    photoData = try data.next()
    try super.init(data: data)
  }
  required init(server data: DataReader, eventid: Int64) throws {
    options = try data.next()
    password = try data.next()
    photoData = try data.next()
    try super.init(server: data, eventid: eventid)
  }
  override func save(data: DataWriter) {
    data.append(options)
    data.append(password)
    data.append(photoData)
    super.save(data: data)
  }
  override func setPreviewUploaded() {
    options[.previewUploaded] = true
    Notification.eventMain { $0.uploaded(preview: self, in: event) }
  }
  func setUploaded(photoData: PhotoData) {
    options[.uploaded] = true
    self.photoData = photoData
    Notification.eventMain { $0.uploaded(content: self, in: event) }
  }
  func view(page: Page) -> UIView {
    let view = ZoomView(frame: screen.frame)
    
    if settings.test.alwaysDownloadImages {
      let temp = downloadType.tempURL
      if let download = serverManager.downloads[temp], download.progress.isCompleted {
        serverManager.downloads[temp] = nil
      }
      url.deleteCache()
      url.delete()
    }
    
    if self.isDownloaded {
      url.image { image in
        view.set(image: image)
      }
//      if url.isCached {
//        if let image = url.cachedImage {
//          view.set(image: image)
//        }
//      } else {
//        imageThread {
//          guard let image = self.url.image() else { return }
////          image.decode()
//          let i = image.decode2()
//          url.cache(image: i)
//          mainThread {
//            view.set(image: i)
//          }
//        }
//      }
    } else {
      if self.isPreviewDownloaded {
        previewURL.image { image in
          let v = view.isUpdated
          view.isUpdated = true
          view.set(image: image)
          view.isUpdated = v
        }
//        imageThread {
//          let image = self.previewURL.cachedImage
//          mainThread {
//            let v = view.isUpdated
//            view.isUpdated = true
//            view.set(image: image)
//            view.isUpdated = v
//          }
//        }
      }
      if let download = view.photo(page, content: self, subscribe: false) {
        let progress = DownloadingView(center: view.center)
        progress.dcenter = { screen.center }
        view.addSubview(progress)
//        view.follow(progress: download.progress, page: page)
        progress.follow(progress: download.progress, page: page)
        var moved = false
        
        newThread {
          download.progress.storeData = true
        }
        let progressiveImage = ProgressiveImage(download: download.progress)
        progressiveImage.shouldUpdate = { [weak view] in
          view?.isOpened ?? false
        }
        progressiveImage.onUpdate = { [weak view] image, last in
          view?.set(image: image)
          if download.progress.isCompleted || last {
            progress.value = 1.0
            progress.destroy(options: .fadeZoom(2.0))
          } else if !moved {
            moved = true
            animate {
              progress.dcenter = { Pos(screen.right - 50, screen.bottom - 50) }
            }
          }
        }
      }
    }
    return view
  }
}
