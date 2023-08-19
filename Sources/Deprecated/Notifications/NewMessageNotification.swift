//
//  NNewMessage.swift
//  faggot
//
//  Created by Димасик on 29/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class NNewMessage: ServerNotification {
  let user: User
  let text: String
  init(user: User, text: String, time: Time) {
    self.user = user
    self.text = text
    super.init(time: time)
    type = NotificationType.newMessage
  }
  override func mini() -> NNotificationViewMini? {
    return NNewMessageViewMini(user: user, text: text)
  }
}



class NNewMessageViewMini: NNotificationViewMini {
  let photo: UIImageView
  let message: UILabel
  init(user: User, text: String) {
    let font = UIFont.thin(17)
    let width: CGFloat = 200
    let height: CGFloat = text.height(font, width: width)
    let center = height / 2
    
    photo = UIImageView(frame: Rect(Pos(15,center),_left,Size(40,40)))
    photo.backgroundColor = .background
    photo.layer.cornerRadius = 20
    message = UILabel(frame: Rect(Pos(70,center),_left,Size(width,height)), text: text, font: font, color: .dark, alignment: .left)
    message.numberOfLines = 0
    
    super.init(Size(width + 40 + 30,height))
    
    addSubviews(photo,message)
    
    photo.user(main.firstPage, user: user)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
