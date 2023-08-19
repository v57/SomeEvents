//
//  EventExtensions.swift
//  Events
//
//  Created by Димасик on 1/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation

extension Event {
  static func ==(left: Event, right: Event) -> Bool {
    return left.id == right.id
  }
  var hashValue: Int {
    return id.hashValue
  }
}
