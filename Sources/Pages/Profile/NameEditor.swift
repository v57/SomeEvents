//
//  NameEditor.swift
//  SomeEvents
//
//  Created by Димасик on 11/28/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class NameEditor: Page {
  override var isFullscreen: Bool {
    return false
  }
  var completion: ((String)->())?
  let text: String
  let view: DFVisualEffectView
  let textField: UITextField
  init(label: UILabel) {
    text = label.text!
    
    view = DFVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    view.frame = label.frame
    view.frame.origin = label.positionOnScreen
    view.clipsToBounds = true
    view.layer.cornerRadius = 12
    textField = UITextField(frame: view.bounds)
    textField.text = text
    textField.font = label.font
    textField.returnKeyType = .done
    
    view.contentView.addSubview(textField)
    
    super.init()
    
    transition = .fade
    
    addTap(self, #selector(tap))
    showsBackButton = false
    
    addSubview(view)
    textField.becomeFirstResponder()
    textField.delegate = self
    animate {
      view.dframe = { CGRect(12,screen.bottom-keyboardHeight-12-60,screen.width-24,60) }
      textField.frame = CGRect(12,0,view.frame.width-24,view.frame.height)
    }
    
    //    view.scale(from: 0.5, to: 1.0, animated: true)
  }
  
  @objc func tap() {
    close()
  }
  
  func close() {
    main.back()
  }
  
  override func keyboardMoved() {
    view.updateFrame()
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    textField.frame = view.bounds
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension NameEditor: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    let text = textField.text!
    if !text.isEmpty && text != self.text {
      completion?(textField.text!)
    }
    close()
    return true
  }
}
