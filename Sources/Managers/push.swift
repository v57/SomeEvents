//
//  push.swift
//  Some Events
//
//  Created by Димасик on 7/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

let pushManager = PushManager()
class PushManager: Manager {
  var lastPush: [AnyHashable: Any]?
  func insert(push: [AnyHashable: Any]) {
    print("push: received \(push)")
    lastPush = push
    if ceo.isLoaded {
      processNotification()
    }
  }
  
  func processNotification() {
    do {
      guard let page = main.pages.first else { return }
      guard page is ProfilePage else { return }
      
      guard let push = lastPush else { return }
      lastPush = nil
      guard account != nil else { throw PushError.noAccount }
      guard let base64 = push["d"] as? String else { return }
      guard let data = DataReader(base64: base64) else { throw PushError.cantParse }
      data.decrypt(password: 0xb46c5f92427dd8e1)
      let type: PushType = try data.next()
      switch type {
      case .friends:
        let page = FriendsPage()
        main.push(page)
      case .event:
        let event = try data.eventMain()
        let page = EventPage(event: event)
        main.push(page)
      case .comments:
        let event = try data.eventMain()
        let page = EventPage(event: event)
        main.push(page)
        let page2 = EventComments(event: event)
        main.push(page2)
      case .map:
        let lat: Float = try data.next()
        let lon: Float = try data.next()
        let settings: UInt8 = try data.next()
        let showsMy = settings[0]
        let showsPublic = settings[1]
        let customEvent = settings[2]
        let map = Map(showsMy: showsMy, showsPublic: showsPublic)
        main.push(map)
        map.map.centerCoordinate = .init(latitude: Double(lat), longitude: Double(lon))
        if customEvent {
          let event = try data.eventMain()
          if event.isOnMap {
            map.insert(event: event)
          }
        }
      case .profile:
        // not implemented
        return
      case .report:
        // not implemented
        return
      }
    } catch {
      print("push: \(error)")
    }
  }
  
  func test() {
    let data = DataWriter()
    data.append(0)
    let aps = ["d": data.base64]
    insert(push: ["aps": aps])
  }
  
  func login() {
    guard !Device.isSimulator else { return }
    mainThread {
      if self.lastPush != nil {
        self.processNotification()
      }
      let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
      if let data = self.token {
        wait(5) {
          if !(self.sending || self.sended) {
            self.set(token: data)
          }
        }
      }
    }
    
    // вызывается только при логине
    if !ceo.isLoaded && !sended, let token = token {
      set(token: token)
    }
  }
  func logout() {
    mainThread {
      UIApplication.shared.unregisterForRemoteNotifications()
    }
    sended = false
  }
  
  
  enum PushError: Error {
    case noAps, noAccount, cantParse
    var localizedDescription: String {
      switch self {
      case .noAps: return "no aps"
      case .noAccount: return "no account"
      case .cantParse: return "cant parse"
      }
    }
  }
  
//  let version = 1
//  func load(_ data: DataReader, version: Int) throws {
//    let hasToken = try data.bool()
//    if hasToken {
//      token = try data.data()
//    }
//  }
//
//  func save(_ data: DataWriter) {
//    if let token = token {
//      data.append(true)
//      data.append(token)
//    } else {
//      data.append(false)
//    }
//  }
  
  var token: Data?
  var sended = false
  var sending = false
  func set(token: Data) {
    self.token = token
    self.sending = true
    server.request()
      .autorepeat()
      .add(token: token)
      .success {
        self.sending = false
        self.sended = true
    }
  }
  
  func pause() {
    
  }
}
