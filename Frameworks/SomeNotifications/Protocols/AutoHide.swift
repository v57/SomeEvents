//
//  AutoHide.swift
//  SomeNotifications
//
//  Created by Дмитрий Козлов on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

public class AutohideNotification: SomeNotification {
  open var autoHideEnabled: Bool { return false }
  open var autoHideTime: Double { return 5.0 }
  let autoHideTimer = SomeTimer()
  public override func display(animated: Bool) {
    if autoHideEnabled {
      resumeAutohide()
    }
    super.display(animated: animated)
  }
  open func resumeAutohide() {
    autoHideTimer.resume(time: autoHideTime, action: { [weak self] in
      guard self != nil else { return }
      guard self!.autoHideEnabled else { return }
      self!.hide(animated: true)
    })
  }
  open func stopAutohide() {
    autoHideTimer.stop()
  }
}
