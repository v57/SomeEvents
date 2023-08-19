//
//  LicenseNotification.swift
//  Events
//
//  Created by Димасик on 3/19/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class LicenseNotification: FullNView, UniqueNotification {
  static var key: String = "License"
  required init() {
    super.init(text: "You must accept our rules before posting comments")
    titleLabel.text = "License agreement"
    iconView.image = "📋".image(font: .normal(20))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/*
class LicenseNotification: DFView {
  var titleLabel: UILabel
  lazy var closedView = LicenseNotificationClosed(owner: self)
  lazy var openedView = LicenseNotificationOpened(owner: self)
  init() {
    titleLabel = UILabel(text: "License", color: .black, font: .body)
    super.init(frame: .zero)
    addSubview(titleLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
 */

/*
class LicenseNotificationOpened {
  unowned var owner: LicenseNotification
  var titleLabel: UILabel {
    return owner.titleLabel
  }
  var descriptionLabel: UILabel
  init(owner: LicenseNotification) {
    self.owner = owner
    
  }
  func show() {
    
  }
  func hide() {
    
  }
}

class LicenseNotificationClosed {
  unowned var owner: LicenseNotification
  init(owner: LicenseNotification) {
    self.owner = owner
  }
  func show() {
    
  }
  func hide() {
    
  }
}
*/
