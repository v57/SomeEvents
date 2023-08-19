//
//  ServerNotifications.swift
//  Some Events
//
//  Created by Димасик on 11/27/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge



class NDataReader: DataReader {
  var op: String = ""
  init(_ data: DataReader) {
    super.init(data: data.data)
    position = data.position
  }
  
  required init(data: DataReader) throws {
    try super.init(data: data)
  }
  func process(command: subcmd) throws {
    op = "\(command)"
    defer {
      op = "\(Time.now.timeFormat) \(op)"
      serverManager.notifications.append(op, max: 10, override: .first)
    }
    
    switch command {
    case .systemMessage:
      try systemMessage()
    case .friendAdded:
      try friendAdded()
    case .friendRemoved:
      try friendRemoved()
    case .incomingAdded:
      try incomingAdded()
    case .outcomingAdded:
      try outcomingAdded()
    case .pName:
      try pName()
    case .pAvatarChanged:
      try pAvatarChanged()
    case .pAvatarRemoved:
      try pAvatarRemoved()
    case .pSubs:
//      try pSubs()
      return
    case .pNewEvent:
      try pNewEvent()
    case .pEventRemoved:
      try pEventRemoved()
    case .pEventPreviewChanged:
      try pEventPreviewChanged()
    case .mAddEvent:
      try mAddEvent()
    case .mRemoveEvent:
      try mRemoveEvent()
    case .eNewOwner:
//      try eNewOwner()
      return
    case .eNewContent:
      try eNewContent()
    case .eContentRemoved:
      try eContentRemoved()
    case .eContentPreviewLoaded:
      try eContentPreviewLoaded()
    case .eContentLoaded:
      try eContentLoaded()
    case .eName:
      try eName()
    case .ec:
      try ec()
    case .ecEnabled:
//      try ecEnabled()
      return
    case .ecDeleted:
      try ecDeleted()
      return
    case .ecEdited:
//      try ecEdited()
      return
    case .ecCleared:
//      try ecCleared()
      return
    case .cc:
//      try cc()
      return
    case .ccDeleted:
//      try ccDeleted()
      return
    case .ccEdited:
//      try ccEdited()
      return
    case .ccCleared:
//      try ccCleared()
      return
    case .pm:
//      try pm()
      return
    case .pmDeleted:
//      try pmDeleted()
      return
    case .pmEdited:
//      try pmEdited()
      return
    case .pmCleared:
//      try pmCleared()
      return
    case .gcCreated:
//      try gcCreated()
      return
    case .gc:
//      try gc()
      return
    case .gcDeleted:
//      try gcDeleted()
      return
    case .gcEdited:
//      try gcEdited()
      return
    case .gcCleared:
//      try gcCleared()
      return
    case .eStatus:
      try eStatus()
    case .ePrivate:
      try ePrivate()
    case .eViews:
      try eViews()
    case .eCurrent:
      try eCurrent()
    case .eComments:
      try eComments()
    case .eInvited:
      try eInvited()
    case .eUninvited:
      try eUninvited()
    case .eMoved:
      try eMoved()
    case .eTimeChanged:
//      try eTimeChanged()
      return
    case .cTyping:
//      try cTyping()
      return
    case .reportSent:
      try reportSent()
    case .reportAvailable:
      try reportAvailable()
    case .pEventPreviewRemoved:
      return
    case .reportRemoved:
      return
    case .newReport:
      return
    case .response:
      return
    case .chat:
      try chatNotification()
    }
  }
  private func friendAdded() throws {
    let userid: ID = try next()
    account.privateProfileVersion = try next()
    account.insert(friend: userid)
    op = "friend added \(userid.userName)"
  }
  
  private func friendRemoved() throws {
    let userid: ID = try next()
    account.privateProfileVersion = try next()
    account.remove(friend: userid)
    account.remove(incoming: userid)
    account.remove(outcoming: userid)
    
    op = "friend removed \(userid.userName)"
  }
  private func incomingAdded() throws {
    let userid: ID = try next()
    account.privateProfileVersion = try next()
    userid.loadUser { user in
      let notification = NFriendRequest(user: user, time: Time.now)
      notificationManager.addNotification(notification)
    }
    
    account.insert(incoming: userid)
    
    op = "friend request received from \(userid.userName)"
  }
  private func outcomingAdded() throws {
    let userid: ID = try next()
    try account.set(privateProfileVersion: next())
    account.insert(outcoming: userid)
    op = "friend request sended to \(userid.userName)"
  }
  private func pNewEvent() throws {
    let userid: ID = try next()
    let publicVersion: UserProfileVersion = try next()
    let event = try eventMain()
    
    userid.user?.set(publicVersion: publicVersion)
    sendNotification(UserProfileNotifications.self) { $0.created(event: event, by: userid) }
    if account.isFriend(userid) {
      userid.loadUser { user in
        let view = FullNView(text: "Created new event")
        view.titleLabel.text = user.name
        view.iconView.user(main.pages.first as? Page, user: user)
        view.action = {
          let page = EventPage(event: event)
          main.push(page)
        }
        view.display()
      }
    }
    op = "event \(event.name) created  by \(userid.userName)"
  }
  private func pEventRemoved() throws {
    let eventid: ID = try next()
    let users: Set<ID> = try next()
    
    let event = eventid.event!
    sendNotification(UserProfileNotifications.self) { $0.removed(event: event, from: users) }
    op = "event \(event.name) removed from \(users.userNames)"
  }
  private func eMoved() throws {
    let eventid: ID = try next()
    let previewVersion: EventPreviewVersion = try next()
    let lat: Float = try next()
    let lon: Float = try next()
    let options: EventOptions.Set = try next()
    
    op = "event \(eventid.eventName) moved to \(lat), \(lon)"
    guard let event = eventid.event else { return }
    event.set(previewVersion: previewVersion)
    event.set(lat: lat, lon: lon)
    event.set(options: options)
  }
  private func eInvited() throws {
    let event = try eventMain()
    let userid: ID = try next()
    let profileVerison: UserProfileVersion = try next()
    
    userid.user?.set(publicVersion: profileVerison)
    event.set(invite: userid)
    op = "event \(event.name) invited \(userid.userName)"
  }
  private func eUninvited() throws {
    let eventid: ID = try next()
    let userid: ID = try next()
    let profileVerison: UserProfileVersion = try next()
    
    userid.user?.set(publicVersion: profileVerison)
    let event = eventid.event!
    event.set(uninvite: userid)
    op = "event \(event.name) uninvited \(userid.userName)"
  }
  
  private func pEventPreviewChanged() throws {
    let eventid: ID = try next()
    let previewVersion: EventPreviewVersion = try next()
    let content = try contentPreview(eventid)
    
    op = "event \(eventid.eventName) preview changed"
    guard let event = eventid.event else { return }
    event.set(previewVersion: previewVersion)
    if event.preview == nil && content == nil { return }
    if event.preview != nil && content != nil {
      guard event.preview!.id != content!.id else { return }
    }
    event.set(preview: content)
  }
  private func pName() throws {
    let id: ID = try next()
    let name: String = try next()
    let mainVersion: UserMainVersion = try next()
    
    let user = id.user!
    op = "user \(user.name) renamed to \(name)"
    user.set(mainVersion: mainVersion)
    user.set(name: name)
    if user.isMe {
      session!.set(name: name)
    }
  }
  private func pAvatarChanged() throws {
    let id: ID = try next()
    let avatarVersion: UserAvatarVersion = try next()
    let mainVersion: UserMainVersion = try next()
    
    let user = id.user!
    var options = user.publicOptions
    options[.avatar] = true
    
    #if debug
      Debug.userAvatarChanged(user: user)
    #endif
    
    user.set(mainVersion: mainVersion)
    user.set(avatarVersion: avatarVersion)
    user.set(publicOptions: options)
    op = "user \(user.name) updated avatar"
  }
  private func pAvatarRemoved() throws {
    let id: ID = try next()
    let mainVersion: UserMainVersion = try next()
    
    let user = id.user!
    var options = user.publicOptions
    options[.avatar] = false
    
    user.mainVersion = mainVersion
    user.set(publicOptions: options)
    op = "user \(user.name) removed avatar"
  }
  private func mAddEvent() throws {
    let event = try eventMain()
    mapManager.insert(event: event)
//    if let page = main.currentPage as? Map {
//      page.insert(event: event)
//    }
    op = "event \(event.name) added on map"
  }
  private func mRemoveEvent() throws {
    let id = try int64()
    mapManager.remove(event: id)
//    if let page = main.currentPage as? Map {
//      page.removeEvent(event)
//    }
    op = "event \(id.eventName) removed from map"
  }
  private func eNewContent() throws {
    let eventid: ID = try next()
    let content = try self.content(eventid)
    op = "content \(content.name) created in \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    event.set(insertContent: content)
  }
  private func eContentRemoved() throws {
    let eventid: ID = try next()
    let contentid: ID = try next()
    op = "content \(contentid.contentName(in: eventid)) removed from \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    event.set(removeContent: contentid)
  }
  private func eContentPreviewLoaded() throws {
    let eventid: ID = try next()
    let contentid: ID = try next()
    
    op = "content \(contentid.contentName(in: eventid)) uploaded preview to \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    guard let content = event.find(content: contentid) else { return }
    content.setPreviewUploaded()
  }
  private func eContentLoaded() throws {
    let eventid: ID = try next()
    let contentid: ID = try next()
    let type: ContentType = try next()
    
    op = "content \(contentid.contentName(in: eventid)) uploaded to \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    guard let content = event.find(content: contentid) else { return }
    switch type {
    case .photo:
      try (content as! PhotoContent).setUploaded(photoData: next())
    case .video:
      try (content as! VideoContent).setUploaded(videoData: next())
    }
  }
  
  private func chatNotification() throws {
    let command: ChatNotifications = try next()
    let chat = try self.chat()
    switch command {
      
    case .received:
      try chat.received(message: self)
    case .deleted:
      try chat.received(remove: self)
    case .edited:
      try chat.received(edit: self)
    case .cleared:
      try chat.received(clear: self)
    case .uploaded:
      try chat.received(fileUpload: self)
    }
  }
  
  private func ec() throws {
    let eventid: ID = try next()
    op = "new comment in \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    try event.comments.received(message: self)
  }
  private func ecDeleted() throws {
    let eventid: ID = try next()
    op = "comment removed from \(eventid.eventName)"
    guard let event = eventManager.online(eventid) else { return }
    try event.comments.received(remove: self)
  }
  private func eStatus() throws {
    let eventid: ID = try next()
    let previewVersion: EventPreviewVersion = try next()
    let status: EventStatus = try next()
    
    op = "event \(eventid.eventName) status changed to \(status)"
    guard let event = eventManager.online(eventid) else { return }
    event.set(previewVersion: previewVersion)
    var startTime: Time?
    var endTime: Time?
    if status == .ended {
      endTime = try next()
    } else if status == .started {
      startTime = try next()
      endTime = try next()
    }
    
    if let startTime = startTime {
      event.set(startTime: startTime)
    }
    if let endTime = endTime {
      event.set(endTime: endTime)
    }
    event.set(status: status)
  }
  private func ePrivate() throws {
    let eventid: ID = try next()
    let previewVersion: EventPreviewVersion = try next()
    let privacy: EventPrivacy = try next()
    
    op = "event \(eventid.eventName) status changed to \(privacy)"
    guard let event = eventManager.online(eventid) else { return }
    event.previewVersion = previewVersion
    event.set(privacy: privacy)
  }
  private func eName() throws {
    let eventid: ID = try next()
    let previewVersion: EventPreviewVersion = try next()
    let name: String = try next()
    
    op = "event \(eventid.eventName) changed name to \(name)"
    let event = eventManager.online(eventid)!
    event.set(previewVersion: previewVersion)
    event.set(name: name)
  }
  private func eViews() throws {
    let eventid: ID = try next()
    let count: Int = try next()
    op = "event \(eventid.eventName) changed views to \(count)"
    let event = eventManager.online(eventid)!
    event.set(views: count)
  }
  private func eCurrent() throws {
    let eventid: ID = try next()
    let count: Int = try next()
    op = "event \(eventid.eventName) changed live views to \(count)"
    let event = eventManager.online(eventid)!
    event.set(current: count)
  }
  private func eComments() throws {
    let eventid: ID = try next()
    let count: Int = try next()
    op = "event \(eventid.eventName) changed comments count to \(count)"
    let event = eventManager.online(eventid)!
    event.set(commentsCount: count)
  }
  private func systemMessage() throws {
    let text: String = try next()
    op = "system message: \(text)"
    let notification = NSystemMessage(text: text, time: Time.now)
    notificationManager.addNotification(notification)
  }
  private func reportSent() throws {
    let type: ReportType = try next()
    switch type {
    case .event:
      let id: ID = try next()
      reporter.received(event: id)
    case .user:
      let id: ID = try next()
      reporter.received(user: id)
    case .content:
      let id: ID2 = try next()
      reporter.received(content: id)
    case .comment:
      let link: MessageLink = try next()
      reporter.received(message: link)
    }
  }
  private func reportAvailable() throws {
    let count: Int = try next()
    let uncheckedCount: Int = try next()
    account.reportsCount = count
    account.uncheckedReportsCount = uncheckedCount
    ReportNotification.set(count: uncheckedCount)
  }
}

extension Server {
  func notification(command: subcmd, data: DataReader) throws {
    print("notification: \(command)")
    let data = NDataReader(data)
    var op = data.op
    defer {
      #if debug
        if settings.debug.notifications {
          "\(command): \(op)".notification(title: "Server notification", emoji: "🖥")
        }
      #endif
      op = "\(Time.now.timeFormat) \(op)"
      serverManager.notifications.append(op, max: 10, override: .first)
    }
    do {
      try data.process(command: command)
    } catch {
      serverManager.notificationCorrupted(name: data.op)
    }
  }
}


