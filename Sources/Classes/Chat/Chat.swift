//
//  class-chat.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

/*
 message duplicates on send
 remove sending messages
 
 message types:
 text
 photo
 video
 audio
 file
 attributed text
 content
 event
 reply
 forward
 pool
 */

class MessageLink: Hashable, DataRepresentable {
  var data: Data
  var message: Message? {
    do {
      let data = DataReader(data: self.data)
      let type: ChatType = try data.next()
      let chat = try type.class.read(link: data)
      let index = try data.int()
      return chat[index]
    } catch {
      return nil
    }
  }
  init() {
    data = Data()
  }
  init(message: Message) {
    let data = DataWriter()
    data.append(message.chat.type)
    message.chat.write(link: data)
    data.append(message.index)
    self.data = data.data
  }
  required init(data: DataReader) throws {
    let position = data.position
    let type: ChatType = try data.next()
    do {
      _ = try type.class.read(link: data)
    } catch MainError.notFound {
      
    } catch {
      throw error
    }
    _ = try data.int()
    self.data = data.data[position..<data.position].copy()
  }
  func save(data: DataWriter) {
    data.append(self.data)
  }
  static func == (l:MessageLink,r:MessageLink) -> Bool {
    return l.data == r.data
  }
  var hashValue: Int {
    return data.hashValue
  }
}

enum ChatType: UInt8 {
  case comments, community, news
  var `class`: Chat.Type {
    switch self {
    case .comments:
      return Comments.self
    case .community:
      return CommunityChat.self
    case .news:
      return NewsChat.self
    }
  }
}

extension DataReader {
  func chat() throws -> Chat {
    let type: ChatType = try next()
    return try type.class.read(link: self)
  }
}
struct ChatLink: DataRepresentable {
  var chat: Chat
  init(data: DataReader) throws {
    let type: ChatType = try data.next()
    chat = try type.class.read(link: data)
  }
  func save(data: DataWriter) {
    data.append(chat.type)
    chat.write(link: data)
  }
}

//MARK:- Chat
class Chat: ArrayPart<Message>, DataRepresentable, Versionable {
  static var version = Version(3)
  var sending = [Message]()
  
  var localIds = Counter<Int32>(Int32.random())
  var lastEdit: Int = 0
  var users = Set<ID>()
  
  var hashValue: Int { return type.hashValue }
  
  var subscription: ChatSubscription {
    overrideRequired()
  }
  var canSend: Bool {
    overrideRequired()
  }
  func canDelete(message: Message) -> Bool {
    return message.from.isMe
  }
  var canClear: Bool {
    overrideRequired()
  }
  var path: String { overrideRequired() }
  var url: FileURL { return path.cacheURL }
  var tempURL: FileURL { return path.tempURL }
  var type: ChatType { overrideRequired() }
  func write(link: DataWriter) {
    link.append(type)
  }
  class func read(link: DataReader) throws -> Chat {
    throw corrupted
  }
  func isReportable(message: Message) -> Bool {
    return !message.isReported && !message.from.isMe && !message.from.isFriend
  }
  
  var delegates = [ChatDelegate]()
  func open(subscribe delegate: ChatDelegate) {
    guard !delegates.contains(where: { $0 === delegate }) else { return }
    delegates.append(delegate)
    open()
  }
  func close(unsubscribe delegate: ChatDelegate) {
    close()
    guard let index = delegates.index(where: { $0 === delegate }) else { return }
    delegates.remove(at: index)
  }
  
  override init() {
    super.init()
  }
  required init(data: DataReader) throws {
    super.init()
    try load(data: data)
  }
  func load(data: DataReader) throws {
    if Chat.version < 2 {
      _ = try data.int()
    }
    lastEdit = try data.next()
    indexOffset = try data.next()
    size = try data.next()
    array = try decodeMessages(with: data, fromServer: false)
    for message in array {
      users.insert(message.from)
    }
  }
  func save(data: DataWriter) {
    data.append(lastEdit)
    data.append(indexOffset)
    data.append(size)
    encode(messages: array, to: data)
  }
  
  
  
  func forEach(body: (Message)->()) {
    array.forEach(body)
    if isLastLoaded {
      sending.forEach(body)
    }
  }
  func find(sending localId: Int32) -> Int? {
    return sending.index(where: { $0.localId == localId })
  }
  func received(message data: DataReader) throws {
    let message = try decodeMessage(with: data, fromServer: true)
    if message.from.isMe, let index = find(sending: message.localId) {
      let local = sending[index]
      local.set(index: message.index)
      local.time = message.time
      sending.remove(at: index)
      insert(local, notify: false)
    } else {
      insert(message)
    }
  }
  func received(messages data: DataReader) throws {
    let users = try data.userMains()
    self.users = Set(users.map { $0.id })
    let size: Int = try data.next()
    let messages = try decodeMessages(with: data, fromServer: true)
    insert(messages)
    for message in messages where message.from.isMe {
      message.checkUploads()
    }
    
    lastEdit = try data.next()
    let edited: [Message] = try data.array {
      let index: Int = try data.next()
      return try Message(data: data, fromServer: true, index: index, chat: self)
    }
    for message in edited {
      insert(message)
    }
    set(size: size)
  }
  func received(edit data: DataReader) throws {
    let message = try decodeMessage(with: data, fromServer: true)
    insert(message)
    self.edited(message: message)
  }
  func received(remove data: DataReader) throws {
    let index: Int = try data.next()
    guard let message = self[index] else { return }
    guard !message.isDeleted else { return }
    message.deleted()
    deleted(message: message)
  }
  func received(clear data: DataReader) throws {
    clear()
    cleared()
  }
  func received(fileUpload data: DataReader) throws {
    let index: Int = try data.next()
    let subindex: Int = try data.next()
    guard let message = self[index] else { return }
    guard let storable = message.storableMessage(at: subindex) else { return }
    storable.uploaded()
    uploaded(message: message, storable: storable, subindex: subindex)
  }
  override func updated(isLastLoaded: Bool) {
    if isLastLoaded {
      if !sending.isEmpty {
        added(last: sending)
      }
    } else {
      removeSending()
    }
  }
  
  
  // MARK: notifications
  override func added(last elements: [Message]) {
    delegates.forEach { $0.appended(messages: elements, in: self) }
  }
  override func added(first elements: [Message]) {
    delegates.forEach { $0.inserted(messages: elements, in: self) }
  }
  func edited(message: Message) {
    delegates.forEach { $0.replaced(message: message, in: self) }
  }
  func deleted(message: Message) {
    delegates.forEach { $0.replaced(message: message, in: self) }
  }
  func uploaded(message: Message, storable: StorableMessage, subindex: Int) {
    delegates.forEach { $0.uploaded(message: message, storable: storable, subindex: subindex) }
  }
  func removeSending() {
    delegates.forEach { $0.removeSending(chat: self) }
  }
  func cleared() {
    delegates.forEach { $0.cleared(chat: self) }
  }
}

// MARK: Getters
private extension Chat {
  var shouldDisplaySendingMessages: Bool {
    return isLastLoaded
  }
}

// MARK: Requests
extension Chat {
  @discardableResult
  func send(message: Message) -> StreamOperations? {
    sending.append(message)
    if isLastLoaded {
      added(last: [message])
    }
    guard !settings.test.disableChatSending else { return nil }
    let operations = server.request()
      .rename("message.send(\(message.body))")
      .autorepeat()
      .request { data in
        data.append(cmd.chat)
        data.append(ChatCommands.send)
        self.write(link: data)
        message.write(to: data, toServer: true, writeUser: false)
      }
      .read { data in
        try data.response()
    }
    return operations
  }
  @discardableResult
  func send(text: String) -> StreamOperations? {
    let message = Message(index: -1, body: [.text(text)], chat: self)
    return send(message: message)
  }
  @discardableResult
  func send(attachments: [AttachmentType]) -> StreamOperations? {
    let message = Message(index: -1, body: attachments, chat: self)
    return send(message: message)
  }
  @discardableResult
  func edit(message: Message) -> StreamOperations {
    return server.request()
      .rename("message.edit()")
      .autorepeat()
      .request { data in
        data.append(cmd.chat)
        data.append(ChatCommands.edit)
        self.write(link: data)
        data.append(message.index)
        message.write(to: data, toServer: true, writeUser: false)
      }
      .checkResponse()
  }
  @discardableResult
  func delete(message: Message) -> StreamOperations? {
    return server.request()
      .rename("message.delete()")
      .autorepeat()
      .request { data in
        data.append(cmd.chat)
        data.append(ChatCommands.delete)
        self.write(link: data)
        data.append(message.index)
      }
      .checkResponse()
  }
  @discardableResult
  func clear() -> StreamOperations {
    return server.request()
      .rename("chat.clear()")
      .autorepeat()
      .request { data in
        data.append(cmd.chat)
        data.append(ChatCommands.clear)
        self.write(link: data)
      }
      .checkResponse()
  }
}

// MARK:- Subscription
extension Chat {
  func open() {
    subscription.subscribe()
  }
  func close() {
    subscription.unsubscribe()
  }
}

// MARK: Encoding
private extension Chat {
  func encode(messages: [Message], to data: DataWriter) {
    if messages.isEmpty {
      data.append(0)
      data.append(0)
    } else {
      data.append(messages.first!.index)
      data.append(messages.count)
      for message in messages {
        encode(message: message, to: data, writeUser: true)
      }
    }
  }
  func encode(message: Message, to data: DataWriter, writeUser: Bool) {
    message.write(to: data, toServer: false, writeUser: writeUser)
  }
  func decodeMessage(with data: DataReader, fromServer: Bool, index: Int) throws -> Message {
    return try Message(data: data, fromServer: fromServer, index: index, chat: self)
  }
  func decodeMessage(with data: DataReader, fromServer: Bool) throws -> Message {
    let index: Int = try data.next()
    return try decodeMessage(with: data, fromServer: fromServer, index: index)
  }
  func decodeMessages(with data: DataReader, fromServer: Bool) throws -> [Message] {
    let start: Int = try data.next()
    let count: Int = try data.next()
    var array = [Message]()
    array.reserveCapacity(Int(count))
    for i in 0..<count {
      let message = try decodeMessage(with: data, fromServer: fromServer, index: start+i)
      array.append(message)
    }
    return array
  }
}

// MARK:- Message

enum MessageLocalOptions: UInt8 {
  case isDeleted
}

final class Message: IndexedElement, Versionable {
  static var version = Version(3)
  var index: Int
  var from: ID
  var time: Time
  var localId: Int32
  var body: MessageBody
  var localOptions: MessageLocalOptions.Set
  var isDeleted: Bool { return body.isDeleted }
  var isSending: Bool { return index < 0 }
  var isDeletable: Bool { return chat.canDelete(message: self) }
  let chat: Chat
  lazy var link: MessageLink = { MessageLink(message: self) }()
  
  init(index: Int, body: [AttachmentType], chat: Chat) {
    self.index = index
    self.from = .me
    self.time = .now
    self.localId = chat.localIds.next()
    self.body = MessageBody()
    self.localOptions = MessageLocalOptions.Set()
    self.chat = chat
    self.body = MessageBody(attachments: body, superMessage: self)
  }
  
  required init(data: DataReader, fromServer: Bool, index: Int, chat: Chat) throws {
    self.chat = chat
    if Message.version < 2 && !fromServer {
      self.index = try data.next()
    } else {
      self.index = index
    }
    from = try data.next()
    time = try data.next()
    localId = try data.next()
    if !fromServer {
      localOptions = try data.next()
    } else {
      localOptions = MessageLocalOptions.Set()
    }
//    print(localOptions.description(withInit: { MessageLocalOptions(rawValue: $0) }), localOptions.rawValue)
    if Message.version < 3 && !fromServer {
      let text = try data.string()
      body = MessageBody(text: text)
    } else {
      body = try data.next()
    }
  }
  
  func set(index: Int) {
    let oldValue = self.index
    self.index = index
    body.indexChanged(message: self, oldValue: oldValue)
  }
  
  func write(to data: DataWriter, toServer: Bool, writeUser: Bool) {
    if writeUser {
      data.append(from)
    }
    data.append(time)
    data.append(localId)
    if !toServer {
      data.append(localOptions)
    }
    data.append(body)
  }
  
  func checkUploads() {
    for body in self.body.messages {
      (body as? StorableMessage)?.checkUpload(message: self)
    }
  }
}

// MARK: ChatCommands
extension Message {
  @discardableResult
  func edit(text: String) -> StreamOperations? {
//    body = text
    return chat.edit(message: self)
  }
  @discardableResult
  func delete() -> StreamOperations? {
    return chat.delete(message: self)
  }
}

// MARK: CustomStringConvertible
extension Message: CustomStringConvertible {
  var string: String {
    return body.string
  }
  var description: String {
    return "\(from.user.name): \(string)"
  }
}

// MARK: Hashable
extension Message: Hashable {
  static func ==(l:Message,r:Message) -> Bool {
    return l.index == r.index && l.from == r.from
  }
  var hashValue: Int { return index.hashValue }
}

// MARK: Private functions
private extension Message {
  func deleted() {
    body.delete(message: self)
  }
}

// MARK:- Subscription
class ChatSubscription: Subscription {
  var chat: Chat {
    overrideRequired()
  }
  func prefix(data: DataWriter) {
    
  }
  
  override func save(data: DataWriter) {
    super.save(data: data)
    prefix(data: data)
    let chat = self.chat
    data.append(chat.lastEdit)
    data.append(chat.indexOffset)
    data.append(chat.lastLoaded+1)
  }
  override func subscribed(response data: DataReader) throws {
    try chat.received(messages: data)
  }
}

// MARK: IDChatSubscription
class IDChatSubscription: ChatSubscription {
  let id: ID
  init(id: ID) {
    self.id = id
    super.init()
  }
  required init(data: DataReader) throws {
    id = try data.next()
    try super.init(data: data)
  }
  override func prefix(data: DataWriter) {
    data.append(id)
  }
}

// MARK:- Notifications
extension Chat {
  class func messageNotification(data: DataWriter) {
    
  }
  class func messagesNotification(data: DataWriter) {
    
  }
  class func editNotification(data: DataWriter) {
    
  }
  class func removeNotification(data: DataWriter) {
    
  }
  class func clearNotification(data: DataWriter) {
    
  }
}

// MARK:- Page notifications
protocol ChatDelegate: class {
  func appended(messages: [Message], in chat: Chat)
  func inserted(messages: [Message], in chat: Chat)
  func replaced(message: Message, in chat: Chat)
  func uploaded(message: Message, storable: StorableMessage, subindex: Int)
  func cleared(chat: Chat)
  func removeSending(chat: Chat)
  func keyboardMoved()
}
