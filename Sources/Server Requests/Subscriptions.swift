//
//  Subscriptions.swift
//  Events
//
//  Created by Димасик on 1/11/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

extension Subtype {
  var `class`: Subscription.Type {
    switch self {
    case .map: return Subscription.Map.self
    case .event: return Subscription.Event.self
    case .profile: return Subscription.Profile.self
    case .reports: return Subscription.Reports.self
    case .comments: return Subscription.Comments.self
    case .groupChat: return Subscription.GroupChat.self
    case .privateChat: return Subscription.PrivateChat.self
    case .communityChat: return Subscription.CommunityChat.self
    case .news: return Subscription.News.self
    }
  }
}

extension DataReader {
  func subscription() throws -> Subscription {
    let type: Subtype = try self.enum()
    return try type.class.init(data: self)
  }
}

class Subscription: DataRepresentable, Hashable, CustomStringConvertible {
  static var version = 0
  var type: Subtype { overrideRequired() }
  var description: String { overrideRequired() }
  var string: String { return String(type.rawValue) }
  var isValid: Bool { return true }
  func subscribed(response: DataReader) throws { overrideRequired() }
  
  init() {
    
  }
  required init(data: DataReader) throws {
    
  }
  func process(error: Response) {
    
  }
  func save(data: DataWriter) {
    data.append(type)
  }
  static func == (l: Subscription, r: Subscription) -> Bool {
    return l.description == r.description
  }
  var hashValue: Int {
    return description.hashValue
  }
  func subscribe() {
    subscriber.open(self)
  }
  func unsubscribe() {
    subscriber.close(self)
  }
  
  
  // MARK:- Profile
  class Profile: Subscription {
    override var type: Subtype { return .profile }
    override var isValid: Bool { return id >= 0 }
    override var description: String { return "profile \(id.userName)" }
    override var string: String { return "\(type.rawValue),\(id)" }
    
    let id: ID
    init(id: ID) {
      self.id = id
      super.init()
    }
    required init(data: DataReader) throws {
      id = try data.next()
      try super.init(data: data)
    }
    override func save(data: DataWriter) {
      super.save(data: data)
      data.append(id)
    }
    override func subscribed(response data: DataReader) throws {
      let user = id.user!
      try data.userMain(user: user)
      try user.set(subscribers: data.next())
      try user.set(subscriptions: data.next())
      try user.set(isSubscriber: data.next())
      try user.set(events: data.eventMains().idsSet)
    }
//    override func subscribe(connection: Connection, data: DataWriter) {
//      thread.lock()
//      defer { thread.unlock() }
//      let me = connection.user!
//      save(data: data)
//      user(id, data) { user in
//        user.write(main: data)
//        data.append(user.subscribers.count)
//        data.append(user.subscriptions.count)
//        data.append(user.subscriptions.contains(me.id))
//        data.append(user.subscriptions.contains(me.id))
//        user.events
//          .events
//          .filter { !$0.isPrivate(for: me) }
//          .eventMain(data: data)
//      }
//    }
  }
  
  
  
  // MARK:- Map
  class Map: Subscription {
    override var type: Subtype { return .map }
    override var description: String { return "map" }
    override func subscribed(response: DataReader) throws {
      let events = try response.eventMains()
      mainThread {
        mapManager.set(events: events)
      }
    }
//    override func subscribe(connection: Connection, data: DataWriter) {
//      thread.lock()
//      defer { thread.unlock() }
//      save(data: data)
//      data.ok()
//      list.online.first(500).eventMain(data: data)
//    }
  }
  
  
  
  // MARK:- Event
  class Event: Subscription {
    override var type: Subtype { return .event }
    override var isValid: Bool { return id >= 0 }
    override var description: String { return "event \(id.eventName)" }
    override var string: String { return "\(type.rawValue),\(id)" }
    
    let id: ID
    init(id: ID) {
      self.id = id
      super.init()
    }
    required init(data: DataReader) throws {
      id = try data.next()
      try super.init(data: data)
    }
    override func save(data: DataWriter) {
      super.save(data: data)
      data.append(id)
    }
    override func subscribed(response data: DataReader) throws {
      let event = try data.eventMain()
      let owner: ID = try data.next()
      
      let content = try data.contents(id)
      
      let invited: [User] = try data.userMains()
      let views: Int = try data.next()
      let current: Int = try data.next()
      let comments: Int = try data.next()
      let options: EventOptions.Set = try data.next()
      let privacy: EventPrivacy = try data.next()
      let status: EventStatus = try data.next()
      
      mainThread {
        event.set(owner: owner)
        event.set(content: content)
        event.set(invited: Set(invited.ids))
        
        event.set(views: views)
        event.set(current: current)
        event.set(commentsCount: comments)
        
        event.set(options: options)
        event.set(privacy: privacy)
        event.set(status: status)
      }
    }
//    override func subscribe(connection: Connection, data: DataWriter) {
//      thread.lock()
//      defer { thread.unlock() }
//      save(data: data)
//      event(id, data) { event in
//        event.saveMain(data: data)
//        data.append(event.owner)
//
//        data.append(contents: event.content.values)
//        data.append(event.preview?.id ?? -1)
//
//        event.invited.userMain(data: data)
//        data.append(event.views)
//        data.append(event.current)
//        data.append(event.comments.messages.count)
//        data.append(event.options)
//        data.append(event.privacy)
//        data.append(event.status)
//      }
//    }
  }
  
  
  
  // MARK:- Reports
  class Reports: Subscription {
    override var type: Subtype { return .reports }
    override var description: String { return "reports" }
    
    override func subscribed(response: DataReader) throws {
      
    }
//    override func subscribe(connection: Connection, data: DataWriter) {
//      thread.lock()
//      defer { thread.unlock() }
//      save(data: data)
//      /*
//       uint8 .ok (always ok)
//       int unchecked reports count
//       int unique unchecked reports count
//       int reports count
//       *^*
//       uint8 report type
//       int id
//       int from count
//       int accepted count
//       int declined count
//       * report body
//       */
//      data.ok()
//      let array = reports.reports(count: 50)
//      data.append(reports.count)
//      data.append(reports.uncheckedCount)
//      data.append(array.count)
//      for report in array {
//        report.preview(body: data)
//      }
//    }
  }
  
  
  // MARK:- Comments
  class Comments: IDChatSubscription {
    override var type: Subtype { return .comments }
    override var isValid: Bool { return id >= 0 }
    override var description: String { return "event comments \(id.eventName)" }
    override var string: String { return "\(type.rawValue),\(id)" }
    override var chat: Chat { return id.event.comments }
  }
  
  // MARK:- GroupChat
  class GroupChat: IDChatSubscription {
    override var type: Subtype { return .groupChat }
    override var isValid: Bool { return id >= 0 }
    override var description: String { return "group chat \(id)" }
    override var string: String { return "\(type.rawValue),\(id)" }
  }
  
  // MARK:- PrivateChat
  class PrivateChat: IDChatSubscription {
    override var type: Subtype { return .privateChat }
    override var isValid: Bool { return id >= 0 }
    override var description: String { return "private chat with \(id.userName)" }
    override var string: String { return "\(type.rawValue),\(id)" }
  }
  
  // MARK:- CommunityChat
  class CommunityChat: ChatSubscription {
    override var type: Subtype { return .communityChat }
    override var description: String { return "community chat" }
    override var chat: Chat { return .community }
  }
  
  // MARK:- News
  class News: ChatSubscription {
    override var type: Subtype { return .news }
    override var description: String { return "news" }
    override var chat: Chat { return .news }
  }
}
