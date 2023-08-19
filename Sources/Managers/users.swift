//
//  MUsers.swift
//  faggot
//
//  Created by Димасик on 20/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

let usersManager = UsersManager()
class UsersManager: Manager, CustomPath {
  var version: Int = 2
  let fileName = "users.db"
  var serverDatabaseVersion: Int64 = 0
  
  func start() {}
  func pause() {}
  func resume(){}
  func close() {}
  func login() {}
  
  subscript(index: ID) -> User? {
    get {
      return users[index]
    }
    set {
      users[index] = newValue
    }
  }
  
  // returns users if they all in db
  func getAll(users: Set<ID>) -> [User]? {
    var array = [User]()
    for id in users {
      if let user = self.users[id] {
        array.append(user)
      } else {
        return nil
      }
    }
    return array
  }
  
//  func get(_ id: Int64, login: String, page: Page?) throws -> User {
//    let e: User
//    if let user = users[id] {
//      e = user
//      if user.profileLoaded() {
//        return user
//      }
//    } else {
//      e = reserve(id, login: login)
//    }
//    var success = false
//    serverRequest(page) {
//      try Server.userProfile(e)
//      success = true
//    }
//    if success {
//      return e
//    } else {
//      throw ServerError.wrong
//    }
//  }
  
  func append(_ user: User) {
    users[user.id] = user
  }
  func reserve(_ id: ID, login: String) -> User {
    let user = User(id: id)
    user.name = login
    return user
  }
  func update(users: [ID]) {
    
  }
  /////
  
  var eid: ID = 0
  var users = [Int64: User]()
  
  func load(data: DataReader) throws {
    eid = try data.next()
    let users: [User] = try data.next()
    for user in users {
      self.users[user.id] = user
    }
    if version >= 2 {
      serverDatabaseVersion = try data.next()
    }
  }
  
  func save(data: DataWriter) throws {
    data.append(eid)
    data.append(Array(users.values))
    data.append(serverDatabaseVersion)
  }
}

extension ID {
  var isMe: Bool { return self == User.me.id }
  var isFriend: Bool { return account.friends.contains(self) }
}

extension User {
  static var me: User { return account.user }
  var isMe: Bool { return id == User.me.id }
  func previewLoaded() -> Bool {
    return false
  }
  func profileLoaded() -> Bool {
    return false
  }
}
