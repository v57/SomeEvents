//
//  ContentUploadNotification.swift
//  SomeEvents
//
//  Created by Димасик on 12/4/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class NContentUpload: LoadingNView, UniqueNotification {
  static var key: String {
    return "Content upload"
  }
  override var doneText: String {
    return "Uploaded"
  }
  let c: Content
  init(content: Content, upload: UploadRequest) {
    self.c = content
    super.init(progress: upload.progress, title: "Uploading photo")
    self.isMinimized = true
    key = NContentUpload.key
  }
  
  override func completed() {
    hide(animated: true)
  }
  
  override func tap() {
    animate {
      isMinimized = false
    }
    resetMinimize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
