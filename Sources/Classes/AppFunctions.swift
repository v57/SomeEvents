//
//  app-functions.swift
//  Some Events
//
//  Created by Димасик on 11/27/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension Hashable {
  func createSet() -> Set<Self> {
    let array = [self]
    return Set(array)
  }
}

extension UIColor {
  static var backgroundDark = UIColor(white: 0, alpha: 0.2)
}

enum Theme {
  case light, dark
}

enum ServerError: Error {
  case wrong, empty, noRights
}

enum LoginError: Error {
  case toolong
}

enum SignupError: Error {
  case longLogin, longPassword
}

extension DataReader {
  func response() throws {
    let response: Response = try next()
    guard response == .ok else { throw response }
  }
  func debug() {
    let slice = data[position..<min(count-1,position+40)]
    print("data debug {")
    print("  " + slice.hexString)
    print("}")
  }
//  func eventMains() throws -> [Event] {
//    let count: Int = try next()
//    var events = [Event]()
//    for _ in 0..<count {
//      let event = try eventMain()
//      events.append(event)
//    }
//    return events
//  }
//  func eventMain() throws -> Event {
//    let id: Int64 = try next()
//    let name: String = try next()
//    let start: UInt32 = try next()
//    let end: UInt32 = try next()
//    let status: EventStatus = try next()
//    let p = try contentPreview(id)
//    
//    let event = eventManager.reserve(id)
//    event.name = name
//    event.preview = p
//    event.startTime = start
//    event.endTime = end
//    event.status = status
//    return event
//  }
}

private var locked = 0
func netLock() {
  mainThread {
    if locked == 0 {
      application.isNetworkActivityIndicatorVisible = true
    }
    locked += 1
  }
}
func netUnlock() {
  mainThread {
    locked -= 1
    if locked == 0 {
      application.isNetworkActivityIndicatorVisible = false
    }
  }
}
func fileThread(block: @escaping ()->()) {
  newThread {
    netLock()
    block()
    netUnlock()
  }
}
