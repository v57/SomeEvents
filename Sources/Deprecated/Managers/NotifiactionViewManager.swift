//
//  NotifiactionViewManager.swift
//  faggot
//
//  Created by Димасик on 02/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class NotificationsPage: Page {
  override init() {
    super.init()
    addTap(self,#selector(tap))
  }
  
  func test() {
    tap()
    let time = Double(random(min: 0, max: 1.0))
    wait(time) { [weak self] in
      self?.test()
    }
  }
  
  @objc func tap() {
    let view = NNewMessageViewMini(user: .me, text: "текст")
    notificationViewManager.show(view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

let notificationViewManager = NotificationViewManager()
class NotificationViewManager {
  var minis = [NNotificationViewMini]()
  var current: NotificationView!
  var height = CGFloat(0)
  
  func show(_ notification: ServerNotification) {
    if let view = notification.view() {
      notificationViewManager.show(view)
    } else if let view = notification.mini() {
      notificationViewManager.show(view)
    }
  }
  
  fileprivate func show(_ current: NotificationView) {
    animate {
      main.currentPage.alpha -= 0.8
    }
    main.currentPage.scale(from: 1.0, to: 0.8, animated: true, remove: false)
    current.scale(from: 1.2, to: 1.0, animated: true)
    main.mainView.display(current)
  }
  func hide(_ current: NotificationView) {
    animate {
      main.currentPage.alpha += 0.8
    }
    main.currentPage.scale(from: 0.8, to: 1.0, animated: true)
    current.scale(from: 1.0, to: 1.2, animated: true)
    current.destroy(animated: true)
  }
  fileprivate func show(_ mini: NNotificationViewMini) {
    mini.move(y: screen.height, _tl)
    height += mini.frame.height
    main.mainView.addSubview(mini)
    minis.append(mini)
    moveMinis()
    
    if height > screen.height - 100 {
      // предложить выключить уведомления
    }
    
    while height > screen.height - 100 && minis.count > 1 {
      remove(minis.first!)
    }
    
    wait(4) {
      self.remove(mini)
    }
  }
  
  func remove(_ mini: NNotificationViewMini) {
    guard mini.alpha == 1.0 else { return }
    self.height -= mini.frame.height
    minis.remove(mini)
    moveMinis()
    mini.destroy()
    animate {
      mini.move(y: 0, _bl)
    }
  }
  
  func moveMinis() {
    var y: CGFloat = (screen.height - height) / 2
    animate {
      for view in minis {
        view.move(y: y, _tl)
        y += view.frame.height
      }
    }
  }
}


class NotificationView: UIView {
  init() {
    super.init(frame: screen.frame)
    addTap(self,#selector(tap))
  }
  
  @objc func tap(_ gesture: UITapGestureRecognizer) {
    let pos = gesture.location(in: self)
    for view in subviews {
      if view.frame.contains(pos) {
        return
      }
    }
    //    destroy()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class NNotificationViewMini: UIView {
  init(_ size: CGSize) {
    super.init(frame: CGRect(size: size))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
