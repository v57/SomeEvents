//
//  content-video.swift
//  Some Events
//
//  Created by Димасик on 7/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

enum VideoTempOptions: UInt8 {
  case createdInThisSession
}

class VideoContent: Content, PhysicalContent {
  override var type: ContentType {
    return .video
  }
  override var uploadType: UploadLink {
    return VideoUpload(content: self)
  }
  override var previewUploadType: UploadLink {
    return VideoPreviewUpload(content: self)
  }
  
  override var downloadType: DownloadType {
    return .video(content: self)
  }
  override var previewDownloadType: DownloadType {
    return .videoPreview(content: preview)
  }
  var link: URL {
    return .server("events/\(eventid)/\(id)-\(password.hex).m4v")
  }
  var options = VideoOptions.Set()
  var tempOptions = VideoTempOptions.Set()
  var videoData = VideoData()
  var password = UInt64()
  
  override var isUploaded: Bool {
    return options[.uploaded]
  }
  override var isPreviewUploaded: Bool {
    return options[.previewUploaded]
  }
  override var size: Int64 {
    return Int64(videoData.size)
  }
  
  var videoLink: URL {
    return link
  }
//  var videoLink: URL {
//    return isDownloaded ? url.url : link
//  }
  
  
  override init(eventid: Int64) {
    super.init(eventid: eventid)
  }
  required init(data: DataReader) throws {
    options = try data.next()
    password = try data.next()
    videoData = try data.next()
    try super.init(data: data)
  }
  required init(server data: DataReader, eventid: Int64) throws {
    options = try data.next()
    password = try data.next()
    videoData = try data.next()
    try super.init(server: data, eventid: eventid)
  }
  override func save(data: DataWriter) {
    data.append(options)
    data.append(password)
    data.append(videoData)
    super.save(data: data)
  }
  
  override func setPreviewUploaded() {
    options[.previewUploaded] = true
    Notification.eventMain { $0.uploaded(preview: self, in: event) }
  }
  func setUploaded(videoData: VideoData) {
    options[.uploaded] = true
    self.videoData = videoData
    Notification.eventMain { $0.uploaded(content: self, in: event) }
  }
  func view(page: Page) -> UIView {
    let url = self.videoLink
    let view = VideoPlayer(page: page, url: url, content: self)
    view.frame = screen.frame
    return view
  }
}
