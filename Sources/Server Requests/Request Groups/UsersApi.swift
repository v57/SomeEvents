//
//  users.swift
//  faggot
//
//  Created by Димасик on 15/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

extension Sequence where Iterator.Element == Int64 {
  @discardableResult
  func loadUsers(completion: @escaping ([User])->()) -> StreamOperations? {
    var missingUsers = Set<Int64>()
    var users = [User]()
    for id in self {
      if let user = id.user, user.isMainLoaded {
        users.append(user)
      } else {
        missingUsers.insert(id)
      }
    }
    
    if missingUsers.count > 0 {
      print("loading \(missingUsers.userNames)")
      return server.request()
        .rename("loadUsers()")
        .userMains(ids: missingUsers, filter: false) { loaded in
          for user in loaded {
            users.append(user)
          }
          mainThread {
            completion(users)
          }
      }
    } else {
      completion(users)
      return nil
    }
  }
}

extension Int64 {
  @discardableResult
  func loadUser(completion: @escaping (User)->()) -> StreamOperations? {
    if let user = self.user {
      completion(user)
      return nil
    } else {
      return server.request()
        .rename("loadUser()")
        .userMains(ids: [self], filter: false) { users in
          if let user = users.first {
            mainThread {
              completion(user)
            }
          }
      }
    }
  }
}

extension Request {
  
  @discardableResult
  func userMains(ids: [Int64], filter: Bool, completion: @escaping ([User])->()) -> StreamOperations {
    var ids = ids
    if filter {
      ids = ids.filter { $0.user == nil }
    }
    guard !ids.isEmpty else {
      completion([])
      return self }
    request { data in
      data.append(cmd.userMains)
      data.append(ids)
    }
    userMainsRead(completion: completion)
    return self
  }
  
  @discardableResult
  func userMains(ids: Set<Int64>, filter: Bool, completion: @escaping ([User])->()) -> StreamOperations {
    if filter {
      let ids = ids.filter { $0.user == nil }
      guard !ids.isEmpty else {
        completion([])
        return self }
      request { data in
        data.append(cmd.userMains)
        data.append(ids)
      }
    } else {
      guard !ids.isEmpty else {
        completion([])
        return self }
      request { data in
        data.append(cmd.userMains)
        data.append(ids)
      }
    }
    userMainsRead(completion: completion)
    return self
  }
  
  @discardableResult
  private func userMainsRead(completion: @escaping ([User])->()) -> StreamOperations {
    read { data in
      let message: Response = try data.next()
      if message == .ok {
        let users = try data.userMains()
        completion(users)
      } else {
        completion([])
      }
    }
    return self
  }
  
  @discardableResult
  func addFriend(_ id: Int64) -> StreamOperations {
    rename("friend()")
    success {
      print(" * adding friend \(id)")
    }
    request { data in
      data.append(cmd.addFriend)
      data.append(id)
    }
    checkResponse()
    success {
      print("added")
    }
    
    return self
  }
  
  @discardableResult
  func removeFriend(_ id: Int64) -> StreamOperations {
    rename("unfriend()")
    success {
      print(" * removing friend \(id)")
    }
    request { data in
      data.append(cmd.removeFriend)
      data.append(id)
    }
    checkResponse()
    success {
      print("removed")
    }
    return self
  }
  
  @discardableResult
  func subscribe(_ id: Int64) -> StreamOperations {
    rename("subscribe()")
    success {
      print(" * subscribing to \(id)")
    }
    request { data in
      data.append(cmd.subscribe)
      data.append(id)
    }
    checkResponse()
    success {
      print("subscribed")
    }
    return self
  }
  
  @discardableResult
  func unsubscribe(_ id: Int64) -> StreamOperations {
    rename("unsubscribe()")
    success {
      print(" * unsubscribing")
    }
    request { data in
      data.append(cmd.unsubscribe)
      data.append(id)
    }
    checkResponse()
    success {
      print("unsubscribed")
    }
    return self
  }
  
  @discardableResult
  func search(users name: String, completion: @escaping ([ID])->()) -> StreamOperations {
    description = "search (\(name))"
    rename("search()")
    request { data in
      data.append(cmd.searchUsers)
      data.append(name)
    }
    read { [unowned self] data in
      let ids = try data.userVersions()
      completion(ids)
      self.description = "search (found \(ids.count) users)"
    }
    return self
  }
  
  @discardableResult
  func add(token: Data) -> StreamOperations {
    description = "sending push token"
    rename("add(token:)")
    request { data in
      data.append(cmd.addPushToken)
      data.append(token.hexString2)
    }
    return self
  }
  
  @discardableResult
  func remove(token: Data) -> StreamOperations {
    description = "removing push token"
    rename("remove(token:)")
    request { data in
      data.append(cmd.removePushToken)
      data.append(token.hexString2)
    }
    return self
  }
  
  @discardableResult
  func rename(to name: String) -> StreamOperations {
    description = "changing name to \(name)"
    rename("name()")
    autorepeat()
    request { data in
      data.append(cmd.rename)
      data.append(name)
    }
    checkResponse()
    success {
      session?.set(name: name)
    }
    return self
  }
  
  @discardableResult
  func removeAvatar() -> StreamOperations {
    description = "removing avatar"
    rename("removeAvatar()")
    autorepeat()
    request(.removeAvatar)
    
    return self
  }
}












