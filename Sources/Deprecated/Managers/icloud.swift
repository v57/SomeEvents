//
//  icloud.swift
//  faggot
//
//  Created by Димасик on 6/17/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

/*
enum iCloudKey: String {
  case session = "String"
}

let icloud = iCloudManager()
class iCloudManager: Manager {
  var isEnabled = true
  let storage = NSUbiquitousKeyValueStore.default
  
//  var sessions = Set<Session>()
  
  func start() {
    guard isEnabled else { return }
    NotificationCenter.default.addObserver(self, selector: #selector(dbChanged), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
    storage.synchronize()
    dbChanged()
  }
  
  @objc func dbChanged() {
    print("icloud: db changed")
    guard isEnabled else {
      print("icloud: disabled")
      return }
    guard session == nil else {
      print("icloud: alread have session")
      return }
    guard let data = self[.session] else {
      print("icloud: no session")
      return }
    do {
      session = try Session(data: data)
      account = Account(session: session!)
      
      print("icloud: \(session!.name)")
      if ceo.loading {
        print("icloud: app still loading")
      }
      (main.pages.first as? StartPage)?.set(session: session!)
    } catch {
      
    }
  }
  
  subscript (key: iCloudKey) -> DataReader? {
    guard let data = storage.data(forKey: key.rawValue) else { return nil }
    let password = UInt64(bitPattern: Int64(key.rawValue.hashValue))
    let reader = DataReader(data)
    reader.decrypt(password: password)
    return reader
  }
  func insert(data: DataWriter, to key: iCloudKey) {
    let password = UInt64(bitPattern: Int64(key.rawValue.hashValue))
    data.encrypt(password: password)
    storage.set(data.data, forKey: key.rawValue)
    storage.synchronize()
  }
}
*/
