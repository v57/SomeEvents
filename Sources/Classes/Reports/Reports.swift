//
//  Reports.swift
//  SomeEvents
//
//  Created by Димасик on 11/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeBridge
import SomeNetwork

class ReportBlank {
  var type: ReportType { overrideRequired() }
  func insert() { overrideRequired() }
  init() {}
  func send() -> StreamOperations {
    return server.request()
      .rename("report(\(type):)")
      .request { data in
        self.write(data: data)
    }
  }
  func write(data: DataWriter) {
    data.append(cmd.report)
    data.append(type)
  }
}

class UserReportBlank: ReportBlank {
  override var type: ReportType { return .user }
  override func insert() {
    reporter.received(user: id)
  }
  let id: ID
  let reason: UserRules
  init(id: ID, reason: UserRules) {
    self.id = id
    self.reason = reason
    super.init()
  }
  override func write(data: DataWriter) {
    super.write(data: data)
    data.append(id)
    data.append(reason)
  }
}

class EventReportBlank: ReportBlank {
  override var type: ReportType { return .event }
  override func insert() {
    reporter.received(event: id)
  }
  let id: ID
  let reason: EventRules
  init(id: ID, reason: EventRules) {
    self.id = id
    self.reason = reason
    super.init()
  }
  override func write(data: DataWriter) {
    super.write(data: data)
    data.append(id)
    data.append(reason)
  }
}


class ContentReportBlank: ReportBlank {
  override var type: ReportType { return .content }
  override func insert() {
    reporter.received(content: id)
  }
  let id: ID2
  let reason: ContentRules
  init(id: ID2, reason: ContentRules) {
    self.id = id
    self.reason = reason
    super.init()
  }
  override func write(data: DataWriter) {
    super.write(data: data)
    data.append(id)
    data.append(reason)
  }
}

class CommentReportBlank: ReportBlank {
  override var type: ReportType { return .comment }
  override func insert() {
    reporter.received(message: link)
  }
  let link: MessageLink
  let reason: MessageRules
  init(link: MessageLink, reason: MessageRules) {
    self.link = link
    self.reason = reason
    super.init()
  }
  override func write(data: DataWriter) {
    super.write(data: data)
    data.append(link)
    data.append(reason)
  }
}



extension ReportType {
  var classType: Report.Type {
    switch self {
    case .user:
      return UserReport.self
    case .event:
      return EventReport.self
    case .content:
      return ContentReport.self
    case .comment:
      return CommentReport.self
    }
  }
}
class Report {
  var reportId: ID
  var fromCount: Int
  var acceptedCount: Int
  var declinedCount: Int
  var type: ReportType { overrideRequired() }
  
  init() {
    self.reportId = 0
    self.fromCount = 0
    self.acceptedCount = 0
    self.declinedCount = 0
  }
  
  required init(data: DataReader) throws {
    reportId = try data.next()
    fromCount = try data.next()
    acceptedCount = try data.next()
    declinedCount = try data.next()
  }
  
  func accept() {
    server.request()
      .rename("report(\(type):)")
      .request { data in
        data.append(cmd.acceptReport)
        data.append(self.type)
        data.append(self.reportId)
    }
  }
  func decline() {
    server.request()
      .rename("report(\(type):)")
      .request { data in
        data.append(cmd.declineReport)
        data.append(self.type)
        data.append(self.reportId)
    }
  }
}

class UserReport: Report {
  var id = ID()
  var reason = UserRules.other
  override var type: ReportType { return .user }
  
  override init() {
    super.init()
  }
  
  required init(data: DataReader) throws {
    try super.init(data: data)
    id = try data.next()
    reason = try data.next()
  }
}

class EventReport: Report {
  var id = ID()
  var reason = EventRules.other
  var event: Event? {
    return id.event
  }
  override var type: ReportType { return .event }
  
  override init() {
    super.init()
  }
  
  required init(data: DataReader) throws {
    try super.init(data: data)
    id = try data.next()
    reason = try data.next()
  }
}

class ContentReport: Report {
  var id = ID2()
  var reason = ContentRules.other
  var event: Event? {
    return id.x.event
  }
  var content: Content? {
    return event?.find(content: id.y)
  }
  override var type: ReportType { return .content }
  
  override init() {
    super.init()
  }
  
  required init(data: DataReader) throws {
    try super.init(data: data)
    id = try data.next()
    reason = try data.next()
  }
}

class CommentReport: Report {
  var link = MessageLink()
  var reason = MessageRules.other
  var comment: Message? {
    return link.message
  }
  override var type: ReportType { return .comment }
  override init() {
    super.init()
  }
  
  required init(data: DataReader) throws {
    try super.init(data: data)
    link = try data.next()
    reason = try data.next()
  }
}
