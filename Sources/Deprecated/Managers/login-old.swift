//
//  login.swift
//  faggot
//
//  Created by Димасик on 2/27/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

//let loginManager = LoginManager()
//class LoginManager: Manager, CustomDBPath {
//  var id: Int64 {
//    if let session = session {
//      return session.id
//    } else {
//      return -1
//    }
//  }
//  var db: String { return "session.db" }
//
//  func load(data: DataReader) throws {
//    data.decrypt(password: 0x1488d1f11a5)
//    let id = try data.next()
//    let password = try data.uint64()
//    let name = try data.string8()
//    session = Session(id: id, password: password, name: name)
//
//    account = try? Account(data: data)
//  }
//  func save(data: DataWriter) throws {
//    guard let session = session else { return }
//    data.append(session.id)
//    data.append(session.password)
//    data.append(session.name)
//
//    account?.save(data: data)
//    data.encrypt(password: 0x1488d1f11a5)
//  }
//
//  func nameChanged(to name: String) {
//    guard let session = session else { return }
//    session.name = name
//  }
//}

