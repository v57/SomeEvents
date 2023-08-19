//
//  UISwitch.swift
//  Some
//
//  Created by Дмитрий Козлов on 02/09/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit

private var switchSize: CGSize?
extension UISwitch {
  public convenience init(pos: Pos, anchor: Anchor, on: Bool) {
    self.init(frame: .zero)
    self.move(pos,anchor)
    self.isOn = on
  }
  public class func size() -> CGSize {
    if let size = switchSize {
      return size
    } else {
      let view = UISwitch(frame: .zero)
      switchSize = view.frame.size
      return view.frame.size
    }
  }
}
