//
//  Map EventView.swift
//  faggot
//
//  Created by Димасик on 19/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class MapEventView: View {
  let name: DCLabel
  let icon: DCImageView
  
  let event: Event
  init(event: Event) {
    
    comments = UILabel(pos: Pos(35, screen.height - 80), anchor: .left, text: String(event.commentsCount), color: .black, font: .normal(12))
    
    self.event = event
    icon = DCImageView("MEIcon")
    icon.dcenter = { screen.center }
    icon.isUserInteractionEnabled = true
    name = DCLabel(frame: CGRect(screen.center.x,screen.center.y - 100,0,0), text: event.name, font: .ultraLight(36), color: .dark, alignment: .center, fixHeight: true)
    name.dcenter = { Pos(screen.center.x,screen.center.y - 100) }
    super.init()
    icon.addTap(self, #selector(tap))
    addSubviews(icon, name)
    
    setup()
  }
  
  @objc func tap() {
    let page = EventPage(event: event)
    let settings = FromViewSettings()
    settings.view = icon
    settings.isTransparent = true
    page.transition = .from(view: settings)
    main.push(page)
//    main.push(page, from: icon, cornerRadius: nil)
  }
  
  func setup() {
    showsViews = event.views > 0
    showsCurrent = event.current > 0
    showsComments = event.commentsCount > 0
    showsStartTime = event.startTime > 0
    showsEndTime = event.endTime > 0
  }
  
  
  var viewsIcon: UIImageView!
  var viewsLabel: Label!
  var showsViews = false {
    didSet {
      if showsViews != oldValue {
        if showsViews {
          viewsIcon = UIImageView("MEViews")
          viewsIcon.move(Pos(15,screen.height - 120), .left)
          viewsLabel = Label(frame: CGRect(35, screen.height - 120,0,0), text: String(event.views), font: .light(12), color: .dark, alignment: .left, fixHeight: true)
          display(viewsIcon)
          display(viewsLabel)
        } else {
          viewsIcon = viewsIcon.destroy()
          viewsLabel = viewsLabel.destroy()
        }
      }
    }
  }
  var currentIcon: UIImageView!
  var currentLabel: Label!
  var showsCurrent = false {
    didSet {
      if showsCurrent != oldValue {
        if showsCurrent {
          currentIcon = UIImageView("MECurrent")
          currentIcon.move(Pos(15,screen.height - 100), .left)
          currentLabel = Label(frame: CGRect(35, screen.height - 100,0,0), text: String(event.current), font: .light(12), color: .dark, alignment: .left, fixHeight: true)
          display(currentIcon)
          display(currentLabel)
        } else {
          currentIcon = currentIcon.destroy()
          currentLabel = currentLabel.destroy()
        }
      }
    }
  }
  
  let comments: UILabel
  var commentsIcon: UIImageView!
  var commentsLabel: Label!
  var showsComments = false {
    didSet {
      if showsComments != oldValue {
        if showsComments {
          commentsIcon = UIImageView("MEComments")
          commentsIcon.move(Pos(15,screen.height - 80), .left)
          commentsLabel = Label(frame: CGRect(35, screen.height - 80,0,0), text: String(event.commentsCount), font: .light(12), color: .dark, alignment: .left, fixHeight: true)
          display(commentsIcon)
          display(commentsLabel)
        } else {
          commentsIcon = commentsIcon.destroy()
          commentsLabel = commentsLabel.destroy()
        }
      }
    }
  }
  
  var startTimeLabel: Label!
  var showsStartTime = false {
    didSet {
      if showsStartTime != oldValue {
        showsClock = showsEndTime || showsStartTime
        if showsStartTime {
          startTimeLabel = Label(frame: CGRect(screen.center.x - 25, screen.height - 40, 0,0), text: event.startTime.timeFormat, font: .light(12), color: .dark, alignment: .right, fixHeight: true)
          display(startTimeLabel)
        } else {
          startTimeLabel = startTimeLabel.destroy()
        }
      }
    }
  }
  
  
  var endTimeLabel: Label!
  var showsEndTime = false {
    didSet {
      if showsEndTime != oldValue {
        showsClock = showsEndTime || showsStartTime
        if showsEndTime {
          endTimeLabel = Label(frame: CGRect(screen.center.x + 25, screen.height - 40, 0,0), text: event.endTime.timeFormat, font: .light(12), color: .dark, alignment: .left, fixHeight: true)
          display(endTimeLabel)
        } else {
          endTimeLabel = endTimeLabel.destroy()
        }
      }
    }
  }
  
  var clock: UIImageView!
  var showsClock = false {
    didSet {
      if showsClock != oldValue {
        if showsClock {
          clock = UIImageView("METime")
          clock.move(Pos(screen.center.x, screen.height - 40), .center)
          display(clock)
        } else {
          clock = clock.destroy()
        }
      }
    }
  }
  
  
  var showsAge = false
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
