//
//  paths.swift
//  faggot
//
//  Created by Димасик on 5/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Foundation
import SomeFunctions
import SomeBridge

extension URL {
  static func server(_ path: String) -> URL {
    return URL(string: "http://\(address.ip):\(httpPort)/\(path)")!
  }
}

private extension String {
  static var eventsPath: String { return "events/" }
  static var avatarsPath: String { return "avatars/" }
  static var communityChatPath: String { return "community/" }
  
  var originalsPath: String { return self + "originals/" }
  var previewsPath: String { return self + "previews/" }
  var downloadedPath: String { return self + "downloaded/" }
  var commentsPath: String { return self + "comments/" }
  
  func contentPath(id: ID, type: ContentType) -> String {
    switch type {
    case .photo:
      return self + "\(id).jpg"
    case .video:
      return self + "\(id).mp4"
    }
  }
}

extension ID {
  var commentsURL: FileURL { return eventPath.commentsPath.cacheURL }
  var commentsTempURL: FileURL { return eventPath.commentsPath.tempURL }
}

private extension ID {
  var avatarPath: String { return .avatarsPath + "\(self).jpg" }
  var eventPath: String { return .eventsPath + "\(self)/" }
  
  var eventURL: FileURL { return eventPath.cacheURL }
  var eventTemp: FileURL { return eventPath.tempURL }
  
  var originalsURL: FileURL { return eventPath.originalsPath.cacheURL }
  var previewsURL: FileURL { return eventPath.previewsPath.cacheURL }
  var downloadedURL: FileURL { return eventPath.downloadedPath.cacheURL }
  
  var originalsTemp: FileURL { return eventPath.originalsPath.tempURL }
  var previewsTemp: FileURL { return eventPath.previewsPath.tempURL }
  var downloadedTemp: FileURL { return eventPath.downloadedPath.tempURL }
  
  func contentPath(type: ContentType, eventid: ID) -> String {
    return eventid.eventPath.downloadedPath.contentPath(id: self, type: type)
  }
  func contentPreviewPath(type: ContentType, eventid: ID) -> String {
    return eventid.eventPath.previewsPath.contentPath(id: self, type: .photo)
  }
  func contentOriginalPath(type: ContentType, eventid: ID) -> String {
    return eventid.eventPath.originalsPath.contentPath(id: self, type: type)
  }
}

private extension FileURL {
  static var avatars: FileURL { return String.avatarsPath.cacheURL }
  static var avatarsTemp: FileURL { return String.avatarsPath.tempURL }
  static var events: FileURL { return String.eventsPath.cacheURL }
  static var eventsTemp: FileURL { return String.eventsPath.tempURL }
}

private extension ID {
  var avatarURL: FileURL { return avatarPath.cacheURL }
  var avatarTemp: FileURL { return avatarPath.tempURL }
  
  func contentURL(type: ContentType, eventid: ID) -> FileURL {
    return contentPath(type: type, eventid: eventid).cacheURL
  }
  func contentPreviewURL(type: ContentType, eventid: ID) -> FileURL {
    return contentPreviewPath(type: type, eventid: eventid).cacheURL
  }
  func contentOriginalURL(type: ContentType, eventid: ID) -> FileURL {
    return contentOriginalPath(type: type, eventid: eventid).cacheURL
  }
  
  func contentTemp(type: ContentType, eventid: ID) -> FileURL {
    return contentPath(type: type, eventid: eventid).tempURL
  }
  func contentPreviewTemp(type: ContentType, eventid: ID) -> FileURL {
    return contentPreviewPath(type: type, eventid: eventid).tempURL
  }
  func contentOriginalTemp(type: ContentType, eventid: ID) -> FileURL {
    return contentOriginalPath(type: type, eventid: eventid).tempURL
  }
}

extension ContentPreview {
  var previewURL: FileURL { return id.contentPreviewURL(type: type, eventid: event) }
  var previewTemp: FileURL { return id.contentPreviewTemp(type: type, eventid: event) }
}

extension Content {
  var url: FileURL { return id.contentURL(type: type, eventid: eventid) }
  var previewURL: FileURL { return id.contentPreviewURL(type: type, eventid: eventid) }
  var originalURL: FileURL { return id.contentOriginalURL(type: type, eventid: eventid) }
  var temp: FileURL { return id.contentTemp(type: type, eventid: eventid) }
  var previewTemp: FileURL { return id.contentPreviewTemp(type: type, eventid: eventid) }
  var originalTemp: FileURL { return id.contentOriginalTemp(type: type, eventid: eventid) }
  
  func moveContent(to: ID) {
    var originalURL: FileURL?
    if self is PhotoContent {
      originalURL = to.contentOriginalURL(type: type, eventid: eventid)
    }
    let previewURL = to.contentPreviewURL(type: type, eventid: eventid)
    let url = to.contentURL(type: type, eventid: eventid)
    
    if let originalURL = originalURL {
      self.originalURL.alias(with: originalURL)
    }
    self.previewURL.alias(with: previewURL)
    self.url.alias(with: url)
  }
}

func createDirectories() {
  FileURL.avatars.create()
  FileURL.avatarsTemp.create()
  FileURL.events.create()
  FileURL.eventsTemp.create()
}

func printDirectories() {
  print()
  print("documents:")
  "".documentsURL.printSubpaths()
  print()
  print("cache:")
  "".cacheURL.printSubpaths()
  print()
  print("temp:")
  "".tempURL.printSubpaths()
  print()
}

extension Event {
  func createDirectories() {
    id.eventURL.create()
    id.originalsURL.create()
    id.previewsURL.create()
    id.downloadedURL.create()
    
    id.eventTemp.create()
    id.originalsTemp.create()
    id.previewsTemp.create()
    id.downloadedTemp.create()
  }
  func moveDirectories(to: ID) {
    id.eventURL.move(to: to.eventURL)
    id.eventTemp.move(to: to.eventTemp)
  }
}

extension User {
  var avatarURL: FileURL { return id.avatarURL }
  var avatarTemp: FileURL { return id.avatarTemp }
}
