//
//  UserNotifications.swift
//  Events
//
//  Created by Димасик on 1/12/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeBridge

protocol AccountNotifications {
  func added(friends: Set<ID>)
  func removed(friends: Set<ID>)
  func added(incoming: Set<ID>)
  func removed(incoming: Set<ID>)
  func added(outcoming: Set<ID>)
  func removed(outcoming: Set<ID>)
}

protocol SmartAccountNotifications {
  func updated(user: ID, friendStatus: FriendStatus)
}

protocol UserMainNotifications {
  func updated(user: User, name: String)
  func updated(user: User, online: Bool)
  func updated(user: User, deleted: Bool)
  func updated(user: User, banned: Bool)
  func updated(user: User, avatar: Bool)
}

protocol UserProfileNotifications {
  func updated(events: Set<Event>, of user: User)
  func created(event: Event, by user: ID)
  func inserted(event: Event, for users: Set<ID>)
  func removed(event: Event, from users: Set<ID>)
}
