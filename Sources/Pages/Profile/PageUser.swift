//
//  profile-user.swift
//  faggot
//
//  Created by Димасик on 4/14/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork
import SomeBridge

extension FriendStatus {
  @discardableResult
  func action(with user: User) -> StreamOperations {
    switch self {
    case .friend:
      return user.unfriend()
    case .notFriend:
      return user.friend()
    case .incoming:
      return user.friend()
    case .outcoming:
      return user.unfriend()
    }
  }
  var doneText: String {
    switch self {
    case .friend: // uppercased добавил потому что у FButton весь текст uppercased
      return "Friend removed".uppercased()
    case .notFriend:
      return "Request sent".uppercased()
    case .incoming:
      return "Accepted".uppercased()
    case .outcoming:
      return "Cancelled".uppercased()
    }
  }
  var text: String {
    switch self {
    case .friend: return "Unfriend"
    case .notFriend: return "Add friend"
    case .incoming: return "Accept\nfriend request"
    case .outcoming: return "Cancel\nfriend request"
    }
  }
}

private let topHeight: CGFloat = 180 + FButtonList.height
class UserPage: Page {
  var photoView: DCButton
  var nameLabel: DCLabel
  var topView: DFView
  var eventsView: EventsView
  var buttons: FButtonList
  
  let mapButton: FButton
  let friendButton: FButton
  lazy var inviteButton: FButton = { [unowned self] in
    let button = FButton(text: self.inviteButtonText(), icon: #imageLiteral(resourceName: "POnline"))
    button.touch { [unowned self] in
      self.invite()
    }
    return button
  }()
  lazy var reportButton: FButton = { [unowned self] in
    let button = FButton(text: "Report", icon: #imageLiteral(resourceName: "PReport"))
    button.touch { [unowned self] in
      self.askForReport()
    }
    return button
  }()
  
  let user: User
  var event: Event?
  
  var friendStatus: FriendStatus
  
  init?(user: User) {
    guard !user.isMe else { return nil }
    self.user = user
    buttons = FButtonList()
    
    eventsView = EventsView(frame: screen.frame.offsetBy(dx: 0, dy: screen.height))
    eventsView.showsCreateEvent = false
    eventsView.contentInset.top = topHeight + 20
    eventsView.alwaysBounceVertical = true
    
    
    topView = DFView()
    photoView = DCButton(frame: Size(90,90).frame)
    nameLabel = DCLabel(text: user.name, color: .black, font: .bold(30))
    nameLabel.dcenter = { Pos(screen.center.x, 155) }
    photoView.dcenter = { Pos(screen.center.x, 85) }
    photoView.backgroundColor = .background
    photoView.circle()
    eventsView.dframe = { screen.frame }
    
    topView.addSubview(nameLabel)
    topView.addSubview(photoView)
    
    topView.dframe = { CGRect(0,-topHeight,screen.width,topHeight) }
    
    //    eventsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
    friendStatus = user.friendStatus
    mapButton = FButton(text: "Map", icon: #imageLiteral(resourceName: "PMap"))
    friendButton = FButton(text: friendStatus.text, icon: #imageLiteral(resourceName: "PFriends"))
    buttons.insert(mapButton, animated: false)
    buttons.insert(friendButton, animated: false)
    
    // если открыта страница с событием, то добавляем кнопку пригласить
    for page in main.npages.reversed() {
      if let page = page as? EventPage {
        event = page.event
        break
      }
    }
    
    super.init()
    
    if !user.isReported {
      buttons.insert(reportButton, animated: false)
    }
    
    if event != nil {
      buttons.insert(inviteButton, animated: false)
    }
    
    buttons.dframe = { CGRect(0,180,screen.width,FButtonList.height) }
    
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
    eventsView.addSubview(topView)
    topView.addSubview(buttons)
    
    print("updating events")
    let events = eventManager.get(self.user.events)
    self.eventsView.set(events: events)
    print("added \(events.count) events")
    
    mapButton.touch { [unowned self] in
      let events = eventManager.get(self.user.events)
      let page = Map(showsMy: false, showsPublic: false)
      page.set(events: events)
      page.transition = .fade
      main.push(page)
    }
    friendButton.touch { [unowned self] in
      self.friendAction()
    }
    
    photoView.user(self, user: user)
    user.open()
  }
  
  func updateState(event: Event) {
    if event.isPrivateForMe {
      eventsView.remove(event: event, animated: true)
    } else {
      eventsView.insert(event: event, animated: true)
    }
  }
  
  func updateStatus() {
    friendButton.button.isEnabled = false
    let old = friendStatus
    let new = user.friendStatus
    friendStatus = new
    
    let text1: String
    let text2 = new.text
    
    switch new {
    case .friend: text1 = FriendStatus.incoming.doneText
    case .incoming:
      text1 = FriendStatus.incoming.text
    case .outcoming: text1 = FriendStatus.notFriend.doneText
    case .notFriend:
      if old == .incoming {
        text1 = FriendStatus.outcoming.doneText
      } else {
        text1 = old.doneText
      }
    }
    
    friendButton.text = text1
    wait(2) {
      self.friendButton.button.isEnabled = true
      if self.friendButton.text == text1 {
        self.friendButton.text = text2
      }
    }
  }
  
  func removeAvatar() {
    self.photoView.setImage(nil, for: .normal)
  }
  
  func friendAction() {
    let user = self.user
    let status = user.friendStatus
    let friendButton = self.friendButton
    friendButton.button.isEnabled = false
    status.action(with: user)
  }
  
  
  func inviteButtonText() -> String {
    let name, invite: String
    if let event = self.event {
      name = "\n\(event.name)"
    } else {
      name = "event"
    }
    if let event = self.event {
      if event.invited.contains(self.user.id) {
        invite = "Uninvite from"
      } else {
        invite = "Invite to"
      }
    } else {
      invite = "Invite"
    }
    return "\(invite) \(name)"
  }
  
  func invite() {
    guard let event = event else { return }
    inviteButton.button.isEnabled = false
    let enable = { [weak self] in
      guard self != nil else { return }
      self!.inviteButton.button.isEnabled = true
      self!.inviteButton.text = self!.inviteButtonText()
    }
    if event.invited.contains(user.id) {
      event.invite(users: Set([self.user.id]))
        .autorepeat()
        .onComplete(action: enable)
    } else {
      event.uninvite(users: Set([self.user.id]))
        .autorepeat()
        .onComplete(action: enable)
    }
  }
  
  func askForReport() {
    let controller = UIAlertController.destructive(title: "Report confirmation", message: "If we find this profile to be in violation of our Rules, we will remove it.", button: "Report") {
      self.report()
    }
    main.present(controller)
  }
  
  func report() {
    inviteButton.button.isEnabled = false
    if let request = user.report(reason: .other) {
      inviteButton.text = "Reporting"
      request.onComplete { [weak self] in
        self?.inviteButton.text = "Reported"
      }
    }
    reportButton.text = "Reported"
  }
  
  override func closed() {
    user.close()
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

extension UserPage: AccountNotifications {
  func added(friends: Set<ID>) {
    guard friends.contains(user.id) else { return }
    updateStatus()
  }
  
  func removed(friends: Set<ID>) {
    guard friends.contains(user.id) else { return }
    updateStatus()
  }
  
  func added(incoming: Set<ID>) {
    guard incoming.contains(user.id) else { return }
    updateStatus()
  }
  
  func removed(incoming: Set<ID>) {
    guard incoming.contains(user.id) else { return }
    updateStatus()
  }
  
  func added(outcoming: Set<ID>) {
    guard outcoming.contains(user.id) else { return }
    updateStatus()
  }
  
  func removed(outcoming: Set<ID>) {
    guard outcoming.contains(user.id) else { return }
    updateStatus()
  }
}

extension UserPage: UserMainNotifications {
  func updated(user: User, name: String) {
    guard self.user == user else { return }
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
    guard self.user == user else { return }
    if avatar {
      photoView.user(self, user: user)
    } else {
      removeAvatar()
    }
  }
}

extension UserPage: UserProfileNotifications {
  func inserted(event: Event, for users: Set<ID>) {
    guard users.contains(user.id) else { return }
    eventsView.insert(event: event, animated: true)
  }
  
  func updated(events: Set<Event>, of user: User) {
    guard self.user == user else { return }
    let sorted = events.sorted(by: { $0.startTime < $1.startTime })
    eventsView.set(events: sorted)
  }
  
  func created(event: Event, by user: ID) {
    guard self.user.id == user else { return }
    eventsView.insert(event: event, animated: true)
  }
  
  func removed(event: Event, from users: Set<ID>) {
    guard users.contains(user.id) else { return }
    eventsView.remove(event: event, animated: true)
  }
}

extension UserPage: EventMainNotifications {
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
    guard self.user.events.contains(event.id) else { return }
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
    guard self.user.events.contains(event.id) else { return }
    guard let view = self.eventsView.find(event: event) as? EventsView.EventContent else { return }
    view.updatePreview(page: self)
  }
  
  func updated(contentAvailable event: Event) {
    
  }
}
extension UserPage: EventPublicNotifications {
  func updated(owner event: Event, oldValue: ID) {
    guard let pageEvent = self.event else { return }
    guard pageEvent == event else { return }
    if event.owner.isMe {
      self.buttons.insert(self.inviteButton, animated: true)
    } else if oldValue.isMe {
      self.buttons.remove(self.inviteButton, animated: true)
    }
  }
  func updated(status event: Event, oldValue: EventStatus) {
    guard self.user.events.contains(event.id) else { return }
    guard let view = self.eventsView.find(event: event) as? EventsView.EventContent else { return }
    view.set(status: event.statusString, animated: true)
  }
  func updated(privacy event: Event) {
    guard self.user.events.contains(event.id) else { return }
    self.updateState(event: event)
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
    guard self.user.id == user else { return }
    guard let pageEvent = self.event else { return }
    guard pageEvent == event else { return }
    guard event.owner.isMe else { return }
    self.inviteButton.text = self.inviteButtonText()
  }
  func uninvited(user: ID, from event: Event) {
    guard self.user.id == user else { return }
    guard let pageEvent = self.event else { return }
    guard pageEvent == event else { return }
    guard event.owner.isMe else { return }
    self.inviteButton.text = self.inviteButtonText()
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
