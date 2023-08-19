//
//  Event Comments.swift
//  faggot
//
//  Created by Димасик on 15/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension Cell {
  static var maxTextWidth: CGFloat { return min(screen.width,screen.height) - 100 }
  var width: CGFloat {
    return table.frame.width
  }
}

extension Message {
  func commentView(table: TableView) -> Cell {
    if body.isDeleted {
      return Cell()
    } else {
      return CommentCell(message: self, table: table)
    }
  }
}

class MessageCell: Cell {
  
}

class CommentCell: MessageCell {
  var from: User
  var container: MessageTextContainer
  var message: Message
//  var event: Event
  init(message: Message, table: TableView) {
//    self.event = message.comment.event
    self.message = message
    self.from = message.from.user
    self.container = message.container(width: Cell.maxTextWidth)
    super.init()
    height = container.minSize.height + 39 + 10
  }
  override func load() {
    let view = CommentView(cell: self)
    view.frame.size.height = self.view.frame.size.height
    addSubview(view)
  }
  func uploaded(storable: StorableMessage, index: Int) {
    
  }
  func delete() {
    
  }
}

class CommentTextView: ReadTextView {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let shouldBegin = super.gestureRecognizerShouldBegin(gestureRecognizer)
    print("(\(shouldBegin)) \(className(gestureRecognizer))")
    return shouldBegin
  }
}

class CommentView: UIView {
  let nameLabel: UILabel // 61,10
  let textView: CommentTextView // 43,29
  let avatar: UIButton
  unowned var cell: CommentCell
  let background: UIImageView
  init(cell: CommentCell) {
    self.cell = cell
    nameLabel = UILabel(text: cell.from.name, color: 0x6C6C6C.color, font: .normal(12))
    textView = CommentTextView(frame: CGRect(origin: Pos(73,29), size: cell.container.minSize), container: cell.container)
    textView.alwaysBounceHorizontal = true
    
    nameLabel.move(Pos(73,10), .topLeft)
    
    let insets = UIEdgeInsets(top: 17.5, left: 18.5, bottom: 18, right: 24.5)
    let image = #imageLiteral(resourceName: "MessageIncoming").resizableImage(withCapInsets: insets)
    background = UIImageView(image: image)
    background.alpha = 0.5
    
    avatar = UIButton(frame: CGRect(0,0,40,40))
    avatar.systemHighlighting()
    avatar.circle()
    avatar.backgroundColor = .background
    avatar.user(main.currentPage as? Page, user: cell.from)
    
    super.init(frame: CGRect(0,0,screen.width,cell.height))
    
    clipsToBounds = true
    
    background.frame = balloonFrame(for: [nameLabel,textView])
    avatar.move(Pos(background.frame.x/2,background.frame.bottom.y), .bottom)
    
    avatar.add(target: self, action: #selector(openProfile))
    
    addSubview(avatar)
    addSubview(background)
    addSubview(nameLabel)
    addSubview(textView)
//    addSubview(line)
    
    let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(hold))
    addGestureRecognizer(holdGesture)
  }
  
  @objc func hold(gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return }
    gesture.cancel()
    openMenu()
  }
  
  override var canBecomeFirstResponder: Bool { return true }
  func openMenu() {
    var items = [UIMenuItem]()
    let message = cell.message
    
    let item = UIMenuItem(title: "Copy", action: #selector(copyMessage))
    items.append(item)
    
    if message.isDeletable {
      let item = UIMenuItem(title: "Delete", action: #selector(deleteMessage))
      items.append(item)
    }
    
    if message.isReportable {
      let item = UIMenuItem(title: "Report", action: #selector(report))
      items.append(item)
    }
    
    
    guard items.count > 0 else { return }
    
    becomeFirstResponder()
    let menu = UIMenuController.shared
    menu.menuItems = items
    menu.setTargetRect(textView.bounds, in: textView)
    menu.setMenuVisible(true, animated: true)
  }
  
  
  @objc func copyMessage() {
    cell.message.string.saveToClipboard()
  }
  @objc func deleteMessage() {
    cell.message.delete()
  }
  @objc func report() {
    cell.message.report(reason: .other)
  }
  
  @objc func openProfile() {
    let page = UserPage(user: cell.from)
    main.push(page)
  }
  
  func balloonFrame(for content: [UIView]) -> CGRect {
    var frame = CGRect.zero
    frame.x = .infinity
    frame.y = .infinity
    for view in content {
      let tl = view.frame.topLeft
      let br = view.frame.bottomRight
      frame.x = min(tl.x, frame.x)
      frame.y = min(tl.y, frame.y)
      frame.w = max(br.x,frame.w)
      frame.h = max(br.y,frame.h)
    }
    frame.w -= frame.x
    frame.h -= frame.y
    frame.w += 30
    frame.h += 20
    frame.x -= 20
    frame.y -= 10
    return frame
  }
  
  override func resolutionChanged() {
    frame.w = screen.width
    frame.h = cell.height
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class EventComments: Page {
  let event: Event
  var comments: Comments { return event.comments }
//  let table = TableView()
//  let input = Input2()
  let chatView = ChatView(frame: screen.frame)
  init(event: Event) {
    self.event = event
    chatView.dframe = screen.dframe
    
//    table.dframe = { screen.frame }
//    table.contentInset.top = 100
//    table.scrollIndicatorInsets.top = 20
//    table.contentInset.bottom = input.frame.height
//    table.scrollIndicatorInsets.bottom = table.contentInset.bottom
    
    super.init()
    
//    comments.forEach {
//      table.append($0.commentView(table: table))
//    }
//
//    table.scrollToBottom()
//    table.scrollViewDidScroll(table)
//    addSubview(table)
//    addSubview(input)
//    addTap(self, #selector(tap))
//
//    input.events.height = { [unowned self] in
//      self.inputHeightChanged()
//    }
//    input.events.send = { [unowned self] text in
//      self.event.comments.send(text: text)
//      return true
//    }
//    comments.open()
    
    chatView.set(chat: comments)
    addSubview(chatView)
  }
  
  override func closed() {
    chatView.bye()
  }
  override func keyboardMoved() {
    chatView.keyboardMoved()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  func inputHeightChanged() {
//    let old = table.contentInset.bottom
//    let new = input.frame.height + keyboardHeight
//    let offset = new - old
//    table.contentInset.bottom = new
//    table.scrollIndicatorInsets.bottom = new
//    if offset > 0 {
//      let offset = table.contentOffset.y + offset
//      let maxOffset = table.contentSize.height + table.contentInset.bottom - table.frame.height
//      table.contentOffset.y = min(offset,maxOffset)
//    }
//  }
//
//  @objc func tap() {
//    input.textView.resignFirstResponder()
//  }
//
//  override func keyboardMoved() {
//    input.updateFrame()
//    input.resolutionChanged()
//    inputHeightChanged()
//  }
}

//
//extension EventComments: CommentsNotifications {
//  func appended(messages: [Message], in comments: Comments) {
//    guard self.comments == comments else { return }
//    let ids = messages.map { $0.from }
//    ids.loadUsers { [weak self] users in
//      guard let page = self else { return }
//      let table = page.table
//      if comments.isLastLoaded && !comments.sending.isEmpty {
//        for message in messages {
//          if message.isSending {
//            table.append(message.commentView(table: table))
//          } else {
//            table[table.cells.count-comments.sending.count] = message.commentView(table: table)
//          }
//        }
//      } else {
//        for message in messages {
//          table.append(message.commentView(table: table))
//        }
//      }
//      }?.autorepeat(self)
//  }
//  func inserted(messages: [Message], in comments: Comments) {
//    guard self.comments == comments else { return }
//    let ids = messages.map { $0.from }
//    ids.loadUsers { [weak self] users in
//      guard let page = self else { return }
//      for (index,message) in messages.enumerated() {
//        page.table[index] = message.commentView(table: page.table)
//      }
//      }?.autorepeat(self)
//  }
//  func replaced(message: Message, in comments: Comments) {
//    guard self.comments == comments else { return }
//    let cell = message.commentView(table: table)
//    let index = comments.index(for: message)
//    table.swap(cell: table[index], with: cell)
//  }
//  func cleared(comments: Comments) {
//    guard self.comments == comments else { return }
//    self.table.removeAll()
//  }
//  func removeSending(comments: Comments) {
//    guard self.comments == comments else { return }
//    for _ in 0..<comments.sending.count {
//      table.remove(table.cells.count-1, animated: false)
//    }
//  }
//}

extension EventComments: EventPublicNotifications {
  func updated(owner event: Event, oldValue: ID) {}
  func updated(status event: Event, oldValue: EventStatus) {
    guard self.event == event else { return }
    guard event.isRemoved || event.isBanned else { return }
    main.close(self)
  }
  func updated(privacy event: Event) {}
  func updated(options event: Event) {}
  func updated(createdTime event: Event) {}
  func updated(online event: Event) {}
  func updated(onMap event: Event) {}
  func updated(removed event: Event) {}
  func updated(banned event: Event) {}
  func updated(protected event: Event) {}
  
  func updated(content event: Event) {}
  func added(content: Content, to event: Event) {}
  func removed(content: Content, from event: Event) {}
  
  func invited(user: ID, to event: Event) {}
  func uninvited(user: ID, from event: Event) {}
  
  func updated(views event: Event) {}
  func updated(comments event: Event) {}
  func updated(current event: Event) {}
  
  func updated(banList event: Event) {}
}
