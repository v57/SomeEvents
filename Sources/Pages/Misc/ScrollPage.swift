//
//  ScrollPage.swift
//  faggot
//
//  Created by Димасик on 21/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class ScrollPage: Page, UIScrollViewDelegate {
  let scrollView: DFScrollView
  var bottomInset: CGFloat = 0
  var topInset: CGFloat = 0
  override init() {
    scrollView = DFScrollView(frame: .zero)
    scrollView.dframe = { screen.frame }
    super.init()
    scrollView.delegate = self
    addSubview(scrollView)
  }
  
  override func orientationChanged() {
    super.orientationChanged()
    updateInsets()
  }
  override func keyboardMoved() {
    super.keyboardMoved()
    updateInsets()
  }
  
  func updateInsets() {
    scrollView.contentInset = UIEdgeInsetsMake(topInset + screen.statusBarHeight, 0, bottomInset + keyboardHeight, 0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
