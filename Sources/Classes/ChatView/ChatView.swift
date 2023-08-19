//
//  ChatView.swift
//  Events
//
//  Created by Димасик on 3/29/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class ChatView: DFView {
  var gravity: Gravity = .bottom
  var inputType: InputType = .normal
  var scrollToNewMessagePack = true
  var scrollToNewMessages = true
  var chat: Chat!
  
  var table = TableView()
  lazy var input: Input2 = { [unowned self] in
    let input = Input2()
    input.events.height = { [unowned self] in
      self.inputHeightChanged()
    }
    input.events.attachmentSend = { [unowned self] attachments in
      self.chat.send(attachments: attachments)
      return true
    }
    return input
  }()
  weak var page: Page?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    table.dframe = { [unowned self] in self.bounds }
    
    addSubview(table)
    addTap(#selector(tap))
  }
  
  func set(chat: Chat) {
    self.chat = chat
    table.autoscroll = false
    
    
    switch gravity {
    case .top:
      table.contentInset.top = 20
      table.scrollToTop()
      table.isInverted = true
      table.scrollIfAppearsOnScreen = false
    case .bottom:
      table.contentInset.top = 100
    }
    
    chat.forEach {
      table.append($0.commentView(table: table), animated: false)
    }
    
    if inputType != .none {
      table.contentInset.bottom = input.frame.height + screen.bottomInsets + 20
    }
    
    
    switch gravity {
    case .top:
      table.isInverted = true
    case .bottom:
      table.scrollToBottom()
      table.scrollViewDidScroll(table)
    }
    
    
    if inputType != .none {
      addSubview(input)
      input.dframe = Input2.dframe(for: self)
    }
    
    chat.open(subscribe: self)
  }
  
  func bye() {
    chat.close(unsubscribe: self)
  }
  
  
  enum InputType {
    case normal, none
  }
  enum Gravity {
    case top, bottom
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func inputHeightChanged() {
    let inset = keyboardInset(for: self)
    let old = table.contentInset.bottom
    let new = input.frame.height + inset + 20
    let offset = new - old
    table.contentInset.bottom = new
    table.scrollIndicatorInsets.bottom = inset
    if offset > 0 && gravity == .bottom {
      let offset = table.contentOffset.y + offset
      let maxOffset = table.contentSize.height + table.contentInset.bottom - table.frame.height
      table.contentOffset.y = min(offset,maxOffset)
    }
  }
  
  @objc func tap() {
    if inputType != .none {
      input.textView.resignFirstResponder()
    }
  }
  
  func keyboardMoved() {
    if inputType != .none {
      input.updateFrame()
      input.resolutionChanged()
      inputHeightChanged()
    }
  }
}

extension ChatView: ChatDelegate {
  func uploaded(message: Message, storable: StorableMessage, subindex: Int) {
    let index = chat.index(for: message)
    (table[index] as? CommentCell)?.uploaded(storable: storable, index: subindex)
  }
  
  func appended(messages: [Message], in chat: Chat) {
    let ids = messages.map { $0.from }
    ids.loadUsers { [weak self] users in
      guard let page = self else { return }
      let table = page.table
      let animated = !table.cells.isEmpty
      if chat.isLastLoaded && !chat.sending.isEmpty {
        for message in messages {
          if message.isSending {
            table.append(message.commentView(table: table), animated: animated)
          } else {
            table[table.cells.count-chat.sending.count] = message.commentView(table: table)
          }
        }
      } else {
        for message in messages {
          table.append(message.commentView(table: table), animated: animated)
        }
      }
      switch page.gravity {
      case .top:
        page.animate {
          table.scrollToTop()
        }
      case .bottom:
        page.animate {
          table.scrollToBottom()
        }
      }
      }?.autorepeat(page)
  }
  func inserted(messages: [Message], in chat: Chat) {
    let ids = messages.map { $0.from }
    ids.loadUsers { [weak self] users in
      guard let page = self else { return }
      for (index,message) in messages.enumerated() {
        page.table[index] = message.commentView(table: page.table)
      }
      }?.autorepeat(page)
  }
  func replaced(message: Message, in chat: Chat) {
//    let cell = message.commentView(table: table)
//    let index = chat.index(for: message)
//    table.swap(cell: table[index], with: cell)
  }
  func cleared(chat: Chat) {
    self.table.removeAll()
  }
  func removeSending(chat: Chat) {
    for _ in 0..<chat.sending.count {
      table.remove(table.cells.count-1, animated: false)
    }
  }
}
