//
//  Download.swift
//  Some Events
//
//  Created by Димасик on 10/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeNetwork
import SomeBridge

extension Server {
  @discardableResult
  func download(type: DownloadType) -> DownloadRequest {
    if let download = serverManager.downloads[type.tempURL] {
      return download
    } else {
      let download = DownloadRequest(type: type)
      serverManager.downloads[type.tempURL] = download
      return download
    }
  }
  
}

enum DownloadStatus {
  case waiting, downloading, downloaded, cancelled
}

class DownloadRequest: Request {
  let downloadType: DownloadType
  let progress: SomeDownload
  let connection = SomeStream2(ip: address.ip, port: address.port)
  var status = DownloadStatus.waiting
  init(type: DownloadType) {
    self.downloadType = type
    self.progress = SomeDownload()
    super.init()
    ops()
  }
  private func ops() {
    
    let type = self.downloadType
    
    let progress = self.progress
    progress.total = 1
    switch type {
    case .photo(content: let content):
      progress.total = Int64(content.photoData.size)
    case .video(content: let content):
      progress.total = Int64(content.videoData.size)
    default: break
    }
    
//    progress.isCancellable = true
//    progress.cancellationHandler = { [unowned self] in
//      self.connection.disconnect()
//    }
    
    #if debug
      switch type {
      case .avatar:
        description = "downloading avatar"
      case .photo:
        description = "downloading photo"
      case .photoPreview:
        description = "downloading photo preview"
      case .video:
        description = "downloading video"
      case .videoPreview:
        description = "downloading video preview"
      case .chatFile:
        description = "downloading chat file"
      }
    #endif
    rename("download(\(type))")
    set(stream: connection)
    autorepeat { [unowned self] in
      if progress.isCancelled {
        self.status = .cancelled
        return false
      } else {
        self.status = .downloading
        return true
      }
    }
    connectOperation(stream: connection)
    request { data in
      type.write(to: data)
      let size = type.tempURL.fileSize
      data.append(size)
    }
//    send { data in
//      let size = type.tempURL.fileSize
//      type.write(to: data)
//      data.append(size)
//    }
    read { data in
      let message: Response = try data.next()
      do {
        try message.check()
      } catch {
        progress.cancel()
        throw error
      }
      let size: Int64 = try data.next()
      let offset: Int64 = try data.next()
      progress.total = size
      progress.completed = offset
      if progress.total == 0 {
        print("-wtf download 0")
        progress.completed = 1
        progress.total = 1
        throw StreamError.lostConnection
      }
      progress.total += 1
    }
    onFail { [unowned self] error in
      self.status = .waiting
      if let error = error {
        print("download error: \(error)")
      } else {
        print("download failed")
      }
    }
    success {
      type.tempURL.create(subdirectories: true)
    }
    readFile {
      progress.url = type.tempURL.url
      return progress
    }
    disconnect()
    success { [unowned self] in
      let dir = type.url.directory
      if !dir.exists {
        type.url.directory.create(subdirectories: true)
      }
      type.tempURL.move(to: type.url)
      progress.completed += 1
      self.status = .downloaded
      downloadManager.completed(at: type.url)
    }
    DispatchQueue.main.async {
      downloadQueue.add(self)
    }
  }
  @discardableResult
  func subscribe(view: UIView, page: Page, editor: UIImageEditor?) -> DownloadRequest {
    autorepeat(page)
    downloadManager.subscribe(progress, view: view, url: downloadType.url, page: page, editor: editor)
    return self
  }
}

enum DownloadType {
  case avatar(user: User)
  case photo(content: PhotoContent)
  case video(content: VideoContent)
  case photoPreview(content: ContentPreview)
  case videoPreview(content: ContentPreview)
  case chatFile(link: StorableMessageLink)
  var url: FileURL {
    switch self {
    case .avatar(user: let user):
      return user.avatarURL
    case .photo(content: let content):
      return content.url
    case .video(content: let content):
      return content.url
    case .photoPreview(content: let content):
      return content.previewURL
    case .videoPreview(content: let content):
      return content.previewURL
    case .chatFile(link: let link):
      return link.localURL
    }
  }
  var tempURL: FileURL {
    switch self {
    case .avatar(user: let user):
      return user.avatarTemp
    case .photo(content: let content):
      return content.temp
    case .video(content: let content):
      return content.temp
    case .photoPreview(content: let content):
      return content.previewTemp
    case .videoPreview(content: let content):
      return content.previewTemp
    case .chatFile(link: let link):
      return link.tempURL
    }
  }
  func write(to data: DataWriter) {
    data.append(cmd.download)
    data.append(session!.id)
    data.append(session!.password)
    switch self {
    case .avatar(user: let user):
      data.append(FileType.avatar)
      data.append(user.id)
    case .photo(content: let content):
      data.append(FileType.photo)
      data.append(content.eventid)
      data.append(content.id)
    case .video(content: let content):
      data.append(FileType.video)
      data.append(content.eventid)
      data.append(content.id)
    case .photoPreview(content: let content):
      data.append(FileType.photoPreview)
      data.append(content.event)
      data.append(content.id)
    case .videoPreview(content: let content):
      data.append(FileType.videoPreview)
      data.append(content.event)
      data.append(content.id)
    case .chatFile(link: let link):
      data.append(FileType.chatFile)
      data.append(link)
    }
  }
}
