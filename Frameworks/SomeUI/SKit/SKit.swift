
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Dmitry Kozlov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

public typealias Pos = CGPoint
public typealias Size = CGSize
public typealias Color = UIColor
public typealias Rect = CGRect

public let _tl = Anchor(0.0,0.0)
public let _tr = Anchor(1.0,0.0)
public let _bl = Anchor(0.0,1.0)
public let _br = Anchor(1.0,1.0)
public let _t = Anchor(0.5,0.0)
public let _b = Anchor(0.5,1.0)
public let _l = Anchor(0.0,0.5)
public let _r = Anchor(1.0,0.5)
public let _c = Anchor(0.5,0.5)


public let _topLeft = Anchor(0.0,0.0)
public let _topRight = Anchor(1.0,0.0)
public let _bottomLeft = Anchor(0.0,1.0)
public let _bottomRight = Anchor(1.0,1.0)
public let _top = Anchor(0.5,0.0)
public let _bottom = Anchor(0.5,1.0)
public let _left = Anchor(0.0,0.5)
public let _right = Anchor(1.0,0.5)
public let _center = Anchor(0.5,0.5)

public enum Alignment {
  case left, center, right
  public var ui: NSTextAlignment {
    switch self {
    case .left: return NSTextAlignment.left
    case .right: return NSTextAlignment.right
    case .center: return NSTextAlignment.center
    }
  }
  public var anchor: Anchor {
    switch self {
    case .left: return _l
    case .right: return _r
    case .center: return _c
    }
  }
}

extension UIView {
  public func append(_ views: SView...) {
    for view in views {
      view.superview = self
    }
  }
  public func adds(_ views: SView...) {
    for view in views {
      view.superview = self
      view.shows = true
    }
  }
}

extension UIView {
  public func addButtons(_ views: SButton...) {
    for view in views {
      view.superview = self
      view.shows = true
      
    }
  }
}

open class TextStyle {
  open var color: UIColor
  open var font: UIFont
  open var alignment: NSTextAlignment
  
  public init() {
    color = .dark
    font = .normal(14)
    alignment = NSTextAlignment.left
  }
  
  public init(color: UIColor, font: UIFont, alignment: NSTextAlignment) {
    self.color = color
    self.font = font
    self.alignment = alignment
  }
}
