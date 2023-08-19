//
//  CameraControls.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class CameraButtons: DPView {
  static let margin: CGFloat = 15
  static let offset: CGFloat = 16
  static let buttonSize: CGFloat = 40
  
  static var firstCenter = margin + buttonSize / 2
  static var buttonOffset = buttonSize + offset
  static func size(with count: Int) -> CGFloat {
    var size = margin * 2
    size += buttonSize * CGFloat(count)
    size += offset * CGFloat(count - 1)
    return size
  }
  
  
  var buttons: [[UIView?]]
  init(buttons: [[UIView?]]) {
    
    self.buttons = buttons
    let width = CameraButtons.size(with: buttons.count)
    let height = CameraButtons.size(with: buttons[0].count)
    super.init(frame: CGRect(0,0,width,height))
    clipsToBounds = true
    layer.cornerRadius = 20
    backgroundColor = .black(0.5)
    
    var y: CGFloat = CameraButtons.firstCenter
    var x: CGFloat = CameraButtons.firstCenter
    for row in buttons {
      for button in row {
        if let button = button {
          button.center = Pos(x,y)
          addSubview(button)
        }
        y += CameraButtons.buttonOffset
      }
      y = CameraButtons.firstCenter
      x += CameraButtons.buttonOffset
    }
  }
  
  func lift(_ x: CGFloat, _ y: CGFloat) {
    let ox = CameraButtons.buttonOffset * x
    let oy = CameraButtons.buttonOffset * y
    var frame = self.frame
    frame.y -= oy
    frame.x -= ox
    frame.w += ox
    frame.h += oy
    self.frame = frame
    
    for row in buttons {
      for button in row {
        button?.frame.origin += Pos(ox,oy)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

class CaptureButton: DCView {
  var capturing = false {
    didSet {
      guard capturing != oldValue else { return }
      if capturing {
        view.set(cornerRadius: 12)
        jellyAnimation {
          self.view.scale(0.5)
        }
      } else {
        animate {
          self.view.scale(1.0)
        }
        view.set(cornerRadius: view.frame.height / 2)
      }
    }
  }
  enum CaptureType {
    case photo, video
  }
  let view: UIView
  let button: UIButton
  private var handler: (()->())?
  init(type: CaptureType) {
    view = UIView(frame: CGRect(0,0,36,36))
    button = UIButton(image: #imageLiteral(resourceName: "CVideo"))
    super.init(frame: button.frame)
    view.center = bounds.center
    switch type {
    case .photo: view.backgroundColor = .white
    case .video: view.backgroundColor = .red
    }
    view.circle()
    button.add(target: self, action: #selector(tap))
    addSubview(view)
    addSubview(button)
  }
  
  func touch(_ v: @escaping ()->()) {
    self.handler = v
  }
  
  @objc func tap() {
    handler?()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
