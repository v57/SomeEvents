//
//  ScreenEditor.swift
//  Events
//
//  Created by Димасик on 5/19/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class ScreenEditor: UIView {
  init() {
    super.init(frame: CGRect(0,0,50,50))
    backgroundColor = .white
    circle()
    center = screen.resolution.bottomRight
  }
  
  func reset() {
    let size = UIScreen.main.bounds.size
    center = Pos(size.width,size.height)
    screen.resolution = size
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    var offset = touches.first!.location(in: self)
    offset -= touches.first!.previousLocation(in: self)
    center += offset
    var pos = centerPositionOnScreen
    pos.x = max(pos.x,320)
    pos.y = max(pos.y,320)
    screen.resolution = CGSize(pos.x,pos.y)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
