//
//  MessageProtocols.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData
import SomeBridge

enum MessageUploadStatus: UInt8 {
  case uploaded, downloaded
  static let `default` = MessageUploadStatus.Set([.downloaded])
}

protocol MessageBodyType: class, DataRepresentable {
  var type: MessageType { get }
  var string: String { get }
  func write(to string: NSMutableAttributedString, message: Message)
}

struct StorableMessageLink {
  let chat: Chat
  let message: Message
  let bodyIndex: Int
  let body: StorableMessage
  var upload: UploadRequest? {
    UploadRequest.lock.lock()
    defer { UploadRequest.lock.unlock() }
    return serverManager.uploads[localURL]
  }
  var fileName: String {
    return body.fileName(index: message.index)
  }
  var remoteURL: URL {
    return .server(chat.path + fileName)
  }
  var localURL: FileURL {
    return body.url(message: message)
  }
  var url: URL {
    if body.isDownloaded {
      return localURL.url
    } else {
      return remoteURL
    }
  }
  var tempURL: FileURL {
    return body.tempURL(message: message)
  }
  init(chat: Chat, message: Message, bodyIndex: Int) {
    self.chat = chat
    self.message = message
    self.bodyIndex = bodyIndex
    self.body = message.body.messages[bodyIndex] as! StorableMessage
  }
}

extension StorableMessageLink: DataRepresentable {
  init(data: DataReader) throws {
    let link: ChatLink = try data.next()
    chat = link.chat
    let index = try data.int()
    guard let message = chat[index] else { throw notFound }
    self.message = message
    bodyIndex = try data.next()
    guard let body = message.body.messages.safe(bodyIndex) as? StorableMessage else { throw notFound }
    self.body = body
  }
  
  func save(data: DataWriter) {
    chat.write(link: data)
    data.append(message.index)
    data.append(bodyIndex)
  }
}

protocol StorableMessage: class {
  var password: UInt64 { get set }
  var fileFormat: String { get }
  var fileSize: Int64 { get }
  var isUploaded: Bool { get set }
  var isDownloaded: Bool { get set }
  var attachment: StorableAttachment? { get }
  func indexChanged(message: Message, oldValue: Int)
  func delete(chat: Chat, message: Message)
  func write(upload: DataWriter)
  func updateFileInformation(url: FileURL)
}

extension StorableMessage {
  func checkUpload(message: Message) {
    guard !isUploaded else { return }
    let url = self.url(message: message)
    guard serverManager.uploads[url] == nil else { return }
    guard url.exists else { return }
    isDownloaded = true
    updateFileInformation(url: url)
    guard fileSize > 0 else { return }
    upload(with: message)
  }
  
  func upload(with message: Message) {
    let link = self.link(for: message)
    let request = ChatFileUpload(link: link)
    let upload = server.upload(type: request)
    mainThread {
      self.attachment?.uploading(with: upload)
    }
  }
  
  func fileName(index: Int) -> String {
    return "\(index)x\(password.hex).\(fileFormat)"
  }
  func url(from url: FileURL, customIndex: Int) -> FileURL {
    return url + fileName(index: customIndex)
  }
  func url(message: Message) -> FileURL {
    return url(from: message.chat.url, customIndex: message.index)
  }
  func tempURL(message: Message) -> FileURL {
    return url(from: message.chat.tempURL, customIndex: message.index)
  }
  func delete(chat: Chat, message: Message) {
    
  }
  func upload(for message: Message) -> UploadRequest? {
    let url = self.url(message: message)
    return serverManager.uploads[url]
  }
  func link(for message: Message) -> StorableMessageLink {
    let chat = message.chat
    let index = self.index(for: message)
    return StorableMessageLink(chat: chat, message: message, bodyIndex: index)
  }
  func index(for message: Message) -> Int {
    return message.body.messages.index(where: { $0 === self })!
  }
  func uploaded() {
    isUploaded = true
    guard let attachment = attachment else { return }
    mainThread {
      attachment.uploaded()
    }
  }
}

class StorableAttachment: AttachmentView {
  func uploading(with upload: UploadRequest) {
    views.values.forEach { ($0 as! StorableAttachmentView).uploading(with: upload) }
  }
  func uploaded() {
    views.values.forEach { ($0 as! StorableAttachmentView).uploaded() }
  }
}
class StorableAttachmentView: UIView {
  var uploadingProgress: DownloadingView!
  func uploading(with upload: UploadRequest) {
    guard uploadingProgress == nil else { return }
    uploadingProgress = DownloadingView(center: bounds.center)
    addSubview(uploadingProgress)
    uploadingProgress.follow(progress: upload.progress) { [weak self] in
      self?.uploadingProgress = nil
    }
  }
  
  func uploaded() {
    
  }
}
