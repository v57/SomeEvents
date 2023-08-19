//
//  subscriber.swift
//  faggot
//
//  Created by Димасик on 1/9/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

class ServerNotifictaions {
  let reports = ReportNotifications()
}

class ReportNotifications {
  var user: ((Int64)->())?
  var event: ((Int64)->())?
  var content: ((ID2)->())?
  var comment: ((MessageLink)->())?
}

let subscriber = Subscriber()
class Subscriber {
  private class Sub {
    var count = 1
    var status = SubStatus.waiting
  }
  private enum SubStatus {
    case waiting, sending, sent
  }
  
  private let locker = NSLock()
  var subs = [Subscription: Int]()
  var isEmpty: Bool { return subs.isEmpty }
  func contains(_ sub: Subscription) -> Bool {
    return subs[sub] != nil
  }
  func merge(from: Subscription, to: Subscription) {
    guard subs[from] != nil else { return }
    subs[to] = subs[from]
    update()
  }
  func open(_ sub: Subscription) {
    if let count = subs[sub] {
      subs[sub] = count + 1
    } else {
      subs[sub] = 1
      if sub.isValid {
        update()
      }
    }
  }
  func close(_ sub: Subscription) {
    guard let count = subs[sub] else { return }
    if count > 1 {
      subs[sub] = count - 1
    } else {
      subs[sub] = nil
      if sub.isValid {
        #if debug
          if settings.debug.subscriptions {
            sub.description.notification(title: "Unsubscribing", emoji: "🖥")
          }
        #endif
        update()
      }
    }
  }
  func closeAll(_ sub: Subscription) {
    guard subs[sub] != nil else { return }
    subs[sub] = nil
    if sub.isValid {
      update()
    }
  }
  
  func update() {
    var subs = Set<Subscription>()
    locker.lock()
    for sub in self.subs.keys where sub.isValid {
      subs.insert(sub)
    }
    locker.unlock()
    print("subscribing to \(subs.count) pages")
    guard subs.count <= 0xff else { return }
    server.request()
      .rename("sub()")
      .override()
      .autorepeat()
      .sub()
  }
  
  func lock() {
    locker.lock()
  }
  func unlock() {
    locker.unlock()
  }
}
