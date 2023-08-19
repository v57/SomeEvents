//
//  content-data.swift
//  Some Events
//
//  Created by Димасик on 7/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData
import SomeBridge

extension DataReader {
  func contentType() throws -> ContentType {
    return try next()
  }
  func contents(_ eventid: Int64) throws -> [Content] {
    let count: Int = try intCount()
    var contents = [Content]()
    contents.reserveCapacity(count)
    for _ in 0..<count {
      let c = try content(eventid)
      contents.append(c)
    }
    return contents.sorted(by: { $0.time > $1.time } )
  }
  func contentPreview(_ eventid: Int64) throws -> ContentPreview? {
    let vtype: UInt8 = try next()
    guard vtype != 0xff else { return nil }
    guard let type = ContentType(rawValue: vtype) else { throw corrupted }
    let id: Int64 = try next()
    return ContentPreview(id: id, type: type, event: eventid)
  }
  func content(_ eventid: Int64) throws -> Content {
    return try contentType().class.init(server: self, eventid: eventid)
  }
  func dataContent() throws -> Content {
    return try contentType().class.init(data: self)
  }
}
