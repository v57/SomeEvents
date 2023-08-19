//
//  account.swift
//  faggot
//
//  Created by Димасик on 2/18/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData
import SomeBridge

#if debug
  extension Debug {
    private static var avatarTrigger = false
    static func avatarUploaded() {
      avatarTrigger = true
    }
    static func userAvatarChanged(user: User) {
      guard user.isMe else { return }
      if avatarTrigger {
        avatarTrigger = false
        "Avatar uploaded".notification()
      } else {
        "Avatar uploaded from other device".notification()
      }
    }
  }
#endif

var isModerator: Bool { return account.isModerator }
enum AccountLocalOptions {
  case offline, updated, shouldRestore
}

class Account: DataRepresentable, Versionable {
  static var version = Version(1)
  let user: User
  
  var privateOptions = PrivateUserOptions.default
  var privateProfileVersion = UserPrivateVersion()
  var friends = Set<ID>()
  var subscribers = Int()
  var subscriptions = Set<ID>()
  var outcoming = Set<ID>()
  var incoming = Set<ID>()
  var favorite = Set<ID>()
  
//  var privateChats = [ID: PrivateChat]()
//  var groupChats = [ID: GroupChat]()
  
//  var reports = Set<Report>()
  
  var allowReports: Bool { return privateOptions[.allowReports] }
  var isModerator: Bool { return privateOptions[.moderator] }
  var isAdmin: Bool { return privateOptions[.admin] }
  
  var reportsCount = 0
  var uncheckedReportsCount = 0
  
  func set(privateOptions: PrivateUserOptions.Set) {
    self.privateOptions = privateOptions
  }
  func set(privateProfileVersion: UserPrivateVersion) {
    self.privateProfileVersion = privateProfileVersion
  }
  func set(subscribers: Int) {
    self.subscribers = subscribers
  }
  func set(subscriptions: Set<ID>) {
    self.subscriptions = subscriptions
  }
  func set(favorite: Set<ID>) {
    self.favorite = favorite
  }
  
  func set(friends: Set<Int64>) {
    let result = self.friends.merge(to: friends)
    if !result.added.isEmpty {
      sendNotification(AccountNotifications.self) { $0.added(friends: result.added) }
    }
    if !result.removed.isEmpty {
      sendNotification(AccountNotifications.self) { $0.removed(friends: result.removed) }
    }
  }
  
  func set(incoming: Set<Int64>) {
    let result = self.incoming.merge(to: incoming)
    if !result.added.isEmpty {
      sendNotification(AccountNotifications.self) { $0.added(incoming: result.added) }
    }
    if !result.removed.isEmpty {
      sendNotification(AccountNotifications.self) { $0.removed(incoming: result.removed) }
    }
  }
  
  func set(outcoming: Set<Int64>) {
    let result = self.outcoming.merge(to: outcoming)
    if !result.added.isEmpty {
      sendNotification(AccountNotifications.self) { $0.added(outcoming: result.added) }
    }
    if !result.removed.isEmpty {
      sendNotification(AccountNotifications.self) { $0.removed(outcoming: result.removed) }
    }
  }
  
  func insert(friend id: Int64) {
    incoming.remove(id)
    outcoming.remove(id)
    guard !friends.contains(id) else { return }
    friends.insert(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.added(friends: set) } }
  
  func insert(incoming id: Int64) {
    guard !incoming.contains(id) else { return }
    incoming.insert(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.added(incoming: set) }
  }
  
  func insert(outcoming id: Int64) {
    guard !outcoming.contains(id) else { return }
    outcoming.insert(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.added(outcoming: set) }
  }
  
  func remove(friend id: Int64) {
    guard friends.contains(id) else { return }
    friends.remove(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.removed(friends: set) }
  }
  
  func remove(incoming id: Int64) {
    guard incoming.contains(id) else { return }
    incoming.remove(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.removed(incoming: set) }
  }
  
  func remove(outcoming id: Int64) {
    guard outcoming.contains(id) else { return }
    outcoming.remove(id)
    let set = Set(id)
    sendNotification(AccountNotifications.self) { $0.removed(outcoming: set) }
  }
  
  init(session: Session) {
    user = session.id.user
  }
  
  required init(data: DataReader) throws {
    let id: ID = try data.next()
    
    friends = try data.next()
    incoming = try data.next()
    outcoming = try data.next()
    
    user = id.user
  }
  func save(data: DataWriter) {
    data.append(user.id)
    
    data.append(friends)
    data.append(incoming)
    data.append(outcoming)
  }
  func isFriend(_ id: Int64) -> Bool {
    return friends.contains(id)
  }
  func isFriendRequest(_ id: Int64) -> Bool {
    return incoming.contains(id)
  }
  func upload(avatar: UIImage) {
    let upload = AvatarUpload()
    if let currentUpload = serverManager.uploads[upload.location] {
      if !currentUpload.progress.isCompleted {
        currentUpload.progress.cancel()
      }
      serverManager.uploads[upload.location] = nil
    }
    fileThread {
      do {
        try avatar.jpg(settings.compressQuality).write(to: upload.location)
        mainThread {
          server.upload(type: upload)
            .success {
              User.me.avatarVersion += 1
              User.me.downloadedAvatarVersion += 1
              #if debug
                Debug.avatarUploaded()
              #endif
          }
        }
      } catch {
        print("avatar upload error: cannot write image file")
      }
    }
  }
}


class Session: Versionable, Hashable, CustomStringConvertible {
  static var version = Version(2)
  
  var hashValue: Int { return id.hashValue }
  
  let id: Int64
  let password: UInt64
  var name: String
  var lastUsed: Time
  init(id: Int64, password: UInt64, name: String) {
    self.id = id
    self.password = password
    self.name = name
    self.lastUsed = .now
    createUser()
  }
  init(data: DataReader) throws {
    id = try data.next()
    password = try data.next()
    name = try data.next()
    lastUsed = try data.next()
    createUser()
  }
  func set(name: String) {
    guard self.name != name else { return }
    self.name = name
    accounts.save()
  }
  func write(to data: DataWriter) {
    data.append(id)
    data.append(password)
    data.append(name)
    data.append(lastUsed)
  }
//  func save() {
//    let data = DataWriter()
//    write(to: data)
//    icloud.insert(data: data, to: .session)
//  }
  static func == (l:Session,r:Session) -> Bool {
    return l.id == r.id && l.password == r.password
  }
  private func createUser() {
    guard usersManager[id] == nil else { return }
    let user = User(id: id)
    user.name = name
    usersManager[id] = user
  }
  var description: String {
    return "\(id)-\(password)"
  }
}

extension DataWriter {
  func login() throws {
    guard let session = session else { throw ServerError.wrong }
    append(session.id)
    append(session.password)
  }
  func login(session: Session) {
    append(session.id)
    append(session.password)
  }
}
