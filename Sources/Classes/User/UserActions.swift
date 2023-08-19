//
//  UserActions.swift
//  Events
//
//  Created by Димасик on 1/12/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

extension User {
  func open() {
    let subscription = Subscription.Profile(id: id)
    subscription.subscribe()
  }
  
  func close() {
    let subscription = Subscription.Profile(id: id)
    subscription.unsubscribe()
  }
  
  @discardableResult
  func friend() -> StreamOperations {
    return server.request()
      .addFriend(id)
      .success {
        switch self.friendStatus {
        case .incoming:
          account.insert(friend: self.id)
        case .notFriend:
          account.insert(outcoming: self.id)
        default: break
        }
    }
  }
  
  @discardableResult
  func unfriend() -> StreamOperations {
    return server.request()
      .removeFriend(id)
      .success {
        switch self.friendStatus {
        case .outcoming:
          account.remove(outcoming: self.id)
        case .friend:
          account.remove(friend: self.id)
        default: break
        }
    }
  }
}
