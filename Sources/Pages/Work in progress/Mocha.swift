//
//  Mocha.swift
//  faggot
//
//  Created by Димасик on 30/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class Mocha: Page {
  override init() {
    super.init()
    
    let circle = ImageEditor.circle(Size(80,80), fillColor: nil, strokeColor: .dark, lineWidth: 1)
    
    let communityIcon = UIImage(named: "MMCommunity")!
    let withCircle = ImageEditor.combineImages([circle,communityIcon], size: circle.size)
    let button = UIButton(pos: screen.center, anchor: _center, image: withCircle)
    
    let communityLabel = Label(frame: CGRect(screen.center.x,420,0,0), text: "Community", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    let settingsIcon = UIImage(named: "MMSettings")!
    let swithCircle = ImageEditor.combineImages([circle,settingsIcon], size: circle.size)
    let sButton = UIButton(pos: Pos(screen.width - 315, 368), anchor: _center, image: swithCircle)
    
    let settingsLabel = Label(frame: CGRect(screen.width - 315,420,0,0), text: "Settings", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    let profileIcon = UIImage(named: "MMStatus")!
    let pwithCircle = ImageEditor.combineImages([circle,profileIcon], size: circle.size)
    let pButton = UIButton(pos: Pos(screen.width - 100, 368), anchor: _center, image: pwithCircle)
    
    let profileLabel = Label(frame: CGRect(screen.width - 100,420,0,0), text: "Profile", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    let mapIcon = UIImage(named: "MMMap")!
    let mwithCircle = ImageEditor.combineImages([circle,mapIcon], size: circle.size)
    let mButton = UIButton(pos: Pos(screen.width - 315, 500), anchor: _center, image: mwithCircle)
    
    let mapLabel = Label(frame: CGRect(screen.width - 315,550,0,0), text: "Map", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    let reportsIcon = UIImage(named: "MMReports")!
    let rwithCircle = ImageEditor.combineImages([circle,reportsIcon], size: circle.size)
    let rButton = UIButton(pos: Pos(207, 500), anchor: _center, image: rwithCircle)
    
    let reportsLabel = Label(frame: CGRect(207,550,0,0), text: "Reports", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    let infoIcon = UIImage(named: "MMWiki")!
    let iwithCircle = ImageEditor.combineImages([circle,infoIcon], size: circle.size)
    let iButton = UIButton(pos: Pos(screen.width - 100, 500), anchor: _center, image: iwithCircle)
    
    let infoLabel = Label(frame: CGRect(screen.width - 100,550,0,0), text: "Info", font: .ultraLight(18), color: .dark, alignment: .center, fixHeight: true)
    
    
    addSubviews(button, sButton, communityLabel, settingsLabel, pButton, profileLabel, mButton, mapLabel, rButton, reportsLabel, iButton, infoLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


//var showsTimer = false {
//didSet {
//    if showsTimer != oldValue {
//        if showsTimer {
//
//        } else {
//
//        }
//    }
//}
//}
//var showsRedButton = false {
//didSet {
//    if showsRedButton != oldValue {
//        if showsRedButton {
//
//        } else {
//
//        }
//    }
//}
//}
//
//
//var comments: UITextField!
//var commentsBackground: UIView!
//var showsComments = false {
//didSet {
//    if showsComments != oldValue {
//        if showsComments {
//
//        } else {
//
//        }
//    }
//}
//}
//
//var batteryBackground: UIView!
//var batteryLabel: UILabel!
//var showsBattery = false {
//didSet {
//    if showsBattery != oldValue {
//        if showsBattery {
//
//        } else {
//
//        }
//    }
//}
//}
//
//func addComments(comments: [String]) {
//
//}
//func addComment(text: String) {
//
//}
//func updateBatteryLevel() {
//
//}
