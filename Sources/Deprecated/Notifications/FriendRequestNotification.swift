//
//  NFriendRequest.swift
//  faggot
//
//  Created by Димасик on 29/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class NFriendRequest: ServerNotification {
  let user: User
  init(user: User, time: Time) {
    self.user = user
    super.init(time: time)
    type = NotificationType.friendRequest
  }
  override func view() -> NotificationView? {
    return NFriendRequestView(user: user)
  }
}

class NFriendRequestView: NotificationView {
  let photo: UIImageView
  let name: UILabel
  let title: UILabel
  let declineButton: Button
  let acceptButton: Button
  let user: User
  init(user: User) {
    self.user = user
    let photoPos = screen.center - Pos(0,120)
    let namePos = screen.center - Pos(0,20)
    let titlePos = screen.center + Pos(0,10)
    
    let photoSize = Size(150,150)
    let photoFrame = Rect(photoPos, _c, photoSize)
    photo = UIImageView(frame: photoFrame)
    name = UILabel(pos: namePos, anchor: _center, text: user.name, color: .dark, font: .bold(30))
    title = UILabel(pos: titlePos, anchor: _center, text: "Wanna be your friend", color: .dark, font: .thin(20))
    
    photo.layer.cornerRadius = photoSize.width / 2
    photo.backgroundColor = .background
    
    declineButton = Button(frame: CGRect(0,screen.center.y + 100,screen.center.x,50), text: "Decline", font: .thin(22), color: .dark)
    acceptButton = Button(frame: CGRect(screen.center.x,screen.center.y + 100,screen.center.x,50), text: "Accept", font: .thin(22), color: .dark)
    declineButton.backgroundColor = UIColor(white: 1, alpha: 0.4)
    acceptButton.backgroundColor = UIColor(white: 1, alpha: 0.4)
    
    super.init()
    
    declineButton.add(target: self, action: #selector(decline))
    acceptButton.add(target: self, action: #selector(accept))
    
    addSubviews(photo,name,title,declineButton,acceptButton)
    photo.user(main.firstPage, user: user)
  }
  
  @objc func accept() {
    let user = self.user
    user.friend()
    notificationViewManager.hide(self)
  }
  @objc func decline() {
    let user = self.user
    user.unfriend()
    notificationViewManager.hide(self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
