//
//  UniqueNotification.swift
//  SomeNotifications
//
//  Created by Дмитрий Козлов on 3/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Swift
import SomeFunctions

private var notifications = [String: SomeNotification]()

public enum NotificationOverride {
  case weak, strong
}

public class NamedNotification: AutohideNotification {
  private var key: String?
  private var override: NotificationOverride = .weak
  public func set(key: String?, override: NotificationOverride) {
    self.key = key
    self.override = override
  }
  override open var shouldDisplay: Bool {
    guard let key = key else { return super.shouldDisplay }
    if override == .weak, notifications[key] != nil {
      return false
    } else {
      return super.shouldDisplay
    }
  }
  public override func display(animated: Bool) {
    if let key = key {
      notifications[key]?.hide(animated: animated)
      notifications[key] = self
    }
    super.display(animated: animated)
  }
  public override func hide(animated: Bool) {
    if let key = key {
      notifications[key] = nil
    }
    super.hide(animated: animated)
  }
  open func updated() {
    
  }
}

protocol UniqueNotification {
  func updated()
}

extension UniqueNotification {
  static var key: String {
    return className(Self.self)
  }
  static var current: Self? {
    return notifications[key] as? Self
  }
  static func unique(execute: (Self.Type)->()) {
    if let notification = notifications[key] {
      (notification as? Self)?.updated()
    } else {
      execute(Self.self)
    }
  }
  static func hide(animated: Bool) {
    notifications[key]?.hide(animated: animated)
  }
}
