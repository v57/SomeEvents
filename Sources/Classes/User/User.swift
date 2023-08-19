//
//  user.swift
//  faggot
//
//  Created by Димасик on 2/18/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeNetwork
import SomeBridge

enum RemoteFileStatus {
  case notDownloaded, waiting, downloading, downloaded, updateAvailable
}

enum FriendStatus {
  case notFriend, incoming, outcoming, friend
}

enum UserLocalOptions: UInt8 {
  case mainLoaded, publicLoaded, avatarDownloaded, mainUpdate, isSubscriber
  public static let `default`: UserLocalOptions.Set = 0b0
}

class User: DataRepresentable, Versionable, Hashable {
  static var version = Version(3)
  
  let id: Int64
  
  // main
  var name = String()
  var publicOptions = PublicUserOptions.default
  var avatarVersion = UserAvatarVersion()
  var mainVersion = UserMainVersion()
  
  // public profile
  var publicProfileVersion = UserProfileVersion()
  var events = Set<ID>()
  
  var subscribers = Int64()
  var subscriptions = Int64()
  
  // local data
  var localOptions = UserLocalOptions.default
  var downloadedAvatarVersion = UserAvatarVersion()
  
  func loadMain(data: DataReader) throws {
    name = try data.next()
    publicOptions = try data.next()
    avatarVersion = try data.next()
    mainVersion = try data.next()
  }
  func saveMain(data: DataWriter) {
    data.append(name)
    data.append(publicOptions)
    data.append(avatarVersion)
    data.append(mainVersion)
  }
  
  func loadPublicProfile(data: DataReader) throws {
    publicProfileVersion = try data.next()
//    Swift.print(id, publicProfileVersion, data)
    events = try data.next()
    subscribers = try data.next()
    subscriptions = try data.next()
  }
  func savePublicProfile(data: DataWriter) {
    data.append(publicProfileVersion)
    data.append(events)
    data.append(subscribers)
    data.append(subscriptions)
  }
  
  func loadLocalData(data: DataReader) throws {
    publicProfileVersion = try data.next()
    if User.version <= 2 {
      events = try data.next()
    }
    if User.version >= 2 {
      downloadedAvatarVersion = try data.next()
    }
    if User.version >= 3 {
      localOptions = try data.next()
    }
  }
  func saveLocalData(data: DataWriter) {
    data.append(publicProfileVersion)
    data.append(downloadedAvatarVersion)
    data.append(localOptions)
  }
  
  init(id: Int64) {
    self.id = id
  }
  
  required init(data: DataReader) throws {
    try id = data.next()
    try loadMain(data: data)
    try loadPublicProfile(data: data)
    try loadLocalData(data: data)
  }
  
  func save(data: DataWriter) {
    data.append(id)
    saveMain(data: data)
    savePublicProfile(data: data)
    saveLocalData(data: data)
  }
  
  static func == (l: User, r: User) -> Bool {
    return l.id == r.id
  }
  var hashValue: Int { return id.hashValue }
}

extension DataReader {
  func userMain(user: User) throws {
    try user.set(name: next())
    try user.set(publicOptions: next())
    try user.set(avatarVersion: next())
    try user.set(mainVersion: next())
    user.localOptions[.mainLoaded] = true
    user.localOptions[.mainUpdate] = false
  }
  func userMain(id: ID) throws -> User {
    if let user = usersManager[id] {
      try userMain(user: user)
      return user
    } else {
      let user = User(id: id)
      try user.name = next()
      try user.publicOptions = next()
      try user.avatarVersion = next()
      try user.mainVersion = next()
      user.isMainLoaded = true
      usersManager[id] = user
      return user
    }
  }
  func userMain() throws -> User {
    let id: ID = try next()
    return try userMain(id: id)
  }
  @discardableResult
  func userMains() throws -> [User] {
    var users = [User]()
    let count = try intCount()
    for _ in 0..<count {
      try users.append(userMain())
    }
    return users
  }
  func userIds() throws -> [ID] {
    var array = [ID]()
    let count = try intCount()
    for _ in 0..<count {
      try array.append(userId())
    }
    return array
  }
  func userId() throws -> ID {
    let id: ID = try next()
    let version: UserMainVersion = try next()
    if let user = id.user {
      if user.isMainLoaded && user.mainVersion != version {
        user.shouldUpdateMain = true
      }
    }
    return id
  }
  
  func userVersion() throws -> (ID,Bool) {
    let id: ID = try next()
    let mainVersion: UserMainVersion = try next()
    if let user = id.user, user.mainVersion < mainVersion {
      return (id,true)
    } else {
      return (id,false)
    }
  }
  func userVersions() throws -> [ID] {
    let count = try intCount()
    var ids = [ID]()
    var updated = [ID]()
    for _ in 0..<count {
      let (id,isUpdated) = try userVersion()
      ids.append(id)
      if isUpdated {
        updated.append(id)
      }
    }
    usersManager.update(users: updated)
    return ids
  }
}

