//
//  reporter.swift
//  faggot
//
//  Created by Димасик on 4/28/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

/*
 Todo:
 
 Client:
 * Pushes
 * Requests
 * Page Notifications
 * Notifications
 
 * Moderator
 
 * Event report button
 * User report button
 * Content report button
 
 - User report window
 - Event report window
 - Content report window
 - Report page
 - Transition from push
 
 Server:
 - Pushes
 - Requests
 - Notifications
 
 
 Requests:
 - report user
 - report content
 - report event
 
 Notifications:
 - user reported
 - content reported
 - event reported
 
 - user banned
 - content banned
 - event banned
 
 - warned
 - banned
 
 Pushes:
 - user report
 - content report
 - event report
 
 Admin requests:
 - accept(report:)
 - decline(report:shouldProtect:)
 - warn
 - ban
 - protect
 
 Admin notifications:
 - user report
 - event report
 - content report
 
 Admin pushes:
 - reports available
 - user report
 - event report
 - content report
 */

class Moderator {
  unowned var user: User
  var reports = 0
  var accepted = 0
  var declined = 0
  var reportsProtected = 0
  
//  var userReports = [ID: UserReport]
  
  var banTime: Time?
  
  init(user: User) {
    self.user = user
  }
}

let reporter = Reporter()
class Reporter: Manager, Saveable {
  var events = Set<Int64>()
  var users = Set<Int64>()
  var content = Set<ID2>()
  var comments = Set<MessageLink>()
  var confirmCombo: UInt8 = 0
  var shouldConfirm: Bool {
    return confirmCombo < 5
  }
  func confirmed() {
    guard shouldConfirm else { return }
    confirmCombo += 1
  }
  func cancelled() {
    confirmCombo = 0
  }
  func displayConfirm(report: Report) {
    
  }
  func save(data: DataWriter) throws {
    data.append(content)
    data.append(events)
    data.append(users)
    data.append(comments)
  }
  func load(data: DataReader) throws {
    content = try data.next()
    events = try data.next()
    users = try data.next()
    comments = try data.next()
  }
  
  func received(content: ID2) {
    self.content.insert(content)
    main.npages.forEach { $0.notifications.reports.content?(content) }
  }
  
  func received(event: Int64) {
    self.events.insert(event)
    main.npages.forEach { $0.notifications.reports.event?(event) }
  }
  
  func received(user: Int64) {
    self.users.insert(user)
    main.npages.forEach { $0.notifications.reports.user?(user) }
  }
  
  func received(message: MessageLink) {
    self.comments.insert(message)
    main.npages.forEach { $0.notifications.reports.comment?(message) }
  }
  
  func reportsAvailable(count: Int) {
    guard isModerator else { return }
    ReportNotification.set(count: count)
  }
}

extension Content {
  private var contentId: ID2 {
    return ID2(eventid,id)
  }
  var isReported: Bool {
    return reporter.content.contains(contentId)
  }
  @discardableResult
  func report(reason: ContentRules) -> StreamOperations? {
    guard !isReported else { return nil }
    let report = ContentReportBlank(id: contentId, reason: reason)
    return report.send()
  }
}

extension Event {
  var isReported: Bool { return reporter.events.contains(id) }
  @discardableResult
  func report(reason: EventRules) -> StreamOperations? {
    guard !isReported else { return nil }
    let report = EventReportBlank(id: id, reason: reason)
    return report.send()
  }
}

extension User {
  var isReported: Bool { return reporter.users.contains(id) }
  @discardableResult
  func report(reason: UserRules) -> StreamOperations? {
    guard !isReported else { return nil }
    let report = UserReportBlank(id: id, reason: reason)
    return report.send()
  }
}

private protocol MessageExtension {
  var message: Message { get }
  init(message: Message)
  var index: Int { get }
  var from: ID { get }
  var time: Time { get }
  var body: String { get }
  var localOptions: MessageLocalOptions.Set { get }
  var isDeleted: Bool { get }
  var chat: Chat { get }
}
private extension MessageExtension {
  var index: Int { return message.index }
  var from: ID { return message.from }
  var time: Time { return message.time }
  var body: String { return message.string }
  var localOptions: MessageLocalOptions.Set { return message.localOptions }
  var isDeleted: Bool { return message.isDeleted }
  var chat: Chat { return message.chat }
}

extension Message {
//  var comment: Comment { return Comment(message: self) }
  var isReported: Bool { return reporter.comments.contains(link) }
  var isReportable: Bool { return chat.isReportable(message: self) }
  @discardableResult
  func report(reason: MessageRules) -> StreamOperations? {
    guard isReportable else { return nil }
    let report = CommentReportBlank(link: link, reason: reason)
    return report.send()
  }
}

//struct Comment: MessageExtension {
//  fileprivate let message: Message
//  fileprivate init(message: Message) {
//    self.message = message
//  }
//  var comments: Comments {
//    return message.chat as! Comments
//  }
//  var event: Event {
//    return comments.event
//  }
//  var commentId: ID2 {
//    return ID2(event.id, Int64(index))
//  }
//}
