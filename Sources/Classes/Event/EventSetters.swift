//
//  EventSetters.swift
//  Events
//
//  Created by Димасик on 1/20/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation
import SomeFunctions
import SomeBridge

extension Event {
  /*
  var id = ID()
  var name = String()
  var startTime = Time()
  var endTime = Time()
  var lat = Float()
  var lon = Float()
  var previewVersion = EventPreviewVersion()
  var preview: Content?
  
  //MARK:- public properties
  var owner = ID()
  var status = EventStatus.started
  var privacy = EventPrivacy.public
  var options = Options<EventOptions,UInt8>()
  var createdTime = Time()
  
  var counter = Counter<ID>()
  var content = [ID: Content]()
  var comments: Comments
  var invited = Set<Int>()
  var commentsCount = Int()
  var views = Int()
  var current = Int()
  
  //MARK:- private properties
  var banlist = Set<ID>()
  
  //MARK:- local properties
  var localOptions = Options<EventLocalOptions,UInt8>()
 */
  
  // main
  
  func set(id: ID) {
    let oldValue = self.id
    guard id != oldValue else { return }
    moveDirectories(to: id)
    
    self.id = id
    content.forEach { $0.eventid = id }
    comments.id = id
    
    contentManager.check(content)
    Notification.eventMain { $0.updated(id: self, oldValue: oldValue) }
    created()
  }
  func created() {
    localOptions[EventLocalOptions.isCreated] = true
    Notification.eventMain { $0.created(event: self) }
  }
  func set(name: String) {
    guard self.name != name else { return }
    self.name = name
    Notification.eventMain { $0.updated(name: self) }
  }
  func set(startTime: Time) {
    guard self.startTime != startTime else { return }
    self.startTime = startTime
    Notification.eventMain { $0.updated(startTime: self) }
  }
  func set(endTime: Time) {
    guard self.endTime != endTime else { return }
    self.endTime = endTime
    Notification.eventMain { $0.updated(endTime: self) }
  }
  func set(lat: Float, lon: Float) {
    guard !(self.lat == lat && self.lon == lon) else { return }
    self.lat = lat
    self.lon = lon
    Notification.eventMain { $0.updated(coordinates: self) }
  }
  func set(previewId: ID) {
    if preview != nil {
      guard previewId != preview!.id else { return }
    }
    guard let content = find(content: previewId) else { return }
    preview = content.preview
    Notification.eventMain { $0.updated(preview: self) }
  }
  func removePreview() {
    guard preview != nil else { return }
    preview = nil
    Notification.eventMain { $0.updated(preview: self) }
  }
  func set(preview: ContentPreview?) {
    if preview != nil && self.preview != nil {
      guard preview!.id != self.preview!.id else { return }
    }
    self.preview = preview
    Notification.eventMain { $0.updated(preview: self) }
  }
  func set(previewVersion: EventPreviewVersion) {
    self.previewVersion = previewVersion
  }
  
  // public
  func set(owner: ID) {
    guard self.owner != owner else { return }
    let previousOwner = self.owner
    self.owner = owner
    Notification.eventPublic { $0.updated(owner: self, oldValue: previousOwner) }
  }
  func set(status: EventStatus) {
    guard self.status != status else { return }
    let old = self.status
    self.status = status
    Notification.eventPublic { $0.updated(status: self, oldValue: old) }
  }
  func set(privacy: EventPrivacy) {
    guard self.privacy != privacy else { return }
    self.privacy = privacy
    Notification.eventPublic { $0.updated(privacy: self) }
  }
  func set(options: EventOptions.Set) {
    guard self.options != options else { return }
    self.options = options
    Notification.eventPublic { $0.updated(options: self) }
  }
  func set(createdTime: Time) {
    guard self.createdTime != createdTime else { return }
    self.createdTime = createdTime
    Notification.eventPublic { $0.updated(createdTime: self) }
  }
  func set(content: [Content]) {
    self.content = content
    contentManager.check(content)
    Notification.eventPublic { $0.updated(content: self) }
  }
  func set(insertContent content: Content) {
    guard !self.content.contains(content) else { return }
    self.content.sortedInsert(content) { $0.time > $1.time }
    Notification.eventPublic { $0.added(content: content, to: self) }
    
    if content.isPreviewAvailable {
      set(preview: content.preview)
    }
  }
  func set(removeContent id: ID) {
    guard let index = self.content.index(where: { $0.id == id }) else { return }
    let content = self.content[index]
    self.content.remove(at: index)
    Notification.eventPublic { $0.removed(content: content, from: self) }
    if let preview = preview, content.id == preview.id {
      updatePreview()
    }
  }
  
  func set(invited: Set<ID>) {
    let result = self.invited.merge(to: invited)
    for added in result.added {
      Notification.eventPublic { $0.invited(user: added, to: self) }
    }
    for removed in result.removed {
      Notification.eventPublic { $0.uninvited(user: removed, from: self) }
    }
    if result.added.contains(.me) || result.removed.contains(.me) {
      isContentAvailable = _canLoadContent
    }
  }
  func set(invite: ID) {
    invite.user?.insert(event: self)
    let status = invited.insert(invite)
    guard status.inserted else { return }
    Notification.eventPublic { $0.invited(user: invite, to: self) }
  }
  func set(uninvite: ID) {
    uninvite.user?.remove(event: self)
    guard invited.remove(uninvite) != nil else { return }
    Notification.eventPublic { $0.uninvited(user: uninvite, from: self) }
  }
  func insert(invited id: ID) {
    guard !invited.contains(id) else { return }
    invited.insert(id)
    Notification.eventPublic { $0.invited(user: id, to: self) }
    if id.isMe {
      isContentAvailable = _canLoadContent
    }
  }
  func remove(invited id: ID) {
    guard invited.contains(id) else { return }
    invited.remove(id)
    Notification.eventPublic { $0.uninvited(user: id, from: self) }
    if id.isMe {
      isContentAvailable = _canLoadContent
    }
  }
  func set(commentsCount: Int) {
    guard self.commentsCount != commentsCount else { return }
    self.commentsCount = commentsCount
    Notification.eventPublic { $0.updated(comments: self) }
  }
  func set(views: Int) {
    guard self.views != views else { return }
    self.views = views
    Notification.eventPublic { $0.updated(views: self) }
  }
  func set(current: Int) {
    guard self.current != current else { return }
    self.current = current
    Notification.eventPublic { $0.updated(current: self) }
  }
  
  func updatePreview() {
    preview = nil
    for c in content where c.isPreviewAvailable {
      preview = c.preview
    }
    Notification.eventMain { $0.updated(preview: self) }
  }
}
