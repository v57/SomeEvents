//
//  PhotoMessage.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge
import UIKit

class PhotoMessage: MessageBodyType, StorableMessage {
  var type: MessageType { return .photo }
  var string: String { return "(photo)" }
  var fileFormat: String { return "jpg" }
  var fileSize: Int64 { return Int64(photoData.size) }
  var isUploaded: Bool {
    get { return status[.uploaded] }
    set { status[.uploaded] = newValue }
  }
  var isDownloaded: Bool {
    get { return status[.downloaded] }
    set { status[.downloaded] = newValue }
  }
  var attachment: StorableAttachment?
  var photoData: PhotoData
  var password: UInt64
  var status: MessageUploadStatus.Set
  init(photo: UIImage) {
    photoData = PhotoData()
    photoData.width = Int16(photo.width)
    photoData.height = Int16(photo.height)
    photoData.size = 0
    password = .random()
    status = MessageUploadStatus.default
  }
  required init(data: DataReader) throws {
    photoData = try data.next()
    password = try data.next()
    status = try data.next()
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(photoData)
    data.append(password)
    data.append(status)
  }
  func write(to string: NSMutableAttributedString, message: Message) {
    if attachment == nil {
      attachment = PhotoAttachment(message: message, body: self)
    }
    string.append(attachment!)
  }
  func indexChanged(message: Message, oldValue: Int) {
    let oldURL = url(from: message.chat.url, customIndex: oldValue)
    let newURL = url(message: message)
    oldURL.alias(with: newURL)
    newURL.whenReady {
      self.photoData.size = Int32(newURL.fileSize)
      self.upload(with: message)
    }
  }
  func write(upload: DataWriter) {
    upload.append(photoData)
  }
  func updateFileInformation(url: FileURL) {
    guard let image = url.cachedImage else { return }
    photoData.size = Int32(url.fileSize)
    photoData.width = Int16(image.width)
    photoData.height = Int16(image.height)
  }
}
