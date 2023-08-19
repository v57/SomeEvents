//
//  ReportNotification.swift
//  SomeEvents
//
//  Created by Димасик on 12/4/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class ReportNotification: TextNView, UniqueNotification {
  static var key: String { return "reports available" }
  static func set(count: Int) {
    if let notification = notifications[key] as? ReportNotification {
      notification.count = count
    } else {
      ReportNotification(count: count).display()
    }
  }
  var count: Int {
    didSet {
      guard count != oldValue else { return }
      if count == 0 {
        hide(animated: true)
      } else {
        if count > 1 {
          set(title: "\(count) reports available")
        } else {
          set(title: "New report")
        }
      }
    }
  }
  init(count: Int) {
    self.count = count
    let title: String
    if count > 1 {
      title = "\(count) reports available"
    } else {
      title = "New report"
    }
    super.init(title: title)
    key = ReportNotification.key
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
