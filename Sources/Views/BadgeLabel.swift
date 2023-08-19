//
//  BadgeLabel.swift
//  faggot
//
//  Created by Димасик on 4/10/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class BadgeLabel: DPLabel {
  init(text: String) {
    super.init(frame: .zero)
    self.text = text.uppercased()
    font = .normal(10)
    textAlignment = .center
    backgroundColor = .black
    update()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func set(text: String) {
    let text = text.uppercased()
    self.text = text
    update()
  }
  private func update() {
    sizeToFit()
    frame.w += 4
    frame.h += 3
    guard let (pos,anchor) = dpos?() else { return }
    move(pos, anchor)
  }
}
