//
//  ImageLoaders.swift
//  faggot
//
//  Created by Димасик on 24/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

enum EditorPreset {
  case none, resize, circle, roundedCorners(CGFloat)
  func editor(for view: UIView) -> UIImageEditor? {
    var imageEditor: UIImageEditor! = UIImageEditor()
    switch self {
    case .none:
      imageEditor = nil
    case .resize:
      imageEditor.operation = .resize(size: view.frame.size)
    case .circle:
      imageEditor.operation = .circle(width: view.frame.width)
    case .roundedCorners(let radius):
      imageEditor.operation = .roundedCorners(radius: radius, size: view.frame.size)
    }
    return imageEditor
  }
}

enum ImageStatus {
  case empty, downloaded(FileURL), updating(FileURL, DownloadRequest), downloading(DownloadRequest)
}

//let imageCache = ImageCache()
//class ImageCache: Manager {
//  private var cache = NSCache<NSURL,UIImage>()
//  subscript(url: FileURL) -> UIImage? {
//    get {
//      if let image = cache.object(forKey: url.nsURL) {
//        return image
//      } else {
//        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
//        cache.setObject(image, forKey: url.nsURL)
//        return image
//      }
//    } set {
//      if let image = newValue {
//        cache.setObject(image, forKey: url.nsURL)
//      } else {
//        cache.removeObject(forKey: url.nsURL)
//      }
//    }
//  }
//  func alias(from: FileURL, to: FileURL) {
//    guard let image = cache.object(forKey: from.nsURL) else { return }
//    cache.setObject(image, forKey: to.nsURL)
//    cache.removeObject(forKey: from.nsURL)
//  }
//  func optional(url: FileURL) -> UIImage? {
//    return cache.object(forKey: url.nsURL)
//  }
//  func contains(url: FileURL) -> Bool {
//    return cache.object(forKey: url.nsURL) != nil
//  }
//  func start() {
//    cache.countLimit = 50
//    cache.totalCostLimit = 50.mb
//  }
//  func memoryWarning() {
//    cache.removeAllObjects()
//  }
//}

/*

enum CachedActionType {
  case main, edit
}

extension FileURL {
  var cachedImage: UIImage? {
    return imageCache[self]
  }
  var cachedImageIfContains: UIImage? {
    return imageCache.optional(url: self)
  }
  func deleteCache() {
    imageCache[self] = nil
  }
  func cache(image: UIImage) {
    imageCache[self] = image
  }
  func migrateCache(to url: FileURL) {
    imageCache.alias(from: self, to: url)
  }
  var isCached: Bool {
    return imageCache.contains(url: self)
  }
  var existsOrCached: Bool {
    return isCached || exists
  }
  func cachedImage(for action: CachedActionType, completion: @escaping (UIImage)->()) {
    switch action {
    case .main:
      if isCached {
        guard let image = cachedImage else { return }
        completion(image)
      } else {
        imageThread {
          guard let image = self.cachedImage else { return }
          mainThread {
            completion(image)
          }
        }
      }
    case .edit:
      imageThread {
        guard let image = self.cachedImage else { return }
        completion(image)
      }
    }
  }
}
 */

protocol ImageDownloader {
  var url: FileURL { get }
  var shouldUpdate: Bool { get }
  var downloadType: DownloadType { get }
  var loadable: Bool { get }
}
extension ImageDownloader {
  func download() -> ImageStatus {
    guard loadable else { return .empty }
    let url = self.url
    if settings.test.alwaysDownloadImages {
      let temp = downloadType.tempURL
      if let download = serverManager.downloads[temp], download.progress.isCompleted {
        serverManager.downloads[temp] = nil
      }
      url.deleteCache()
      url.delete()
    }
    if url.exists {
      if shouldUpdate {
        return .updating(url,server.download(type: downloadType))
      } else {
        return .downloaded(url)
      }
    } else {
      return .downloading(server.download(type: downloadType))
    }
  }
  func download(view: UIView, page: Page, editor: UIImageEditor?, subscribe: Bool) -> DownloadRequest? {
    var request: DownloadRequest?
    var url: FileURL!
    let status = download()
    switch status {
    case .empty: break
    case .downloading(let r): request = r
    case .downloaded(let u): url = u
    case .updating(let u, let r):
      url = u
      request = r
    }
    
    if subscribe {
      request?.subscribe(view: view, page: page, editor: editor)
    }
    
    guard url != nil else { return request }
    guard let view = view as? ImageDisplayable else { return request }
    url.whenReady {
      mainThread {
        url.image(with: editor?.operation) { image in
          view.backgroundColor = nil
          view.set(image: image)
        }
      }
    }
    return request
  }
}
private struct UserAvatarDownloader: ImageDownloader {
  let user: User
  var url: FileURL { return user.avatarURL }
  var shouldUpdate: Bool { return user.shouldUpdateAvatar }
  var downloadType: DownloadType { return .avatar(user: user) }
  var loadable: Bool { return user.hasAvatar }
}
private struct EventPreviewDownloader: ImageDownloader {
  let event: Event
  var url: FileURL { return event.preview!.previewURL }
  var shouldUpdate: Bool { return false }
  var downloadType: DownloadType { return event.preview!.downloadType }
  var loadable: Bool { return event.preview != nil }
}
private struct ContentPreviewDownloader: ImageDownloader {
  let content: Content
  var url: FileURL { return content.previewURL }
  var shouldUpdate: Bool { return false }
  var downloadType: DownloadType { return content.previewDownloadType }
  var loadable: Bool { return content.isPreviewAvailable }
}
private struct ContentDownloader: ImageDownloader {
  let content: Content
  var url: FileURL { return content.url }
  var shouldUpdate: Bool { return false }
  var downloadType: DownloadType { return content.downloadType }
  var loadable: Bool { return content.isAvailable }
}
private struct ChatFileDownloader: ImageDownloader {
  let link: StorableMessageLink
  var url: FileURL { return link.localURL }
  var shouldUpdate: Bool { return false }
  var downloadType: DownloadType { return .chatFile(link: link) }
  var loadable: Bool { return link.body.isUploaded || link.body.isDownloaded }
}

let imageQueue: OperationQueue = {
  let queue = OperationQueue()
  queue.maxConcurrentOperationCount = 4
  return queue
}()
func imageThread(_ block: @escaping ()->()) {
  imageQueue.addOperation(block)
}

//class DownloadOperation: Operation {
//  
//  var file: Download
//  var download: DownloadType
//  init(file: Download, download: DownloadType) {
//    self.file = file
//    self.download = download
//    
//    super.init()
//    
//    switch download {
//    case .avatar:
//      queuePriority = .veryHigh
//    case .photoPreview:
//      queuePriority = .normal
//    case .photo:
//      queuePriority = file.forceListen ? .low : .high
//    case .videoPreview:
//      queuePriority = .normal
//    case .video:
//      queuePriority = file.forceListen ? .low : .high
//    }
//  }
//  override func main() {
//    netLock()
//    guard file.hasListeners else { return }
//    do {
//      print("downloading")
//      try Server.download(download)
//      print("downloaded")
//    } catch {
//      print("download failed: \(error)")
//      let operation = DownloadOperation(file: file, download: download)
//      wait(5) {
//        imageQueue.addOperation(operation)
//      }
//    }
//    netUnlock()
//  }
//}

extension UIView {
  func follow(progress: ProgressProtocol, page: Page) {
    downloadManager.subscribe(progress, view: self, url: nil, page: page)
  }
  
//  func download(_ download: DownloadType, page: Page, editor: UIImageEditor?) -> DownloadRequest? {
//    guard download.isUploaded else { return nil }
//    let frame = self.frame
//    let url = download.url
//    let path = url.path
//    if url.exists {
//      imageThread {
//        thread.lock()
//        let i = UIImage(contentsOfFile: path)
//        thread.unlock()
//        if var image = i {
//          editor?.edit(image: &image, size: frame.size)
//          mainThread {
//            editor?.edit(view: self, page: page)
//            if let imageView = self as? UIImageView {
//              imageView.image = image
//            } else if let button = self as? UIButton {
//              button.setImage(image, for: .normal)
//            }
//          }
//        } else {
//          thread.lock {
//            url.delete()
//          }
//        }
//      }
//    } else {
//      return server.download(type: download)
//      .subscribe(view: self, page: page, editor: editor)
//    }
//    return nil
//  }
  
  @discardableResult
  func user(_ page: Page?, user: User) -> DownloadRequest? {
    guard let page = page else { return nil }
    let preset = EditorPreset.circle
    let editor = preset.editor(for: self)
    let downloader = UserAvatarDownloader(user: user)
    return downloader.download(view: self, page: page, editor: editor, subscribe: true)?
    .success {
      user.isAvatarDownloaded = true
      user.downloadedAvatarVersion = user.avatarVersion
    }
  }
  
  @discardableResult
  func event(_ page: Page?, event: Event, preset: EditorPreset) -> DownloadRequest? {
    guard let page = page else { return nil }
    let editor = preset.editor(for: self)
    let downloader = EventPreviewDownloader(event: event)
    return downloader.download(view: self, page: page, editor: editor, subscribe: true)
  }
  
  @discardableResult
  func preview(_ page: Page?, content: Content, preset: EditorPreset) -> DownloadRequest? {
    guard let page = page else { return nil }
    let editor = preset.editor(for: self)
    if let editor = editor {
      editor.animateLoader = false
      if let upload = content.currentUpload {
        editor.customProgress = upload.progress
      } else {
        editor.showsLoader = false
      }
    }
    let downloader = ContentPreviewDownloader(content: content)
    return downloader.download(view: self, page: page, editor: editor, subscribe: true)
  }
  
  @discardableResult
  func photo(_ page: Page, content: PhotoContent, subscribe: Bool) -> DownloadRequest? {
    let downloader = ContentDownloader(content: content)
    return downloader.download(view: self, page: page, editor: nil, subscribe: subscribe)
  }
  
  @discardableResult
  func chatPhoto(_ page: Page?, link: StorableMessageLink, subscribe: Bool) -> DownloadRequest? {
    guard let page = page else { return nil }
    let downloader = ChatFileDownloader(link: link)
    return downloader.download(view: self, page: page, editor: nil, subscribe: subscribe)
  }
}
