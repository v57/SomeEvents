//
//  CommunityChat.swift
//  Events
//
//  Created by Димасик on 3/29/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//


import SomeData
import SomeBridge

extension Chat {
  static let community = CommunityChat()
  static let news = NewsChat()
}

class CommunityChat: Chat {
  override var type: ChatType { return .community }
  override var subscription: ChatSubscription { return Subscription.CommunityChat() }
  override var canSend: Bool { return true }
  override var canClear: Bool { return false }
  override var path: String { return "communityChat/" }
  override class func read(link: DataReader) throws -> CommunityChat {
    return .community
  }
  override func received(messages data: DataReader) throws {
    try super.received(messages: data)
  }
}

class NewsChat: Chat {
  override var type: ChatType { return .news }
  override var subscription: ChatSubscription { return Subscription.News() }
  override var canSend: Bool { return false }
  override var canClear: Bool { return false }
  override var path: String { return "news/" }
  override class func read(link: DataReader) throws -> NewsChat { return .news }
  override func received(messages data: DataReader) throws {
    try super.received(messages: data)
  }
}
