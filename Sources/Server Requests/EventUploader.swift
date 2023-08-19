//
//  MyEventManager.swift
//  faggot
//
//  Created by Димасик on 21/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

let eventUploadManager = EventUploadManager()

class EventUploadManager: Manager, CustomPath {
  let version = 2
  let fileName = "event-uploader.db"
  func start() {}
  func pause() {}
  func resume(){}
  func close() {}
  func login() {}
  private(set) var currentEvent: Event!
  private(set) var events = [Event]()
  private(set) var running = false
  func save(data: DataWriter) throws {
    data.append(events.count)
    for event in events {
      data.append(event.id)
    }
  }
  func load(data: DataReader) throws {
    if version < 2 {
      while true {
        do {
          let id: ID = try data.next()
          if let event = eventManager.get(id) {
            events.append(event)
          }
        } catch {
          return
        }
      }
    } else {
      let count = try data.intCount()
      for _ in 0..<count {
        let id: ID = try data.next()
        if let event = eventManager.get(id) {
          events.append(event)
        }
      }
    }
  }
  
  func upload(_ event: Event) {
    events.insert(event)
    server.request()
    .autorepeat()
    .create(event: event)
  }
}



