//
//  downloads.swift
//  faggot
//
//  Created by Димасик on 3/4/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

//let downloads = DownloadsManager()
//
//enum DownloadsError {
//  case alreadyDownloading
//}
//
//class DownloadRetain {
//  weak var page: Page?
//  weak var view: UIView?
//  var isValid: Bool {
//    guard view != nil else { return false }
//    guard let page = page else { return false }
//    return !page.isClosed
//  }
//  init(page: Page, view: UIView) {
//    self.page = page
//    self.view = view
//  }
//}
//
//class Download: NetFile {
//  var forceListen = false
//  var retains = WeakArray<AnyObject>()
//  var downloadRetains = [DownloadRetain]()
//  
//  var priority: Operation.QueuePriority {
//    var priority: Operation.QueuePriority
//    if retains.count > 0 || downloadRetains.count > 0 {
//      priority = .normal
//    } else {
//      priority = .low
//    }
//    for retain in downloadRetains {
//      guard let page = retain.page else { continue }
//      if page.isCurrentPage {
//        priority = .high
//      }
//    }
//    return priority
//  }
//  
//  func reap() {
//    downloadRetains = downloadRetains.filter { $0.isValid }
//  }
//  
//  override func update() {
//    if !hasListeners {
//      isCancelled = true
//    }
//  }
//  
//  var hasListeners: Bool {
//    reap()
//    return forceListen || !retains.isEmpty || !downloadRetains.isEmpty
//  }
//  
//  func append(retain: AnyObject) {
//    retains.append(retain)
//  }
//  func append(view: UIView, page: Page) {
//    let retain = DownloadRetain(page: page, view: view)
//    downloadRetains.append(retain)
//  }
//  func append(retain: DownloadRetain) {
//    downloadRetains.append(retain)
//  }
//}
//
//class DownloadsManager {
//  private let locker = NSLock()
//  private var content = [FileURL: Download]()
//  var all: [Download] {
//    locker.lock()
//    defer { locker.unlock() }
//    
//    return Array(content.values)
//  }
//  subscript(url: FileURL) -> Download {
//    locker.lock()
//    defer { locker.unlock() }
//    
//    if let file = content[url] {
//      return file
//    } else {
//      let file = Download(at: url)
//      content[url] = file
//      return file
//    }
//  }
//  func remove(url: FileURL) {
//    locker.lock()
//    content[url] = nil
//    locker.unlock()
//  }
//  func contains(_ url: FileURL) -> Bool {
//    locker.lock()
//    defer { locker.unlock() }
//    return content[url] != nil
//  }
//  func check(_ url: FileURL, create: Bool) -> Download? {
//    locker.lock()
//    defer { locker.unlock() }
//    let download = content[url]
//    if create && download == nil {
//      content[url] = Download(at: url)
//    }
//    return download
//  }
//}
//
//let uploads = UploadsManager()
//class UploadsManager {
//  private let locker = NSLock()
//  private var content = [FileURL: NetFile]()
//  var all: [NetFile] {
//    locker.lock()
//    defer { locker.unlock() }
//    
//    return Array(content.values)
//  }
//  subscript(url: FileURL) -> NetFile {
//    locker.lock()
//    defer { locker.unlock() }
//    
//    if let file = content[url] {
//      return file
//    } else {
//      let file = NetFile(at: url)
//      content[url] = file
//      return file
//    }
//  }
//  func activate(url: FileURL) {
//    guard content[url] == nil else { return }
//    let file = NetFile(at: url)
//    content[url] = file
//  }
//  func remove(url: FileURL) {
//    locker.lock()
//    content[url] = nil
//    locker.unlock()
//  }
//  func contains(_ url: FileURL) -> Bool {
//    locker.lock()
//    defer { locker.unlock() }
//    return content[url] != nil
//  }
//  func check(_ url: FileURL) -> NetFile? {
//    locker.lock()
//    defer { locker.unlock() }
//    return content[url]
//  }
//}

