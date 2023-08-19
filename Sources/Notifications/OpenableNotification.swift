//
//  OpenableNotification.swift
//  Events
//
//  Created by Дмитрий Козлов on 3/19/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

protocol NotificationProtocol {
  var view: UIView { get }
  var dpos: DPos { get set }
  
  var isDisplayed: Bool { get set }
}

extension NotificationProtocol {
  func display() {
    
  }
}

protocol AutohideNotification: NotificationProtocol {
  var shouldAutohide: Bool { get }
  var autohideTimer: Double { get }
}

protocol OpenableNotification: NotificationProtocol {
  var isOpened: Bool { get set }
  var shouldOpen: Bool { get }
  var shouldClose: Bool { get }
  
  func willOpen()
  func opening()
  func didOpen()
  
  func willClose()
  func closing()
  func didClose()
}

extension OpenableNotification {
  var shouldOpen: Bool { return false }
  var shouldClose: Bool { return true }
  func open() {
    guard !isOpened else { return }
    guard shouldOpen else { return }
  }
  func close() {
    
  }
}

class NotificationBackground: UIView {
  static var current: NotificationBackground?
  var notification: OpenableNotification
  init(notification: OpenableNotification) {
    self.notification = notification
    super.init(frame: screen.frame)
  }
  override func resolutionChanged() {
    super.resolutionChanged()
    frame = screen.frame
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func open(closeCurrent: Bool) -> Bool {
    if let current = NotificationBackground.current {
      guard closeCurrent else { return false }
      current.close()
    }
    NotificationBackground.current = self
    main.view.addSubview(self)
    addSubview(notification.view)
    return true
  }
  func close() {
    
  }
}


