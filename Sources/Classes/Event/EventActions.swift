//
//  EventActions.swift
//  Events
//
//  Created by Димасик on 1/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge
import UIKit

extension Event {

  func open() {
    let subscription = Subscription.Event(id: id)
    subscription.subscribe()
  }
  
  func close() {
    let subscription = Subscription.Event(id: id)
    subscription.unsubscribe()
  }
  
  @discardableResult
  func invite(users: Set<ID>) -> StreamOperations {
    return server.request()
      .invite(event: self, users: users)
      .success {
        self.invited += users
    }
  }
  
  @discardableResult
  func uninvite(users: Set<ID>) -> StreamOperations {
    return server.request()
      .uninvite(event: self, users: users)
      .success  {
        self.invited -= users
    }
  }
  
  @discardableResult
  func leave() -> StreamOperations {
    return server.request()
      .leave(event: self)
      .success {
        self.remove(invited: .me)
    }
  }
  
  @discardableResult
  func start() -> StreamOperations {
    return server.request()
      .status(id, status: .started)
  }
  
  @discardableResult
  func pause() -> StreamOperations {
    return server.request()
      .status(id, status: .paused)
  }
  
  @discardableResult
  func stop() -> StreamOperations {
    return server.request()
      .status(id, status: .ended)
  }
  
  @discardableResult
  func remove(content: Content) -> StreamOperations {
    guard content.id >= 0 else { return server.request() }
    return server.request()
      .remove(content: content, from: self)
  }
  
  @discardableResult
  func privacy(_ privacy: EventPrivacy) -> StreamOperations {
    return server.request()
      .privacy(id, privacy: privacy)
  }
  
  @discardableResult
  func move(lat: Float, lon: Float) -> StreamOperations {
    return server.request()
      .move(event: self, lat: lat, lon: lon)
      .success {
        self.set(lat: lat, lon: lon)
    }
  }
  
  @discardableResult
  func changeTime(start: Time, end: Time) -> StreamOperations {
    var end = end
    if end - start > .week + .day {
      end = start+(self.endTime-self.startTime)
    }
    end = min(end,.now)
    
    return server.request()
      .changeTime(event: self, start: start, end: end)
      .onFail { error in
        guard let error = error else { return }
        do {
          throw error
        } catch Response.eventWrongTime {
          "Invalid date".notification()
        } catch Response.eventPermissions {
          "Invalid date".notification()
        } catch {
          
        }
      }
      .success {
        self.set(startTime: start)
        self.set(endTime: end)
    }
  }
  
  func addPhoto(_ photo: UIImage) {
    let content = PhotoContent(eventid: id)
    content.photoData.width = Int16(photo.width * photo.scale)
    content.photoData.height = Int16(photo.height * photo.scale)
    content.previewURL.prepare()
    content.url.prepare()
    content.previewURL.write(image: photo, .jpg(settings.previewQuality), .limit(size: 180))
    content.url.write(image: photo, .progressive(settings.compressQuality))
    contentManager.append(content)
    
//    let editor = ContentEditor()
//    content.editor = editor
    set(insertContent: content)
    
//    imageThread {
//      editor.edit(content: photoContent, photo: photo)
//    }
  }
  func addVideo(_ url: FileURL) {
    let content = VideoContent(eventid: id)
    content.previewURL.prepare()
    content.url.prepare()
    
    url.move(to: content.url)
    let video = Video(url: content.url)
    content.videoData.duration = Int32(video.asset.duration.seconds)
    content.videoData.size = UInt64(content.url.fileSize)
    if let resolution = video.asset.resolution {
      content.videoData.width = Int16(resolution.width)
      content.videoData.height = Int16(resolution.height)
    }
    video.preview(.limit(size: 180)) { image in
      guard let image = image else { return }
      content.previewURL.write(image: image, .jpg(settings.previewQuality))
//        url.cache(image: image)
//        let data = image.jpg(settings.compressQuality)
//        url.write(data: data)
      
      contentManager.append(content)
      self.set(insertContent: content)
      for page in main.pages {
        guard let eventPage = page as? EventDelegate else { continue }
        eventPage.eventVideoAdded(content)
      }
    }
  }
}
