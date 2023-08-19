//
//  Screen.swift
//  Some
//
//  Created by Дмитрий Козлов on 11/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

public class SomeScreen {
  public static var `default`: ()->SomeScreen = { SomeScreen() }
  
  public private(set) var frame: CGRect = UIScreen.main.bounds
  public private(set) var center: CGPoint = UIScreen.main.bounds.center
  public private(set) var statusBarHeight: CGFloat = 0
  public private(set) var safeArea: UIEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
  public private(set) var customSafeArea: UIEdgeInsets = .zero
  public let cornerRadius: CGFloat = device.cornerRadius
  public var orientations: UIInterfaceOrientationMask = .all
  public var isLeftToRight: Bool {
    return application.userInterfaceLayoutDirection != .rightToLeft
  }
  
  public var statusBarY: CGFloat = 0 {
    didSet {
      let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as! UIWindow;
      var f = statusBarWindow.frame;
      f.origin.y = max(statusBarY,0)
      statusBarWindow.frame = f;
    }
  }
  
  var isLocked = false
  var shouldUpdate = false
  
  init() {
    updateSafeArea()
  }
  init(viewController: UIViewController) {
    updateSafeArea()
  }
  
  func sendUpdates() {
    shouldUpdate = true
    guard !isLocked else { return }
    shouldUpdate = false
    main?.resolutionChanged()
  }
  
  func lock(execute: ()->()) {
    isLocked = true
    execute()
    isLocked = false
    guard shouldUpdate else { return }
    sendUpdates()
  }
  
  func updateSafeArea() {
    if device == .iphoneX {
      if resolution.width > resolution.height {
        safeArea = UIEdgeInsets(top: 20.0, left: 44.0, bottom: 21.0, right: 44.0)
      } else {
        safeArea = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 34.0, right: 0.0)
      }
    } else {
      safeArea = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
  }
}

extension SomeScreen {
  public var dframe: DFrame { return { [unowned(unsafe) self] in self.frame } }
  public var dframeSafe: DFrame { return { self.safeFrame } }
  public var resolution: CGSize {
    get { return frame.size }
    set {
      frame.size = newValue
      center = newValue.center
      Device.updateType()
      updateSafeArea()
      sendUpdates()
    }
  }
  public var width: CGFloat { return resolution.width }
  public var height: CGFloat { return resolution.height }
  public var retina: CGFloat { return UIScreen.main.scale }
  public var pixel: CGFloat { return 1 / UIScreen.main.scale }
  public var isLandscape: Bool { return width > height }
  public var brigtness: CGFloat { return UIScreen.main.brightness }
  public var orientation: UIInterfaceOrientation {
    get { return application.statusBarOrientation }
    set { UIDevice.current.setValue(newValue.rawValue, forKey: "orientation") }
  }
  
  public var top: CGFloat {
    get { return safeArea.top + customSafeArea.top }
    set {
      customSafeArea.top = newValue
      sendUpdates()
    }
  }
  public var bottom: CGFloat {
    get { return height - (safeArea.bottom + customSafeArea.bottom) }
    set {
      customSafeArea.bottom = newValue
      sendUpdates()
    }
  }
  public var bottomInsets: CGFloat {
    return safeArea.bottom + customSafeArea.bottom
  }
  public var left: CGFloat {
    get { return safeArea.left + customSafeArea.left }
    set {
      customSafeArea.left = newValue
      sendUpdates()
    }
  }
  public var right: CGFloat {
    get { return width - (safeArea.right + customSafeArea.right) }
    set {
      customSafeArea.right = newValue
      sendUpdates()
    }
  }
  public var rightInsets: CGFloat {
    return safeArea.right + customSafeArea.right
  }
  public var safeFrame: CGRect {
    return CGRect(left,top,right,bottom)
  }
}

extension UIInterfaceOrientation {
  public static var current: UIInterfaceOrientation {
    return application.statusBarOrientation
  }
}
