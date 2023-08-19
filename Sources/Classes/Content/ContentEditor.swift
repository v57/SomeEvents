//
//  content-editor.swift
//  Some Events
//
//  Created by Димасик on 7/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

//class ContentEditor {
//  var _original = false
//  var _lowquality = false
//  var _preview = false
//  private let locker = NSLock()
//  private var _lowqualityBlocks = [()->()]()
//  private var _previewBlocks = [()->()]()
//  
//  func onPreview(block: @escaping ()->()) {
//    thread.lock()
//    if _preview {
//      thread.unlock()
//      block()
//    } else {
//      _previewBlocks.append(block)
//      thread.unlock()
//    }
//  }
//  
//  func onLoad(block: @escaping ()->()) {
//    locker.lock()
//    if _lowquality {
//      locker.unlock()
//      block()
//    } else {
//      _lowqualityBlocks.append(block)
//      locker.unlock()
//    }
//  }
//  
//  func edit(content: PhotoContent, photo: UIImage) {
//    save(preview: photo, content: content)
//    save(lowQuality: photo, content: content)
//    save(original: photo, content: content)
//  }
//  
//  func checkURL(started: FileURL, ended: FileURL) {
//    guard started != ended else { return }
//    started.move(to: ended)
//  }
//  
//  func save(preview photo: UIImage, content: PhotoContent) {
////    let image = photo.thumbnail(Size(180,180),false)
//    let image = photo.limit(minSize: 180,false)
//    let url = content.previewURL
//    url.write(image: image, quality: 0.6)
////    url.cache(image: image)
////    let data = image.jpg(0.6)
////    url.write(data: data)
//    checkURL(started: url, ended: content.previewURL)
//    thread.lock()
//    _preview = true
//    thread.unlock()
//    print("content preview: writed to \(url)")
//    mainThread {
//      self._previewBlocks.forEach({$0()})
//      self._previewBlocks.removeAll()
//    }
//    guard content.eventid >= 0 else { return }
//    contentManager.append(content)
//  }
//  
//  func save(lowQuality photo: UIImage, content: PhotoContent) {
//    let data = photo.progressive(quality: settings.compressQuality)
//    content.photoData.size = Int32(data.count)
//    content.photoData.width = Int16(photo.width * photo.scale)
//    content.photoData.height = Int16(photo.height * photo.scale)
//    let url = content.url
//    url.write(data: data)
//    checkURL(started: url, ended: content.url)
//    locker.lock()
//    _lowquality = true
//    locker.unlock()
//    mainThread {
//      self._lowqualityBlocks.forEach({$0()})
//    }
//  }
//  
//  func save(original photo: UIImage, content: PhotoContent) {
//    let data = photo.jpg()
//    let url = content.originalURL
//    url.write(data: data)
//    checkURL(started: url, ended: content.originalURL)
//    _original = true
//  }
//  
//  func done(content: Content) {
//    content.editor = nil
//  }
//}
