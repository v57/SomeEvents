//
//  EventDownloadNotification.swift
//  SomeEvents
//
//  Created by Димасик on 12/4/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class NEventDownload: LoadingNView {
  override var doneText: String {
    return "Event downloaded"
  }
  
  let export: Export
  init(progress: Export) {
    self.export = progress
    super.init(progress: progress, title: "Downloading event")
  }
  
  override func tap() {
    if export.isCompleted {
      hide(animated: true)
      export.openMenu()
    } else {
      animate {
        isMinimized = false
      }
      resetMinimize()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

