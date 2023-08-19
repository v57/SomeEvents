//
//  EventPreview.top.swift
//  faggot
//
//  Created by Димасик on 3/24/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class EPTopView: EPBlock {
  static let height: CGFloat = 205
  
  let imageView: UIImageView
  let blur: UIVisualEffectView
  
  let topView: UIView
  let nameLabel: UILabel
  
  let bodyView: UIView
  let starView: UIImageView
  
  var playButton: UIButton
  var stopButton: UIButton
  
  var startedTitle: UILabel
  var startedLabel: UILabel
  
  var endedTitle: UILabel
  var endedLabel: UILabel
  
  let height: CGFloat = EPTopView.height
  
  let playX: CGFloat = 168
  let stopX: CGFloat = 243
  let buttonY: CGFloat = 42.5
  let titleY: CGFloat = 77
  let dateY: CGFloat = 103
  
  init(page: EventPreview) {
    let event = page.event
    
    imageView = UIImageView(frame: CGRect(0,0,EventPreview.width,height))
    imageView.backgroundColor = .white
    imageView.isOpaque = true
    let effect = UIBlurEffect(style: .extraLight)
    blur = UIVisualEffectView(effect: effect)
    blur.frame = imageView.frame
    
    topView = UIView(frame: CGRect(0,0,EventPreview.width ,30))
    topView.backgroundColor = UIColor(white: 0, alpha: 0.1)
    nameLabel = UILabel(frame: CGRect(14,0,EventPreview.width-28,30), text: page.event.name, font: .light(18), color: .black, alignment: .left)
    bodyView = UIView(frame: CGRect(0,30,EventPreview.width,height-30))
    
    starView = UIImageView(image: #imageLiteral(resourceName: "EPStar"))
    starView.frame.origin = Pos(19,15)
    
    let playIcon: UIImage = event.status == .started ? #imageLiteral(resourceName: "EPPause") : #imageLiteral(resourceName: "EPResume")
    playButton = UIButton(pos: Pos(playX,buttonY), anchor: .center, image: playIcon)
    playButton.systemHighlighting()
    stopButton = UIButton(pos: Pos(stopX,buttonY), anchor: .center, image: #imageLiteral(resourceName: "EPStop"))
    stopButton.systemHighlighting()
    
    startedTitle = UILabel(pos: Pos(playX,titleY), anchor: .center, text: "Started", color: .black, font: .normal(14))
    startedLabel = UILabel(pos: Pos(playX,dateY), anchor: .center, text: EPTopView.format(time: event.startTime), color: .darkGray, font: .normal(14))
    startedLabel.numberOfLines = 2
    
    endedTitle = UILabel(pos: Pos(stopX,titleY), anchor: .center, text: "Ended", color: .black, font: .normal(14))
    endedLabel = UILabel(pos: Pos(stopX,dateY), anchor: .center, text: EPTopView.format(time: event.endTime), color: .darkGray, font: .normal(14))
    endedLabel.numberOfLines = 2
    
    super.init(frame: CGRect(0,0,EventPreview.width,height), page: page)
    
    playButton.add(target: self, action: #selector(pause))
    stopButton.add(target: self, action: #selector(stop))
    
    imageView.event(page, event: page.event, preset: .none)
    
//    addSubview(imageView)
//    addSubview(blur)
    addSubview(topView)
    topView.addSubview(nameLabel)
    addSubview(bodyView)
    bodyView.addSubview(starView)
    
    
    if event.status != .ended {
      bodyView.addSubview(playButton)
      bodyView.addSubview(stopButton)
    }
    
    if event.startTime > 0 {
      bodyView.addSubview(startedTitle)
      bodyView.addSubview(startedLabel)
    }
    if event.status == .ended {
      bodyView.addSubview(endedTitle)
      bodyView.addSubview(endedLabel)
    }
    
    updateLabelPositions()
    
    page.addSubview(self)
    
    
    startedTitle.addTap(self, #selector(changeStarted))
    startedLabel.addTap(self, #selector(changeStarted))
    
    endedTitle.addTap(self, #selector(changeEnded))
    endedLabel.addTap(self, #selector(changeEnded))
  }
  
  func startTimeChanged() {
    startedLabel.text = EPTopView.format(time: event.startTime)
  }
  
  func endTimeChanged() {
    endedLabel.text = EPTopView.format(time: event.endTime)
  }
  
  func statusChanged() {
    let event = page.event
    
    if event.status != .ended {
      if event.status == .started {
        playButton.setImage(#imageLiteral(resourceName: "EPPause"), for: .normal)
      } else {
        playButton.setImage(#imageLiteral(resourceName: "EPResume"), for: .normal)
      }
      bodyView.addSubviewSafe(playButton)
      bodyView.addSubviewSafe(stopButton)
    } else {
      playButton.removeFromSuperview()
      stopButton.removeFromSuperview()
    }
    
    if event.startTime > 0 {
      startedLabel.text = EPTopView.format(time: event.startTime)
      bodyView.addSubviewSafe(startedTitle)
      bodyView.addSubviewSafe(startedLabel)
    } else {
      startedTitle.removeFromSuperview()
      startedLabel.removeFromSuperview()
    }
    if event.status == .ended {
      endedLabel.text = EPTopView.format(time: event.endTime)
      endedLabel.fixFrame(true)
      bodyView.addSubviewSafe(endedTitle)
      bodyView.addSubviewSafe(endedLabel)
    } else {
      endedTitle.removeFromSuperview()
      endedLabel.removeFromSuperview()
    }
    
    updateLabelPositions()
    
    var a: [UIView] = [playButton,startedTitle,startedLabel]
    a = a.filter({$0.superview != nil})
  }
  
  var changing = false
  
  @objc func changeStarted() {
    guard !changing else { return }
    let picker = DatePicker(time: event.startTime)
    picker.completion = { [unowned self] date in
      self.change(start: date.time, end: self.event.endTime, view: self.startedLabel)
    }
    page.push(picker)
  }
  
  @objc func changeEnded() {
    guard !changing else { return }
    let picker = DatePicker(time: event.endTime)
    picker.completion = { [unowned self] date in
      self.change(start: self.event.startTime, end: date.time, view: self.endedLabel)
    }
    page.push(picker)
  }
  
  func change(start: Time, end: Time, view: UIView) {
    changing = true
    view.alpha = 0
    let loader = DownloadingView(center: view.center)
    loader.animating = true
    view.superview?.addSubview(loader)
    event.changeTime(start: start, end: end)
      .autorepeat(page)
      .onComplete { [weak self] in
        view.alpha = 1
        loader.animating = false
        loader.removeFromSuperview()
        self?.changing = false
    }
  }
  
  func updateLabelPositions() {
    if playButton.superview == nil && stopButton.superview == nil {
      startedTitle.center.y = titleY - 25
      endedTitle.center.y = titleY - 25
      startedLabel.center.y = dateY - 25
      endedLabel.center.y = dateY - 25
    } else {
      startedTitle.center.y = titleY
      endedTitle.center.y = titleY
      startedLabel.center.y = dateY
      endedLabel.center.y = dateY
    }
  }
  
  @objc func pause() {
    let event = page.event
    if event.status == .started {
      event.pause()
      .autorepeat(page)
    } else if event.status == .paused {
      event.start()
      .autorepeat(page)
    }
  }
  
  @objc func stop() {
    let event = page.event
    guard event.status == .started || event.status == .paused else { return }
    event.stop()
    .autorepeat(page)
  }
  
  
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  static func format(time: Time) -> String {
    guard time != 0 else { return "" }
    let date = time.date
    let df = DateFormatter()
    df.dateFormat = "dd MMM"
    var result = df.string(from: date)
    df.timeStyle = .short
    result += "\n"
    result += df.string(from: date)
    return result.lowercased()
  }
  
  class DatePicker: EventPreview.Subpage {
    let view: UIDatePicker
    lazy var timeView: UIDatePicker = { [unowned self] in
      let view = UIDatePicker()
      view.datePickerMode = .time
      view.maximumDate = Date()
      self.insertSubview(view, aboveSubview: self.view)
      return view
    }()
    var completion: ((Date)->())?
    let doneButton: DPButton
    let cancelButton: DPButton
    let time: Time
    var secondPage = false {
      didSet {
        guard secondPage != oldValue else { return }
        let offset = frame.width
        if secondPage {
          timeView.frame = bounds
          timeView.frame.x += offset
          timeView.setDate(view.date, animated: false)
          doneButton.setTitle("Done", for: .normal)
          cancelButton.setTitle("Back", for: .normal)
          animate {
            timeView.frame.x -= offset
            view.frame.x -= offset
          }
        } else {
          view.frame = bounds
          view.frame.x -= offset
          doneButton.setTitle("Next", for: .normal)
          cancelButton.setTitle("Cancel", for: .normal)
          animate {
            view.frame.x += offset
            timeView.frame.x += offset
          }
        }
      }
    }
    init(time: Time) {
      self.time = time
      view = UIDatePicker()
      view.datePickerMode = .date
      view.maximumDate = Date()
      view.setDate(time.date, animated: false)
      
      doneButton = DPButton(text: "Next", font: UIFont.title3.semibold, color: .system)
      cancelButton = DPButton(text: "Cancel", font: .title3, color: .system)
      
      super.init()
      
      doneButton.addTap(self, #selector(done))
      cancelButton.addTap(self, #selector(cancel))
      
      addSubview(view)
      addSubview(cancelButton)
      addSubview(doneButton)
    }
    
    @objc func done() {
      if secondPage {
        completion?(timeView.date)
        back()
      } else {
        secondPage = true
      }
    }
    
    @objc func cancel() {
      if secondPage {
        secondPage = false
      } else {
        back()
      }
    }
    
    override var frame: CGRect {
      didSet {
        guard frame.size != oldValue.size else { return }
        doneButton.move(Pos(frame.width - 12, 12), .topRight)
        cancelButton.move(Pos(12, 12), .topLeft)
        if secondPage {
          timeView.frame = bounds
        } else {
          view.frame = bounds
        }
      }
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

