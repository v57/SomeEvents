//
//  MEvents.swift
//  faggot
//
//  Created by Димасик on 20/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeData

let eventManager = EventManager()
class EventManager: Manager, CustomPath {
  let fileName = "events.db"
  
  private var eid: Int64 = -1
//  private var _events = [Int64: Event]()
//  private var events: [Int64: Event] { return _events }
  let thread = NSLock()
  private var _events = [Int64: Event]()
  private var _offlineEvents = [Int64: Event]()
  private var events: [Int64: Event] { return _events }
  private var offlineEvents: [Int64: Event] { return _offlineEvents }
  func insert(event: Event) {
//    print("inserting event: \(event.id)")
//    if _events[event.id] != nil {
//      print("setop")
//    }
    _events[event.id] = event
  }
  func remove(event: Event) {
    _events[event.id] = nil
  }
  func insert(offline event: Event) {
    _offlineEvents[event.id] = event
  }
  func remove(offline event: Event) {
    _offlineEvents[event.id] = nil
  }
  
  func start() {}
  func pause() {}
  func resume(){}
  func close() {}
  func login() {}
  
  func printInfo() -> [String] {
    var array = [String]()
    array.append("Online: \(events.count)")
    array.append("Offline: \(offlineEvents.count)")
    array.append("My: \(User.me.events.count)")
    return array
  }
  
  /// Events
  func get(_ ids: Set<Int64>) -> [Event] {
    var array = [Event]()
    for id in ids {
      if let event = get(id) {
        array.append(event)
      }
    }
    return array
  }
  func contains(_ id: Int64) -> Bool {
    return offlineEvents[id] != nil || events[id] != nil
  }
  func get(_ id: Int64) -> Event! {
    if let event = offlineEvents[id] {
      return event
    } else if let event = events[id] {
      return event
    } else {
      return nil
    }
  }
  func offline(_ id: Int64) -> Event! {
    return offlineEvents[id]
  }
  func online(_ id: Int64) -> Event! {
    return events[id]
  }
//  func get(_ id: Int64, page: Page?, handler: @escaping (Event)->()) {
//    let e: Event
//    if let event = events[id] {
//      e = event
//      if event.isFull() {
//        handler(event)
//        return
//      }
//    } else {
//      e = reserve(id)
//    }
//    serverThread {
//      serverRequest(page) {
//        try Server.get(event: e)
//        handler(e)
//      }
//    }
//  }
  func reserve(_ id: Int64) -> Event {
    thread.lock()
    defer { thread.unlock() }
    if let event = get(id) {
      return event
    } else {
      let event = Event(id: id)
      print("insert event from reserve()")
      insert(event: event)
      return event
    }
  }
//  func setMain(_ event: Event, user: User) {
//    if !user.events.contains(event.id) {
//      user.events.append(event.id)
//    }
//    if let e = events[event.id] {
//      e.name = event.name
//      e.preview = event.preview
//      e.startTime = event.startTime
//      e.endTime = event.endTime
//    } else {
//      events[event.id] = event
//      event.owner = user.id
//    }
//  }
  
  /// My events
  // MARK:- My
  
//  func setMyMain(_ event: Event) {
//    myEvents.insert(event.id)
//    setMain(event, user: .me)
//  }
  
  func recover(_ id: Int64) -> Event? {
    return nil
  }
  
  func uploaded(_ from: Int64, _ to: Int64) {
    thread.lock()
    defer { thread.unlock() }
    guard let event = offlineEvents[from] else { return }
    let old = Subscription.Event(id: from)
    let new = Subscription.Event(id: to)
    subscriber.merge(from: old, to: new)
    User.me.events.remove(from)
    User.me.events.insert(to)
    remove(offline: event)
    event.set(id: to)
    print("insert event from uploaded()")
    insert(event: event)
  }
  
  func my() -> [Event] {
    var array = [Event]()
    for id in User.me.events {
      guard let event = get(id) else { continue }
      array.append(event)
    }
    let sorted = array.sorted { $0.startTime < $1.startTime }
    return sorted
  }
  
  func create(_ name: String, lat: Float, lon: Float, time: Time) -> Event {
    eid -= 1
    while User.me.events.contains(eid) { // wtf
      eid -= 1
    }
    
    let me = User.me.id
    let event = Event(id: eid)
    event.invited.insert(me)
    event.owner = me
    event.localOptions[.isCreated] = false
    event.startTime = time
    if time > .now {
      event.status = .paused
    }
    
    User.me.events.insert(eid)
    
    event.name = name
    
    event.lat = lat
    event.lon = lon
    
    insert(offline: event)
    
    account?.save()
    try? self.save(ceo: ceo)
    
    sendNotification(UserProfileNotifications.self) { $0.created(event: event, by: .me) }
    
    eventUploadManager.upload(event)
    
    return event
  }
  
  /////
//  private func append(_ event: Event) {
//    events[event.id] = event
//  }
  
  func load(data: DataReader) throws {
    eid = try data.next()
    var count = try data.intCount()
    for _ in 0..<count {
      let event = try Event(data: data)
      insert(event: event)
    }
    count = try data.intCount()
    for _ in 0..<count {
      let event = try Event(data: data)
      insert(offline: event)
    }
  }
  func save(data: DataWriter) throws {
    data.append(eid)
    data.append(events.count)
    for event in events.values {
      event.save(data: data)
    }
    data.append(offlineEvents.count)
    for event in offlineEvents.values {
      event.save(data: data)
    }
  }
}

extension Event {
  func isPreview() -> Bool {
    return name.count > 0
  }
  func isFull() -> Bool {
    return true
  }
}
