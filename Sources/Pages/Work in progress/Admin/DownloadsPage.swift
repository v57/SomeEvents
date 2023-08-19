//
//  DownloadsPage.swift
//  Some Events
//
//  Created by Димасик on 10/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork

class DownloadsPage: Page {
  var contentView: DFContentView
  override init() {
    contentView = DFContentView(frame: screen.frame)
    contentView.dframe = { screen.frame }
    super.init()
    contentView.contentInset.top = screen.top
    var ops = [StreamOperations]()
    serverManager.downloads.values.forEach { ops.append($0) }
    serverManager.uploads.values.forEach { ops.append($0) }
    ops.sort { $0.time < $1.time }
    ops.forEach { append($0) }
    
    addSubview(contentView)
  }
  func insert(_ op: StreamOperations) {
    if let download = op as? DownloadRequest {
      let cell = DownloadCell(download: download)
      contentView.insert(cell, at: 0)
    } else if let upload = op as? UploadRequest {
      let cell = UploadCell(upload: upload)
      contentView.insert(cell, at: 0)
    }
  }
  
  func append(_ op: StreamOperations) {
    if let download = op as? DownloadRequest {
      let cell = DownloadCell(download: download)
      contentView.append(cell)
    } else if let upload = op as? UploadRequest {
      let cell = UploadCell(upload: upload)
      contentView.append(cell)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension DownloadsPage: UploadNotifications {
  func uploading(avatar: UploadRequest) {
    insert(avatar)
  }
  func uploading(photoPreview: UploadRequest, content: Content) {
    insert(photoPreview)
  }
  func uploading(photo: UploadRequest, content: Content) {
    insert(photo)
  }
  func uploading(videoPreview: UploadRequest, content: Content) {
    insert(videoPreview)
  }
  func uploading(video: UploadRequest, content: Content) {
    insert(video)
  }
}

private class PageBlock: Block {
  
}

private class DownloadCell: PageBlock {
  let download: DownloadRequest
  init(download: DownloadRequest) {
    self.download = download
    super.init(height: 50)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class UploadCell: PageBlock {
  let upload: UploadRequest
  init(upload: UploadRequest) {
    self.upload = upload
    super.init(height: 50)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

