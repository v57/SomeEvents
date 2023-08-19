//
//  EventPreview.middle.swift
//  faggot
//
//  Created by Димасик on 3/24/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class EPMiddleView: EPBlock {
  static let minHeight = MenuItem.height
  var height: CGFloat = MenuItem.height {
    didSet {
      guard height != oldValue else { return }
      let offset = height - oldValue
      page.set(height: page.height + offset)
    }
  }
  let content: MenuContentView
  
  lazy var exportItem: MenuItem = { [unowned self] in
    let size = self.event.content.sum { $0.size }
    let right = size == 0 ? "" : size.bytesString
    let item = MenuItem(position: 0, text: "Export", right: right)
    item.action = { [unowned self] in self.showsExport = !self.showsExport }
    return item
  }()
  lazy var exportPhotosAndVideos: MenuItem = { [unowned self] in
    let item = MenuItem(position: 1, text: "Photos and videos", right: "")
    item.isSubmenu = true
    item.action = { [unowned self] in self.export(photos: true, videos: true) }
    return item
  }()
  lazy var exportPhotos: MenuItem = { [unowned self] in
    let item = MenuItem(position: 2, text: "Photos", right: "")
    item.isSubmenu = true
    item.action = { [unowned self] in self.export(photos: true, videos: false) }
    return item
  }()
  lazy var exportVideos: MenuItem = { [unowned self] in
    let item = MenuItem(position: 3, text: "Videos", right: "")
    item.isSubmenu = true
    item.action = { [unowned self] in self.export(photos: false, videos: true) }
    return item
  }()
  
  var showsExport = false {
    didSet {
      guard showsExport != oldValue else { return }
      exportItem.isSubmenu = showsExport
      if showsExport {
        let photos = page.info.photos
        let videos = page.info.videos
        if photos > 0 && videos > 0 {
          insert(item: exportPhotosAndVideos)
        }
        if photos > 0 {
          insert(item: exportPhotos)
        }
        if videos > 0 {
          insert(item: exportVideos)
        }
      } else {
        remove(item: exportPhotosAndVideos)
        remove(item: exportPhotos)
        remove(item: exportVideos)
      }
    }
  }
  
  var isPrivacyOpened = false {
    didSet {
      guard isPrivacyOpened != oldValue else { return }
      privacyItem.isSubmenu = isPrivacyOpened
      if isPrivacyOpened {
        insert(item: publicItem)
        insert(item: privateItem)
      } else {
        remove(item: publicItem)
        remove(item: privateItem)
      }
    }
  }
  lazy var privacyItem: MenuItem = { [unowned self] in
    let right = self.event.privacy == .private ? "private" : "public"
    let item = MenuItem(position: 4, text: "Privacy", right: right)
    item.action = { [unowned self] in self.openPrivacy() }
    return item
  }()
  lazy var publicItem: MenuItem = { [unowned self] in
    let right = self.event.privacy == .public ? "•" : ""
    let item = MenuItem(position: 5, text: "Public", right: right)
    item.isSubmenu = true
    item.action = { [unowned self] in self.setPublic() }
    return item
  }()
  lazy var privateItem: MenuItem = { [unowned self] in
    let right = self.event.privacy == .private ? "•" : ""
    let item = MenuItem(position: 6, text: "Private", right: right)
    item.isSubmenu = true
    item.action = { [unowned self] in self.setPrivate() }
    return item
  }()
  lazy var moveItem: MenuItem = { [unowned self] in
    let item = MenuItem(position: 7, text: "Change Location", right: "")
    item.action = { [unowned self] in self.move() }
    return item
  }()

  var _reportItem: MenuItem?
  lazy var reportItem: MenuItem = { [unowned self] in
    let item = MenuItem(position: 8, text: "Report", right: "", showsLine: false)
    item.action = { [unowned self] in self.report() }
    self._reportItem = item
    return item
  }()
  
  init(page: EventPreview, offset: CGFloat) {
    let size = CGSize(EventPreview.width,height)
    content = MenuContentView(frame: CGRect(origin: .zero, size: size))
    
    super.init(frame: CGRect(0,offset,size.width,size.height), page: page)
    
    let event = page.event
    if !event.content.isEmpty && !event.isPrivateForMe {
      content.insert(item: exportItem)
    }
    if event.isOwner {
      content.insert(item: privacyItem)
      content.insert(item: moveItem)
    }
    if !event.isReported {
      content.insert(item: reportItem)
    }
    
    addSubview(content)
    print(content.height)
    height = content.height
    frame.h = height
    content.frame.h = height
  }
  
  func updateExport() {
    let photos = page.info.photos
    let videos = page.info.videos
    if showsExport {
      if photos > 0 && videos > 0 {
        insert(item: exportPhotosAndVideos)
      } else {
        remove(item: exportPhotosAndVideos)
      }
      if photos > 0 {
        insert(item: exportPhotos)
      } else {
        remove(item: exportPhotos)
      }
      if videos > 0 {
        insert(item: exportVideos)
      } else {
        remove(item: exportVideos)
      }
    }
    if !event.content.isEmpty && !event.isPrivateForMe {
      insert(item: exportItem)
      let size = event.content.sum { $0.size }
      let right = size == 0 ? "empty" : size.bytesString
      exportItem.right = right
    } else {
      remove(item: exportItem)
    }
  }
  
  func insert(item: MenuItem) {
    content.insert(item: item)
    animate {
      height = content.height
      page.updateHeight()
    }
  }
  
  func remove(item: MenuItem) {
    content.remove(item: item)
    animate {
      height = content.height
      page.updateHeight()
    }
  }
  
  func export(photos: Bool, videos: Bool) {
    let content: [Content]
    if !(photos && videos) {
      if photos {
        content = event.content.filter { $0.type == .photo }
      } else if videos {
        content = event.content.filter { $0.type == .video }
      } else {
        content = []
      }
    } else {
      content = event.content
    }
    guard !content.isEmpty else { return }
    let export = Export(content: content)
    if export.isCompleted {
      export.openMenu()
    } else {
      export.resume()
      exportManager.append(export)
//      let a = "почини плс"
//      notification(.eventDownload(export))
    }
  }
  
  func report() {
    event.report(reason: .other)
  }
  func reported() {
    if let item = _reportItem {
      remove(item: item)
    }
  }
  func changeOwner() {
    
  }
  
  func owned() {
    insert(item: privacyItem)
    insert(item: moveItem)
  }
  
  func unowned() {
    remove(item: privacyItem)
    remove(item: moveItem)
  }
  
  func invited() {
    
  }
  
  func uninvited() {
    
  }
  
  // MARK:- Privacy
  func openPrivacy() {
    isPrivacyOpened = !isPrivacyOpened
  }
  
  func updatePrivacy() {
    guard event.isOwner else { return }
    if event.privacy == .private {
      privacyItem.right = "private"
      privateItem.right = "•"
      publicItem.right = ""
    } else {
      privacyItem.right = "public"
      privateItem.right = ""
      publicItem.right = "•"
    }
    isPrivacyOpened = false
  }
  
  func setPublic() {
    event.privacy(.public)
  }
  
  func setPrivate() {
    event.privacy(.private)
  }
  
  func move() {
    MapViewController.show(startCoordinate: nil) { location in
      self.event.move(lat: Float(location.latitude), lon: Float(location.longitude))
    }
  }
  
  // MARK:-
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class MenuItem: Block {
  static let height: CGFloat = 42
  var text: String {
    didSet {
      guard text != oldValue else { return }
      leftLabel.set(text: text)
    }
  }
  var right: String {
    didSet {
      guard right != oldValue else { return }
      rightLabel.set(text: right)
    }
  }
  var leftLabel: DPLabel
  lazy var rightLabel: DPLabel = {
    let label = DPLabel(text: self.right, color: 0x4A4A4A.color, font: .normal(14))
    label.dpos = { Pos(EventPreview.width - 12, MenuItem.height / 2).right }
    self.addSubview(label)
    return label
  }()
  var position: Int
  var action: (()->())?
  
  init(position: Int, text: String, right: String, showsLine: Bool = true) {
    self.position = position
    self.text = text
    self.right = right
    leftLabel = DPLabel(text: text, color: 0x4A4A4A.color, font: .normal(18))
    leftLabel.dpos = { Pos(12, MenuItem.height / 2).left }
    super.init(height: MenuItem.height)
    addSubview(leftLabel)
    
    if !right.isEmpty {
      rightLabel.set(text: right)
    }
    
    if showsLine {
      let line = DFView.dfhline(Pos(12, MenuItem.height), anchor: .bottomLeft, width: EventPreview.width - 24, color: .black(0.18))
      addSubview(line)
    }
    
    selectable = true
  }
  
  var isSubmenu = false {
    didSet {
      guard isSubmenu != oldValue else { return }
      if isSubmenu {
//        backgroundColor = .black(0.1)
      } else {
//        backgroundColor = .clear
      }
    }
  }
  
  override func selected() {
    action?()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class MenuContentView: ContentView {
  var items = Set<MenuItem>()
  func insert(item: MenuItem) {
    guard !items.contains(item) else { return }
    items.insert(item)
    let i = position(for: item)
    insert(item, at: i)
  }
  func remove(item: MenuItem) {
    guard items.contains(item) else { return }
    items.remove(item)
    remove(item)
  }
  func position(for item: MenuItem) -> Int {
    for (i,cell) in cells.enumerated() {
      guard let cell = cell as? MenuItem else { continue }
      guard cell.position > item.position else { continue }
      return i
    }
    return cells.count
  }
}
