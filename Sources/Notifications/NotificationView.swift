//
//  NotificationView.swift
//  faggot
//
//  Created by Димасик on 5/15/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class FullNView: NView {
  lazy var iconView: UIImageView = { [unowned self] in
    let imageView = UIImageView(frame: CGRect(8,8,20,20))
    imageView.contentMode = .scaleAspectFit
    self.contentView.addSubview(imageView)
    return imageView
  }()
  lazy var titleLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRect(37,0,NView.width-37-12,NView.height))
    label.font = .normal(13)
    label.textColor = .black
    self.contentView.addSubview(label)
    return label
  }()
  lazy var rightLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRect(NView.width-13,0,NView.width-13-12,NView.height))
    label.font = .normal(13)
    label.textColor = .black
    label.textAlignment = .right
    self.contentView.addSubview(label)
    return label
    }()
  let descriptionLabel: UILabel
  var action: (()->())?
  
  init(text: String) {
    let titleBackground = UIView(frame: CGRect(0,0,NView.width,36))
    titleBackground.backgroundColor = .white(0.3)
    
    let font = UIFont.body
    var labelHeight = text.height(font, width: NView.width-32)
    labelHeight = min(labelHeight,font.lineHeight * 3 + 10)
    
    descriptionLabel = UILabel(frame: CGRect(16,45,NView.width-32,labelHeight))
    descriptionLabel.font = font
    descriptionLabel.textColor = .black
    descriptionLabel.numberOfLines = 3
    descriptionLabel.text = text
    
    super.init(CGSize(NView.width,56 + labelHeight))
    contentView.addSubview(titleBackground)
    contentView.addSubview(descriptionLabel)
  }
  
  override func tap() {
    super.tap()
    action?()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class LoadingNView: NView {
  static var font: UIFont { return titleFont }
  static var color: UIColor { return titleColor }
  
  let titleLabel: UILabel
  let loader: DownloadingView
  let content: UIView
  var width: CGFloat
  var progress: ProgressProtocol? {
    return loader.currentProgress
  }
  var doneText: String {
    return "Downloaded"
  }
  init(progress: ProgressProtocol, title: String) {
    let title = title.uppercased()
    let font = LoadingNView.font
    width = min(NView.width,title.width(font)+48)
    
    content = UIView(frame: CGRect(8,0,width - 40,36))
    content.clipsToBounds = true
    
    titleLabel = UILabel(frame: content.bounds)
    titleLabel.font = font
    titleLabel.text = title
    titleLabel.textColor = LoadingNView.color
    loader = DownloadingView(center: Pos(width - 18,18))
    
    super.init(CGSize(width, NView.height))
    
    content.addSubview(titleLabel)
    
    contentView.addSubview(content)
    contentView.addSubview(loader)
    
    loader.follow(progress: progress) { [weak self] in
      self?.completed()
    }
    
    resetMinimize()
  }
  
  var mversion = 0
  func resetMinimize() {
    mversion += 1
    let v = mversion
    wait(3) {
      guard v == self.mversion else { return }
      guard let progress = self.progress else { return }
      guard !progress.isCompleted else { return }
      self.animate {
        self.isMinimized = true
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func completed() {
    set(width: width - 28)
    set(title: doneText)
    animate {
      isMinimized = false
    }
  }
  
  func set(title: String) {
    let title = title.uppercased()
    titleLabel.text = title
    width = title.width(LoadingNView.font)+16
    if progress != nil {
      width += 32
    }
    set(width: width)
  }
  
  func set(width: CGFloat) {
    let width = min(NView.width,width)
    let offset = width - self.width
    self.width = width
    guard !isMinimized else { return }
    animate {
      frame.w = width
      guard shows else { return }
      frame.x -= offset
    }
  }
  
  var isMinimized = false {
    didSet {
      guard isMinimized != oldValue else { return }
      if isMinimized {
        content.frame.w = 0
        let offset = frame.width - 36
        frame.w = 36
        if shows {
          frame.x += offset
        }
        loader.center = Pos(18,18)
      } else {
        content.frame.w = width - 16
        if progress != nil {
          content.frame.w -= 24
        }
        let offset = width - frame.width
        frame.w = width
        if shows {
          frame.x -= offset
        }
        loader.center = Pos(width - 18,18)
      }
    }
  }
}

class TextNView: NView {
  let label: UILabel
  var maxWidth: CGFloat { return NView.width - 16 - .margin }
  init(title: String) {
    label = UILabel(text: title, color: .black, font: .normal(15), maxWidth: NView.width - 16 - .margin, numberOfLines: 3)
    label.frame.origin = Pos(16,9)
    super.init(CGSize(label.frame.right.x + 16,label.frame.bottom.y + 11))
    contentView.addSubview(label)
  }
  
  func set(title: String) {
    label.text = title
    let width = min(title.width(label.font!),maxWidth)
    let height = title.height(label.font!, width: width)
    label.frame.w = width
    label.frame.h = height
    resize(width: label.frame.right.x + 16, .right)
    self.height = label.frame.bottom.y + 11
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NView: DPVisualEffectView {
  static var titleFont: UIFont = .normal(13)
  static var titleColor: UIColor = .black//0x6C6C6C.color
  
  static var descriptionFont: UIFont = .normal(15)
  static var descriptionColor: UIColor = .dark
  
  static var width: CGFloat { return 216 }
  static var height: CGFloat { return 36 }
  
  var key: String?
  var height: CGFloat {
    get {
      return frame.height
    } set {
      frame.h = newValue
    }
  }
  var fullHeight: CGFloat { return height + Notifications.offset }
  var index = 0
  var y: CGFloat = 40 {
    didSet {
      frame.y = y
    }
  }
  
  var shows = false {
    didSet {
      if shows {
        _show()
      } else {
        _hide()
      }
      guard shows != oldValue else { return }
      if shows {
        append()
      } else {
        remove()
      }
    }
  }
  
  // icon pos: 18,18; x += 29
  // description 18,9
  // height: 36 || 72
  
  var autohide = false {
    didSet {
      if autohide {
        resetAutohide()
      } else {
        autohideVersion += 1
      }
    }
  }
  private var autohideVersion = 0
  static var autohideTime = 5.0
  func resetAutohide() {
    guard autohide else { return }
    autohideVersion += 1
    let v = autohideVersion
    wait(NView.autohideTime) {
      guard v == self.autohideVersion else { return }
      guard self.autohideAction() else { return }
      self.hide(animated: true)
    }
  }
  
  func autohideAction() -> Bool {
    return true
  }
  
  override var frame: CGRect {
    didSet {
      
    }
  }
  init(_ size: CGSize) {
    let effect = UIBlurEffect(style: .light)
    super.init(effect: effect)
    y = Notifications.top
    frame.size = size
    clipsToBounds = true
    layer.cornerRadius = 13
    setBorder(.line, screen.pixel)
    updatePosition()
    addTap(self, #selector(tap))
  }
  
  @objc func tap() {
    hide(animated: true)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func updatePosition() {
    if shows {
      _show()
    } else {
      _hide()
    }
  }
  func display(animated: Bool = true) {
    if let key = key {
      notifications[key] = self
    }
    main.view.addSubview(self)
    animateif(animated) {
      shows = true
    }
    if autohide {
      resetAutohide()
    }
  }
  func hide(animated: Bool) {
    if let key = key {
      notifications[key] = nil
    }
    if animated {
      animate ({
        shows = false
      }) {
        self.removeFromSuperview()
      }
    } else {
      shows = false
      self.removeFromSuperview()
    }
  }
  private func _show() {
    dpos = { [unowned self] in return Pos(screen.width - 12,self.y).topRight }
  }
  private func _hide() {
    dpos = { [unowned self] in return Pos(screen.width + 12,self.y).topLeft }
  }
  
  private func remove() {
    notifications.cells.remove(at: index)
    for c in notifications.cells.from(index) {
      c.y -= fullHeight
      c.index -= 1
    }
  }
  private func append() {
    index = 0
    for c in notifications.cells {
      c.y += fullHeight
      c.index += 1
    }
    notifications.cells.insert(self, at: 0)
  }
  private func offset(_ offset: CGFloat) {
    guard index != notifications.cells.count - 1 else { return }
    for cell in notifications.cells.from(index+1) {
      cell.y += y
    }
  }
}
