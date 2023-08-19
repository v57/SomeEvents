//
//  CameraTimer.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class TimerView: DPView2 {
  var started = 0.0
  let recordingLabel: UILabel
  let label: Label
  override init() {
    let width = CameraButtons.size(with: 2)
    let height = CameraButtons.size(with: 1)
    let labelWidth: CGFloat = width - .margin2
    let rfont: UIFont = .normal(14)
    recordingLabel = UILabel(frame: CGRect(.margin,.miniMargin,labelWidth,rfont.lineHeight), text: "Recording", font: rfont, color: .white, alignment: .center)
    recordingLabel.autoresizeFont()
    
    let ly: CGFloat = recordingLabel.frame.bottom.y
    
    label = Label(frame: CGRect(.margin,recordingLabel.frame.bottom.y,labelWidth,height - ly), text: "00:00:00", font: .monoNumbers(18), color: .light, alignment: .center)
    label.autoresizeFont()
    super.init(frame: CGRect(size: CGSize(width,height)))
    backgroundColor = .black(0.5)
    layer.cornerRadius = 20
    
    addSubview(recordingLabel)
    addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private var version = 0
  func start() {
    version += 1
    started = Time.abs
    tick()
  }
  func end() {
    version += 1
  }
  func tick() {
    let version = self.version
    let time = Time.abs
    let seconds = Int(time - started)
    let minutes = seconds / 60
    let hours = minutes / 60
    
    let s = seconds%60
    let m = minutes%60
    
    if hours < 0 {
      
    }
    
    let sec = s < 10 ? "0\(s)" : String(s)
    let min = m < 10 ? "0\(m)" : String(m)
    
    if hours > 0 {
      let hr = hours < 10 ? "0\(hours)" : String(hours)
      label.text = "\(hr):\(min):\(sec)"
    } else {
      label.text = "\(min):\(sec)"
    }
    wait(0.1) {
      if version == self.version {
        self.tick()
      }
    }
  }
}

extension Time {
  var duration: String {
    let minutes = self / 60
    let hours = minutes / 60
    
    let s = self%60
    let m = minutes%60
    
    if hours < 0 {
      
    }
    
    let sec = s < 10 ? "0\(s)" : String(s)
    let min = m < 10 ? "0\(m)" : String(m)
    
    if hours > 0 {
      let hr = hours < 10 ? "0\(hours)" : String(hours)
      return "\(hr):\(min):\(sec)"
    } else {
      return "\(min):\(sec)"
    }
  }
}
