//
//  View.swift
//  Some
//
//  Created by Дмитрий Козлов on 11/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit


// MARK:- #View
open class View: UIView {
  open var viewShowSpeed: TimeInterval = atime
  open var viewHideSpeed: TimeInterval = atime
  open var shows: Bool = true {
    didSet {
      if oldValue != self.shows {
        if self.shows {
          if self.superview == nil {
            self.alpha = 1.0
          } else {
            UIView.animate(withDuration: viewShowSpeed, animations: {self.alpha = 1.0})
          }
        } else {
          if self.superview == nil {
            self.alpha = 0.0
          } else {
            UIView.animate(withDuration: viewHideSpeed, animations: {self.alpha = 0.0})
          }
        }
      }
    }
  }
  public init() {
    super.init(frame: screen.frame)
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  public init(lineY: CGFloat, width: CGFloat) {
    super.init(frame: CGRect(x: 0, y: lineY, width: width, height: 1))
    backgroundColor = .line
  }
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
