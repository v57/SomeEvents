//
//  UITextField.swift
//  Some
//
//  Created by Димасик on 2/13/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit

extension UITextField {
  public enum Style {
    case none, login, password, email
  }
  
  public var string: String { return text ?? "" }
  public var isEmpty: Bool { return string.isEmpty }
  public var isEmail: Bool { return string.isEmail }
  
  public var style: Style {
    get {
      if isSecureTextEntry {
        return .password
      } else if keyboardType == .emailAddress {
        return .email
      } else if autocapitalizationType == .none {
        return .login
      } else {
        return .none
      }
    }
    set {
      switch newValue {
      case .none: break
      case .login:
        isSecureTextEntry = false
        spellCheckingType = .no
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboardType = .default
      case .email:
        isSecureTextEntry = false
        spellCheckingType = .no
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboardType = .emailAddress
      case .password:
        isSecureTextEntry = true
        spellCheckingType = .no
        autocorrectionType = .no
        autocapitalizationType = .none
        keyboardType = .default
      }
    }
  }
}
