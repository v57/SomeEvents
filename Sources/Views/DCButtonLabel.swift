//
//  DCButtonLabel.swift
//  Some Events
//
//  Created by Димасик on 7/13/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class LabelController {
  var action: (()->())?
  var label: UILabel
  init(label: UILabel) {
    self.label = label
    label.isUserInteractionEnabled = true
    label.addTap(self, #selector(tap))
    let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(hold(gesture:)))
    label.addGestureRecognizer(holdGesture)
  }
  func touch(action: @escaping ()->()) {
    self.action = action
  }
  
  @objc func tap() {
    label.bounce()
    action?()
  }
  var isInside = false {
    didSet {
      guard isInside != oldValue else { return }
      if isInside {
        down()
      } else {
        up()
      }
    }
  }
  @objc func hold(gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      isInside = true
    case .cancelled, .failed:
      isInside = false
    case .ended:
      if isInside {
        action?()
      }
      isInside = false
    case .possible: break
    case .changed:
      isInside = label.bounds.contains(gesture.location(in: label))
    }
  }
  
  func up() {
    animate {
      label.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
  }
  
  func down() {
    animate {
      label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
