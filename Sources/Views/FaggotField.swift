//
//  FaggotField.swift
//  faggot
//
//  Created by Димасик on 23/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class FaggotField: View, UITextFieldDelegate, DynamicPos {
  public var dpos: (()->(Pos,Anchor))? {
    didSet {
      guard let dpos = self.dpos else { return }
      let (pos,anchor) = dpos()
      move(pos,anchor)
    }
  }
  
  var done = {}
  var typing: ((_ oldText: String, _ newText: String)->())!
  
  var hideKeyboardOnReturn = false
  var autoShowsNext = true
  
  var text: String {
    get {
      return textField?.text ?? ""
    }
    set {
      textField?.text = newValue
    }
  }
  
  var theme = Theme.light
  
  var animated = true
  
  override init() {
    super.init(frame: CGRect(0,0,320, 80))
  }
  
  func setup() {
    animated = false
    showsTextField = true
    showsPlaceholder = true
    animated = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  var showsNextButton = false {
    didSet {
      if showsNextButton != oldValue {
        if showsNextButton {
          nextButton = Button(frame: CGRect(bounds.center.x + 105 - 5,0,60,60), imageName: "NextDark")
          nextButton.add(target: self, action: #selector(FaggotField.nextButtonTapped))
          display(nextButton, animated: animated)
        } else {
          nextButton = nextButton.destroy()
        }
      }
    }
  }
  var nextButton: Button!
  
  var showsTextField = false {
    didSet {
      if showsTextField != oldValue {
        if showsTextField {
          textField = TextField(frame: CGRect(Pos(frame.size.center.x, 10),.top,Size(210,40)), placeholder: nil, font: .normal(16), color: theme == .dark ? .light : .dark, clearsOnSelect: textFieldClearsOnSelect, returnKey: returnKeyType, leftOffset: 15)
          textField.tintColor = .light
          textField.delegate = self
          textField.keyboardAppearance = .dark
          textFieldBackground = UIView(frame: textField.frame)
          textFieldBackground.backgroundColor = theme == .dark ? .background : .backgroundDark
          textFieldBackground.layer.cornerRadius = 5
          textField.style = style
          display(textFieldBackground, animated: animated)
          display(textField, animated: animated)
        } else {
          textField = textField.destroy()
          textFieldBackground = textFieldBackground.destroy()
        }
      }
    }
  }
  var textFieldBackground: UIView!
  var textField: TextField!
  var textFieldClearsOnSelect = false {
    didSet {
      if textFieldClearsOnSelect != oldValue {
        textField?.clearsOnBeginEditing = textFieldClearsOnSelect
      }
    }
  }
  var returnKeyType = UIReturnKeyType.join {
    didSet {
      if returnKeyType != oldValue {
        textField?.returnKeyType = returnKeyType
      }
    }
  }
  var style = TextField.Style.login {
    didSet {
      if style != oldValue {
        textField?.style = style
      }
    }
  }
  
  var showsPlaceholder = false {
    didSet {
      if showsPlaceholder != oldValue {
        if showsPlaceholder {
          placeholderLabel = Label(frame: CGRect(bounds.center.x - 105 + 10,60,0,0), text: placeholder, font: .light(12), color: theme == .dark ? .light : .dark, alignment: .left, fixHeight: true)
          display(placeholderLabel, animated: animated)
        } else {
          placeholderLabel = placeholderLabel.destroy()
        }
      }
    }
  }
  var placeholderLabel: Label!
  var placeholder = "Login" {
    didSet {
      if placeholder != oldValue && showsPlaceholder {
        placeholderLabel.animateText = placeholder
        placeholderLabel.fixFrame(false)
      }
    }
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nextButtonTapped()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard !isAnimating else { return false }
    
    let oldText = textField.text ?? ""
    let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    if newText.count > oldText.count {
      self.bounce(from: 1.05)
    }
    if autoShowsNext {
      if oldText.count == 0 && newText.count > 0 {
        showsNextButton = true
      } else if newText.count == 0 && oldText.count > 0 {
        showsNextButton = false
      }
    }
    typing?(oldText, newText)
    return true
  }
  
  var _label: DCLabel!
  private var _text: String!
  var isAnimating: Bool = false
  
  func colAnimation(_ completion: @escaping ()->()) {
    textField.tintColor = .clear
    _text = textField.text
    let text: String
    if textField.isSecureTextEntry {
      text = String([Character](repeating: "•", count: _text.count))
    } else {
      text = _text
    }
    _label = _label?.destroy()
    _label = DCLabel(frame: textField.frame.offsetBy(dx: 15, dy: 0), text: text, font: textField.font!, color: textField.textColor!, alignment: .left, fixHeight: true)
    textField.text = ""
    isAnimating = true
    animate ({
      self._label.center = self.textField.center// + CGPoint(0,y)
    }) {
      self.isAnimating = false
      completion()
    }
    addSubview(_label)
  }
  func colAnimationBack() {
    textField.tintColor = .clear
    isAnimating = true
    animate ({
      self._label.frame = self.textField.frame.offsetBy(dx: 15,dy: self.frame.y)
      //            self._label.moveTo(self.textField.frame.left + CGPoint(15,self.frame.y), anchorPoint: _left, animated: false)
    }) {
      self.isAnimating = false
      self.textField.tintColor = .light
      self.textField.text = self._text
      self._label = self._label.destroy()
      
    }
  }
  func colAnimationUp() {
    guard let label = self._label else { return }
    self.textField.tintColor = .light
    let center = label.center
    let text = label.text!
    let font = UIFont.normal(20)
    self._label.textAlignment = .center
    self._label.frame = Rect(center,.center,text.size(font))
    
    
    
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = NSNumber(value:1.0)
    animation.toValue = NSNumber(value:1.25)
    //        animation.duration = 0.3
    //        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    animation.isRemovedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
    Animation.start(atime, function: Animation.linear)
    label.layer.add(animation, forKey: "scale")
    Animation.end()
    
    wait(atime) {
      label.layer.removeAllAnimations()
      label.font = font
    }
    animate ({
      label.center.y -= 50
    }) {
      
    }
  }
  func colRemove() {
    guard _label != nil else { return }
    let label = _label
    _label = nil
    animate ({
      label?.frame = (label?.frame.offsetBy(dx: 0,dy: -50))!
      label?.alpha = 0
    }) {
      label?.removeFromSuperview()
    }
  }
  
  @objc func nextButtonTapped() {
    guard !isAnimating else { return }
    if hideKeyboardOnReturn {
      textField.resignFirstResponder()
    }
    done()
  }
}
