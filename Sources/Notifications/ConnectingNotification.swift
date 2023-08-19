//
//  ConnectingNotification.swift
//  SomeEvents
//
//  Created by Димасик on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class ConnectingNotification: TextNView, UniqueNotification {
  static var key: String {
    return "Connecting"
  }
  
  var retryTime: Time = 0
  var isRunning = false
  static var connectingText: String {
    #if debug
    return "Connecting to \(address.ip)"
    #else
    return "Connecting"
    #endif
  }
  
  var buttons = [UIButton]()
  
  private var openedHeight: CGFloat { return CGFloat(addresses.count) * 30 }
  private var isOpened = false {
    didSet {
      guard isOpened != oldValue else { return }
      if isOpened {
        height += openedHeight
        makeButtons()
      } else {
        height -= openedHeight
      }
    }
  }
  private func makeButtons() {
    guard buttons.isEmpty else { return }
    var y = height - openedHeight
    for (key,value) in addresses {
      let button = Button(text: key)
      button.move(Pos(.margin,y), .topLeft)
      button.touch {
        address.ip = value
        server.ip = value
        server.disconnect()
      }
      contentView.addSubview(button)
      y += 30
    }
  }
  private var heightOffset: CGFloat {
    return isOpened ? openedHeight : 0
  }
  
  required init() {
    super.init(title: ConnectingNotification.connectingText)
    key = ConnectingNotification.key
  }
  
  override func tap() {
    #if debug
    isOpened = !isOpened
    #else
    super.tap()
    #endif
  }
  
  override func set(title: String) {
    super.set(title: title)
    height += heightOffset
  }
  
  func connecting() {
    set(title: ConnectingNotification.connectingText)
  }
  func connectionFailed(wait: Time) {
    #if debug
    retryTime = Time.now + wait
    waitTick()
    #endif
  }
  
  func waitTick() {
    guard !isRunning else { return }
    let now = Time.now
    guard now <= retryTime else { return }
    set(title: "Connecting failed\nretry in \(retryTime - now)")
    isRunning = true
    wait(0.5) {
      self.isRunning = false
      self.waitTick()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
