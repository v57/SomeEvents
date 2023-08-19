//
//  date-picker.swift
//  Some Events
//
//  Created by Димасик on 7/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class DatePicker: Page {
  let view: UIDatePicker
  var completion: ((Date)->())?
  let doneButton: DPButton
  let cancelButton: DPButton
  lazy var yearLabel: UILabel = { [unowned self] in
    let label = UILabel(text: "", color: .black, font: .title1)
    label.move(Pos(self.frame.w/2,doneButton.center.y), .center)
    self.addSubview(label)
    return label
  }()
  let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
  var year: Int = Time.now.year
  var time: Time {
    get { return view.date.time }
    set { view.date = newValue.date }
  }
  override var isFullscreen: Bool {
    return false
  }
  override var screenFrame: DFrame {
    return {
      CGRect(screen.center, .center, CGSize(EventPreview.width,320))
    }
  }
  override init() {
    view = UIDatePicker(frame: screen.frame)
    view.datePickerMode = .dateAndTime
    
    doneButton = DPButton(text: "Done")
    cancelButton = DPButton(text: "Cancel")
    
    super.init()
    
    doneButton.onTouch { [unowned self] in
      self.done()
    }
    cancelButton.onTouch { [unowned self] in
      self.cancel()
    }
    
    layer.cornerRadius = 20
    layer.borderColor = UIColor.lightGray.cgColor
    layer.borderWidth = screen.pixel
    
    addSubview(blurView)
    addSubview(view)
    addSubview(cancelButton)
    addSubview(doneButton)
    
    showsBackButton = false
  }
  
  func done() {
    completion?(view.date)
    main.back()
  }
  
  func cancel() {
    main.back()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    blurView.frame = bounds
    var f = bounds
    f.y += 50
    f.h -= 50
    view.frame = f
    doneButton.move(Pos(frame.w - .margin, 10),.topRight)
    cancelButton.move(Pos(.margin, 10),.topLeft)
  }
}
