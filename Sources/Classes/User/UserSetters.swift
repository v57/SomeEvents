//
//  UserSetters.swift
//  Events
//
//  Created by Димасик on 1/12/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions
import SomeBridge

extension User {
  func set(name: String) {
    var name = name
    if name.isEmpty {
      name = "unnamed"
    }
    guard self.name != name else { return }
    self.name = name
    sendNotification(UserMainNotifications.self) {
      $0.updated(user: self, name: name)
    }
  }
  func set(publicOptions options: PublicUserOptions.Set) {
    guard publicOptions != options else { return }
    let updated = publicOptions.symmetricDifference(options)
    self.publicOptions = options
    if updated.contains(.avatar) {
      sendNotification(UserMainNotifications.self) {
        $0.updated(user: self, avatar: hasAvatar)
      }
    }
    if updated.contains(.banned) {
      sendNotification(UserMainNotifications.self) {
        $0.updated(user: self, banned: isBanned)
      }
    }
    if updated.contains(.deleted) {
      sendNotification(UserMainNotifications.self) {
        $0.updated(user: self, deleted: isDeleted)
      }
    }
    if updated.contains(.online) {
      sendNotification(UserMainNotifications.self) {
        $0.updated(user: self, online: isOnline)
      }
    }
  }
  func set(avatarVersion: UInt8) {
    guard self.avatarVersion != avatarVersion else { return }
    self.avatarVersion = avatarVersion
    guard hasAvatar else { return }
    if let download = serverManager.downloads[avatarTemp], download.progress.isCompleted {
      serverManager.downloads[avatarTemp] = nil
    }
    sendNotification(UserMainNotifications.self) {
      $0.updated(user: self, avatar: true)
    }
  }
  func insert(event: Event) {
    guard !self.events.contains(event.id) else { return }
    self.events.insert(event.id)
    sendNotification(UserProfileNotifications.self) {
      $0.inserted(event: event, for: Set([id]))
    }
  }
  func remove(event: Event) {
    guard self.events.contains(event.id) else { return }
    self.events.remove(event.id)
    sendNotification(UserProfileNotifications.self) {
      $0.removed(event: event, from: Set([id]))
    }
  }
  func set(events: Set<ID>) {
    guard self.events != events else { return }
    let array = events.map({$0.event!})
    for event in array {
      event.invited.insert(self.id)
    }
    self.events = events
    sendNotification(UserProfileNotifications.self) {
      $0.updated(events: Set(array), of: self)
    }
  }
  func set(mainVersion: UInt16) {
    self.mainVersion = mainVersion
  }
  func set(publicVersion: UInt16) {
    self.publicProfileVersion = publicVersion
  }
  func set(subscribers: Int64) {
    self.subscribers = subscribers
  }
  func set(subscriptions: Int64) {
    self.subscriptions = subscriptions
  }
  func set(isSubscriber: Bool) {
    self.isSubscriber = isSubscriber
  }
}
