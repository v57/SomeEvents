//
//  UIAlertController.swift
//  Some
//
//  Created by Дмитрий Козлов on 2/13/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

extension UIAlertController {
  public class func destructive(title: String?, message: String?, button: String, action: @escaping ()->()) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let destroy = UIAlertAction(title: button, style: .destructive) { _ in
      action()
    }
    alert.addAction(destroy)
    alert.addCancel()
    return alert
  }
  public func addCancel() {
    let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    addAction(action)
  }
  public func add(_ title: String, action: (()->())? = nil) {
    var handler: ((UIAlertAction) -> Void)?
    if let action = action {
      handler = { _ in
        action()
      }
    }
    let action = UIAlertAction(title: title, style: .default, handler: handler)
    addAction(action)
  }
  public func addDestructive(_ title: String, action: (()->())? = nil) {
    var handler: ((UIAlertAction) -> Void)?
    if let action = action {
      handler = { _ in
        action()
      }
    }
    let action = UIAlertAction(title: title, style: .destructive, handler: handler)
    addAction(action)
  }
}
