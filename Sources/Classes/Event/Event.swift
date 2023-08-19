//
//  event.swift
//  faggot
//
//  Created by Димасик on 2/18/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeNetwork
import SomeBridge
//import Some

extension Int64 {
  static var me: Int64 { return session?.id ?? -1 }
}

enum EventType {
  case common, planned
}

enum EventLocalOptions: UInt8 {
  case isCreated, isContentAvailable
}

class ContentPreview: DataRepresentable {
  var id: ID
  let type: ContentType
  let event: ID
  var downloadType: DownloadType {
    switch type {
    case .photo: return .photoPreview(content: self)
    case .video: return .videoPreview(content: self)
    }
  }
  required init(data: DataReader) throws {
    id = try data.next()
    type = try data.next()
    event = try data.next()
  }
  func save(data: DataWriter) {
    data.append(id)
    data.append(type)
    data.append(event)
  }
  init(id: ID, type: ContentType, event: ID) {
    self.id = id
    self.type = type
    self.event = event
  }
  static func == (l:ContentPreview,r:ContentPreview) -> Bool {
    return l.id == r.id
  }
}
extension ContentPreview: CustomStringConvertible {
  var description: String { return "\(event)-\(id)-\(type)" }
}

class Event: Equatable, Versionable, Hashable {
  static var version = Version(1)
  
  //MARK:- main properties
  var id = ID()
  var name = String()
  var startTime = Time()
  var endTime = Time()
  var lat = Float()
  var lon = Float()
  var previewVersion = EventPreviewVersion()
  var preview: ContentPreview?
  
  func loadMain(data: DataReader) throws {
    id = try data.next()
    name = try data.next()
    startTime = try data.next()
    endTime = try data.next()
    lat = try data.next()
    lon = try data.next()
    previewVersion = try data.next()
  }
  func saveMain(data: DataWriter) {
    data.append(id)
    data.append(name)
    data.append(startTime)
    data.append(endTime)
    data.append(lat)
    data.append(lon)
    data.append(previewVersion)
  }
  
  //MARK:- public properties
  var owner = ID()
  var status = EventStatus.started
  var privacy = EventPrivacy.public
  var options = EventOptions.Set()
  var createdTime = Time()
  
  var counter = Counter<ID>()
  var content = [Content]()
  var comments: Comments
  var invited = Set<ID>()
  var commentsCount = Int()
  var views = Int()
  var current = Int()
  
  func loadPublic(data: DataReader) throws {
    owner = try data.next()
    status = try data.next()
    privacy = try data.next()
    options = try data.next()
    createdTime = try data.next()
    
    counter = try data.next()
    preview = try data.next()
    content = try data.array { try data.contentType().class.init(data: data) }
    invited = try data.next()
    views = try data.next()
    current = try data.next()
  }
  func savePublic(data: DataWriter) {
    data.append(owner)
    data.append(status)
    data.append(privacy)
    data.append(options)
    data.append(createdTime)
    
    data.append(counter)
    data.append(preview)
    data.append(content.count)
    for c in content {
      data.append(c.type)
      data.append(c)
    }
    data.append(invited)
    data.append(views)
    data.append(current)
  }
  
  //MARK:- private properties
  var banlist = Set<ID>()
  
  func loadPrivate(data: DataReader) throws {
    banlist = try data.next()
  }
  func savePrivate(data: DataWriter) {
    data.append(banlist)
  }
  
  //MARK:- local properties
  var localOptions = EventLocalOptions.Set()
  
  func loadLocal(data: DataReader) throws {
    localOptions = try data.next()
  }
  func saveLocal(data: DataWriter) {
    data.append(localOptions)
  }
  
  ///////////////////////
  // MARK:- Init
  ///////////////////////
  
  init(id: ID) {
    self.id = id
    createdTime = .now
    status = .started
    
    comments = Comments(id: id)
    
    createDirectories()
  }
  
  init(data: DataReader) throws {
    comments = try data.next()
    try loadMain(data: data)
    try loadPublic(data: data)
    try loadPrivate(data: data)
  }
  func save(data: DataWriter) {
    data.append(comments)
    saveMain(data: data)
    savePublic(data: data)
    savePrivate(data: data)
  }
  
  
  
  
  func find(content id: ID) -> Content? {
    guard let i = self.content.index(where: { $0.id == id }) else { return nil }
    return content[i]
  }
}

extension Int64 {
  var event: Event! {
    return eventManager.get(self)
  }
  var eventName: String {
    #if debug
    if let event = event {
      return "\(event.name) (\(self))"
    } else {
      return "unknown (\(self))"
    }
    #else
      if let event = event {
        return "\(event.name)"
      } else {
        return "unknown"
      }
    #endif
  }
  func contentName(in eventid: ID) -> String {
    do {
      let content = try self.content(in: eventid)
      return content.name
    } catch {
      return "\(self)"
    }
  }
  func content(in event: ID) throws -> Content {
    if let c = event.event.find(content: self) {
      return c
    } else {
      throw notFound
    }
  }
}

extension DataReader {
  func eventMains() throws -> [Event] {
    var array = [Event]()
    let count = try intCount()
    for _ in 0..<count {
      try array.append(eventMain())
    }
    return array
  }
  func eventMain(event: Event) throws {
    try event.name = next()
    try event.startTime = next()
    try event.endTime = next()
    try event.status = next()
    event.privacy = .public
    try event.lat = next()
    try event.lon = next()
    try event.options = next()
    try event.preview = contentPreview(event.id)
  }
  func eventMain(id: ID) throws -> Event {
    let event = eventManager.reserve(id)
    try eventMain(event: event)
    return event
//    if let event = id.event {
//      try eventMain(event: event)
//    } else {
//      let event = eventManager.reserve(id)
//
//    }
  }
  func eventMain() throws -> Event {
    let id: ID = try next()
    return try eventMain(id: id)
  }
}

extension Sequence where Iterator.Element == Event {
  var ids: [Int64] { return map { $0.id } }
  var idsSet: Set<Int64> {
    var set = Set<Int64>()
    self.forEach { set.insert($0.id) }
    return set
  }
}

extension Sequence where Iterator.Element == Int64 {
  var events: [Event] { return map { eventManager.get($0)! } }
  var eventNames: String {
    var string = ""
    for id in self {
      if string.isEmpty {
        string += id.eventName
      } else {
        string += ", \(id.eventName)"
      }
    }
    return string
  }
}

extension Sequence where Iterator.Element == Event {
  static var my: [Event] { return User.me.events.events }
}

extension Event {
  var isOwner: Bool {
    return owner.isMe
  }
  var isInvited: Bool {
    return invited.contains(.me)
  }
  func isMy() -> Bool {
    return User.me.events.contains(id)
  }
}

protocol EventDelegate: class {
  var event: Event {get set}
  @discardableResult
  func eventVideoAdded(_ video: Content) -> EventCell!
  @discardableResult
  func eventPhotoAdded(_ photo: Content) -> EventCell!
}




/*
 extension Event {
 
 var id: Int64
 var content = [Content]()
 var photos: [Content] { return content.filter { $0.type == .photo } }
 var videos: [Content] { return content.filter { $0.type == .video } }
 var owner: Int64 = -1
 
 // main data
 var options = Options<EventOptions,UInt8>()
 var name = ""
 var lat: Float = 0
 var lon: Float = 0 // event position
 var hasCoordinates: Bool { return !(lat == 0 && lon == 0) }
 var preview: ContentPreview?
 var created: Time
 var lastModified: Time
 var status: EventStatus
 var isStarted: Bool { return startTime < .now }
 var statusString: String? {
 if isBanned {
 return "banned"
 } else if isRemoved {
 return "removed"
 } else {
 switch status {
 case .ended:
 return nil
 case .paused:
 if startTime > .now {
 return EPTopView.format(time: startTime)
 } else {
 return "paused"
 }
 case .started:
 return "live"
 }
 }
 }
 var isPrivateForMe: Bool {
 return isPrivate && !isMy()
 }
 
 // online data
 var views = 0
 var current = 0
 var comments = 0
 
 var isPrivate = false
 
 var invited = Set<Int64>()
 
 var _comments: Comments
 
 // event info
 var startTime: Time = 0
 var endTime: Time = 0
 var age = 0
 
 // local data
 var online = true
 
 var canLoadContent = true
 var isBanned: Bool {
 optio
 let implementationNeeded: Int
 fatalError()
 }
 var isRemoved: Bool {
 let implementationNeeded: Int
 fatalError()
 }
 
 var _canLoadContent: Bool {
 if isBanned || isRemoved || (isPrivate && !invited.contains(.me)) {
 return false
 } else {
 return true
 }
 }
 
 // setters
 func set(id: Int64) {
 moveDirectories(to: id)
 self.id = id
 for c in content {
 c.eventid = id
 }
 contentManager.check(content)
 }
 func insert(content: Content) {
 self.content.sortedInsert(content) { $0.time > $1.time }
 for page in main.npages {
 page.notifications.event.contentAdded?(self, [content])
 }
 if let editor = content.editor {
 editor.onPreview {
 self.set(preview: content.preview)
 }
 } else {
 set(preview: content.preview)
 }
 }
 func set(content: [Content]) {
 self.content = content
 contentManager.check(content)
 for page in main.npages {
 page.notifications.event.content?(self)
 }
 }
 func set(owner: Int64) {
 guard self.owner != owner else { return }
 let previousOwner = self.owner
 self.owner = owner
 for page in main.npages {
 page.notifications.event.owner?(self,previousOwner)
 }
 }
 func set(name: String) {
 guard self.name != name else { return }
 self.name = name
 for page in main.npages {
 page.notifications.event.name?(self)
 }
 }
 func set(lat: Float, lon: Float) {
 guard !(self.lat == lat && self.lon == lon) else { return }
 self.lat = lat
 self.lon = lon
 for page in main.npages {
 page.notifications.event.coordinates?(self)
 }
 }
 func set(preview: ContentPreview?) {
 if preview != nil && self.preview != nil {
 guard preview!.id != self.preview!.id else { return }
 }
 self.preview = preview
 for page in main.npages {
 page.notifications.event.preview?(self)
 }
 }
 func set(created: Time) {
 guard self.created != created else { return }
 self.created = created
 for page in main.npages {
 page.notifications.event.created?(self)
 }
 }
 func set(lastModified: Time) {
 guard self.lastModified != lastModified else { return }
 self.lastModified = lastModified
 for page in main.npages {
 page.notifications.event.lastModified?(self)
 }
 }
 func set(views: Int) {
 guard self.views != views else { return }
 self.views = views
 for page in main.npages {
 page.notifications.event.views?(self)
 }
 }
 func set(current: Int) {
 guard self.current != current else { return }
 self.current = current
 for page in main.npages {
 page.notifications.event.current?(self)
 }
 }
 func set(comments: Int) {
 guard self.comments != comments else { return }
 self.comments = comments
 for page in main.npages {
 page.notifications.event.comments?(self)
 }
 }
 func set(isPrivate: Bool) {
 guard self.isPrivate != isPrivate else { return }
 self.isPrivate = isPrivate
 for page in main.npages {
 page.notifications.event.isPrivate?(self)
 }
 }
 func set(status: EventStatus) {
 guard self.status != status else { return }
 self.status = status
 for page in main.npages {
 page.notifications.event.status?(self)
 }
 }
 func set(invited: Set<Int64>) {
 let result = self.invited.merge(to: invited)
 for page in main.npages {
 for added in result.added {
 page.notifications.event.invited?(self,added)
 }
 for removed in result.removed {
 page.notifications.event.uninvited?(self,removed)
 }
 }
 if result.added.contains(.me) || result.removed.contains(.me) {
 set(canLoadContent: _canLoadContent)
 }
 }
 func set(canLoadContent: Bool) {
 guard self.canLoadContent != canLoadContent else { return }
 self.canLoadContent = canLoadContent
 for page in main.npages {
 page.notifications.event.canLoadContent?(self)
 }
 set(canLoadContent: _canLoadContent)
 }
 func insert(invited id: Int64) {
 guard !invited.contains(id) else { return }
 invited.insert(id)
 main.npages.forEach { $0.notifications.event.uninvited?(self,id) }
 }
 func remove(invited id: Int64) {
 guard invited.contains(id) else { return }
 invited.remove(id)
 main.npages.forEach { $0.notifications.event.uninvited?(self,id) }
 }
 func set(startTime: Time) {
 guard self.startTime != startTime else { return }
 self.startTime = startTime
 for page in main.npages {
 page.notifications.event.startTime?(self)
 }
 }
 func set(endTime: Time) {
 guard self.endTime != endTime else { return }
 self.endTime = endTime
 for page in main.npages {
 page.notifications.event.endTime?(self)
 }
 }
 func set(age: Int) {
 guard self.age != age else { return }
 self.age = age
 for page in main.npages {
 page.notifications.event.age?(self)
 }
 }
 func set(online: Bool) {
 guard self.online != online else { return }
 self.online = online
 for page in main.npages {
 page.notifications.event.online?(self)
 }
 }
 
 init(id: Int64) {
 self.id = id
 created = Time.now
 lastModified = Time.now
 status = .started
 
 _comments = Comments()
 
 createDirectories()
 
 _comments.event = self
 }
 init(data: DataReader) throws {
 
 id = try data.next()
 name = try data.next()
 owner = try data.next()
 status = try data.next()
 canLoadContent = try data.next()
 
 lat = try data.next()
 lon = try data.next()
 created = try data.next()
 lastModified = try data.next()
 _comments = try Comments(data: data)
 _comments.event = self
 
 views = try data.next()
 current = try data.next()
 comments = try data.next()
 isPrivate = try data.next()
 invited = try data.next()
 
 startTime = try data.next()
 endTime = try data.next()
 
 let hasContent: Bool = try data.next()
 if hasContent {
 let id: ID = try data.next()
 let type = try data.contentType()
 preview = ContentPreview(id: id, type: type, event: self.id)
 }
 
 let contentCount: Int = try data.next()
 guard contentCount > 0 else { return }
 
 for _ in 0..<contentCount {
 let c = try data.dataContent()
 content.append(c)
 }
 content.sort(by: { $0.time > $1.time } )
 //    for c in content {
 //      print(c.id, c.time)
 //    }
 }
 func save(data: DataWriter) {
 data.append(id)
 data.append(name)
 data.append(owner)
 data.append(status)
 data.append(canLoadContent)
 
 data.append(lat)
 data.append(lon)
 data.append(created)
 data.append(lastModified)
 _comments.save(data: data)
 
 data.append(views)
 data.append(current)
 data.append(comments)
 data.append(isPrivate)
 data.append(invited)
 
 data.append(startTime)
 data.append(endTime)
 
 if let preview = preview {
 data.append(true)
 data.append(preview.id)
 data.append(preview.type)
 } else {
 data.append(false)
 }
 
 data.append(content.count)
 guard content.count > 0 else { return }
 
 for c in content {
 data.append(c.type)
 c.save(data: data)
 }
 }
 }
 */
