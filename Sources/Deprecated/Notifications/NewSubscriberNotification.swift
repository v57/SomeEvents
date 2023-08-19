//
//  NNewSubscriber.swift
//  faggot
//
//  Created by Димасик on 29/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class NNewSubscriber: ServerNotification {
  override init(time: Time) {
    super.init(time: time)
    type = NotificationType.newSubscriber
  }
}

class NNewSubscriberView: NotificationView {
  let photo: UIImageView
  let name: UILabel
  let title: UILabel
  init(user: User) {
    let photoPos = screen.center - Pos(0,120)
    let namePos = screen.center - Pos(0,20)
    let titlePos = screen.center + Pos(0,10)
    
    let photoSize = Size(150,150)
    let photoFrame = Rect(photoPos, _c, photoSize)
    photo = UIImageView(frame: photoFrame)
    name = UILabel(pos: namePos, anchor: _center, text: user.name, color: .dark, font: .bold(30))
    title = UILabel(pos: titlePos, anchor: _center, text: "Subscribed to you", color: .dark, font: .thin(20))
    
    photo.layer.cornerRadius = photoSize.width / 2
    photo.backgroundColor = .background
    
    super.init()
    
    addSubviews(photo,name,title)
    
    photo.user(main.firstPage, user: user)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
