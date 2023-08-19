//
//  accounts.swift
//  Some Events
//
//  Created by Димасик on 10/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

var session: Session?
var account: Account!
var isAuthorized: Bool { return session != nil }

let accounts = Accounts()
class Accounts: Manager, CustomSaveable, Versionable {
  var current: Session? { return session }
  static var version: Version = Version(1)
  
  var isLoaded = false
  
  var sessions = [Session]()
  var locker = NSLock()
  
  let storage = Storage(appGroup: "group.ru.kozlov.some")
  
  var isEnabled = true
  
  func start() {
    guard isEnabled else { return }
    storage.onUpdate = update
    storage.syncronize()
    
//    #if debug
//    let local = storage.localStorage.dictionaryRepresentation()
//    print("accounts: local storage")
//    for (key,value) in local {
//      print("\(key): \(value)")
//    }
//    print("")
//    print("")
//    print("accounts: cloud storage")
//    for (key,value) in storage.cloudStorage.dictionaryRepresentation {
//      print("\(key): \(value)")
//    }
//    print("")
//    print("")
//    #endif
  }
  func set(newSession: Session) {
    locker.lock()
    defer { locker.unlock() }
    
    newSession.lastUsed = .now
    insert(session: newSession)
    sort()
    set(session: newSession)
    save()
    print(accounts: "setting new session: \(newSession)")
  }
  
  var url: FileURL { return "accounts.db".documentsURL }
  func load() throws {
    guard isEnabled else { return }
    locker.lock()
    defer { locker.unlock() }
    
    try? loadFromStorage()
    account = try? Account(url: url)
    pickSession()
    isLoaded = true
  }
  
  func save() {
    guard isEnabled else { return }
    guard let account = account else { return }
    account.save()
    
    var array = [Data]()
    for session in sessions {
      let data = DataWriter()
      session.write(to: data)
      data.encrypt(password: 0x9b86fbe1d7770037)
      array.append(data.data)
    }
    if !array.isEmpty {
      storage.set(object: array, for: "accounts")
    }
  }
  
  func set(_ session: Session?) {
    guard let session = session else { return }
    Events.session = session
  }
}

private extension Accounts {
  func set(session newSession: Session) {
    session = newSession
    newSession.lastUsed = .now
    if let currentAccount = account, currentAccount.user.id != newSession.id {
      if currentAccount.user.id != newSession.id {
        account = nil
      } else {
        currentAccount.user.set(name: newSession.name)
      }
    }
    if account == nil {
      account = Account(session: session!)
    }
    if isLoaded {
      mainThread {
        (main.pages.first as? StartPage)?.set(session: newSession)
      }
    }
  }
  func pickSession() {
    print(accounts: "picking session")
    if let account = account {
      for session in sessions where session.id == account.user.id {
        print(accounts: "picked \(session.id) \(session.name)")
        set(session: session)
        return
      }
    } else {
      guard let session = sessions.first else { return }
      print(accounts: "picked \(session.id) \(session.name)")
      set(session: session)
    }
  }
  func loadFromStorage() throws {
    let array: [Data] = try storage.object(for: "accounts")
    print(accounts: "found \(array.count) sessions")
    let count = sessions.count
    for data in array {
      var data = data
      data.decrypt(password: 0x9b86fbe1d7770037)
      let reader = DataReader(data: data)
      let session = try Session(data: reader)
      insert(session: session)
    }
    sort()
    if count != sessions.count {
      print(accounts: "loaded sessions")
      for session in sessions {
        print(accounts: "\(session.lastUsed.uniFormat) [\(session.id)]: \(session.name)")
      }
    }
  }
  func insert(session: Session) {
    guard !session.name.isEmpty else { return }
    if let index = sessions.index(of: session) {
      let oldSession = sessions[index]
      if oldSession.lastUsed < session.lastUsed {
        print(accounts: "overrided session \(oldSession) with \(session)")
        oldSession.lastUsed = session.lastUsed
        oldSession.name = session.name
      }
    } else {
      print(accounts: "added \(session.name) \(session)")
      sessions.append(session)
    }
  }
  func sort() {
    sessions.sort(by: { $0.lastUsed > $1.lastUsed } )
  }
  
  // storage notification
  func update(key: String, value: Any?) {
    print(accounts: "received value at \(key)")
    locker.lock()
    defer { locker.unlock() }
    
    try? loadFromStorage()
    if session == nil {
      pickSession()
    }
  }
}

extension Account {
  convenience init(url: FileURL) throws {
    guard let data = DataReader(url: url) else { throw corrupted }
    data.decrypt(password: 0x436906fcf5424ad4)
    try self.init(data: data)
  }
  func save() {
    let data = DataWriter()
    save(data: data)
    data.encrypt(password: 0x436906fcf5424ad4)
    try? data.write(to: accounts.url)
  }
}
