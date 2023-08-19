//
//  MessageBody.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension Message {
  func storableMessage(at index: Int) -> StorableMessage? {
    return body.messages.safe(index) as? StorableMessage
  }
  func container(width: CGFloat) -> MessageTextContainer {
    let string = NSMutableAttributedString()
    for message in body.messages {
      message.write(to: string, message: self)
    }
    let container = MessageTextContainer(width: width, string: string)
    return container
  }
}

struct MessageBody {
  var messages = [MessageBodyType]()
  var isDeleted: Bool {
    return messages.isEmpty
  }
  var string: String {
    if isDeleted {
      return "(deleted)"
    } else {
      return messages.map { $0.string }.joined(separator: " ")
    }
  }
  mutating func delete(message: Message) {
    messages.forEach {
      ($0 as? StorableMessage)?.delete(chat: message.chat, message: message)
    }
    messages.removeAll()
  }
  init() {
    
  }
  init(text: String) {
    guard !text.isEmpty else { return }
    messages.append(TextMessage(text: text))
  }
  init(attachments: [AttachmentType], superMessage: Message) {
    var passwords = Set<UInt64>()
    for a in attachments {
      switch a {
      case .text(let text):
        messages.append(TextMessage(text: text))
      case .image(let image):
        let message = PhotoMessage(photo: image)
        validate(password: &message.password, with: &passwords)
        messages.append(message)
        let url = message.url(message: superMessage)
        url.create()
        url.write(image: image, .jpg(settings.compressQuality))
        url.whenReady {
          message.photoData.size = Int32(url.fileSize)
        }
      case .video(let videoURL):
        let message = VideoMessage(video: videoURL)
        validate(password: &message.password, with: &passwords)
        messages.append(message)
        let url = message.url(message: superMessage)
        url.run { url in
          url.directory.create(subdirectories: true)
          videoURL.move(to: url)
        }
      case .coordinate(let coordinate):
        let message = CoordinateMessage(latitude: Float(coordinate.lat), longitude: Float(coordinate.lon))
        messages.append(message)
      }
    }
  }
  func validate(password: inout UInt64, with set: inout Set<UInt64>) {
    while true {
      let (inserted,_) = set.insert(password)
      if inserted {
        break
      } else {
        password = .random()
      }
    }
  }
  func indexChanged(message: Message, oldValue: Int) {
    messages.forEach {
      ($0 as? StorableMessage)?.indexChanged(message: message, oldValue: oldValue)
    }
  }
}

extension MessageBody: DataRepresentable {
  init(data: DataReader) throws {
    messages = try data.array {
      let type: MessageType = try data.next()
      switch type {
      case .text:
        return try TextMessage(data: data)
      case .richText:
        return try RichTextMessage(data: data)
      case .photo:
        return try PhotoMessage(data: data)
      case .video:
        return try VideoMessage(data: data)
      case .coordinate:
        return try CoordinateMessage(data: data)
      }
    }
  }
  func save(data: DataWriter) {
    data.append(messages.count)
    messages.forEach {
      data.append($0)
    }
  }
}
