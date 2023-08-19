//
//  content.swift
//  Some Events
//
//  Created by Димасик on 7/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData
import SomeBridge

protocol PhysicalContent: class {
  var link: URL { get }
  func view(page: Page) -> UIView
}

extension ContentType {
  var `class`: Content.Type {
    switch self {
    case .photo: return PhotoContent.self
    case .video: return VideoContent.self
    }
  }
}

class Content: DataRepresentable, Hashable, ComparableValue, Versionable {
  static var version = Version(1)
  var type: ContentType {
    overrideRequired()
  }
  var uploadType: UploadLink { overrideRequired() }
  var previewUploadType: UploadLink { overrideRequired() }
  var downloadType: DownloadType { overrideRequired() }
  var previewDownloadType: DownloadType { overrideRequired() }
  
  var id: Int64 = 0
  let author: Int64
  
  var isUploaded: Bool {
    return true
  }
  var isPreviewUploaded: Bool {
    return true
  }
  var size: Int64 {
    return 0
  }
  
  var time: Time
  
  var eventid: Int64
  
  
  
//  var editor: ContentEditor?
//  func onPreviewAvailable(block: @escaping ()->()) {
//    if let editor = editor {
//      editor.onPreview(block: block)
//    } else if isPreviewDownloaded || isPreviewUploaded {
//      block()
//    }
//  }
//  func onLowQualityAvailable(block: @escaping ()->()) {
//    if let editor = editor {
//      editor.onLoad(block: block)
//    } else if isDownloaded || isUploaded {
//      block()
//    }
//  }
  
  init(eventid: Int64) {
    self.eventid = eventid
    self.author = .me
    self.time = .now
    setLocalId()
  }
  
  required init(server data: DataReader, eventid: Int64) throws {
    self.eventid = eventid
    
    self.id = try data.next()
    self.author = try data.next()
    self.time = try data.next()
  }
  
  required init(data: DataReader) throws {
    eventid = try data.next()
    id = try data.next()
    author = try data.next()
    time = try data.next()
  }
  func save(data: DataWriter) {
    data.append(eventid)
    data.append(id)
    data.append(author)
    data.append(time)
  }
  func setPreviewUploaded() {}
  
  func check() {
    //        previewLoaded = _e(previewPath)
    //        downloaded = _e(path)
  }
  
  func setLocalId() {
    id = -.unique
    while url.exists {
      id = -.unique
    }
  }
  
  func set(id: Int64) {
    guard self.id != id else { return }
    moveContent(to: id)
    if let event = eventid.event {
      if let preview = event.preview {
        if preview.id == self.id {
          preview.id = id
        }
      }
    }
    self.id = id
  }
  
//  func onPreviewAvailable(action: @escaping ()->()) {
//    if isPreviewDownloaded {
//      previewURL.whenReady(action: action)
//    } else if isPreviewUploaded {
//      action()
//    }
//  }
//  func onLowQualityAvailable(block: @escaping ()->()) {
//    if let editor = editor {
//      editor.onLoad(block: block)
//    } else if isDownloaded || isUploaded {
//      block()
//    }
//  }
  
  var hashValue: Int { return id.hashValue }
  static func == (l: Content, r: Content) -> Bool {
    return l.id == r.id && l.type == r.type
  }
}
