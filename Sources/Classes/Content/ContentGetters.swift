//
//  ContentGetters.swift
//  Events
//
//  Created by Димасик on 1/22/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions

extension Content {
  var event: Event {
    return eventid.event!
  }
  var isDownloaded: Bool {
    return url.exists
  }
  var isPreviewDownloaded: Bool {
    return previewURL.exists
  }
  var isPreviewAvailable: Bool {
    return isPreviewUploaded || isPreviewDownloaded
  }
  var isAvailable: Bool {
    return isUploaded || isDownloaded
  }
  var name: String {
    return "\(type) (\(id))"
  }
  var comparableValue: Time {
    return self.time
  }
  var currentUpload: UploadRequest? {
    guard let upload = serverManager.uploads[url] else { return nil }
    guard !upload.progress.isCompleted else { return nil }
    return upload
  }
  var currentPreviewUpload: UploadRequest? {
    guard let upload = serverManager.uploads[previewURL] else { return nil }
    guard !upload.progress.isCompleted else { return nil }
    return upload
  }
  
//  var isRemoved: Bool {
//    get {
//      fatalError()
//    } set {
//      let implementationNeeded = true
//    }
//  }
  var preview: ContentPreview {
    return ContentPreview(id: id, type: type, event: eventid)
  }
}
