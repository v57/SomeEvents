//
//  RichTextMessage.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension RichTextFont {
  var ui: UIFont {
    switch self {
      
    case .largeTitle:
      return .largeTitle
    case .title1:
      return .title1
    case .title2:
      return .title2
    case .title3:
      return .title3
    case .body:
      return .body
    case .headline:
      return .headline
    case .subheadline:
      return .subheadline
    case .callout:
      return .callout
    case .footnote:
      return .footnote
    case .caption1:
      return .caption1
    case .caption2:
      return .caption2
    }
  }
}

class RichTextMessage: MessageBodyType {
  var type: MessageType { return .richText }
  var string: String { return text }
  var text: String
  var options: RichTextOption.Set
  var font: RichTextFont
  init(text: String, options: RichTextOption.Set, font: RichTextFont) {
    self.text = text
    self.options = options
    self.font = font
  }
  required init(data: DataReader) throws {
    text = try data.next()
    options = try data.next()
    font = try data.next()
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(text)
    data.append(options)
    data.append(font)
  }
  func write(to string: NSMutableAttributedString, message: Message) {
    string.append(text, inline: options[.inline]) { attributes in
      attributes.font = font.ui
    }
  }
}
