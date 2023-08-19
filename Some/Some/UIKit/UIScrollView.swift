//
//  UIScrollView.swift
//  SomeUI
//
//  Created by Димасик on 5/9/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import UIKit

open class UIScrollView2: UIScrollView {
  public init() {
    super.init(frame: .zero)
    ios11()
  }
  public override init(frame: CGRect) {
    super.init(frame: frame)
    ios11()
  }
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func ios11() {
    if #available(iOS 11.0, *) {
      contentInsetAdjustmentBehavior = .never
    }
  }
}

public extension UIScrollView {
  var offsetTop: CGFloat {
    return contentOffset.y + contentInset.top
  }
  var page: Int {
    return Int(round(contentOffset.x / frame.w))
  }
  var isScrollable: Bool {
    var a = contentSize.height
    a += contentInset.top
    a += contentInset.bottom
    return a > frame.h
  }
  func scrollToTop() {
    contentOffset.y = 0
  }
  func scrollToBottom() {
    if contentSize.height > bounds.h - contentInset.bottom {
      contentOffset.y = contentSize.height + contentInset.bottom - frame.h
    }
  }
}
