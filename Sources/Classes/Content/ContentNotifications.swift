//
//  ContentNotifications.swift
//  Events
//
//  Created by Димасик on 1/22/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation
import SomeBridge

protocol ContentNotifications {
  func uploaded(content: Content)
  func previewUploaded(content: Content)
}
