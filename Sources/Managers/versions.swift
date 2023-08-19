//
//  versions.swift
//  Some Events
//
//  Created by Димасик on 10/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork
import SomeBridge

let versions = Versions()
class Versions: Manager, Saveable {
  var classes = [String: Versionable.Type]()
  
  func start() {
    insert(Accounts.self)
    insert(Session.self)
    insert(Account.self)
    insert(Content.self)
    insert(Chat.self)
    insert(User.self)
    insert(Event.self)
    insert(Message.self)
  }
  
  func save(data: DataWriter) throws {
    data.append(classes.count)
    for c in classes {
      data.append(c.key)
      data.append(c.value.version.current)
    }
  }
  
  func load(data: DataReader) throws {
    let count = try data.intCount()
    for _ in 0..<count {
      let name: String = try data.next()
      let version: UInt8 = try data.next()
      classes[name]?.version.loaded = version
    }
    classes.forEach {
      Swift.print("version: \($0.key) \($0.value.version)")
    }
  }
  
  func insert(_ value: Versionable.Type) {
    let name = className(value)
    classes[name] = value
  }
}

protocol Versionable: class {
  static var version: Version { get set }
}

class Version: CustomStringConvertible {
  let current: UInt8
  var loaded: UInt8 = 0
  init(_ current: UInt8) {
    self.current = current
  }
  static func <(l:Version,r:UInt8) -> Bool {
    return l.loaded < r
  }
  static func <=(l:Version,r:UInt8) -> Bool {
    return l.loaded <= r
  }
  static func >=(l:Version,r:UInt8) -> Bool {
    return l.loaded >= r
  }
  static func >(l:Version,r:UInt8) -> Bool {
    return l.loaded > r
  }
  static func ==(l:Version,r:UInt8) -> Bool {
    return l.loaded == r
  }
  var description: String {
    return "current: \(current) loaded: \(loaded)"
  }
}


extension AppVersion {
  static func outdated() {
    mainQueue.disable()
    StreamQueue.upload.disable()
    StreamQueue.previewUpload.disable()
    downloadQueue.disable()
    let alert = UIAlertController(title: "Update pls", message: "Your version is too old, but you can stay offline", preferredStyle: .alert)
    let offline = UIAlertAction(title: "Stay offline", style: .default) { _ in
      
    }
    let update = UIAlertAction(title: "Update", style: .cancel) { _ in
      let url = NSURL(string: "http://appstore.com/SomeEvents")
      application.openURL(url! as URL)
    }
    alert.addAction(offline)
    alert.addAction(update)
    main.present(alert, animated: true, completion: nil)
  }
}
