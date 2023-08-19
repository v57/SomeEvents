//
//  MinecraftView.swift
//  faggot
//
//  Created by Димасик on 06/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class MinV {
  let view: UIScrollView2
  private var blocks = [MB]()
  var blockWidth: CGFloat
  var w: Int
  init(frame: CGRect, blockSize: CGFloat) {
    w = Int(frame.width / blockSize)
    let fw = CGFloat(w)
    blockWidth = (frame.width) / fw
    
    view = UIScrollView2(frame: frame)
    view.alwaysBounceVertical = true
  }
  
  subscript(index: Int) -> MB {
    get {
      return blocks[index]
    }
    set {
      insert(newValue, index)
    }
  }
  
  func append(_ block: MB) {
    blocks.append(block)
  }
  
  private func insert(_ block: MB, _ index: Int) {
    
  }
  
  func remove(_ index: Int) {
    blocks.remove(at: index)
  }
  
  func index(_ block: MB) -> Int? {
    return blocks.index(of: block)
  }
  
  var count: Int {
    return blocks.count
  }
  
  private func pos(_ index: Int) -> CGPoint {
    let x = CGFloat(index % w)
    let y = CGFloat(index / w)
    return CGPoint(x * blockWidth, y * blockWidth)
  }
  
  private func getHeight(_ count: Int) -> CGFloat {
    let count = count - 1
    let h = CGFloat(count / w)
    return h * blockWidth
  }
}
func == (l:MB,r:MB) -> Bool {
  return l.view == r.view
}
class MB: Equatable {
  let view: UIView
  let size: CGFloat
  init(size: CGFloat) {
    self.size = size
    view = UIView(frame: CGRect(0,0,size,size))
  }
  
  func cp() -> MB {
    return MB(size: size)
  }
}
