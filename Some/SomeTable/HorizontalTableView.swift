//
//  HorizontalTableView.swift
//  Table-final 2
//
//  Created by Димасик on 5/9/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import Some

public class HorizontalTableView: TableView {
  override public var isHorizontal: Bool { return true }
  override public func viewToLoad(frame: CGRect) -> UIView {
    let scrollView = super.viewToLoad(frame: frame) as! ScrollView
    scrollView.alwaysBounceVertical = false
    scrollView.alwaysBounceHorizontal = true
    return scrollView
  }
  override var contentOffset: CGFloat {
    return scrollView!.contentOffset.x
  }
  override var contentHeight: CGFloat {
    get { return contentSize.width }
    set { contentSize.width = newValue }
  }
  override var topInset: CGFloat {
    return cameraInset.left
  }
  override var bottomInset: CGFloat {
    return cameraInset.right
  }
  override func offset(for cell: TableCell) -> CGFloat {
    return cell.position.x
  }
  override var frameHeight: CGFloat {
    return size.width
  }
  override func set(offset: CGFloat, for cell: TableCell) {
    cell.position.x = offset
  }
  override func height(for cell: TableCell) -> CGFloat {
    return cell.size.width
  }
}
