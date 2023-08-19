//
//  Event-Photos.swift
//  faggot
//
//  Created by Димасик on 15/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

extension EventCell {
  static let cellSize: CGFloat = 70
  static let startOffset: CGFloat = 20
  static let cellOffset: CGFloat = 7
  static let cellFullSize = cellSize + cellOffset
  static let cornerRadius: CGFloat = 10
}

class EventPhotosView: ScrollViewBlock {
  private(set) var objects = [EventCell]()
  private var ids = Set<ID>()
  var x = 0
  var y = 0
  var offset: CGFloat
  var width: Int
  weak var page: Page?
  init(event: Event, page: Page?) {
    self.page = page
    width = Int(screen.width) / 80
    let w = EventCell.cellFullSize * CGFloat(width)
    offset = (screen.width - w) / 2
    let h = EventCell.startOffset + EventCell.cellSize
    
    super.init(height: h)
    
    for content in event.content {
      append(content: content)
    }
  }
  
  var sw = screen.width
  
  var shouldAnimate: Bool {
    guard let page = page else { return false }
    guard let current = main.currentPage as? Page else { return false }
    return page == current
  }
  
  override func resolutionChanged() {
    guard sw != screen.width else { return }
    sw = screen.width
    frame.w = screen.width
    width = Int(screen.width) / 80
    let w = EventCell.cellFullSize * CGFloat(width)
    offset = (screen.width - w) / 2
    height = EventCell.startOffset + EventCell.cellSize
    x = 0
    y = 0
    for cell in objects {
      cell.move(x: x, y: y, offset: offset)
      incx()
    }
  }
  
  func new(content: Content, animated: Bool) -> EventCell? {
    return insert(content: content, at: 0, animated: animated)
  }
  
  func append(content: Content) {
    guard !ids.contains(content.id) else { return }
    guard let page = page else { return }
    ids.insert(content.id)
    let eventButton = EventCell(content: content, x: x, y: y, offset: offset, page: page)
    objects.append(eventButton)
    addSubview(eventButton)
    incx()
  }
  @discardableResult
  func insert(content: Content, animated: Bool) -> EventCell? {
    let i = objects.reversedIndex(for: content.time, compareWith: { $0.content.time })
    return insert(content: content, at: i, animated: animated)
  }
  
  func insert(content: Content, at index: Int, animated: Bool) -> EventCell? {
    guard !ids.contains(content.id) else { return nil }
    guard let page = page else { return nil }
    
    var animated = animated
    if animated && !shouldAnimate {
      animated = false
    }
    
    var x = index % width
    var y = index / width
    
    ids.insert(content.id)
    let cell = EventCell(content: content, x: x, y: y, offset: offset, page: page)
    objects.insert(cell, at: index)
    display(cell)
    incx()
    
    guard objects.count > 1 else { return cell }
    for i in index+1..<objects.count {
      increment2d(&x, &y, width)
      let object = objects[i]
      animateif(animated) {
        object.moveTo(x, y)
      }
    }
    return cell
  }
  
  func remove(at index: Int, animated: Bool) {
    let content = objects[index].content
    guard ids.contains(content.id) else { return }
    
    
    var animated = animated
    if animated && !shouldAnimate {
      animated = false
    }
    
    var x = index % width
    var y = index / width
    
    ids.remove(content.id)
    let cell = objects[index]
    objects.remove(at: index)
    cell.destroy(animated: animated)
    decx()
    
    for i in index..<objects.count {
      let object = objects[i]
      animateif(animated) {
        object.moveTo(x, y)
      }
      increment2d(&x, &y, width)
    }
  }
  
  func remove(_ id: Int64, animated: Bool) {
    guard let index = objects.index(where: { $0.content.id == id }) else { return }
    remove(at: index, animated: animated)
  }
  
  func findContent(_ id: Int64) -> EventCell! {
    for cell in objects where cell.content.id == id {
      return cell
    }
    return nil
  }
  
  func incx() {
    x += 1
    if x == width {
      x = 0
      y += 1
      height += EventCell.cellSize + EventCell.cellOffset
    }
  }
  func decx() {
    x -= 1
    if x == -1 {
      x = width-1
      y -= 1
      height -= EventCell.cellSize + EventCell.cellOffset
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}




/////////////////////////////////////////////////////////////////
//MARK:- Event cell c=3
/////////////////////////////////////////////////////////////////

class EventCell: UIView {
  
  let content: Content
  
  var centerx: CGFloat {
    return frame.width / 2
  }
  
  let offset: CGFloat
  
  var showsPhoto = false {
    didSet {
      if showsPhoto != oldValue {
        if showsPhoto {
          guard page != nil else { return }
          photoView = UIImageView(frame: CGRect(0,0,EventCell.cellSize,EventCell.cellSize))
          photoView.clipsToBounds = true
//          photoView.layer.cornerRadius = cornerRadius
          if content.type == .video {
            let icon = UIImageView(image: #imageLiteral(resourceName: "EVideoIcon"))
            icon.move(Pos(EventCell.cellSize-5,EventCell.cellSize-5), .bottomRight)
            photoView.addSubview(icon)
          }
          display(photoView)
        } else {
          photoView = photoView?.destroy()
        }
      }
    }
  }
  var photoView: UIImageView!
  
  var uv: UIImageView?
  var uploading = false {
    didSet {
      guard uploading != oldValue else { return }
      if uploading {
        let uv = UIImageView(image: EventCell.uploadingIcon())
        addSubview(uv)
        self.uv = uv
//        let label = UILabel(text: "Uploading", color: .white, font: .normal(10))
//        label.textAlignment = .center
//        label.frame.size = Size(cellSize-10,20)
//        label.backgroundColor = .black(0.5)
//        label.clipsToBounds = true
////        label.roundCorners([.bottomRight,.topLeft], radius: 10)
////        label.optimizeCorners()
////        label.layer.cornerRadius = 4
////        label.center = Pos(cellSize/2,cellSize/2)
//        addSubview(label)
//        uploadingLabel = label
      } else {
        uv = uv?.destroy()
//        uploadingLabel = uploadingLabel?.destroy()
      }
    }
  }
  
  func move(x: Int, y: Int, offset: CGFloat) {
    frame.origin = Pos(CGFloat(x) * EventCell.cellFullSize + offset, CGFloat(y) * EventCell.cellFullSize + EventCell.startOffset)
  }
  weak var page: Page?
  init(content: Content, x: Int, y: Int, offset: CGFloat, page: Page) {
    self.page = page
    self.offset = offset
    self.content = content
    super.init(frame: CGRect(CGFloat(x) * EventCell.cellFullSize + offset, CGFloat(y) * EventCell.cellFullSize + EventCell.startOffset, EventCell.cellSize, EventCell.cellSize))
//    layer.cornerRadius = 10
//    backgroundColor = .background
    
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(EventCell.holdGesture(_:)))
    gesture.minimumPressDuration = 0.3
    addGestureRecognizer(gesture)
    addTap(self, #selector(EventCell.tapGesture))
    setup()
  }
  
  var isPreviewLoaded: Bool {
    guard let view = photoView else { return false }
    return view.image != nil && view.image != EventCell.background
  }
  
  var updating: Bool = false
  
  func updatePreview() {
    guard let page = page else { return }
    var s = 0
    if let photoView = photoView {
      s = photoView.subviews.count
    }
    guard !(updating && s > 0) else { return }
    updating = true
    let content = self.content
    photoView?.preview(page, content: content, preset: .roundedCorners(EventCell.cornerRadius))
  }
  
  func setup() {
    let content = self.content
    showsPhoto = true
    photoView.image = EventCell.background
    if !content.isUploaded {
      uploading = true
    }
    handler = { [unowned self] in
      guard content.isAvailable else { return }
//      guard !self.uploading else { return }
      let page = Previews(event: content.eventid.event, content: content)
//      preview.pageTransition = .zoom(to: self)
      let settings = FromViewSettings()
      settings.view = self
      settings.cornerRadius = EventCell.cornerRadius
      settings.viewIsTransparent = { [unowned self] in
        return self.photoView?.image == nil || self.photoView!.image! == EventCell.background
      }
      page.transition = .from(view: settings)
      main.push(page)
//      main.push(preview, from: self, cornerRadius: 10)
    }
    hold = { [unowned self] in
      self.contentMenu()
    }
    updatePreview()
  }
  
  func moveTo(_ x: Int, _ y: Int) {
    self.frame = self.bounds.offsetBy(dx: CGFloat(x) * EventCell.cellFullSize + self.offset, dy: CGFloat(y) * EventCell.cellFullSize + EventCell.startOffset)
  }
  override var canBecomeFirstResponder: Bool { return true }
  
  func contentMenu() {
    guard let page = page as? EventPage else { return }
    let event = page.event
    
    var items = [UIMenuItem]()
    
    if content is VideoContent || content is PhotoContent {
      if content.isUploaded {
        let item = UIMenuItem(title: "Copy Link", action: #selector(copyLink))
        items.append(item)
      }
    }
    
    if event.invited.contains(.me) {
      let item = UIMenuItem(title: "Delete", action: #selector(removeContent))
      items.append(item)
    }
    
    if !content.isReported {
      let report = UIMenuItem(title: "Report", action: #selector(reportContent))
      items.append(report)
    }
    
    
    guard items.count > 0 else { return }
    
    becomeFirstResponder()
    let menu = UIMenuController.shared
    menu.menuItems = items
    menu.setTargetRect(bounds, in: self)
    menu.setMenuVisible(true, animated: true)
  }
  
  @objc func removeContent() {
    guard let page = self.page as? EventPage else { return }
    let event = page.event
    guard event.invited.contains(.me) else { return }
    
    self.alpha = 0.5
    event.remove(content: content)
      .onComplete { [weak self] in
        self?.alpha = 1.0
    }
  }
  
  @objc func reportContent() {
    
  }
  
  @objc func copyLink() {
    if let content = content as? PhotoContent {
      content.link.absoluteString.saveToClipboard()
    } else if let content = content as? VideoContent {
      content.link.absoluteString.saveToClipboard()
    }
  }
  
  
  var down = false {
    didSet {
      if down != oldValue {
        if down {
          alpha = 0.5
        } else {
          animate {
            self.alpha = 1.0
          }
        }
      }
    }
  }
  var inside = false
  var handler = {}
  var hold: (()->())?
  @objc func holdGesture(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      if let hold = hold {
        hold()
        scale(0.8)
        jellyAnimation {
          self.scale(1.0)
        }
        gesture.cancel()
      } else {
        inside = true
        down = true
      }
    case .changed:
      let position = gesture.location(in: self)
      let ins = bounds.contains(position)
      if inside != ins {
        inside = ins
        if ins {
          alpha = 0.5
        } else {
          animate {
            self.alpha = 1.0
          }
        }
      }
    case .ended:
      if inside {
        handler()
      }
      down = false
    case .cancelled:
      down = false
      inside = false
    default: break
    }
  }
  @objc func tapGesture() {
    down = true
    down = false
    handler()
  }
  
  var x = 0, y = 0
  
  private var loaded = false
  func load() {
    if loaded { return }
    loaded = true
  }
  
  func unload() {
    if !loaded { return }
    loaded = false
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  static var background: UIImage = ImageEditor.fill(color: .background, size: Size(cellSize,cellSize), cornerRadius: EventCell.cornerRadius)
  static var _uploadingIcon: UIImage?
  static func uploadingIcon() -> UIImage? {
    guard _uploadingIcon == nil else { return _uploadingIcon }
    let size = Size(cellSize-10,20)
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    defer { UIGraphicsEndImageContext() }
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    
    context.setFillColor(UIColor.black(0.5).cgColor)
    let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), byRoundingCorners: [.topLeft, .bottomRight], cornerRadii: CGSize(width: EventCell.cornerRadius, height: EventCell.cornerRadius))
    context.addPath(path.cgPath)
    context.drawPath(using: .fill)
    
    var attr = [NSAttributedStringKey : Any]()
    attr[.font] = UIFont.normal(10)
    attr[.foregroundColor] = UIColor.white
    let text: NSString = "Uploading"
    let textSize = text.size(withAttributes: attr)
    text.draw(in: CGRect(size.center, .center, textSize), withAttributes: attr)
    
    _uploadingIcon = UIGraphicsGetImageFromCurrentImageContext()!
    return _uploadingIcon!
  }
}
