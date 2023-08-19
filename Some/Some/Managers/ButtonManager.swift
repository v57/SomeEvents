//
//  ButtonGesture.swift
//  Some
//
//  Created by Димасик on 5/23/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import UIKit
import SomeFunctions

public final class ButtonActions {
  fileprivate var gesture: ButtonGesture
  fileprivate init(gesture: ButtonGesture) {
    self.gesture = gesture
  }
}
public extension ButtonActions {
  @discardableResult
  func onToggle(action: @escaping (Bool)->()) -> Self {
    gesture.addTapGesture()
    gesture.toggleActions.append(action)
    return self
  }
  @discardableResult
  func onHold(action: @escaping ()->()) -> Self {
    gesture.holdActions.append(action)
    return self
  }
  @discardableResult
  func onForceTouch(action: @escaping ()->()) -> Self {
    gesture.forceTouchActions.append(action)
    return self
  }
  @discardableResult
  func onTouch(action: @escaping ()->()) -> Self {
    gesture.addTapGesture()
    gesture.touchActions.append(action)
    return self
  }
  @discardableResult
  func set(animations: ButtonAnimations) -> Self {
    gesture.animations = animations
    return self
  }
  @discardableResult
  func set(toggle: Bool, style: ButtonToggleStyle) -> Self {
    gesture.toggleStyle = style
    gesture.toggleStyle.apply(view: gesture.currentView, manager: gesture)
    gesture.set(toggle: toggle, animated: false)
    return self
  }
  @discardableResult
  func set(toggle: Bool) -> Self {
    gesture.set(toggle: toggle, animated: false)
    return self
  }
  @discardableResult
  func set(shadow: ShadowType) -> Self {
    gesture.options[.hasShadow] = true
    let opacity: Float = 0.5
    switch shadow {
    case .square:
      gesture.currentView.dropShadow(opacity, offset: 0)
    case .rounded(radius: let radius):
      gesture.currentView.dropShadow(opacity, offset: 0, cornerRadius: radius)
    case .circle:
      gesture.currentView.dropCircleShadow(opacity, offset: 0)
    }
    gesture.currentView.layer.shadowRadius = 5
    return self
  }
  func removeShadow() {
    gesture.options[.hasShadow] = false
  }
}


public extension UIView {
  var buttonActions: ButtonActions {
    if let gesture = gestureRecognizers?.find(ButtonGesture.self) {
      return ButtonActions(gesture: gesture)
    } else {
      let gesture = ButtonGesture(view: self)
      addGestureRecognizer(gesture)
      return ButtonActions(gesture: gesture)
    }
  }
}

public enum ShadowType {
  case square, circle, rounded(radius: CGFloat)
}

open class ButtonToggleStyle {
  public static var `default`: ButtonToggleStyle { return Push() }
  public static var border: ButtonToggleStyle { return Border() }
  open func apply(view: UIView, manager: ButtonGesture) {}
  open func enable(view: UIView, manager: ButtonGesture, animated: Bool) {}
  open func disable(view: UIView, manager: ButtonGesture, animated: Bool) {}
  private class Border: ButtonToggleStyle {
    override func apply(view: UIView, manager: ButtonGesture) {
      view.layer.borderColor = UIColor.system.cgColor
      view.layer.borderWidth = 0.0
    }
    override func enable(view: UIView, manager: ButtonGesture, animated: Bool) {
      view.set(borderWidth: 3, animated: animated)
    }
    override func disable(view: UIView, manager: ButtonGesture, animated: Bool) {
      view.set(borderWidth: 0, animated: animated)
    }
  }
  private class Push: ButtonToggleStyle {
    override func enable(view: UIView, manager: ButtonGesture, animated: Bool) {
      manager.forceOffset = 0.5
      animateif(animated) {
        view.alpha = 0.5
      }
    }
    override func disable(view: UIView, manager: ButtonGesture, animated: Bool) {
      manager.forceOffset = 0.0
      animateif(animated) {
        view.alpha = 1.0
      }
    }
  }
}

open class ButtonAnimations {
  public static var `default`: ButtonAnimations { return Push() }
  public static var push: ButtonAnimations { return Push() }
  public static var none: ButtonAnimations { return ButtonAnimations() }
  public init() {}
  open func animate1(animation: @escaping ()->()) {
    animation()
  }
  open func animate2(animation: @escaping ()->(), completion: @escaping ()->()) {
    animation()
    completion()
  }
  open func down(manager: ButtonGesture, force: CGFloat) {
  }
  open func down(manager: ButtonGesture) {
  }
  open func up(manager: ButtonGesture) {
  }
  private class Push: ButtonAnimations {
    var _force: CGFloat = 0.0
    override func animate1(animation: @escaping ()->()) {
      jellyAnimation {
        animation()
      }
    }
    override func animate2(animation: @escaping ()->(), completion: @escaping ()->()) {
      animate(0.1, animation, completion: completion)
    }
    override func down(manager: ButtonGesture, force: CGFloat) {
      push(manager: manager, force: force)
    }
    override func down(manager: ButtonGesture) {
      push(manager: manager, force: 0.3)
    }
    override func up(manager: ButtonGesture) {
      push(manager: manager, force: 0.0)
    }
    func push(manager: ButtonGesture, force: CGFloat) {
      let force = min(force + manager.forceOffset,1.0)
      guard force != _force else { return }
      _force = force
      let s = (1.0 - (force / 5))
      manager.currentView.scale(s)
      if manager.options[.hasShadow] {
        manager.currentView.layer.shadowOpacity = 0.5 + 0.5 * Float(force)
        manager.currentView.layer.shadowRadius = 10 - 10 * force
      }
    }
  }
}

public enum ButtonOptions: UInt8 {
  case touch, hold, forceTouch, toggle
  case hasShadow
  case isToggle
}

private class ButtonTap: UITapGestureRecognizer {
  unowned var gesture: ButtonGesture
  init(gesture: ButtonGesture) {
    self.gesture = gesture
    super.init(target: gesture.view, action: #selector(UIView._tap(gesture:)))
    gesture.currentView.addGestureRecognizer(self)
  }
}

public class ButtonGesture: ForceTouchGestureRecognizer {
  public var options = ButtonOptions.Set64()
  unowned var currentView: UIView
  var toggleActions = [(Bool)->()]()
  var holdActions = [()->()]()
  var forceTouchActions = [()->()]()
  var touchActions = [()->()]()
  var animations: ButtonAnimations = .default
  var toggleStyle: ButtonToggleStyle = .default
  private var tapGesture: UITapGestureRecognizer!
  
  var forceOffset: CGFloat = 0.0
  private var _force: CGFloat = 0.0
  private var version = 0
  private var beganTime: Double = 0.0
  private var isTouchInside = false
  init(view: UIView) {
    currentView = view
    view.isUserInteractionEnabled = true
    super.init(target: view, action: #selector(UIView._hold(gesture:)))
    minimumPressDuration = 0.2
  }
}

private extension ButtonGesture {
  func tapped() {
    let t = forceOffset
    touch()
    if forceOffset != t {
      up()
    } else {
      downUp()
    }
  }
  func holding() {
    var force: CGFloat?
    if screen.forceTouchAvailable {
      force = self.force
    }
    switch self.state {
    case .began:
      beganTime = Time.abs
      version += 1
      isTouchInside = true
      if let force = force {
        down(force: force)
      } else {
        down()
      }
    case .changed:
      if isTouchInside {
        let location = self.location(in: currentView)
        let pos = currentView.bounds.anchor(.center)
        let frame = CGRect(center: pos, size: currentView.bounds.size / 0.8)
        isTouchInside = frame.contains(location)
        if isTouchInside, let force = force {
          down(force: force)
          if shouldForceTouch && force > 0.8 {
            up()
          }
        } else {
          up()
        }
      } else {
        let location = self.location(in: currentView)
        isTouchInside = currentView.bounds.contains(location)
        if isTouchInside && force == nil {
          down()
        }
      }
    case .ended:
      guard isTouchInside else { return }
      touch()
      isTouchInside = false
      let time = Time.abs - beganTime
      if time < 0.1 && (force ?? 0) < 0.3 {
        downUp()
      } else {
        up()
      }
    case .cancelled:
      guard isTouchInside else { return }
      isTouchInside = false
      up()
    default: break
    }
  }
}

private extension ButtonGesture {
  var shouldToggle: Bool { return !toggleActions.isEmpty }
  var shouldForceTouch: Bool { return !forceTouchActions.isEmpty }
  var shouldHold: Bool { return !holdActions.isEmpty }
  var shouldTouch: Bool { return !touchActions.isEmpty }
  var holdDuration: CFTimeInterval {
    if shouldHold || shouldForceTouch {
      return 0.5
    } else {
      return 0.1
    }
  }
  func addTapGesture() {
    guard tapGesture == nil else { return }
    tapGesture = ButtonTap(gesture: self)
  }
  func set(toggle: Bool, animated: Bool) {
    guard toggle != options[.isToggle] else { return }
    options[.isToggle] = toggle
    if toggle {
      toggleStyle.enable(view: currentView, manager: self, animated: animated)
    } else {
      toggleStyle.disable(view: currentView, manager: self, animated: animated)
    }
  }
}

private extension ButtonGesture {
  func hold() {
    holdActions.forEach { $0() }
  }
  func forceTouch() {
    forceTouchActions.forEach { $0() }
  }
  func toggle() {
    let toggle = !options[.isToggle]
    set(toggle: toggle, animated: true)
    toggleActions.forEach { $0(toggle) }
  }
  func touch() {
    if shouldToggle {
      toggle()
    }
    touchActions.forEach { $0() }
  }
}

private extension ButtonGesture {
  func up() {
    self.animations.animate1 {
      self.animations.up(manager: self)
    }
  }
  func down(force: CGFloat) {
    animations.down(manager: self, force: force)
  }
  func down() {
    animations.animate1 {
      self.animations.down(manager: self)
    }
  }
  func downUp() {
    version += 1
    let v = version
    animations.animate2(animation: {
      self.animations.down(manager: self)
    }, completion: {
      guard self.version == v else { return }
      self.animations.animate1 {
        self.animations.up(manager: self)
      }
    })
  }
}

private extension UIView {
  @objc func _tap(gesture: ButtonTap) {
    gesture.gesture.tapped()
  }
  @objc func _hold(gesture: ButtonGesture) {
    gesture.holding()
  }
}
