//
//  Monitoring.swift
//  faggot
//
//  Created by Димасик on 18/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

/*

#if debug
enum MotinoringTab {
  case non, user, event, map, cloud, settings
}

let monitoring = Monitoring()
class Monitoring {
  let userButton: SButton
  let eventButton: SButton
  let notificationsButton: SButton
  let serverButton: SButton
  let fileButton: SButton
  let subButton: SButton
  let settingsButton: SButton
  
  private var buttons: [SButton]
  private var views: [MonitoringView]
  
  private let userView = UserView()
  private let eventView = EventView()
  private let notificationsView = NotificationsView()
  private let serverView = ServerView()
  private let fileView = FileView()
  private let subView = SubView()
  private let settingsView = SettingsView()
  
  var shows = true {
    didSet {
      if shows != oldValue {
        if shows {
          for button in buttons {
            button.view?.move(x: button.view.center.x + 50, _center)
          }
        } else {
          for button in buttons {
            button.view?.move(x: button.view.center.x - 50, _center)
          }
        }
      }
    }
  }
  
  init() {
    let oy: CGFloat = 30
    let ox: CGFloat = 5
    userButton = SButton(pos: Pos(ox,oy + 0), size: Size(50,50), anchor: _topLeft, imageName: "MProfile")
    eventButton = SButton(pos: Pos(ox,oy + 50), size: Size(50,50), anchor: _topLeft, imageName: "MEvents")
    notificationsButton = SButton(pos: Pos(ox,oy + 100), size: Size(50,50), anchor: _topLeft, imageName: "MNotifications")
    serverButton = SButton(pos: Pos(ox,oy + 150), size: Size(50,50), anchor: _topLeft, imageName: "MServerConnections")
    fileButton = SButton(pos: Pos(ox,oy + 200), size: Size(50,50), anchor: _topLeft, imageName: "MFileConnections")
    subButton = SButton(pos: Pos(ox,oy + 250), size: Size(50,50), anchor: _topLeft, imageName: "MNotificationConnections")
    settingsButton = SButton(pos: Pos(ox,oy + 300), size: Size(50,50), anchor: _topLeft, imageName: "MSettings")
    
    buttons = [userButton, eventButton, notificationsButton, serverButton, fileButton, subButton, settingsButton]
    views = [userView, eventView, notificationsView, serverView, fileView, subView, settingsView]
    
    
    
    for (i,button) in buttons.enumerated() {
      button.handler = { [unowned self] in
        self.open(i)
      }
      main.view.append(button)
      button.shows = true
    }
    for view in views {
      view.alpha = 0
      view.shows = false
      main.readonlyLayer.addSubview(view)
    }
    Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(Monitoring.update), userInfo: nil, repeats: true)
  }
  var current = -1
  func open(_ n: Int) {
    if n == current {
      if n == -1 {
        return
      } else {
        open(-1)
      }
    } else {
      if current != -1 {
        let view = views[current]
        view.shows = false
        let button = buttons[current]
        animate {
          button.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        if button == settingsButton || button == eventButton {
          let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
          rotationAnimation.toValue = .pi * 2.0 * 2
          rotationAnimation.duration = 1
          rotationAnimation.isCumulative = true
          rotationAnimation.repeatCount = 1
          rotationAnimation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
          button.view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
      }
      if n != -1 {
        let view = views[n]
        view.shows = true
        let button = buttons[n]
        animate {
          button.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        if button == settingsButton || button == eventButton {
          let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
          rotationAnimation.toValue = .pi * 2.0 * 1
          rotationAnimation.duration = 1
          rotationAnimation.isCumulative = true
          rotationAnimation.repeatCount = 1
          rotationAnimation.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
          button.view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
      }
      current = n
    }
  }
  func hide() {
    open(-1)
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  @objc func update() {
    guard current != -1 else { return }
    let view = views[current]
    view.update()
  }
  
}

private class MonitoringView: View {
  override init() {
    super.init(frame: screen.frame)
  }
  
  func update() {
    
  }
  
  var labels = [UILabel]()
  func createLabels(_ count: Int) {
    labels = [UILabel]()
    for i in 0..<count {
      let l = UILabel(frame: Rect(50,CGFloat(i) * 20 + 30,200,20))
      l.textColor = .dark
      l.font = .mono(12)
      
      addSubview(l)
      labels.append(l)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class UserView: MonitoringView {
  override init() {
    super.init()
  }
  
  override func update() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class EventView: MonitoringView {
  
  override init() {
    super.init()
  }
  
  override func update() {
    var strings = [String]()
//    let now = Time.now
    
    let em = eventManager.printInfo()
    for string in em {
      strings.append(string)
    }
    
    strings.append("Pages inited: \(SomeDebug.pagesInited)")
    strings.append("Pages closed: \(SomeDebug.pagesClosed)")
    strings.append("Pages deinited: \(SomeDebug.pagesDeinited)")
    var pagesString = ""
    for page in SomeDebug.pages.allObjects {
      pagesString += "\(className(page)) "
    }
    strings.append(pagesString)
    
    if labels.count == 0 {
      createLabels(strings.count)
    }
    for (i,s) in strings.enumerated() {
      labels[i].text = s
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


private class NotificationsView: MonitoringView {
  override init() {
    super.init()
  }
  
  override func update() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class SubView: MonitoringView {
}
private class ServerView: MonitoringView {
  
}
private class FileView: MonitoringView {
  override func update() {
//    var strings = [String]()
//    let now = Time.now
//    let s = connectionManager.stats
//    
//    strings.append("connected: \(s.currentConnections)")
//    strings.append("  opened: \(s.cOpened)")
//    strings.append("  closed: \(s.cClosed)")
//    strings.append("  failed: \(s.cFailed)")
//    strings.append("  ping: \(s.cPing)")
//    strings.append("  last error: \(s.cError?.name ?? "-")")
//    
//    
//    strings.append("sended: \(s.sBytes.bytesString)")
//    strings.append("  delivered: \(s.ssBytes.bytesString)")
//    strings.append("  lost: \(s.slBytes.bytesString)")
//    strings.append("  packets sended: \(s.sPackets)")
//    strings.append("  packets delivered: \(s.ssPackets)")
//    strings.append("  packets lost: \(s.slPackets)")
//    strings.append("  ping: \(s.sPing)")
//    strings.append("  last error: \(s.sError?.name ?? "-")")
//    
//    strings.append("readed: \(s.rBytes.bytesString)")
//    strings.append("  received packets: \(s.rPackets)")
//    strings.append("  failed reads: \(s.readFails)")
//    strings.append("  read ping: \(s.rPing)")
//    strings.append("  last error: \(s.rError?.name ?? "-")")
//    
//    //    private(set) var cOpenedLast: Time = 0 // последнее открытое соединение
//    //    private(set) var cClosedLast: Time = 0 // последнее закрытое соединение
//    //    private(set) var cFailedLast: Time = 0 // последнее закрытое соединение сервером
//    //    private(set) var sLast: Time = 0 // последняя отправка
//    //    private(set) var rLast: Time = 0 // последний полученый пакет
//    
//    strings.append("connecting: \(s.currentConnecting)")
//    strings.append("reading: \(s.currentReads)")
//    strings.append("writing: \(s.currentWrites)")
//    
//    if labels.count != strings.count+1 {
//      createLabels(strings.count+1)
//      labels[0].text = serverAddress.ip + ":" + String(serverAddress.port)
//    }
//    for (i,s) in strings.enumerated() {
//      labels[i+1].text = s
//    }
  }
}


private class SettingsView: MonitoringView {
  override init() {
    super.init()
  }
  
  override func update() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
#endif
*/
