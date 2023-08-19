//
//  transport manager.swift
//  faggot
//
//  Created by Димасик on 18/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeFunctions

let listenerManager = ListenerManager()
class ListenerManager: Manager {
  private var listeners = [Listener]()
  func listen(_ action: @escaping () -> Bool) {
    let listener = Listener(action: action)
    listeners.append(listener)
    if !running {
      run()
    }
  }
  
  private(set) var running = false
  private func run() {
    running = true
    var offset = 0
    var stopped = [Int]()
    for (i,listener) in self.listeners.enumerated() {
      let stop = listener.action()
      if stop {
        stopped.append(i-offset)
        offset += 1
      }
    }
    if stopped.count > 0 {
      for i in stopped {
        listeners.remove(at: i)
      }
      if listeners.count == 0 {
        running = false
        return
      }
    }
    wait(1, run)
  }
}

private class Listener {
  let action: () -> Bool
  init(action: @escaping ()->Bool) {
    self.action = action
  }
}


