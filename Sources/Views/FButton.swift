//
//  FButton.swift
//  faggot
//
//  Created by Димасик on 06/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

extension PageTransition {
  static func from(button: FButton) -> PageTransition {
    let settings = FromViewSettings()
    settings.view = button.button
    settings.cornerRadius = button.button.frame.width/2
    return .from(view: settings)
  }
}

private let buttonSize = Size(FButton.width,FButton.height)
private let image = ImageEditor.circle(buttonSize, fillColor: .background, strokeColor: nil, lineWidth: 0)


class FButton: DCView {
  static var width: CGFloat = 60
  static var height: CGFloat = 60
  static var cornerRadius: CGFloat = 30
  let button: UIButton
  let label: UILabel
  var loading = false
  var position: Int // position in FButtonList
  private var action: (()->())!
  convenience init(text: String, icon: UIImage = image, position: Int = -1) {
    self.init(pos: .zero, .topLeft, text: text, icon: icon, position: position)
  }
  
  let size: CGSize
  init(pos: Pos, _ anchor: Anchor, text: String, icon: UIImage = image, position: Int = -1) {
    self.size = icon.size
    self.position = position
    let text = text.uppercased()
    let font = UIFont.normal(10)
    let labelSize = (text as NSString).size(withAttributes: [.font: font])
    
    button = UIButton(type: .system)
    button.systemHighlighting()
    button.setImage(icon, for: .normal)
    button.frame = CGRect(origin: Pos(), size: size)
    
    label = UILabel(frame: Rect(Pos(size.width/2,size.height),_top,labelSize), text: text, font: font, color: .dark, alignment: .center)
    label.numberOfLines = 0
    
    super.init(frame: Rect(pos,anchor,CGSize(size.width,size.height + 40)))
    
    addSubview(button)
    addSubview(label)
    
    button.add(target: self, action: #selector(tap))
  }
  
  var text: String {
    get {
      return label.text!
    } set {
      label.animateText = newValue.uppercased()
      label.fixFrame(true)
      label.move(Pos(size.width/2,size.height), .top)
    }
  }
  
  @objc func tap() {
    action?()
  }
  
  func touch(_ action: @escaping ()->()) {
    guard !loading else { return }
    self.action = action
  }
  func open(page: @escaping ()->Page) {
    guard !loading else { return }
    action = { [unowned self] in
      let p = page()
      p.transition = .from(button: self)
      main.push(p)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
