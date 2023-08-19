//
//  Notification.swift
//  SomeNotifications
//
//  Created by Дмитрий Козлов on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

public protocol LoadableView {
  var view: UIView! { get }
  func loaded(view: UIView)
  func unloaded(view: UIView)
}

public class SomeNotification {
  public static var displayed = [SomeNotification]()
//  static var cache
  
  public var index: Int = 0
  
  public private(set) var view: UIView!
  public var isDisplayed: Bool = false
  
  public var size: CGSize = .zero
  public var insets: UIEdgeInsets = .zero
  
  private var cellHeight: CGFloat {
    return size.height + insets.top + insets.bottom
  }
  open var shouldDisplay: Bool {
    return size.width > 0 && size.height > 0
  }
  
  open func loaded(view: UIView) {
    
  }
  open func unloaded(view: UIView) {
    
  }
  
  public func display(animated: Bool) {
    assert(!isDisplayed)
    guard shouldDisplay else { return }
    isDisplayed = true
  }
  public func hide(animated: Bool) {
    assert(isDisplayed)
    isDisplayed = false
  }
}

// MARK:- Private
private extension SomeNotification {
  var displayedNotifications: [SomeNotification] {
    get { return SomeNotification.displayed }
    set { SomeNotification.displayed = newValue }
  }
  var bottomNotifications: ArraySlice<SomeNotification> { return [] }
  func offset(notifications: ArraySlice<SomeNotification>, by offset: CGFloat) {
    notifications.forEach {
      $0.view.frame.origin.y += offset
    }
  }
}

// MARK:- Equatable
extension SomeNotification: Equatable {
  public static func ==(lhs: SomeNotification, rhs: SomeNotification) -> Bool {
    return lhs === rhs
  }
}
