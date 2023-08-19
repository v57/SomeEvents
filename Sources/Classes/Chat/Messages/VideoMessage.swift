//
//  VideoMessage.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge


class VideoMessage: MessageBodyType, StorableMessage {
  var type: MessageType { return .video }
  var string: String { return "(video)" }
  var fileFormat: String { return "mp4" }
  var fileSize: Int64 { return Int64(videoData.size) }
  var isUploaded: Bool {
    get { return status[.uploaded] }
    set { status[.uploaded] = newValue }
  }
  var isDownloaded: Bool {
    get { return status[.downloaded] }
    set { status[.downloaded] = newValue }
  }
  var videoData: VideoData
  var password: UInt64
  var status: MessageUploadStatus.Set
  var attachment: StorableAttachment?
  
  init(video url: FileURL) {
    let video = Video(url: url)
    videoData = VideoData()
    videoData.duration = Int32(video.asset.duration.seconds)
    if let resolution = video.asset.resolution {
      videoData.width = Int16(resolution.width)
      videoData.height = Int16(resolution.height)
    }
    videoData.size = UInt64(url.fileSize)
    password = .random()
    status = MessageUploadStatus.default
  }
  required init(data: DataReader) throws {
    videoData = try data.next()
    password = try data.next()
    status = try data.next()
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(videoData)
    data.append(password)
    data.append(status)
  }
  func write(to string: NSMutableAttributedString, message: Message) {
    if attachment == nil {
      attachment = VideoAttachment(message: message, body: self)
    }
    string.append(attachment!)
  }
  
  func indexChanged(message: Message, oldValue: Int) {
    let oldURL = url(from: message.chat.url, customIndex: oldValue)
    let newURL = url(message: message)
    oldURL.alias(with: newURL)
    newURL.whenReady {
      self.videoData.size = UInt64(newURL.fileSize)
      self.upload(with: message)
    }
  }
  func write(upload: DataWriter) {
    upload.append(videoData)
  }
  func updateFileInformation(url: FileURL) {
    let video = Video(url: url)
    if let size = video.asset.resolution {
      videoData.width = Int16(size.width)
      videoData.height = Int16(size.height)
    }
    videoData.duration = Int32(video.asset.duration.seconds)
    videoData.size = UInt64(url.fileSize)
  }
}
