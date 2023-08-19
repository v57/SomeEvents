//
//  class-comments.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge

class Comments: Chat {
  var id: ID
  var event: Event { return id.event }
  var options = CommentsOptions.Set()
  var isEnabled: Bool { return !options[.disabled] }
  override var subscription: ChatSubscription { return Subscription.Comments(id: id) }
  override var canSend: Bool { return isEnabled && !event.isPrivateForMe }
  override func canDelete(message: Message) -> Bool {
    return message.from.isMe || event.isMy()
  }
  override var canClear: Bool { return event.isOwner }
  override var path: String { return "events/\(id)/comments/" }
  override var type: ChatType {
    return .comments
  }
  override var hashValue: Int {
    return super.hashValue &* 0x5cc435a5 &+ id.hashValue
  }
  override func write(link: DataWriter) {
    super.write(link: link)
    link.append(id)
  }
  override class func read(link: DataReader) throws -> Comments {
    let id = try link.id()
    guard let chat = id.event?.comments else { throw notFound }
    return chat
  }
  
  init(id: ID) {
    self.id = id
    super.init()
  }
  required init(data: DataReader) throws {
    id = try data.next()
    if Chat.version >= 3 {
      options = try data.next()
    }
    try super.init(data: data)
  }
  override func save(data: DataWriter) {
    data.append(id)
    data.append(options)
    super.save(data: data)
  }
  
  func updateCount() {
    event.set(commentsCount: size + sending.count)
  }
  
  override func received(messages data: DataReader) throws {
    let options: CommentsOptions.Set = try data.next()
    try super.received(messages: data)
    set(options: options)
  }
  override func added(last elements: [Message]) {
    super.added(last: elements)
    updateCount()
    Notification.comments { $0.appended(messages: elements, in: self) }
  }
  override func added(first elements: [Message]) {
    super.added(first: elements)
    Notification.comments { $0.inserted(messages: elements, in: self) }
  }
  override func replaced(elements: [Message]) {
    super.replaced(elements: elements)
  }
  override func deleted(message: Message) {
    super.deleted(message: message)
    Notification.comments { $0.replaced(message: message, in: self) }
  }
  override func edited(message: Message) {
    super.edited(message: message)
    Notification.comments { $0.replaced(message: message, in: self) }
  }
  override func removeSending() {
    super.removeSending()
    Notification.comments { $0.removeSending(comments: self) }
  }
  override func cleared() {
    super.cleared()
    updateCount()
    Notification.comments { $0.cleared(comments: self) }
  }
  func set(options: CommentsOptions.Set) {
    self.options = options
  }
}

extension Comments: Equatable {
  static func ==(lhs: Comments, rhs: Comments) -> Bool {
    return lhs.event == rhs.event
  }
}

protocol CommentsNotifications {
  func appended(messages: [Message], in comments: Comments)
  func inserted(messages: [Message], in comments: Comments)
  func replaced(message: Message, in comments: Comments)
  func cleared(comments: Comments)
  func removeSending(comments: Comments)
}

extension Notification {
  static func comments(body: (CommentsNotifications)->()) {
    sendNotification(CommentsNotifications.self, body)
  }
}

