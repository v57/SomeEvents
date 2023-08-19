//
//  DownloadManager.swift
//  faggot
//
//  Created by Димасик on 24/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

let downloadManager = DownloadManager()
class DownloadManager: Manager {
  private var subscribers = [DownloadSubscriber]()
  private var timer: Timer!
  func pause() {
    paused = true
    for view in subscribers {
      view.loadingView?.disableAnimations = true
    }
  }
  func resume(){
    paused = false
    for view in subscribers {
      view.loadingView?.disableAnimations = false
    }
  }
  
  func completed(at url: FileURL) {
    var indexes = [Int]()
    for (index,subscriber) in subscribers.enumerated() {
      if let subscriberUrl = subscriber.url, subscriberUrl == url {
        indexes.append(index-indexes.count)
        subscriber.done()
      }
    }
    guard !indexes.isEmpty else { return }
    for index in indexes {
      subscribers.remove(at: index)
    }
    if subscribers.count == 0 {
      running = false
    }
  }
  
  @objc func update() {
    var indexes = [Int]()
    for (index,subscriber) in subscribers.enumerated() {
      subscriber.update()
      let download = subscriber.download
      if download.isCancelled {
        subscriber.cancel()
        indexes.append(index-indexes.count)
      } else if download.isCompleted {
        subscriber.done()
        indexes.append(index-indexes.count)
      }
    }
    guard !indexes.isEmpty else { return }
    for index in indexes {
      subscribers.remove(at: index)
    }
    if subscribers.count == 0 {
      running = false
    }
  }
  
  private var paused = false {
    didSet {
      if paused != oldValue {
        updateStatus()
      }
    }
  }
  private var running = false {
    didSet {
      if running != oldValue {
        updateStatus()
      }
    }
  }
  private func updateStatus() {
    if timer != nil {
      if !running || paused {
        timer.invalidate()
        timer = nil
      }
    } else {
      if running && !paused {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
      }
    }
  }
  
  func subscribe(_ download: ProgressProtocol, view: UIView, url: FileURL?, page: Page, editor: UIImageEditor? = nil) {
    mainThread {
      self._subscribe(download, view: view, url: url, page: page, editor: editor)
    }
  }
  
  private func _subscribe(_ download: ProgressProtocol, view: UIView, url: FileURL?, page: Page, editor: UIImageEditor?) {
    let subscriber = DownloadSubscriber(view: view, download: download, url: url, page: page, editor: editor)
    subscribers.append(subscriber)
    running = true
  }
  
//  private func remove(_ view: DownloadSubscriber) {
//    for i in 0..<subscribers.count {
//      let v = subscribers[i]
//      if v.id == view.id {
//        subscribers.remove(at: i)
//        break
//      }
//    }
//    if subscribers.count == 0 {
//      running = false
//    }
//  }
}

class UIImageEditor {
  var showsLoader = true
  var animateLoader = true
  var displayImage = true
  var customProgress: ProgressProtocol?
  var operation: ImageOperation?
  weak var view: UIView?
  func edit(view: UIView, page: Page) {
    if let progress = customProgress {
      view.follow(progress: progress, page: page)
    }
  }
}

private class DownloadSubscriber {
  var id: Int { return ObjectIdentifier(self).hashValue }
  let view: UIView
  let download: ProgressProtocol
  let page: Page
  let loadingView: DownloadingView?
  let url: FileURL?
  var editor: UIImageEditor?
  
  init(view: UIView, download: ProgressProtocol, url: FileURL?, page: Page, editor: UIImageEditor?) {
    self.view = view
    self.download = download
    self.url = url
    self.page = page
    self.editor = editor
    var showsLoader = true
    var animateLoader = true
    if let editor = editor {
      showsLoader = editor.showsLoader
      animateLoader = editor.animateLoader
    }
//    if let button = view as? UIButton {
//      showsLoader = button.imageView?.image == nil
//    } else if let imageView = view as? UIImageView {
//      showsLoader = imageView.image == nil
//    }
    if showsLoader {
      self.loadingView = DownloadingView(center: view.frame.size.center)
      if download.completed == 0 && animateLoader {
        self.loadingView!.animating = true
      }
      for v in view.subviews {
        if let v = v as? LoadingView {
          v.animating = false
          v.removeFromSuperview()
        }
      }
      view.addSubview(loadingView!)
    } else {
      self.loadingView = nil
    }
  }
  
  func update() {
    guard download.completed > 0 else { return }
    guard let loadingView = loadingView else { return }
    if loadingView.animating {
      loadingView.animating = false
    }
    loadingView.value = download.value()
  }
  
  func done() {
    loadingView?.animating = false
    loadingView?.removeFromSuperview()
    guard let url = url else { return }
    if let editor = editor, !editor.displayImage { return }
    guard let view = view as? ImageDisplayable else { return }
    url.image(with: editor?.operation) { [weak view] image in
      view?.backgroundColor = nil
      view?.set(image: image)
//      self?.set(image: image)
    }
  }
  
  private func set(image: UIImage) {
    if let imageView = view as? UIImageView {
      imageView.animate(image)
    } else if let button = view as? UIButton {
      button.animateImage(image)
    } else if let view = view as? ImageDisplayable {
      view.set(image: image)
    }
    view.bounce()
  }
  
  func cancel() {
    loadingView?.hideAndRemove()
  }
}

//// MARK:- Test
//extension DownloadManager {
//  func test() {
//    var time: Double = 0.0
//    for _ in 0..<100 {
//      let rv: CGFloat = random(min: 0.1, max: 5)
//      time += Double(rv)
//      wait(time) {
//        self.addTestDownload()
//      }
//    }
//  }
//
//  private func addTestDownload() {
//    let download = CustomProgress()
//    download.total = 1024
//    downloadManager.append(download, text: "Маша говнова.avi")
//
//    wait(Double(random(min: 0.5, max: 2.0))) {
//      var value: CGFloat = 0.0
//      var time: Double = 0.0
//      while value < 1.0 {
//        let rt: CGFloat = random(min: 0.03, max: 0.1)
//        let rv: CGFloat = random(min: 0.001, max: 0.03)
//        time += Double(rt)
//        value += rv
//        let v = value
//        if 1% {
//          if 1% {
//            wait(time) {
//              download.isCancelled = true
//            }
//            return
//          }
//        }
//        wait(time) {
//          download.completed = Int64(v * CGFloat(download.total))
//        }
//      }
//      wait(time) {
//        download.completed = download.total
//      }
//    }
//  }
//}

