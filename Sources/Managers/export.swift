//
//  export.swift
//  faggot
//
//  Created by Димасик on 4/21/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork

let exportManager = ExportManager()
class ExportManager {
  var exports = [Export]()
  func append(_ export: Export) {
    exports.append(export)
  }
}

private extension Content {
  @discardableResult
  func dl() -> DownloadRequest {
    switch type {
    case .photo:
      return server.download(type: .photo(content: self as! PhotoContent))
    case .video:
      return server.download(type: .video(content: self as! VideoContent))
    }
  }
}

class Export: ProgressProtocol {
  var completed: Int64 {
    get {
      var completed = downloaded
      completed += downloads.sum(by: {$0.progress.completed})
      return completed
    } set {
      
    }
  }

  let content: [Content]
  var downloads = [DownloadRequest]()
  var total: Int64 = 0
  var downloaded: Int64 = 0
  var isRunning = false
  init(content: [Content]) {
    self.content = content
    for c in content {
      total += c.size
      if c.isDownloaded {
        downloaded += c.size
      }
    }
  }
  func cancel() {
    isRunning = false
    for download in downloads {
      if download.shouldRepeat {
        download.connection.disconnect()
      }
    }
  }
  func resume() {
    guard !isRunning else { return }
    isRunning = true
    let content = self.content.filter { !$0.isDownloaded }
    for c in content {
      let download = c.dl()
      download.autorepeat { [weak self] in
        if self != nil {
          return self!.isRunning
        } else {
          return false
        }
      }
      downloads.append(download)
    }
//    newThread {
//      for c in content {
//        let url = c.url
//        guard !downloads.contains(url) else { continue }
//        let file = downloads[url]
//        self.currentDownloads.insert(file)
//        file.forceListen = true
//        while self.isRunning {
//          do {
//            try c.download()
//            self.downloaded += c.size
//            break
//          } catch {
//            sleep(5)
//          }
//        }
//        self.currentDownloads.remove(file)
//
//        guard self.isRunning else { return }
//      }
//      self.isRunning = false
//    }
  }
  
  func openMenu() {
    var urls = [URL]()
    for c in content {
      if c.originalURL.exists {
        urls.append(c.originalURL.url)
      } else if c.url.exists {
        urls.append(c.url.url)
      }
    }
    let vc = UIActivityViewController(activityItems: urls, applicationActivities: nil)
    vc.excludedActivityTypes = [.addToReadingList, .assignToContact, .copyToPasteboard, .openInIBooks]
    main.present(vc, animated: true, completion: nil)
  }
  
  static func share(url: URL) {
    var excluded = [UIActivityType]()
    excluded.append(.addToReadingList)
    excluded.append(.assignToContact)
    excluded.append(.openInIBooks)
    if #available(iOS 11.0, *) {
      excluded.append(.markupAsPDF)
    }
    excluded.append(.saveToCameraRoll)
    excluded.append(.print)
    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    vc.excludedActivityTypes = excluded
    main.present(vc, animated: true, completion: nil)
  }
}


