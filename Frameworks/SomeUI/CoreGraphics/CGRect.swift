//
//  CGRect.swift
//  mutating funcs
//
//  Created by Дмитрий Козлов on 02/09/16.
//  Copyright © 2016 Дмитрий Козлов. All rights reserved.
//

import CoreGraphics

extension CGRect {
  public init(_ pos: Pos, _ anchor: Anchor, _ size: Size) {
    self.init(origin: Pos(pos.x - size.width * anchor.x, pos.y - size.height * anchor.y), size: size)
  }
  public init(size: CGSize) {
    self.init(origin: .zero, size: size)
  }
  public func anchor(_ anchor: Anchor) -> Pos {
    let w = size.width * anchor.x
    let h = size.height * anchor.y
    let x = origin.x + w
    let y = origin.y + h
    return Pos(x,y)
  }
  public init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
    self.init(x: x, y: y, width: width, height: height)
  }
  public init(_ x: Int, _ y: Int, _ width: Int, _ height: Int) {
    self.init(x: x, y: y, width: width, height: height)
  }
  public init(_ x: Double, _ y: Double, _ width: Double, _ height: Double) {
    self.init(x: x, y: y, width: width, height: height)
  }
  public init(frame: CGRect, size: CGSize) {
    self.init(x: (frame.size.width - size.width) / 2, y: (frame.size.height - size.height) / 2, width: size.width, height: size.height)
  }
  public init(center: CGPoint, size: CGSize) {
    self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
  }
  
  public var x: CGFloat {
    get {
      return origin.x
    }
    set {
      origin.x = newValue
    }
  }
  public var y: CGFloat {
    get {
      return origin.y
    }
    set {
      origin.y = newValue
    }
  }
  public var width: CGFloat {
    get {
      return size.width
    }
    set {
      size.width = newValue
    }
  }
  public var height: CGFloat {
    get {
      return size.height
    }
    set {
      size.height = newValue
    }
  }
  
  public var topLeft: CGPoint {
    get {
      return origin
    }
    set {
      origin = newValue
    }
  }
  
  
  public var top: CGPoint {
    get {
      return CGPoint(x+width*0.5,y)
    }
    set {
      origin = CGPoint(newValue.x+width*0.5,newValue.y)
    }
  }
  public var topRight: CGPoint {
    get {
      return CGPoint(x+width,y)
    }
    set {
      origin = CGPoint(x+width,y)
    }
  }
  public var right: CGPoint {
    get {
      return CGPoint(x+width,y+height*0.5)
    }
    set {
      origin = CGPoint(newValue.x+width,newValue.y+height*0.5)
    }
  }
  public var bottomRight: CGPoint {
    get {
      return CGPoint(x+width,y+height)
    }
    set {
      origin = CGPoint(newValue.x+width,newValue.y+height)
    }
  }
  public var bottom: CGPoint {
    get {
      return CGPoint(x+width*0.5,y+height)
    }
    set {
      origin = CGPoint(newValue.x+width*0.5,newValue.y+height)
    }
  }
  public var bottomLeft: CGPoint {
    get {
      return CGPoint(x,y+height)
    }
    set {
      origin = CGPoint(newValue.x,newValue.y+height)
    }
  }
  public var left: CGPoint {
    get {
      return CGPoint(x,y+height*0.5)
    }
    set {
      origin = CGPoint(newValue.x,newValue.y+height*0.5)
    }
  }
  public var center: CGPoint {
    get { return CGPoint(x+width*0.5,y+height*0.5) }
    set { origin = CGPoint(newValue.x-width*0.5,newValue.y-height*0.5) }
  }
  
  public mutating func moveX(_ x: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: x - size.width * anchor.x, y: origin.y, width: size.width, height: size.height)
  }
  public mutating func moveY(_ y: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x, y: y - size.height * anchor.y, width: size.width, height: size.height)
  }
  public mutating func move(_ pos: CGPoint, _ anchor: Anchor) {
    self = CGRect(x: pos.x - size.width * anchor.x, y: pos.y - size.height * anchor.y, width: size.width, height: size.height)
  }
  
  public mutating func resize(width: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x - (width - size.width) * anchor.x, y: origin.y, width: width, height: size.height)
  }
  public mutating func resize(height: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x, y: origin.y - (height - size.height) * anchor.y, width: size.width, height: height)
  }
  public mutating func resize(_ size: CGSize, _ anchor: Anchor) {
    self = CGRect(x: origin.x - (width - size.width) * anchor.x, y: origin.y - (height - size.height) * anchor.y, width: width, height: height)
  }
  public mutating func resize(_ width: CGFloat, _ height: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x - (width - size.width) * anchor.x, y: origin.y - (height - size.height) * anchor.y, width: width, height: height)
  }
  
  public mutating func extend(width: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x - width * anchor.x, y: origin.y, width: size.width + width, height: size.height)
  }
  public mutating func extend(height: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x, y: origin.y - height * anchor.y, width: size.width, height: size.height + height)
  }
  public mutating func extend(_ width: CGFloat, _ height: CGFloat, _ anchor: Anchor) {
    self = CGRect(x: origin.x - width * anchor.x, y: origin.y - height * anchor.y, width: size.width + width, height: size.height + height)
  }
  public mutating func extend(_ size: CGSize, _ anchor: Anchor) {
    self = CGRect(x: origin.x - size.width * anchor.x, y: origin.y - size.height * anchor.y, width: self.size.width + size.width, height: self.size.height + size.height)
  }
  
}

public func + (left: CGRect, right: CGRect) -> CGRect {
  return CGRect(x: left.origin.x + right.origin.x, y: left.origin.y + right.origin.y, width: left.size.width + right.size.width, height: left.size.height + right.size.height)
}
public func + (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(x: left.origin.x + right.x, y: left.origin.y + right.y, width: left.size.width, height: left.size.height)
}
public func + (left: CGRect, right: CGSize) -> CGRect {
  return CGRect(x: left.origin.x, y: left.origin.y, width: left.size.width + right.width, height: left.size.height + right.height)
}

public func += (left: inout CGRect, right: CGRect) {
  left = left + right
}
public func += (left: inout CGRect, right: CGPoint) {
  left = left + right
}
public func += (left: inout CGRect, right: CGSize) {
  left = left + right
}

public func - (left: CGRect, right: CGRect) -> CGRect {
  return CGRect(x: left.origin.x - right.origin.x, y: left.origin.y - right.origin.y, width: left.size.width - right.size.width, height: left.size.height - right.size.height)
}
public func - (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(x: left.origin.x - right.x, y: left.origin.y - right.y, width: left.size.width, height: left.size.height)
}
public func - (left: CGRect, right: CGSize) -> CGRect {
  return CGRect(x: left.origin.x, y: left.origin.y, width: left.size.width - right.width, height: left.size.height - right.height)
}

public func -= (left: inout CGRect, right: CGRect) {
  left = left - right
}
public func -= (left: inout CGRect, right: CGPoint) {
  left = left - right
}
public func -= (left: inout CGRect, right: CGSize) {
  left = left - right
}

public func * (left: CGRect, right: CGRect) -> CGRect {
  return CGRect(x: left.origin.x * right.origin.x, y: left.origin.y * right.origin.y, width: left.size.width * right.size.width, height: left.size.height * right.size.height)
}
public func * (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(x: left.origin.x * right.x, y: left.origin.y * right.y, width: left.size.width, height: left.size.height)
}
public func * (left: CGRect, right: CGSize) -> CGRect {
  return CGRect(x: left.origin.x, y: left.origin.y, width: left.size.width * right.width, height: left.size.height * right.height)
}
public func * (left: CGRect, right: CGFloat) -> CGRect {
  return CGRect(x: left.origin.x * right, y: left.origin.y * right, width: left.size.width * right, height: left.size.height * right)
}

public func *= (left: inout CGRect, right: CGRect) {
  left = left * right
}
public func *= (left: inout CGRect, right: CGPoint) {
  left = left * right
}
public func *= (left: inout CGRect, right: CGSize) {
  left = left * right
}

public func / (left: CGRect, right: CGRect) -> CGRect {
  return CGRect(x: left.origin.x / right.origin.x, y: left.origin.y / right.origin.y, width: left.size.width / right.size.width, height: left.size.height / right.size.height)
}
public func / (left: CGRect, right: CGPoint) -> CGRect {
  return CGRect(x: left.origin.x / right.x, y: left.origin.y / right.y, width: left.size.width, height: left.size.height)
}
public func / (left: CGRect, right: CGSize) -> CGRect {
  return CGRect(x: left.origin.x, y: left.origin.y, width: left.size.width / right.width, height: left.size.height / right.height)
}
public func / (left: CGRect, right: CGFloat) -> CGRect {
  return CGRect(x: left.origin.x / right, y: left.origin.y / right, width: left.size.width / right, height: left.size.height / right)
}

public func /= (left: inout CGRect, right: CGRect) {
  left = left / right
}
public func /= (left: inout CGRect, right: CGPoint) {
  left = left / right
}
public func /= (left: inout CGRect, right: CGSize) {
  left = left / right
}
public func /= (left: inout CGRect, right: CGFloat) {
  left = left / right
}
