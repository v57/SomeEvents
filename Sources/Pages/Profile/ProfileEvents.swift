//
//  profile-events.swift
//  faggot
//
//  Created by Димасик on 3/21/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class EventsView: DFScrollView, UIScrollViewDelegate {
  var blocks = [Block]()
  weak var currentPage: Page?
  var didScroll: ((UIScrollView)->())?
  var showsCreateEvent = true
  override init(frame: CGRect) {
    super.init(frame: frame)
    alwaysBounceVertical = true
    showsVerticalScrollIndicator = false
    delegate = self
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?(scrollView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func set(events: [Event]) {
    if !blocks.isEmpty {
      for block in blocks {
        block.removeFromSuperview()
      }
      blocks.removeAll()
    }
    
    var years = [Int: [Event]]()
    let sorted = events.sorted { $0.startTime > $1.startTime }
    for event in sorted {
      guard !event.isPrivateForMe else { continue }
      let year = event.startTime.year
      if years[year] != nil {
        years[year]!.append(event)
      } else {
        years[year] = [event]
      }
    }
    
    addStartBlock(if: years[Time.now.year] == nil)
    
    let array = years.sorted { $0.key > $1.key }
    for (year,events) in array {
      let block = create(year,events)
      blocks.append(block)
    }
    
    resolutionChanged()
  }
  
  private func addStartBlock(if condition: Bool) {
    guard condition else { return }
    let block = create(Time.now.year, [])
    blocks.append(block)
  }
  
  private func create(_ year: Int, _ events: [Event]) -> Block {
    let block: Block
    if year == Time.now.year && showsCreateEvent {
      block = FirstBlock(title: "\(year)", events: events, page: currentPage)
    } else {
      block = Block(title: "\(year)", events: events, page: currentPage)
    }
    block.year = year
//    for view in block.views {
//      guard let view = view as? EventContent else { continue }
//      let event = view.event
//      view.customAction = { [unowned self] in
//        self.remove(event: event, animated: true)
//      }
//      view.customHold = { [unowned self] in
//        let event = eventManager.my().any
//        self.insert(event: event, animated: true)
//      }
//    }
    addSubview(block)
    return block
  }
  
  func insert(event: Event, animated: Bool) {
    let year = event.startTime.year
    for (i,block) in blocks.enumerated() {
      if year == block.year {
        guard block.find(event: event) == nil else { return }
        block.insert(event: event, page: currentPage, animated: animated)
        animateif(animated) {
          update(block,i)
        }
        return
      } else if year > block.year {
        let y = blocks[i].frame.y
        let block = create(year,[event])
        block.update(y: y)
        offset(from: i, offset: block.frame.height)
        blocks.insert(block, at: i)
        return
      }
    }
    let block = create(year, [event])
    blocks.append(block)
    let y = contentSize.height
    block.update(y: y)
    contentSize.height += block.frame.height
  }
  
  func remove(event: Event, animated: Bool) {
    let year = event.startTime.year
    for (i,block) in blocks.enumerated() {
      if year == block.year {
        if block.willRemove() {
          blocks.remove(at: i)
          animateif(animated) {
            offset(from: i, offset: -block.frame.height)
          }
          
          block.destroy(options: .horizontal(.left),animated: animated)
        } else {
          block.remove(event: event, animated: animated)
          animateif(animated) {
            update(block,i)
          }
        }
        return
      } else if year > block.year {
        // not found
        return
      }
    }
  }
  
  func find(event: Event) -> Content? {
    let year = event.startTime.year
    for block in blocks {
      if year == block.year {
        return block.find(event: event)
      }
    }
    return nil
  }
  
  private func offset(from i: Int, offset: CGFloat) {
    contentSize.height += offset
    guard i < blocks.count else { return }
    for block in blocks[i..<blocks.count] {
      block.frame.y += offset
    }
  }
  
  func update(_ block: Block, _ i: Int) {
    let height = block.frame.height
    block.update()
    guard height != block.frame.height else { return }
    offset(from: i+1, offset: block.frame.height - height)
  }
  
  func update(if condition: Bool = true, from i: Int) {
    guard condition else { return }
    var y: CGFloat = blocks[i].frame.y
    for block in blocks[i..<blocks.count] {
      block.update(y: y)
      y += block.frame.height
    }
    contentSize.height = y
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    var y: CGFloat = 0
    for block in blocks {
      block.update(y: y)
      y += block.frame.height
    }
    contentSize.height = y
  }
  
  class Content: UIView {
    var customAction: (()->())?
    var customHold: (()->())?
    let button: UIButton
    let label: UILabel
    init(text: String) {
      button = UIButton(frame: Cell.cgsize.frame)
      button.frame.x = Cell.offset/2
      button.systemHighlighting()
      
      label = UILabel(frame: CGRect(Cell.offset/2,Cell.size,Cell.size,20), text: "", font: .normal(12), color: .black, alignment: .center)
      label.numberOfLines = 2
      label.set(text: text, anchor: .top, maxWidth: Cell.size)
      
      
      
      super.init(frame: CGRect(0,0,Cell.width,Cell.height))
//      clipsToBounds = true
      addSubview(button)
      addSubview(label)
      
      button.addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    @objc func touchDown() {
      vibrate(.light)
    }
    
    func addHold() {
      let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(hold(touch:)))
      button.addGestureRecognizer(holdGesture)
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(touch:)))
      button.addGestureRecognizer(tapGesture)
    }
    
    @objc func hold(touch: UILongPressGestureRecognizer) {
      button.isEnabled = false
      button.isEnabled = true
      button.isHidden = true
      button.isHidden = false
      button.cancelTracking(with: nil)
    }
    @objc func tap(touch: UITapGestureRecognizer) {
      
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  class EventContent: Content {
    let event: Event
//    static let background: UIImage = ImageEditor.fill(color: .background, size: Cell.cgsize)
    var statusLabel: UILabel?
    func set(status: String?, animated: Bool) {
      if let status = status {
        let label: UILabel
        if let statusLabel = statusLabel {
          label = statusLabel
        } else {
          label = UILabel()
          label.font = .normal(10)
//          label.backgroundColor = .black(0.2)
          label.textColor = .white
          label.textAlignment = .center
          label.isUserInteractionEnabled = false
          label.numberOfLines = 2
//          label.roundCorners([.bottomLeft,.topRight], radius: Cell.cornerRadius)
          button.display(label, options: .slide, animated: animated)
          self.statusLabel = label
        }
        let size = status.size(label.font)
        label.text = status
        label.frame.w = size.width + 10
        label.frame.h = size.height + 6
        label.move(button.frame.topRight, .topRight)
      } else {
        statusLabel = statusLabel?.destroy()
      }
    }
    init(event: Event, page: Page?) {
      self.event = event
      
      super.init(text: event.name)
      
      button.backgroundColor = .background
      button.clipsToBounds = true
      button.layer.cornerRadius = Cell.cornerRadius
      button.event(page, event: event, preset: .roundedCorners(Cell.cornerRadius))
      
      addHold()
      
      set(status: event.statusString, animated: false)
    }
    
    func updatePreview(page: Page?) {
      button.event(page, event: event, preset: .roundedCorners(Cell.cornerRadius))
    }
    
    func updateName() {
      label.text = event.name
    }
    
    override func hold(touch: UILongPressGestureRecognizer) {
      super.hold(touch: touch)
      guard touch.state == .began else { return }
      touch.cancel()
      
//      button.scale(1)
      
      customHold?()
      vibrate(.medium)
      let page = EventPreview(event: event)
      page.set(startView: button)
      
      let settings = FromViewSettings()
      settings.view = button
      settings.cornerRadius = Cell.cornerRadius
      settings.shouldHideView = false
      settings.insertIndex = 0
      settings.viewIsTransparent = { [weak self] in
        return self?.button.image(for: .normal) == nil
      }
      page.transition = .from(view: settings)
      main.push(page)
    }
    
    override func tap(touch: UITapGestureRecognizer) {
      openEvent()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    func openEvent() {
      if let action = customAction {
        action()
      } else {
        let page = EventPage(event: event)
        let settings = FromViewSettings()
        settings.view = button
        settings.cornerRadius = Cell.cornerRadius
        settings.viewIsTransparent = { [weak self] in
          return self?.button.image(for: .normal) == nil
        }
        page.transition = .from(view: settings)
//        page.pageTransition = .zoom(to: button)
        main.push(page)
      }
    }
  }
  
  class NewEventContent: Content {
    init() {
      super.init(text: "Create event")
      button.setImage(#imageLiteral(resourceName: "addEvent"), for: .normal)
      button.add(target: self, action: #selector(newEvent))
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    @objc func newEvent() {
      let page = CreateEventView()
      main.push(page)
    }
  }
  
  class Block: UIView {
    var year: Int = 0
    
    let title: String?
    var events: [Event]
    var views = [Content]()
    weak var currentPage: Page?
    var titleLabel: UILabel!
    var eventsOffset = 0
    init(title: String?, events: [Event], page: Page?) {
      currentPage = page
      self.title = title
      self.events = events
      super.init(frame: CGRect(0,0,screen.width,0))
      //      backgroundColor = UIColor(white: 0, alpha: 0.2)
      for event in events {
        let view = EventContent(event: event, page: page)
        addSubview(view)
        views.append(view)
      }
      
      if let title = title {
        titleLabel = UILabel(text: title, color: .black, font: .heavy(24))
        addSubview(titleLabel)
      }
    }
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    func update() {
      update(y: frame.y)
    }
    
    func insert(event: Event, page: Page?, animated: Bool) {
      for (i,e) in events.enumerated() {
        if event.startTime > e.startTime {
          events.insert(event, at: i)
          let view = EventContent(event: event, page: page)
          display(view, options: .horizontal(.left), animated: animated)
          if let v = views.safe(i) {
            view.center = v.center
          }
          views.insert(view, at: i)
          return
        }
      }
      events.append(event)
      let view = EventContent(event: event, page: page)
      addSubview(view)
      views.append(view)
    }
    
    func remove(event: Event, animated: Bool) {
      guard let i = events.index(of: event) else { return }
      let view = views[i]
      views.remove(at: i)
      events.remove(at: i)
      view.destroy(options: .vertical(.left), animated: animated)
      return
    }
    
    func find(event: Event) -> Content? {
      guard let i = events.index(of: event) else { return nil }
      return views[i]
    }
    
    func willRemove() -> Bool {
      return eventsOffset == 0 && events.count == 1
    }
    
    func update(y blockY: CGFloat) {
      let viewsPerRow = CGFloat(Int(screen.width / Cell.width))
      let width = Cell.width * viewsPerRow
      let xo: CGFloat = (screen.width - width) / 2
      var yo: CGFloat = 0
      var x: CGFloat = 0
      var y: CGFloat = 0
      if title != nil {
        let x = xo + (Cell.width - Cell.size) / 2
        let w = screen.width - xo - xo
        titleLabel.frame = CGRect(x,0,w, Cell.titleHeight - 10)
        yo += Cell.titleHeight
      }
      for i in 0..<eventsOffset {
        move(cell: i, x: xo + Cell.width * x, y: yo + Cell.height * y)
        increment2d(&x, &y, viewsPerRow)
      }
      for view in views {
        let pos = Pos(xo + Cell.width * x, yo + Cell.height * y)
        view.move(pos, .topLeft)
        increment2d(&x, &y, viewsPerRow)
      }
      y += 1
      if x == 0 { y -= 1 }
      frame = CGRect(0,blockY,screen.width,yo + Cell.height * y)
    }
    
    func move(cell: Int, x: CGFloat, y: CGFloat) {
      
    }
  }
  
  class FirstBlock: Block {
    let newEvent: NewEventContent
    override init(title: String?, events: [Event], page: Page?) {
      newEvent = NewEventContent()
      super.init(title: title, events: events, page: page)
      eventsOffset = 1
      addSubview(newEvent)
    }
    
    override func move(cell: Int, x: CGFloat, y: CGFloat) {
      switch cell {
      case 0: newEvent.frame.origin = Pos(x,y)
      default: break
      }
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  class Cell: UIView {
    static let size: CGFloat = device < .ipad ? 75 : 90
    static let cgsize: CGSize = CGSize(Cell.size,Cell.size)
    static let offset: CGFloat = device <= .iphone5 ? 5 : 7
    static let cornerRadius: CGFloat = 8
    static let titleHeight: CGFloat = 36
    static let width: CGFloat = Cell.size + Cell.offset
    static let height: CGFloat = Cell.size + Cell.offset + 23
  }
}
