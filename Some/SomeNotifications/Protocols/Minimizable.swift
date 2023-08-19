//
//  Minimizable.swift
//  SomeNotifications
//
//  Created by Димасик on 3/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

public class MinimizableNotification: NamedNotification {
  open var shouldMinimize: Bool { return false }
  open var minimizeTime: Double { return 5.0 }
  open var minimizedSize: CGSize { return CGSize(60,60) }
  open var shouldDisplayMinimized: Bool { return false }
  public private(set) var isMinimized: Bool = false
  
  public override func display(animated: Bool) {
    if shouldDisplayMinimized {
      minimize(animated: false)
    } else if shouldMinimize {
      resumeMinimizing()
    }
    super.display(animated: animated)
  }
  
  open func maxmize(animated: Bool) {
    isMinimized = false
  }
  open func minimize(animated: Bool) {
    isMinimized = true
  }
  
  open func resumeMinimizing() {
    minimizeTimer.resume(time: minimizeTime) { [weak self] in
      self?.minimize(animated: true)
    }
  }
  open func stopMinimizing() {
    minimizeTimer.stop()
  }
  let minimizeTimer = SomeTimer()
}

