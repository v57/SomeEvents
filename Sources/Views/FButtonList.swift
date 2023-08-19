//
//  Buttons.swift
//  faggot
//
//  Created by Димасик on 3/21/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class FButtonList: DFScrollView {
  static var height: CGFloat = 100
  var buttons = [FButton]()
  var height: CGFloat = 100
  var offset: CGFloat = 30
  var boffset: CGFloat = 30 + FButton.width
  var contentSizeChanged: (()->())?
  var topInset: CGFloat = 0
  override init() {
    super.init(frame: .zero)
    showsHorizontalScrollIndicator = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func insert(_ button: FButton, animated: Bool) {
    guard buttons.index(of: button) == nil else { return }
    button.frame.y = topInset
    if animated {
      defer { bounceButtons() }
    }
    guard button.position >= 0 else {
      append(button, animated: animated)
      return }
    for (i,button2) in buttons.enumerated() {
      if button.position < button2.position || button2.position == -1 {
        insert(button, at: i, animated: animated)
        return
      }
    }
    append(button, animated: animated)
  }
  private func insert(_ button: FButton, at index: Int, animated: Bool) {
    let x = CGFloat(index) * boffset + offset
    button.frame.x = x
    display(button, options: .slide, animated: animated)
    
    if index < buttons.count {
      animateif(animated) {
        for i in index..<buttons.count {
          buttons[i].frame.x += boffset
        }
      }
    }
    
    buttons.insert(button, at: index)
    update(animated: animated)
  }
  private func append(_ button: FButton, animated: Bool) {
    let x = CGFloat(buttons.count) * boffset + offset
    button.frame.x = x
    display(button, animated: animated)
    buttons.append(button)
    update(animated: animated)
  }
  func remove(_ button: FButton, animated: Bool) {
    guard let index = buttons.index(of: button) else { return }
    buttons.remove(at: index)
    button.destroy(options: .slide, animated: animated)
    update(animated: animated)
  }
  
  func bounceButtons() {
    for (i,button) in buttons.enumerated() {
      wait(Double(i) * 0.1) {
        button.button.bounce()
      }
    }
  }
  func update(animated: Bool) {
    contentSize.width = CGFloat(buttons.count) * boffset + offset
    if contentSize.width > frame.width {
      if contentOffset.x == 0 {
        animateif(animated) {
          contentOffset.x = 0
          for (i,button) in buttons.enumerated() {
            button.frame.x = CGFloat(i) * boffset + offset
          }
        }
      }
    } else {
      let offset = (frame.width - contentSize.width) / 2
      animateif(animated) {
        for (i,button) in buttons.enumerated() {
          button.frame.x = CGFloat(i) * boffset + self.offset + offset
        }
      }
    }
    contentSizeChanged?()
  }
  override func resolutionChanged() {
    update(animated: false)
  }
}
