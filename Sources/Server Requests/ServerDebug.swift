//
//  ServerDebug.swift
//  Some Events
//
//  Created by Димасик on 10/20/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork

#if debug
let serverDebug = ServerDebugView()
class ServerDebugView: DFTextView {
  var isRunning = false {
    didSet {
      guard isRunning != oldValue else { return }
      if isRunning {
        update()
        main.readonlyLayer.addSubview(self)
      } else {
        self.removeFromSuperview()
      }
    }
  }
  var isUpdating = false
  
  init() {
    super.init(frame: screen.safeFrame, textContainer: nil)
    dframe = screen.dframeSafe
    isScrollEnabled = false
    isUserInteractionEnabled = false
    isEditable = false
    isSelectable = false
    backgroundColor = .clear
    font = .mono(10)
  }
  
  func update() {
    guard isRunning else { return }
    guard !isUpdating else { return }
    isUpdating = true
    
    var string = ""
    string.append(queue: mainQueue)
    string.append(queue: downloadQueue)
    string.append(queue: StreamQueue.upload)
    string.append(queue: StreamQueue.previewUpload)
    string.addLine("Notifications:")
    for notification in serverManager.notifications {
      string.addLine(notification)
    }
    
    if text != string {
      text = string
    }
    wait(0.1) {
      self.isUpdating = false
      self.update()
    }
  }
//
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension String {
  mutating func append(queue: Queue) {
    queue.debug(to: &self)
    addLine(queue.description)
    for stream in queue.streams.unique() {
      stream.writeDescription(to: &self)
    }
    addLine()
  }
}
#endif
