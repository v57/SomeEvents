//
//  profile-my.swift
//  faggot
//
//  Created by Димасик on 3/21/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension String {
  var profileDisplayName: String {
    if isEmpty {
      return "Tap to set your name"
    } else {
      return self
    }
  }
}

private let topHeight: CGFloat = 180 + FButtonList.height
class ProfilePage: Page {
  var photoView: DCButton
  var nameLabel: DCLabel
  let nameController: LabelController
  var topView: DFView
  var eventsView: EventsView
  var buttons: FButtonList
  
  let mapButton: FButton = FButton(text: "Map", icon: #imageLiteral(resourceName: "PMap"))
  let onlineButton: FButton = FButton(text: "Browse", icon: #imageLiteral(resourceName: "POnline"))
  let friendsButton: FButton = FButton(text: "Friends", icon: #imageLiteral(resourceName: "PFriends"))
  let communityButton: FButton = FButton(text: "Community", icon: #imageLiteral(resourceName: "PCommunity"))
  let licenseButton: FButton = FButton(text: "Rules", icon: #imageLiteral(resourceName: "PLicense"))
  
//  let googleView: DPView
  
  init(start: StartPage?) {
    buttons = FButtonList()
    buttons.topInset = 20
//    googleView = google.view(size: .s320x50)
    
    eventsView = EventsView(frame: screen.frame.offsetBy(dx: 0, dy: screen.height))
    eventsView.contentInset.top = topHeight + 20
    eventsView.alwaysBounceVertical = true
    
    if let page = start {
      topView = page.topView
      photoView = page.photoView
      nameLabel = page.nameLabel
      topView.removeFromSuperview()
    } else {
      topView = DFView()
      photoView = DCButton(frame: Size(90,90).frame)
      photoView.systemHighlighting()
      photoView.backgroundColor = .background
      photoView.circle()
      nameLabel = DCLabel(text: session!.name.profileDisplayName, color: .black, font: .bold(30))
      nameLabel.dcenter = { Pos(screen.center.x, 155) }
      photoView.dcenter = { Pos(screen.center.x, 85) }
      eventsView.dframe = { screen.frame }
    }
    nameController = LabelController(label: nameLabel)
    
    //    eventsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
    
    buttons.insert(mapButton, animated: false)
//    buttons.insert(onlineButton, animated: false)
    buttons.insert(friendsButton, animated: false)
//    buttons.insert(communityButton, animated: false)
    buttons.insert(licenseButton, animated: false)
    
    super.init()
    
    photoView.add(target: self, action: #selector(avatar))
    buttons.dframe = { CGRect(0,180,screen.width,FButtonList.height + 20) }
//    googleView.dpos = { Pos(screen.center.x, 180 + FButtonList.height + 20).top }
    if start != nil {
      topView.dframe = { CGRect(0,0,screen.width,topHeight) }
      buttons.isHidden = true
      animate(1, slide, completion: slided)
    } else {
      topView.dframe = { CGRect(0,-topHeight,screen.width,topHeight) }
//      topView.addSubview(googleView)
    }
    
    eventsView.currentPage = self
    eventsView.didScroll = { [unowned self] scrollView in
      let y = scrollView.contentOffset.y + scrollView.contentInset.top - 20
      
      let top = self.topView
      if y < 0 {
        top.dframe = { CGRect(0,y - topHeight,screen.width,topHeight) }
      } else {
        if top.frame.y != -topHeight {
          top.dframe = { CGRect(0,-topHeight,screen.width,topHeight) }
        }
      }
    }
    
    addSubview(eventsView)
    addSubview(topView)
    topView.addSubview(buttons)
    
    let events = eventManager.get(User.me.events)
    self.eventsView.set(events: events)
    
    nameController.touch { [unowned self] in
      self.changeName()
    }
    
    mapButton.touch {
      let page = Map(showsMy: true, showsPublic: true)
      page.transition = .fade
      main.push(page)
    }
    friendsButton.touch {
      let page = FriendsPage()
      main.push(page)
    }
    licenseButton.touch {
      let page = LicensePage(displayButtons: false)
      main.push(page)
    }
    communityButton.touch {
      let page = CommunityPage()
      main.push(page)
    }
  }
  
  func slide() {
    nameLabel.dcenter = { Pos(screen.center.x, 155) }
    photoView.dcenter = { Pos(screen.center.x, 85) }
    eventsView.dframe = { screen.frame }
  }
  func slided() {
    topView.removeFromSuperview()
    eventsView.addSubview(topView)
    topView.dframe = { CGRect(0,-topHeight-20,screen.width,topHeight) }
    buttons.isHidden = false
    buttons.bounce()
//    topView.addSubview(googleView)
//    googleView.alpha = 0.0
//    animate {
//      googleView.alpha = 1.0
//    }
    
    wait(0.2) {
      self.buttons.bounceButtons()
    }
    buttons.update(animated: false)
  }
  
  @objc func avatar() {
    let page = PhotoPicker(from: photoView, camera: true, library: true, removable: true)
    page.picked = { image in
      self.update(avatar: image)
    }
    page.removed = {
      self.removeAvatar()
      server.request().removeAvatar()
    }
    main.push(page)
  }
  
  func update(avatar: UIImage) {
    let image = avatar.thumbnail(CGSize(512,512),false)
    self.photoView.setImage(ImageEditor.circle(image, size: CGSize(90,90)), for: .normal)
    account?.upload(avatar: image)
  }
  
  func removeAvatar() {
    photoView.setImage(nil, for: .normal)
    photoView.backgroundColor = .background
    photoView.circle()
  }
  
  func changeName() {
    let page = NameEditor(label: nameLabel)
    page.completion = { name in
      server.request()
      .rename(to: name)
    }
    main.push(page)
  }
  
//  override func customTransition(with page: SomePage?, ended: @escaping () -> ()) -> Bool {
//    guard let page = page as? StartPage else { return false }
//
//    page.removeFromSuperview()
//    ended()
//    dframe = { screen.frame }
//    return true
//  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}



extension ProfilePage: UploadNotifications {
  func uploading(avatar: UploadRequest) {
    avatar.subscribe(view: photoView, page: self)
  }
}

extension ProfilePage: UserMainNotifications {
  func updated(user: User, name: String) {
    guard user.isMe else { return }
    nameLabel.set(text: user.name)
    nameLabel.bounce()
  }
  
  func updated(user: User, online: Bool) {
    
  }
  
  func updated(user: User, deleted: Bool) {
    
  }
  
  func updated(user: User, banned: Bool) {
    
  }
  
  func updated(user: User, avatar: Bool) {
    guard user.isMe else { return }
    if avatar {
      photoView.user(self, user: user)
    } else {
      removeAvatar()
    }
  }
}

extension ProfilePage: UserProfileNotifications {
  func inserted(event: Event, for users: Set<ID>) {
    guard users.contains(.me) else { return }
    eventsView.insert(event: event, animated: true)
  }
  
  func updated(events: Set<Event>, of user: User) {
    guard user.isMe else { return }
    let sorted = events.sorted(by: { $0.startTime < $1.startTime })
    eventsView.set(events: sorted)
  }
  
  func created(event: Event, by user: ID) {
    guard user.isMe else { return }
    eventsView.insert(event: event, animated: true)
  }
  
  func removed(event: Event, from users: Set<ID>) {
    guard users.contains(.me) else { return }
    eventsView.remove(event: event, animated: true)
  }
}

extension ProfilePage: EventMainNotifications {
  func created(event: Event) {
    
  }
  func created(content: Content, in event: Event) {
    
  }
  func uploaded(preview: Content, in event: Event) {
    
  }
  func uploaded(content: Content, in event: Event) {
    
  }
  
  func updated(id event: Event, oldValue: ID) {
    
  }
  func updated(name event: Event) {
    guard let view = self.eventsView.find(event: event) as? EventsView.EventContent else { return }
    view.updateName()
  }
  func updated(startTime event: Event) {
    
  }
  func updated(endTime event: Event) {
    
  }
  func updated(coordinates event: Event) {
    
  }
  func updated(preview event: Event) {
    guard let view = self.eventsView.find(event: event) as? EventsView.EventContent else { return }
    view.updatePreview(page: self)
  }
  
  func updated(contentAvailable event: Event) {
    
  }
}

extension ProfilePage: EventPublicNotifications {
  
  func updated(owner event: Event, oldValue: ID) {
    
  }
  func updated(status event: Event, oldValue: EventStatus) {
    guard let view = self.eventsView.find(event: event) as? EventsView.EventContent else { return }
    view.set(status: event.statusString, animated: true)
  }
  func updated(privacy event: Event) {
    
  }
  func updated(options event: Event) {
    
  }
  func updated(createdTime event: Event) {
    
  }
  func updated(online event: Event) {
    
  }
  func updated(onMap event: Event) {
    
  }
  func updated(removed event: Event) {
    
  }
  func updated(banned event: Event) {
    
  }
  func updated(protected event: Event) {
    
  }
  
  func updated(content event: Event) {
    
  }
  func added(content: Content, to event: Event) {
    
  }
  func removed(content: Content, from event: Event) {
    
  }
  
  func invited(user: ID, to event: Event) {
    guard user.isMe else { return }
    self.eventsView.insert(event: event, animated: true)
  }
  func uninvited(user: ID, from event: Event) {
    guard user.isMe else { return }
    self.eventsView.remove(event: event, animated: true)
  }
  
  func updated(views event: Event) {
    
  }
  func updated(comments event: Event) {
    
  }
  func updated(current event: Event) {
    
  }
  
  func updated(banList event: Event) {
    
  }
}
