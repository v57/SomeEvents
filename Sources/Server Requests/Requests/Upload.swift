//
//  Upload.swift
//  Some Events
//
//  Created by Димасик on 10/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//


import UIKit
import SomeNetwork
import SomeBridge

protocol UploadNotifications {
  func uploading(avatar: UploadRequest)
  func uploading(photoPreview: UploadRequest, content: Content)
  func uploading(photo: UploadRequest, content: Content)
  func uploading(videoPreview: UploadRequest, content: Content)
  func uploading(video: UploadRequest, content: Content)
  func uploading(chatFile: UploadRequest, link: StorableMessageLink)
}
extension UploadNotifications {
  func uploading(avatar: UploadRequest) {}
  func uploading(photoPreview: UploadRequest, content: Content) {}
  func uploading(photo: UploadRequest, content: Content) {}
  func uploading(videoPreview: UploadRequest, content: Content) {}
  func uploading(video: UploadRequest, content: Content) {}
  func uploading(chatFile: UploadRequest, link: StorableMessageLink) {}
}

extension Server {
  @discardableResult
  func upload(type: UploadLink) -> UploadRequest {
    UploadRequest.lock.lock()
    defer { UploadRequest.lock.unlock() }
    if let upload = serverManager.uploads[type.location] {
      return upload
    } else {
      let upload = UploadRequest(type: type)
      serverManager.uploads[type.location] = upload
//      if uploadQueue.isEmpty, let content = type.content {
//        NType.upload(content, upload).display()
//      }
      type.uploading(request: upload)
      return upload
    }
  }
}

class UploadRequest: Request, SaveableRequest {
  static let lock = NSLock()
  var type: RequestType { return .upload }
  let uploadType: UploadLink
  let progress: Progress
  let connection = SomeStream2(ip: address.ip, port: address.port)
  var queue: StreamQueue {
    return .upload
  }
  init(type: UploadLink) {
    self.uploadType = type
    progress = Progress()
    progress.isCancellable = true
    super.init()
    #if debug
    description = type.description
    #endif
    ops()
    type.queue.add(self)
  }
  required init(data: DataReader) throws {
    let type: FileType = try data.next()
    uploadType = try type.linkClass.init(data: data)
    progress = Progress()
    progress.isCancellable = true
    super.init()
    ops()
  }
  func save(data: DataWriter) {
    data.append(type)
    uploadType.save(data: data)
  }
  private func ops() {
    let progress = self.progress
    let type = self.uploadType
    progress.total = type.location.fileSize
    assert(progress.total > 0, "\(type.location)")
    rename("upload(\(type))")
    set(stream: connection)
    autorepeat {
      !progress.isCancelled
    }
    connectOperation(stream: connection)
//    connect()
    request { data in
      progress.total = type.location.fileSize
      if progress.total == 0 {
        print("-wtf upload 0 \(type.location.exists) \(type.location.fileSize)")
        throw corrupted
      }
      
      type.write(to: data, total: progress.total)
    }
    read { data in
      let message: Response = try data.next()
      switch message {
      case .wrongFileSize:
        print("upload failed (\(type)): wrong file size \(progress.total)")
      case .fileIsTooBig:
        print("upload failed (\(type)): wrong file size \(progress.total)")
      case .wrongFileOffset:
        print("upload failed (\(type)): wrong file offset \(progress.completed)")
      case .ok: break
      default:
        print("upload failed (\(type)): \(message)")
      }
      guard message == .ok else { throw UploadError.wrongMessage }
      progress.completed = try data.next()
    }
    sendFile { offset, _progress in
      offset = UInt64(progress.completed)
      _progress = progress
      return type.location.url
    }
//    disconnect()
    success {
      type.uploaded()
    }
  }
  @discardableResult
  func subscribe(view: UIView, page: Page) -> UploadRequest {
    view.follow(progress: progress, page: page)
    return self
  }
}

extension FileType {
  var linkClass: UploadLink.Type {
    switch self {
    case .avatar:
      return AvatarUpload.self
    case .photo:
      return PhotoUpload.self
    case .photoPreview:
      return PhotoPreviewUpload.self
    case .video:
      return VideoUpload.self
    case .videoPreview:
      return VideoPreviewUpload.self
    case .chatFile:
      return ChatFileUpload.self
    }
  }
}

class UploadLink: DataRepresentable {
  var type: FileType { overrideRequired() }
  var location: FileURL { overrideRequired() }
  var queue: StreamQueue { return .upload }
  var description: String { return "empty decription" }
  
  func write(to data: DataWriter, total: Int64) {
    data.append(cmd.upload)
    data.append(session!.id)
    data.append(session!.password)
    data.append(type)
  }
  init() {
    
  }
  required init(data: DataReader) throws {
    
  }
  func save(data: DataWriter) {
    data.append(type)
  }
  private var fileSize: String {
    return location.fileSize.bytesString
  }
  func uploading(request: UploadRequest) {
    let queueInfo = "\(queue.isRunning ? 1 : 0)/\(queue.count)"
    let fileSize = self.location.fileSize.bytesString
    print("[\(fileSize), \(queueInfo)] uploading \(self.description)")
  }
  func uploaded() {
    let queueInfo = "\(queue.isRunning ? 1 : 0)/\(queue.count)"
    let fileSize = self.location.fileSize.bytesString
    print("[\(fileSize), \(queueInfo)] uploaded \(self.description)")
  }
}

class AvatarUpload: UploadLink {
  override var type: FileType { return .avatar }
  override var location: FileURL { return User.me.avatarURL }
  override var description: String { return "avatar" }
  
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    data.append(total)
  }
  override func uploading(request: UploadRequest) {
    sendNotification(UploadNotifications.self) {
      $0.uploading(avatar: request)
    }
  }
}

class ContentUpload: UploadLink {
  var content: Content
  init(content: Content) {
    self.content = content
    super.init()
  }
  
  required init(data: DataReader) throws {
    let e: ID = try data.next()
    let c: ID = try data.next()
    content = try c.content(in: e)
    try super.init(data: data)
  }
  override func save(data: DataWriter) {
    super.save(data: data)
    data.append(content.eventid)
    data.append(content.id)
  }
}

class PhotoUpload: ContentUpload {
  override var type: FileType { return .photo }
  override var location: FileURL { return content.url }
  override var description: String { return "photo (event: \(photoContent.eventid))" }
  var photoContent: PhotoContent { return content as! PhotoContent }
  
  override init(content: Content) {
    super.init(content: content)
  }
  required init(data: DataReader) throws {
    try super.init(data: data)
    guard content is PhotoContent else { throw corrupted }
  }
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    photoContent.photoData.size = Int32(total)
    data.append(content.eventid)
    data.append(content.id)
    data.append(photoContent.photoData)
  }
  override func uploading(request: UploadRequest) {
    super.uploading(request: request)
    sendNotification(UploadNotifications.self) {
      $0.uploading(photo: request, content: content)
    }
  }
}

class PhotoPreviewUpload: ContentUpload {
  override var type: FileType { return .photoPreview }
  override var location: FileURL { return content.previewURL }
  override var description: String { return "photo preview (event: \(photoContent.eventid), size: \(location.fileSize.bytesStringShort))" }
  override var queue: StreamQueue { return .previewUpload }
  var photoContent: PhotoContent { return content as! PhotoContent }
  
  override init(content: Content) {
    super.init(content: content)
  }
  required init(data: DataReader) throws {
    try super.init(data: data)
    guard content is PhotoContent else { throw corrupted }
  }
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    data.append(content.eventid)
    data.append(content.id)
    data.append(total)
  }
  override func uploading(request: UploadRequest) {
    super.uploading(request: request)
    sendNotification(UploadNotifications.self) {
      $0.uploading(photoPreview: request, content: content)
    }
  }
  override func uploaded() {
    super.uploaded()
    let content = self.content
    content.url.whenReady {
      let type = PhotoUpload(content: content)
      server.upload(type: type)
    }
//    content.onLowQualityAvailable {
//      let type = PhotoUpload(content: content)
//      server.upload(type: type)
//    }
  }
}

class VideoUpload: ContentUpload {
  override var type: FileType { return .video }
  override var location: FileURL { return content.url }
  override var description: String { return "video (event: \(videoContent.eventid), size: \(location.fileSize.bytesStringShort))" }
  var videoContent: VideoContent { return content as! VideoContent }
  
  override init(content: Content) {
    super.init(content: content)
  }
  required init(data: DataReader) throws {
    try super.init(data: data)
    guard content is VideoContent else { throw corrupted }
  }
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    videoContent.videoData.size = UInt64(total)
    data.append(content.eventid)
    data.append(content.id)
    data.append(videoContent.videoData)
  }
  override func uploading(request: UploadRequest) {
    super.uploading(request: request)
    sendNotification(UploadNotifications.self) {
      $0.uploading(video: request, content: content)
    }
  }
}

class VideoPreviewUpload: ContentUpload {
  override var type: FileType { return .videoPreview }
  override var location: FileURL { return content.previewURL }
  override var description: String { return "video preview (event: \(videoContent.eventid), size: \(location.fileSize.bytesStringShort))" }
  override var queue: StreamQueue { return .previewUpload }
  var videoContent: VideoContent { return content as! VideoContent }
  
  override init(content: Content) {
    super.init(content: content)
  }
  required init(data: DataReader) throws {
    try super.init(data: data)
    guard content is VideoContent else { throw corrupted }
  }
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    data.append(content.eventid)
    data.append(content.id)
    data.append(total)
  }
  override func uploading(request: UploadRequest) {
    super.uploading(request: request)
    sendNotification(UploadNotifications.self) {
      $0.uploading(videoPreview: request, content: content)
    }
  }
  override func uploaded() {
    super.uploaded()
    let type = VideoUpload(content: content)
    server.upload(type: type)
  }
}

class ChatFileUpload: UploadLink {
  override var type: FileType { return .chatFile }
  override var location: FileURL { return link.localURL }
  let link: StorableMessageLink
  init(link: StorableMessageLink) {
    self.link = link
    super.init()
  }
  
  required init(data: DataReader) throws {
    link = try data.next()
    try super.init(data: data)
  }
  override func save(data: DataWriter) {
    data.append(link)
  }
  override func write(to data: DataWriter, total: Int64) {
    super.write(to: data, total: total)
    data.append(link)
    link.body.write(upload: data)
  }
  override func uploading(request: UploadRequest) {
    super.uploading(request: request)
    sendNotification(UploadNotifications.self) {
      $0.uploading(chatFile: request, link: link)
    }
  }
}


enum UploadError: Error {
  case wrongMessage
}

