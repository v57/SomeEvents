//
//  TextMessage.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class TextMessage: MessageBodyType {
  var type: MessageType { return .text }
  var string: String { return text }
  var text: String
  init(text: String) {
    self.text = text
  }
  required init(data: DataReader) throws {
    text = try data.next()
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(text)
  }
  func write(to string: NSMutableAttributedString, message: Message) {
    string.append(text)
  }
}
