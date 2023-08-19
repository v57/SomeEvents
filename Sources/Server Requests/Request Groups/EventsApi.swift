//
//  events.swift
//  faggot
//
//  Created by Димасик on 15/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

/*
 extension StreamOperations {
 func sample(completion: @escaping ([Int64])->()) -> StreamOperations {
 
 return self
 }
 }
 */

extension Request {
  @discardableResult
  func checkResponse() -> Self {
    read { data in
      try data.response()
    }
    return self
  }
  @discardableResult
  func create(event: Event) -> StreamOperations {
    description = "creating event \(event.id)"
    rename("create(event:)")
    request { data in
      data.append(cmd.newEvent)
      data.append(event.name)
      data.append(event.startTime)
      data.append(event.lat)
      data.append(event.lon)
      data.append(event.privacy)
    }
    read { [unowned self] data in
      try data.response()
      let id: ID = try data.next()
      self.description = "creating event \(event.id) -> \(id)"
      eventManager.uploaded(event.id, id)
    }
    return self
  }
  
  @discardableResult
  func move(event: Event, lat: Float, lon: Float) -> StreamOperations {
    description = "\(event.requestDescription) moving to \(lat),\(lon)"
    rename("move(event:)")
    request { data in
      data.append(cmd.moveEvent)
      data.append(event.id)
      data.append(lat)
      data.append(lon)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func changeTime(event: Event, start: Time, end: Time) -> StreamOperations {
    description = "\(event.requestDescription) changing time \(start)-\(end)"
    rename("changeTime(event:)")
    request { data in
      data.append(cmd.eventTime)
      data.append(event.id)
      data.append(start)
      data.append(end)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func remove(content: Content, from event: Event) -> StreamOperations {
    description = "\(event.requestDescription) removing \(content.requestDescription)"
    rename("remove(content:)")
    request { data in
      data.append(cmd.removeContent)
      data.append(event.id)
      data.append(content.id)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func leave(event: Event) -> StreamOperations {
    description = "\(event.requestDescription) leaving"
    rename("leave()")
    request { data in
      data.append(cmd.leaveEvent)
      data.append(event.id)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func invite(event: Event, users: Set<Int64>) -> StreamOperations {
    description = "\(event.requestDescription) inviting \(users.count) users"
    rename("invite()")
    request { data in
      data.append(cmd.invite)
      data.append(event.id)
      data.append(users)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func uninvite(event: Event, users: Set<Int64>) -> StreamOperations {
    description = "\(event.requestDescription) inviting \(users.count) users"
    rename("uninvite()")
    request { data in
      data.append(cmd.uninvite)
      data.append(event.id)
      data.append(users)
    }
    checkResponse()
    return self
  }
  
//  @discardableResult
//  func invite(_ event: Int64, user: Int64) -> StreamOperations {
//    rename("invite()")
//    success {
//      print("inviting \(user) to \(event)")
//    }
//    request { data in
//      data.append(cmd.invite)
//      data.append(event)
//      data.append(user)
//    }
//    checkResponse()
//    return self
//  }
  
  @discardableResult
  func status(_ event: Int64, status: EventStatus) -> StreamOperations {
    rename("status()")
    request { data in
      data.append(cmd.eventStatus)
      data.append(event)
      data.append(status)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func privacy(_ event: Int64, privacy: EventPrivacy) -> StreamOperations {
    rename("privacy()")
    request { data in
      data.append(cmd.eventPrivacy)
      data.append(event)
      data.append(privacy)
    }
    checkResponse()
    return self
  }
  
  @discardableResult
  func rename(event: Event, to name: String) -> StreamOperations {
    rename("rename()")
    request { data in
      data.append(cmd.renameEvent)
      data.append(event.id)
      data.append(name)
    }
    checkResponse()
    return self
  }
}
