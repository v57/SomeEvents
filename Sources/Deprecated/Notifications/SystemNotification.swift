//
//  NSystem.swift
//  faggot
//
//  Created by Димасик on 29/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class NSystemMessage: ServerNotification {
  let text: String
  init(text: String, time: Time) {
    self.text = text
    super.init(time: time)
    type = NotificationType.system
  }
  override func mini() -> NNotificationViewMini? {
    return NSystemMessageViewMini(text: text)
  }
}



class NSystemMessageViewMini: NNotificationViewMini {
  let photo: UIImageView
  let message: UILabel
  init(text: String) {
    let font = UIFont.thin(17)
    let width: CGFloat = 200
    let height: CGFloat = text.height(font, width: width)
    let center = height / 2
    
    photo = UIImageView(frame: Rect(Pos(15,center),_left,Size(40,40)))
    photo.backgroundColor = .background
    photo.layer.cornerRadius = 20
    message = UILabel(frame: Rect(Pos(70,center),_left,Size(width,height)), text: "system message: \(text)", font: font, color: .dark, alignment: .left)
    message.numberOfLines = 0
    
    super.init(Size(width + 40 + 30,height))
    
    addSubviews(photo,message)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
