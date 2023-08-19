//
//  PageReports.swift
//  Events
//
//  Created by Димасик on 2/9/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class ReportsPage: Page {
  override init() {
    super.init()

    let report = EventReport()
    report.acceptedCount = .random(max: 10)
    report.declinedCount = .random(max: 10)
    
    let view = ReportView.Event(report: report)
    view.center = screen.center
    addSubview(view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class ReportView: UIView {
  class var height: CGFloat {
    return 60 + 20
  }
  
  let titleLabel: UILabel
  let action: ReportActionButton
  
  init(title: String, report: Report) {
    titleLabel = UILabel(text: title, color: .black, font: .normal(12))
    titleLabel.center.x = screen.center.x
    action = ReportActionButton()
    action.accept.count = report.acceptedCount
    action.decline.count = report.declinedCount
    action.move(Pos(screen.width - .margin, 24), .topRight)
    super.init(frame: CGRect(0,0,screen.width,ReportView.height))
    addSubviews(titleLabel,action)
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    frame.size = CGSize(screen.width,ReportView.height)
    titleLabel.center.x = screen.center.x
    action.move(x: screen.width - .margin, .right)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  class Event: ReportView {
    let openButton: DFButton2
    let report: EventReport
    init(report: EventReport) {
      openButton = DFButton2(text: "Open")
      self.report = report
      super.init(title: "Event: \(report.id.eventName)", report: report)
      openButton.move(Pos(30,action.center.y), .left)
      addSubview(openButton)
      
      openButton.touch {
        let event = report.id.event!
        let page = EventPage(event: event)
        main.push(page)
      }
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  class Content: ReportView {
    let openButton: DFButton2
    let report: ContentReport
    init(report: ContentReport) {
      openButton = DFButton2(frame: CGRect(origin: .zero, size: Size(30,30)))
      self.report = report
      super.init(title: "Content", report: report)
      openButton.move(Pos(30,action.center.y),.left)
      addSubview(openButton)
      
      openButton.touch {
        guard let event = report.event else { return }
        guard let content = report.content else { return }
        let page = Previews(event: event, content: content)
        main.push(page)
      }
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
}

class ReportActionButton: UIView {
  let decline = Button(title: "Decline")
  let accept = Button(title: "Accept")
  
  var declineAction: (()->())?
  var acceptAction: (()->())?
  
  init() {
    accept.frame.x += 90
    super.init(frame: CGRect(0,0,180,60))
    
    addBackground(radius: .margin)
    layer.masksToBounds = true
    
    addSubviews(decline,accept)
    
    decline.selected = { [unowned self] in
      self.accept.isSelected = false
      self.accept.title = "Accept"
      self.decline.title = "Declined"
      self.declineAction?()
    }
    accept.selected = { [unowned self] in
      self.decline.isSelected = false
      self.accept.title = "Accepted"
      self.decline.title = "Decline"
      self.acceptAction?()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  class Button: DFView {
    let titleLabel: UILabel
    let countLabel: UILabel
    var title: String {
      get { return titleLabel.text! }
      set { titleLabel.set(text: newValue, anchor: .center) }
    }
    var count = 0 {
      didSet {
        guard count != oldValue else { return }
        countLabel.set(text: "\(count)", anchor: .center)
      }
    }
    var isSelected = false {
      didSet {
        guard isSelected != oldValue else { return }
        if isSelected {
          selected?()
          bounce()
          count += 1
          animate {
            titleLabel.textColor = .white
            countLabel.textColor = .white
            backgroundColor = .system
          }
        } else {
          count -= 1
          animate {
            titleLabel.textColor = .black
            countLabel.textColor = .black
            backgroundColor = .clear
          }
        }
        
      }
    }
    var selected: (()->())?
    init(title: String) {
      let width: CGFloat = 90
      let height: CGFloat = 60
      titleLabel = UILabel(text: title, color: .black, font: .normal(14))
      titleLabel.textAlignment = .center
      titleLabel.center.x = 45
      countLabel = UILabel(text: "0", color: .black, font: .bold(18))
      countLabel.textAlignment = .center
      countLabel.center.x = 45
      super.init(frame: CGRect(0,0,width,height))
      backgroundColor = .clear
      centerViewsVertically([countLabel,titleLabel],offset:0)
      addSubviews(countLabel,titleLabel)
      addTap(#selector(tap))
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    @objc func tap() {
      isSelected = true
    }
  }
}
