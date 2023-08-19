//
//  Anchor.swift
//  mutating funcs
//
//  Created by Дмитрий Козлов on 02/09/16.
//  Copyright © 2016 Дмитрий Козлов. All rights reserved.
//

import UIKit

public struct Anchor {
  public var x: CGFloat
  public var y: CGFloat
  public init() {
    x = 0
    y = 0
  }
  public init(_ x: CGFloat, _ y: CGFloat) {
    self.x = x
    self.y = y
  }
  public init(point: CGPoint) {
    self.x = point.x
    self.y = point.y
  }
  
  public static var left: Anchor = Anchor(0,0.5)
  public static var topLeft: Anchor = Anchor(0,0)
  public static var top: Anchor = Anchor(0.5,0)
  public static var topRight: Anchor = Anchor(1,0)
  public static var right: Anchor = Anchor(1,0.5)
  public static var bottomRight: Anchor = Anchor(1,1)
  public static var bottom: Anchor = Anchor(0.5,1)
  public static var bottomLeft: Anchor = Anchor(0,1)
  public static var center: Anchor = Anchor(0.5,0.5)
  
  public var alignment: NSTextAlignment {
    if x == 0.5 {
      return .center
    } else if x == 1 {
      return .right
    } else {
      return .left
    }
  }
}
