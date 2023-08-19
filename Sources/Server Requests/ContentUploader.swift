//
//  MyContentManager.swift
//  faggot
//
//  Created by Димасик on 12/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions
import SomeBridge

let contentManager = ContentManager()
class ContentManager: Manager {
  func append(_ content: Content) {
    guard content.eventid >= 0 else { return }
    var event: Event! = content.eventid.event
    if event == nil {
      event = eventManager.recover(content.eventid)
    }
    guard event != nil else { return }
    server.upload(content: content, to: event)
  }
  func check(_ contents: [Content]) {
    let me = ID.me
    for content in contents {
      guard content.author == me else { continue }
      content.uploadPreview()
      content.upload()
    }
  }
  func check(_ content: Content) {
    guard content.author.isMe else { return }
    content.uploadPreview()
    content.upload()
  }
}
private extension Content {
  func uploadPreview() {
    guard !isPreviewUploaded else { return }
    guard isPreviewDownloaded else { return }
    guard previewURL.exists else { return }
    server.upload(type: previewUploadType)
  }
  func upload() {
    guard isPreviewUploaded else { return }
    guard !isUploaded else { return }
    guard isDownloaded else { return }
    server.upload(type: uploadType)
  }
}

