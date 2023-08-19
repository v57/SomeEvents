//
//  EventNotifications.swift
//  Events
//
//  Created by Димасик on 1/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation
import SomeBridge

extension Notification {
  static func eventMain(_ body: (EventMainNotifications)->()) {
    sendNotification(EventMainNotifications.self, body)
  }
  static func eventPublic(_ body: (EventPublicNotifications)->()) {
    sendNotification(EventPublicNotifications.self, body)
  }
}

protocol EventMainNotifications {
  func created(event: Event)
  func created(content: Content, in event: Event)
  func uploaded(preview: Content, in event: Event)
  func uploaded(content: Content, in event: Event)
  
  func updated(id event: Event, oldValue: ID)
  func updated(name event: Event)
  func updated(startTime event: Event)
  func updated(endTime event: Event)
  func updated(coordinates event: Event)
  func updated(preview event: Event)
  
  func updated(contentAvailable event: Event)
}

protocol EventPublicNotifications {
  func updated(owner event: Event, oldValue: ID)
  func updated(status event: Event, oldValue: EventStatus)
  func updated(privacy event: Event)
  func updated(options event: Event)
  func updated(createdTime event: Event)
  func updated(online event: Event)
  func updated(onMap event: Event)
  func updated(removed event: Event)
  func updated(banned event: Event)
  func updated(protected event: Event)
  
  func updated(content event: Event)
  func added(content: Content, to event: Event)
  func removed(content: Content, from event: Event)
  
  func invited(user: ID, to event: Event)
  func uninvited(user: ID, from event: Event)
  
  func updated(views event: Event)
  func updated(comments event: Event)
  func updated(current event: Event)
  
  func updated(banList event: Event)
}



