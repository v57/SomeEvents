//
//  Notifications.swift
//  Some
//
//  Created by Димасик on 11/14/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData

open class SomeAppNotifications {
  public static var `default`: ()->SomeAppNotifications = { SomeAppNotifications() }
  public init() {}
  
  public var token: Data?
  public var history = [PushNotification]()
  public func request() {}
  open func opened(remote notification: PushNotification) throws {}
  open func registered() {}
  open func registerFailed(error: Error) {}
}

extension SomeAppNotifications {
  func mainLoaded() {
    guard let last = history.last else { return }
    try? opened(remote: last)
  }
  func didRegister(settings: UIUserNotificationSettings) {
    application.registerForRemoteNotifications()
  }
  
  func didFail(error: Error) {
    print("push error: \(error)")
    registerFailed(error: error)
  }
  
  func didRegister(deviceToken: Data) {
    token = deviceToken
    registered()
  }
  
  func didReceive(remote userInfo: [AnyHashable : Any]) {
    let notification = PushNotification(userInfo: userInfo)
    if main.isLoaded {
      if ceo.isPaused {
        try? opened(remote: notification)
      }
    }
    history.append(notification)
  }
}

public class PushNotification {
  public var userInfo: [AnyHashable: Any]
  init(userInfo: [AnyHashable: Any]) {
    self.userInfo = userInfo
  }
  public func dictionary() throws -> [String: Any] {
    let value = userInfo["aps"] as? [String: Any]
    return try unnil(value, PushError.noAps)
  }
  public func data() throws -> DataReader {
    let aps = try dictionary()
    let raw64 = aps["d"] as? String
    let base64: String = try unnil(raw64, PushError.noData)
    return try unnil(DataReader(base64: base64), PushError.noData)
  }
}

public enum PushError: Error {
  case noAps, noData
  public var localizedDescription: String {
    switch self {
    case .noAps: return "no aps"
    case .noData: return "no data"
    }
  }
}
