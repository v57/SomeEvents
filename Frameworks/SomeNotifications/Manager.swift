//
//  Manager.swift
//  SomeNotifications
//
//  Created by Дмитрий Козлов on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeFunctions

extension UIBlurEffectStyle {
  public static var notification: UIBlurEffectStyle = .light
}

open class NotificationsManager {
  public static var `default` = NotificationsManager()
  public static var defaultBlurStyle = UIBlurEffectStyle.light
  public init() {}
  open func view(for notification: SomeNotification) -> UIView {
    return NotificationBackgroundView(notification.size)
  }
}

class NotificationBackgroundView: UIView {
  let visualEffectView: UIVisualEffectView
  override var frame: CGRect {
    didSet {
      visualEffectView.frame.size = frame.size
    }
  }
  init(_ size: CGSize) {
    let effect = UIBlurEffect(style: .notification)
    visualEffectView = UIVisualEffectView(effect: effect)
    visualEffectView.frame.size = size
    super.init(frame: CGRect(origin: .zero, size: size))
    addSubview(visualEffectView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
