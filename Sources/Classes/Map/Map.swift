//
//  Map.swift
//  Events
//
//  Created by Димасик on 3/27/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation

let mapManager = MapManager()
class MapManager {
  func open() {
    let subscription = Subscription.Map()
    subscription.subscribe()
  }
  func close() {
    let subscription = Subscription.Map()
    subscription.unsubscribe()
  }
  func set(events: [Event]) {
    Notification.map { $0.map(set: events) }
  }
  func insert(event: Event) {
    Notification.map { $0.map(insert: event) }
  }
  func remove(event: Int64) {
    Notification.map { $0.map(remove: event) }
  }
}

extension Notification {
  static func map(_ body: (MapNotifications)->()) {
    sendNotification(MapNotifications.self, body)
  }
}

protocol MapNotifications {
  func map(set events: [Event])
  func map(insert event: Event)
  func map(remove event: Int64)
}
