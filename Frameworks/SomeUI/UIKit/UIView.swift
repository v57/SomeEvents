//
//  UIView.swift
//  Some
//
//  Created by Дмитрий Козлов on 18/08/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit

// MARK: - properties
extension UIView {
  public var cornerRadius: CGFloat {
    get { return layer.cornerRadius }
    set {
      guard layer.cornerRadius != newValue else { return }
      layer.cornerRadius = newValue
    }
  }
  public var positionOnScreen: CGPoint {
    return superview!.convert(frame.origin, to: nil)
  }
  public var centerPositionOnScreen: CGPoint {
    return superview!.convert(center, to: nil)
  }
  public var frameOnScreen: CGRect {
    return CGRect(origin: positionOnScreen, size: frame.size)
  }
}

// MARK: - functions
extension UIView {
  public convenience init(size: CGSize) {
    self.init(frame: CGRect(origin: .zero, size: size))
  }
  public func addTap(_ selector: Selector?) {
    isUserInteractionEnabled = true
    let gesture = UITapGestureRecognizer(target: self, action: selector)
    addGestureRecognizer(gesture)
  }
  public func addTap(_ target: Any?, _ selector: Selector?) {
    isUserInteractionEnabled = true
    let gesture = UITapGestureRecognizer(target: target, action: selector)
    addGestureRecognizer(gesture)
  }
  public func removeSubviews() {
    subviews.forEach { $0.removeFromSuperview() }
  }
  public func addCircleLayer(_ color: UIColor ,width: CGFloat) {
    let o: CGFloat = 4
    let rect = CGRect(-o,-o,bounds.size.width+o+o,bounds.size.height+o+o)
    let layer = CAShapeLayer()
    layer.path = CGPath(ellipseIn: rect, transform: nil)
    layer.strokeColor = color.cgColor
    layer.fillColor = UIColor.clear.cgColor
    layer.lineWidth = width
    layer.frame = bounds
    self.layer.addSublayer(layer)
  }
  public func optimizeCorners() {
    // Huge change in performance by explicitly setting the below (even though default is supposedly NO)
    layer.masksToBounds = false
    // Performance improvement here depends on the size of your view
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }
  public func bounce(from: CGFloat) {
    guard animationsAvailable() else { return }
    scale(from)
    jellyAnimation {
      self.scale(1.0)
    }
  }
  public func bounce() {
    guard animationsAvailable() else { return }
    scale(1.2)
    jellyAnimation {
      self.scale(1.0)
    }
  }
  public func bounce(completion: @escaping ()->()) {
    guard animationsAvailable() else { return }
    scale(1.2)
    jellyAnimation ({
      self.scale(1.0)
    }, completion)
  }
  public func shetBounce() {
    guard animationsAvailable() else { return }
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value: 1.5 as Float)
    animation.toValue = NSNumber(value: 1 as Float)
    animation.duration = 0.4
    animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    animation.isRemovedOnCompletion = true
    layer.add(animation, forKey: "bounceAnimation")
  }
  public func scale(_ s: CGFloat) {
    transform = CGAffineTransform(scaleX: s, y: s)
  }
  public func rotate(_ a: CGFloat) {
    transform = CGAffineTransform(rotationAngle: a)
  }
  public func scale(from: Float, to: Float, animated: Bool, remove: Bool = true) {
    if animated && animationsAvailable() {
      let animation = CABasicAnimation(keyPath: "transform.scale")
      animation.fromValue = NSNumber(value: from)
      animation.toValue = NSNumber(value: to)
      animation.duration = atime
      animation.timingFunction = .default
      animation.isRemovedOnCompletion = remove
      animation.fillMode = kCAFillModeForwards
      layer.add(animation, forKey: "scale")
    } else {
      transform = CGAffineTransform(scaleX: CGFloat(to), y: CGFloat(to))
    }
  }
  public func downAnimation(to value: Float = 0.95) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value: 1.0)
    animation.toValue = NSNumber(value: value)
    animation.duration = 0.2
    animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
    layer.add(animation, forKey: "touch")
  }
  public func upAnimation(from value: Float = 0.95) {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value: value)
    animation.toValue = NSNumber(value: 1.0)
    animation.duration = 0.4
    animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    animation.isRemovedOnCompletion = true
    layer.add(animation, forKey: "touch")
  }
  public func hideAnimation() {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value: 1)
    animation.toValue = NSNumber(value: 0.5)
    animation.duration = 0.2
    animation.isRemovedOnCompletion = true
    layer.add(animation, forKey: "hide")
  }
  public func showsAnimation() {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value: 0.0)
    animation.toValue = NSNumber(value: 1.0)
    animation.duration = 0.4
    animation.isRemovedOnCompletion = true
    layer.add(animation, forKey: "hide")
  }
  public func addSubviews(_ subviews: [UIView]) {
    for view in subviews {
      addSubview(view)
    }
  }
  public func addSubviews(_ subviews: UIView...) {
    for view in subviews {
      addSubview(view)
    }
  }
  public func addSubviews(_ subviews: UIView?...) {
    for view in subviews {
      if view != nil {addSubview(view!)}
    }
  }
  public class func optimize(_ views: [UIView], backgroundColor: UIColor) {
    for view in views {
      view.isOpaque = true
      view.clipsToBounds = true
      view.backgroundColor = backgroundColor
      view.clearsContextBeforeDrawing = false
    }
  }
  public class func backgroundColor(_ views: [UIView]) {
    for view in views {
      view.backgroundColor = view.superview?.backgroundColor
    }
  }
  public func circle() {
    clipsToBounds = true
    layer.cornerRadius = frame.size.min / 2
  }
  
  /// blur
  public func addBlur(_ style: UIBlurEffectStyle = .light) {
    let effect = UIBlurEffect(style: .dark)
    let view = UIVisualEffectView(effect: effect)
    view.frame = frame
    addSubview(view)
  }
  public func addDarkBlur() {
    addBlur(.dark)
  }
  public func addLightBlur() {
    addBlur(.extraLight)
  }
  
  /// centering views
  public func centerViewsVertically(_ views: [UIView], offset: CGFloat = .margin) {
    var vheight: CGFloat = 0
    for view in views {
      vheight += view.frame.size.height + offset
    }
    var y = (frame.size.height - vheight) / 2
//    let x = frame.size.width / 2
    for view in views {
      view.move(y: y, _top)
      y += view.frame.size.height + offset
    }
  }
  public func centerViewsHorisontally(_ views: [UIView], offset: CGFloat = .margin) {
    var hwidth: CGFloat = -offset
    for view in views {
      hwidth += view.frame.size.width + offset
    }
    var x = (frame.size.width - hwidth) / 2
    let y = frame.size.height / 2
    for view in views {
      view.move(Pos(x,y), _left)
      x += view.frame.size.width + offset
    }
  }
  
  
  /// shadows
  public func dropShadow(_ opacity: Float, offset: CGFloat) {
    let shadowPath = UIBezierPath(rect: bounds)
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.0, height: offset)
    layer.shadowOpacity = opacity
    layer.shadowPath = shadowPath.cgPath
  }
  public func dropCircleShadow(_ opacity: Float, offset: CGFloat) {
    let shadowPath = UIBezierPath(ovalIn: bounds)
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.0, height: offset)
    layer.shadowOpacity = opacity
    layer.shadowPath = shadowPath.cgPath
  }
  
  /// border
  public func setBorder(_ color: UIColor, _ width: CGFloat) {
    layer.borderColor = color.cgColor
    layer.borderWidth = width
  }
  
  public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
  
  /// lines
  public class func vline(_ pos: Pos, anchor: Anchor, height: CGFloat, color: UIColor) -> UIView {
    let view = UIView(frame: CGRect(pos, anchor, Size(screen.pixel, height)))
    view.backgroundColor = color
    return view
  }
  public class func hline(_ pos: Pos, anchor: Anchor, width: CGFloat, color: UIColor) -> UIView {
    let view = UIView(frame: CGRect(pos, anchor, Size(width, screen.pixel)))
    view.backgroundColor = color
    return view
  }
  
  /// options default: .fade
  /// animated default: true
  @discardableResult
  public func destroy(options: DisplayOptions = .fade, animated: Bool = true) -> Self? {
    if animated && animationsAvailable() {
      switch options {
      case .fadeZoom(let zoom):
        animate ({
          self.scale(zoom)
          self.alpha = 0.0
        }) {
          self.alpha = 1.0
          self.scale(1.0)
          self.removeFromSuperview()
        }
      case .fade:
        animate({
          alpha = 0.0
        }) {
          self.removeFromSuperview()
          self.alpha = 1.0
        }
      case .slide:
        animate({
          alpha = 0.0
          frame.origin.y += 10
        }) {
          self.removeFromSuperview()
          self.alpha = 1.0
          self.frame.origin.y -= 10
        }
      case .anchor(let anchor):
        let size = frame.size
        animate({
          resize(.zero, anchor)
        }) {
          self.removeFromSuperview()
          self.resize(size, anchor)
        }
      case .vertical(let anchor):
        let size = frame.size
        animate({
          resize(Size(size.width,0), anchor)
        }) {
          self.removeFromSuperview()
          self.resize(size, anchor)
        }
      case .horizontal(let anchor):
        let size = frame.size
        animate({
          resize(Size(0,size.height), anchor)
        }) {
          self.removeFromSuperview()
          self.resize(size, anchor)
        }
      case .scale(let s):
        animate ({
          scale(s)
        }) {
          self.scale(1)
          self.removeFromSuperview()
        }
      }
    } else {
      self.removeFromSuperview()
    }
    return nil
  }
  public func display(_ view: UIView, options: DisplayOptions = .fade, animated: Bool = true) {
    addSubview(view)
    if animated && animationsAvailable() {
      switch options {
      case .fadeZoom(let zoom):
        view.scale(zoom)
        view.alpha = 0.0
        animate {
          view.alpha = 1.0
          view.scale(1.0)
        }
      case .fade:
        view.alpha = 0.0
        view.frame.origin.y += 10
        animate {
          view.alpha = 1.0
          view.frame.origin.y -= 10
        }
      case .slide:
        view.alpha = 0.0
        view.frame.origin.y += 10
        animate {
          view.alpha = 1.0
          view.frame.origin.y -= 10
        }
      case .anchor(let anchor):
        let size = view.frame.size
        view.resize(.zero, anchor)
        animate {
          view.resize(size, anchor)
        }
      case .vertical(let anchor):
        let size = view.frame.size
        view.resize(Size(size.width,0), anchor)
        animate {
          view.resize(size, anchor)
        }
      case .horizontal(let anchor):
        let size = view.frame.size
        view.resize(Size(0,size.height), anchor)
        animate {
          view.resize(size, anchor)
        }
      case .scale(let s):
        view.scale(s)
        animate {
          view.scale(1)
        }
      }
    }
  }
  public func addSubviewSafe(_ view: UIView) {
    guard view.superview == nil else { return }
    addSubview(view)
  }
}

public enum DisplayOptions {
  case fade, slide
  case anchor(Anchor)
  case vertical(Anchor)
  case horizontal(Anchor)
  case scale(CGFloat)
  case fadeZoom(CGFloat)
  public static var horizontalLeft: DisplayOptions = .horizontal(.left)
  public static var verticalLeft: DisplayOptions = .vertical(.left)
}
