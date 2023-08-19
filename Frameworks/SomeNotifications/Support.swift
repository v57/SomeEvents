//
//  Support.swift
//  SomeNotifications
//
//  Created by Дмитрий Козлов on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions

public class SomeTimer {
  public var version = 0
  public func resume(time: Double, action: @escaping ()->()) {
    version = version &+ 1
    let v = version
    wait(time) {
      guard self.version == v else { return }
      action()
    }
  }
  public func stop() {
    version = version &+ 1
  }
}
