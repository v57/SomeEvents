//
//  notification manager.swift
//  faggot
//
//  Created by Димасик on 18/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeFunctions

let notificationManager = NotificationManager()

class NotificationManager: Manager {
  func addNotification(_ notification: ServerNotification) {
    notifications.append(notification)
    notificationViewManager.show(notification)
  }
  func getNotifications(_ type: [NotificationType]) -> [ServerNotification] {
    var a = [ServerNotification]()
    for n in notifications {
      for t in type where n.type == t {
        a.append(n)
        break
      }
    }
    return a
  }
  
  var notifications = [ServerNotification]()
  
}

enum NotificationType {
  case newMessage, newEvent, newSubscriber, invite, friendRequest, system, unknown
}


class ServerNotification {
  var type: NotificationType
  let time: Time
  init(time: Time) {
    self.time = time
    type = NotificationType.unknown
  }
  func open() {
    
  }
  func show(_ type: Int) {
    
  }
  func view() -> NotificationView? {
    return nil
  }
  func mini() -> NNotificationViewMini? {
    return nil
  }
}



