//
//  FShare.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class FShare: Block {
  let view: UIView
  let leftButton: UIButton
//  let rightButton: UIButton
//  let line: UIView
  init() {
    let w: CGFloat = 200 //screen.right - .margin2 - screen.left
//    w = min(w,250)
    let w2 = w
    let h: CGFloat = 60
    leftButton = UIButton(frame: CGRect(0,0,w2,h))
    leftButton.setTitleColor(.black, for: .normal)
    leftButton.setTitle("Share this app", for: .normal)
    leftButton.setImage(#imageLiteral(resourceName: "FAppLink"), for: .normal)
    leftButton.titleEdgeInsets.left = .margin
    leftButton.titleEdgeInsets.right = .miniMargin
    leftButton.imageEdgeInsets.left = .miniMargin
    leftButton.imageEdgeInsets.right = .margin
    leftButton.systemHighlighting()
    leftButton.titleLabel!.autoresizeFont()
    
//    rightButton = UIButton(frame: CGRect(w2,0,w2,h))
//    rightButton.setTitleColor(.black, for: .normal)
//    rightButton.setTitle("Share profile link", for: .normal)
//    rightButton.setImage(#imageLiteral(resourceName: "FProfileLink"), for: .normal)
//    rightButton.titleEdgeInsets.left = .margin
//    rightButton.titleEdgeInsets.right = .miniMargin
//    rightButton.imageEdgeInsets.left = .miniMargin
//    rightButton.imageEdgeInsets.right = .margin
//    rightButton.imageEdgeInsets.bottom = 5
//    rightButton.systemHighlighting()
//    rightButton.titleLabel!.adjustsFontSizeToFitWidth = true
//    rightButton.titleLabel!.minimumScaleFactor = 0.5
//
//    line = UIView(frame: CGRect(w2,0,screen.pixel,h))
//    line.backgroundColor = .black(0.1)
    
    view = UIView(frame: CGRect(screen.left + .margin, .miniMargin, w, h))
    view.addBackground(radius: 18)
    
    super.init(height: 60 + .miniMargin2)
    
    addSubview(view)
//    view.addSubview(line)
    view.addSubview(leftButton)
//    view.addSubview(rightButton)
    
    leftButton.add(target: self, action: #selector(left))
  }
  
//  override func resolutionChanged() {
//    var w: CGFloat = screen.right - .margin2 - screen.left
//    w = min(w,250)
//    let w2 = w//w/2
//    leftButton.frame.width = w2
////    rightButton.frame.x = w2
////    rightButton.frame.width = w2
////    line.frame.x = w2
//    view.frame.width = w
//  }
  
  @objc func left() {
    let s = "https://itunes.apple.com/us/app/some-events/id1249298110?ls=1&mt=8"
    let url = URL(string: s)!
    Export.share(url: url)
  }
  
  func right() {
    let s = "http://\(address.ip)/users/\(ID.me)"
    let url = URL(string: s)!
    Export.share(url: url)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
