//
//  DownloadButton.swift
//  Some Events
//
//  Created by Димасик on 7/28/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class DownloadButton: DCButton {
  weak var progress: ProgressProtocol?
  var resume: (()->())?
  var pause: (()->())?
  let loader: DownloadingView
  let followInterval = 0.5
  init() {
    loader = DownloadingView(center: Pos(20,20))
    super.init(frame: CGRect(0,0,40,40))
    addSubview(loader)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func follow(progress: ProgressProtocol) {
    self.progress = progress
    tick()
  }
  
  var ticking = false
  func tick() {
    guard !ticking else { return }
    guard let progress = progress else {
      ticking = false
      return }
    ticking = true
    if progress.completed == 0 {
      loader.animating = true
    } else {
      CATransaction.begin()
      CATransaction.setAnimationDuration(followInterval)
      loader.value = progress.value()
      CATransaction.commit()
    }
    wait(5) {
      self.ticking = false
      self.tick()
    }
  }
}
