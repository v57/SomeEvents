//
//  LoginRequest.swift
//  Events
//
//  Created by Димасик on 1/19/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

extension StreamOperations {
  @discardableResult
  func easyLogin() -> Self {
    let request = LoginRequest()
    add(request)
    return self
  }
}

private class LoginRequest: Request {
  override init() {
    super.init(name: "login")
    if let session = session {
      description = "login \(session.id)x\(session.password.hex)"
    } else {
      description = "login"
    }
    ops()
  }
  func ops() {
    skipOn { session == nil }
    skipOn { server.loginned }
    request { [unowned self] data in
      let me = User.me
      data.append(cmd.auth)
      data.append(session!.id)
      data.append(session!.password)
      data.append(me.isMainLoaded)
      data.append(me.mainVersion)
      data.append(me.publicProfileVersion)
      data.append(account.privateProfileVersion)
      self.description = "login \(session!.id)x\(session!.password.hex)"
    }
    read { [unowned self] data in
      let response: Response = try data.next()
      if response == .ok {
        try mainThreadSync {
          try data.processProfile()
        }
        server.loginned = true
      } else if response == .wrongPassword {
        mainThread {
          "Making new account".notification(title: "Wrong password", emoji: "🔑")
        }
        self.signup(name: session!.name)
      } else {
        throw response
      }
    }
  }
}

extension DataReader {
  func processProfile() throws {
    let me: User = .me
    if try bool() {
      try userMain(user: me)
    }
    if try bool() {
      try me.set(publicVersion: next())
      let events = try eventMains()
      me.set(events: events.idsSet)
    }
    if try bool() {
      try account.set(privateOptions: next())
      try account.set(privateProfileVersion: next())
      try account.set(friends: next())
      try account.set(outcoming: next())
      try account.set(incoming: next())
      try account.set(subscribers: next())
      try account.set(subscriptions: next())
      try account.set(favorite: next())
    }
    if account.isModerator {
      account.reportsCount = try next()
      account.uncheckedReportsCount = try next()
    }
    
//    let mainVersion = try request.uint16()
//    data.append(mainVersion != user.mainVersion)
//    if mainVersion != user.mainVersion {
//      user.write(main: data)
//    }
//    let publicVersion = try request.uint16()
//    data.append(user.publicProfileVersion != publicVersion)
//    if user.publicProfileVersion != publicVersion {
//      data.append(user.publicProfileVersion)
//      user.events.eventMain(data: data)
//    }
//    let privateVerison = try request.int()
//    data.append(user.privateProfileVersion != privateVerison)
//    if user.privateProfileVersion != privateVerison {
//      data.append(user.privateOptions)
//      data.append(user.privateProfileVersion)
//      data.append(user.friends)
//      data.append(user.subscribers)
//
//      data.append(user.subscriptions)
//      data.append(user.outcoming)
//      data.append(user.incoming)
//      data.append(user.favorite)
//    }
//    if user.isModerator {
//      data.append(reports.count)
//      data.append(reports.uncheckedCount)
//    }
    
//    let name: String = try next()
//    let avatar: UInt8 = try next()
//    let friends: Set<Int64> = try next()
//    let outcoming: Set<Int64> = try next()
//    let incoming: Set<Int64> = try next()
//    let subscribers: Int = try next()
//    let subscriptions: Set<Int64> = try next()
//    let favoriteEvents: Array<Int64> = try next()
//    let events = try eventMains()
//    
//    let me = User.me
//    
//    account.updated = true
//    mainThread {
//      session!.set(name: name)
//      me.set(name: name)
//      me.set(avatar: avatar)
//      account.set(friends: friends)
//      account.set(outcoming: outcoming)
//      account.set(incoming: incoming)
//      me.set(subscribersCount: subscribers)
//      me.set(subscriptions: subscriptions)
//      me.set(favoriteEvents: favoriteEvents)
//      me.set(events: events.idsSet)
//    }
//    
//    print("name is \(name)")
//    print(avatar > 0 ? "has image" : "has no image")
//    print("subscribers: \(subscribers)")
//    print("subscriptions: \(subscriptions.count)")
//    print("favorite events: \(favoriteEvents)")
//    print("events: \(events.count)")
//    print("friends: \(friends.count)")
//    print("friend requests: \(incoming.count)")
//    print("")
  }
}
