//
//  View.swift
//  SomeNotifications
//
//  Created by Димасик on 3/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

open class NotificationView {
  public static var backgroundEffect: UIBlurEffectStyle = .light
  public static var width: CGFloat { return 216 }
  open var replaceMode: Bool { return false }
  open var key: String? { return nil }
  open var swipable: Bool { return true }
  open var autoMinimize: Bool { return false }
  
  public weak var background: UIVisualEffectView!
  public var view: UIView!
  public var size: CGSize {
    didSet {
      guard size != oldValue else { return }
      guard let view = view else { return }
      view.resize(size, .topRight)
      background.frame.size = size
    }
  }
  public init(size: CGSize) {
    self.size = size
  }
  public init(height: CGFloat) {
    self.size = CGSize(NotificationView.width,height)
  }
  
  open func didLoad() {
    let effect = UIBlurEffect(style: NotificationView.backgroundEffect)
    let background = UIVisualEffectView(effect: effect)
    background.frame.size = size
    view.addSubview(background)
    self.background = background
  }
  open func sizeChanged() {
    
  }
  open func display(animated: Bool) {
    
  }
  open func hide(animated: Bool) {
    
  }
}

open class SmartNotification: NotificationView {
  public var title: String? {
    didSet {
      updateFull()
      titleLabel?.text = title
    }
  }
  public var icon: UIImage? {
    didSet {
      updateFull()
      imageView?.image = icon
    }
  }
  public var description: String? {
    didSet {
      updateFull()
      descriptionLabel?.text = description
    }
  }
  var isFull = false {
    didSet {
      guard isFull != oldValue else { return }
      updateHeight()
      guard view != nil else { return }
    }
  }
  
  weak var titleLabel: UILabel!
  weak var imageView: UIImageView!
  weak var descriptionLabel: UILabel!
  weak var titleBackground: UIView!
  
  public init() {
    super.init(height: height1)
  }
}

extension SmartNotification {
  var titleFont: UIFont {
    return .normal(13)
  }
  var titleColor: UIColor {
    return .black //0x6C6C6C.color
  }
  var descriptionFont: UIFont {
    return .normal(15)
  }
  var descriptionColor: UIColor {
    return .dark
  }
  var width: CGFloat {
    return 216
  }
  var height1: CGFloat {
    return 36
  }
  var titleX: CGFloat {
    if icon != nil {
      return .margin2 + 20
    } else {
      return .margin
    }
  }
  var titleWidth: CGFloat {
    return NotificationView.width - .margin2
  }
  var descriptionPos: CGPoint {
    if isFull {
      return Pos(16,45)
    } else {
      return Pos(16,45)
    }
  }
  var descriptionWidth: CGFloat {
    return NotificationView.width - .margin2
  }
  var descriptionHeight: CGFloat {
    if let description = description {
      return height1 + description.height(descriptionFont, width: descriptionWidth)
    } else {
      return height1
    }
  }
  func updateFull() {
    isFull = description != nil && (title != nil || icon != nil)
  }
  func updateHeight() {
    if isFull {
      size.height = height1 + height1
    } else {
      size.height = height1
    }
  }
  func createTitleLabel() {
    guard let view = view else { return }
    guard let title = title else { return }
    let label = UILabel(pos: Pos(titleX,height1/2), anchor: .left, text: title, color: titleColor, font: titleFont, maxWidth: titleWidth)
    view.addSubview(label)
    self.titleLabel = label
  }
  func createImageView() {
    
  }
  func createDescriptionLabel() {
    guard let view = view else { return }
    guard let description = description else { return }
    let label = UILabel(pos: Pos(.margin,height1/2), anchor: .left, text: description, color: titleColor, font: titleFont, maxWidth: titleWidth)
    view.addSubview(label)
    self.titleLabel = label
  }
}
