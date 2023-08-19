//
//  HelpManager.swift
//  faggot
//
//  Created by Димасик on 07/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

private var helpBackground: UIImage!
private let cornerRadius: CGFloat = 20

class InfoButton: UIView {
  let button: UIButton
  let help: Help
  init(pos: Pos, anchor: Anchor, help: Help) {
    self.help = help
    button  = UIButton(type: .infoDark)
    super.init(frame: Rect(pos,anchor,button.frame.size))
    tintColor = .dark
    addSubview(button)
    button.add(target: self, action: #selector(tap))
  }
  
  @objc func tap() {
    help.show()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

class Help {
  var pos = Pos()
  var anchor = Anchor()
  func append(_ button: HelpButton) {
    button.rect = Rect(button.position,button.anchor,button.size)
    buttons.append(button)
  }
  func show() {
    if view == nil {
      generateImage()
      view = HelpView(pos: pos, anchor: anchor, image: backgroundImage, buttons: buttons)
    }
    main.view.display(view)
  }
  
  private var view: HelpView!
  
  private var buttons = [HelpButton]()
  private var backgroundImage: UIImage!
  private func generateImage() {
    guard backgroundImage == nil else { return }
    let size = screen.resolution
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(UIColor.white.cgColor)
    for button in buttons {
      let path = CGPath(roundedRect: button.rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
      context!.addPath(path)
    }
    context!.drawPath(using: CGPathDrawingMode.fill)
    let mask = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    drawBackground()
    backgroundImage = ImageEditor.createMask(helpBackground.cgImage!, mask: (mask?.cgImage!)!).ui
  }
  private func drawBackground() {
    guard helpBackground == nil else { return }
    UIGraphicsBeginImageContextWithOptions(screen.resolution, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(UIColor(white: 0, alpha: 0.6).cgColor)
    context!.fill(screen.frame)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    helpBackground = image
  }
}

private class HelpView: UIView {
  let backgroundView = UIImageView(frame: screen.frame)
  let buttons: [HelpButton]
  init(pos: Pos, anchor: Anchor, image: UIImage, buttons: [HelpButton]) {
    self.buttons = buttons
    backgroundView.image = image
    super.init(frame: screen.frame)
    addSubview(backgroundView)
  }
  
  var selectedButton = -1
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    selectedButton = -1
    guard let pos = touches.first?.location(in: self) else { return }
    for (i,button) in buttons.enumerated() {
      if button.rect.contains(pos) {
        selectedButton = i
        break
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let pos = touches.first?.location(in: self) else { return }
    if selectedButton != -1 {
      let button = buttons[selectedButton]
      if button.rect.contains(pos) {
        currentHelp = selectedButton
      }
    } else {
      currentHelp = -1
    }
  }
  
  var currentView: UIView!
  var currentHelp = -1 {
    didSet {
      if currentHelp != oldValue {
        if currentHelp != -1 {
          let button = buttons[currentHelp]
          showView(button)
        } else {
          hideView()
        }
      }
    }
  }
  
  func hideView() {
    guard currentView != nil else { return }
    currentView = currentView.destroy()
  }
  
  func showView(_ button: HelpButton) {
    hideView()
    currentView = UIView(frame: button.rect)
    currentView.layer.cornerRadius = cornerRadius
    currentView.layer.borderColor = UIColor.yellow.cgColor
    currentView.layer.borderWidth = 2
    display(currentView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class HelpButton {
  var title: String!
  var text: String!
  var position = Pos()
  var size = Size()
  var anchor = _center
  var view: (() -> UIView)!
  fileprivate var rect = Rect()
  fileprivate var _view: UIView!
  private func getView() -> UIView! {
    if view != nil {
      if _view == nil {
        _view = view()
      }
      return _view
    } else {
      return nil
    }
  }
}

