//
//  NSubscription.swift
//  faggot
//
//  Created by Димасик on 29/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions

class NNewEvent: ServerNotification {
  override init(time: Time) {
    super.init(time: time)
    type = NotificationType.newEvent
  }
}
