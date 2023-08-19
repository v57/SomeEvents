//
//  EventGetters.swift
//  Events
//
//  Created by Димасик on 1/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation
import SomeFunctions

extension Event {
  /*
   var id = ID()
   var name = String()
   var startTime = Time()
   var endTime = Time()
   var lat = Float()
   var lon = Float()
   var previewVersion = EventPreviewVersion()
   var preview: Content?
   
   //MARK:- public properties
   var owner = ID()
   var _status = EventStatus.started
   var privacy = EventPrivacy.public
   var options = Options<EventOptions,UInt8>()
   var createdTime = Time()
   
   var counter = Counter<ID>()
   var content = [ID: Content]()
   var comments: Comments
   var invited = Set<Int>()
   var commentsCount = Int()
   var views = Int()
   var current = Int()
   
   //MARK:- private properties
   var banlist = Set<ID>()
   
   //MARK:- local properties
   var localOptions = Options<EventLocalOptions,UInt8>()
   */
  
//  case online
//  case onMap
//  case removed
//  case banned
//  case protected
  
//  isCreated
//  isContentAvailable
  
  var isOnline: Bool { return options[.online] }
  var isOnMap: Bool { return options[.onMap] }
  var isRemoved: Bool { return options[.removed] }
  var isBanned: Bool { return options[.banned] }
  var isProtected: Bool { return options[.protected] }
  
  var isCreated: Bool {
    get {
      return localOptions[.isCreated]
    } set {
      guard isCreated != newValue else { return }
      localOptions[.isCreated] = newValue
      Notification.eventMain { $0.created(event: self) }
    }
  }
  var isContentAvailable: Bool {
    get {
      return localOptions[.isContentAvailable]
    } set {
      guard isContentAvailable != newValue else { return }
      localOptions[.isContentAvailable] = newValue
      Notification.eventMain { $0.updated(contentAvailable: self) }
    }
  }
  
  var isStarted: Bool { return startTime < .now }
  
  var statusString: String? {
    if isBanned {
      return "banned"
    } else if isRemoved {
      return "removed"
    } else {
      switch status {
      case .ended:
        return nil
      case .paused:
        if startTime > .now {
          return EPTopView.format(time: startTime)
        } else {
          return "paused"
        }
      case .started:
        return "live"
      }
    }
  }
  var isPrivateForMe: Bool {
    return privacy == .private && !isMy()
  }
  var photos: [Content] {
    return content.filter { $0.type == .photo }
  }
  var videos: [Content] {
    return content.filter { $0.type == .video }
  }
  
  var _canLoadContent: Bool {
    if isBanned || isRemoved || isPrivateForMe {
      return false
    } else {
      return true
    }
  }
}
