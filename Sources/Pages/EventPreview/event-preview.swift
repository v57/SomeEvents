//
//  EventPreview.swift
//  faggot
//
//  Created by Димасик on 3/24/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class EventPreview: Page {
  static var width: CGFloat = 287
  var height: CGFloat = 320
  let minHeight = EPTopView.height + EPMiddleView.minHeight + EPBottomView.height
  var maxHeight: CGFloat
  
  // background
//  let view: UIView
  var subpages = [Subpage]()
  let blur: UIVisualEffectView
  
  let event: Event
  
  let mainView = Subpage()
  var top: EPTopView!
  var info: EPInfoView!
  var middle: EPMiddleView!
  var bottom: EPBottomView!
  
  var startFrame: CGRect?
  
  override var isFullscreen: Bool {
    return false
  }
  override var transition: PageTransition {
    didSet {
//      if transition.isFromView {
//        blur.frame.y = frame.width
//        transition.animation(type: .normal, opening: true, {
//          self.blur.frame.y = 0
//        }, completion: {})
//      }
    }
  }
  
  func set(startView view: UIView) {
    var frame = view.frame
    frame.origin = view.convert(view.frame.origin, to: nil)
    startFrame = frame
  }
  
  
  init(event: Event) {
    maxHeight = max(screen.height - 50,minHeight)
    
    self.event = event
    
//    view = UIView(frame: CGRect(0,0,EventPreview.width,height))
//    view.layer.cornerRadius = 20
//    view.layer.borderColor = UIColor.lightGray.cgColor
//    view.clipsToBounds = true
//    view.layer.borderWidth = screen.pixel
//    view.center = screen.center
    
    let effect = UIBlurEffect(style: .extraLight)
    blur = UIVisualEffectView(effect: effect)
    
    super.init()
    
    layer.cornerRadius = 20
    layer.borderColor = UIColor.lightGray.cgColor
    layer.borderWidth = screen.pixel
    
    showsBackButton = false
    
//    addSubview(view)
    
    top = EPTopView(page: self)
    info = EPInfoView(page: self)
    middle = EPMiddleView(page: self, offset: top.height)
    bottom = EPBottomView(page: self, offset: top.height + middle.height)
    
    height = top.height + middle.height + bottom.height
    
    frame = screenFrame()
//    view.frame.height = height
    blur.frame = bounds
//    blur.frame.y += top.height
//    blur.frame.height -= top.height
    
    mainView.frame = bounds
    
    addSubview(blur)
    blur.contentView.addSubview(mainView)
    
    mainView.addSubview(top)
    info.move(top.frame.bottomLeft, .bottomLeft)
    top.addSubview(info)
    mainView.addSubview(middle)
    mainView.addSubview(bottom)
    
    subpages.append(mainView)
    
    swipable(direction: .any)
    
    notifications.reports.event = { [unowned self] event in
      guard event == self.event.id else { return }
      self.middle.reported()
    }
    
//    addTap(self, #selector(tap(gesture:)))
    event.open()
  }
  
  
  
//  @objc func tap(gesture: UITapGestureRecognizer) {
//    let location = gesture.location(in: view)
//    guard !bounds.contains(location) else { return }
//    close()
//  }
  
  func close() {
    main.back()
//    if let frame = startFrame {
//      let a = frame.size.min
//      let b = view.frame.size.min
//      let s = a / b
//
//      animate {
//        self.view.transform = .init(scaleX: s, y: s)
//        self.view.center = frame.center
//      }
//    } else {
//      animationSettings(time: 0.25, curve: .easeIn) {
//        view.scale(from: 1.0, to: 0, animated: true)
//      }
//    }
  }
  
  override func willHide() {
//    if isClosing {
//      if transition.isFromView {
//        transition.animation(type: .normal, opening: true, {
//          self.blur.frame.y = self.frame.width
//        }, completion: {})
//      }
//    }
  }
  
  override func closed() {
    event.close()
  }
  
//  override func customTransition(with page: SomePage?, ended: @escaping () -> ()) -> Bool {
//    let size = CGSize(EventPreview.width, height)
//    if let startFrame = startFrame {
//      let a = startFrame.size.min
//      let b = size.min
//      let s = a / b
//      
//      let endFrame = CGRect(screen.center, .center, size)
//      view.frame = endFrame//CGRect(0,0,b,b)
//      view.scale(s)
//      view.center = startFrame.center
//      jellyAnimation2 {
//        self.view.scale(1)
//        self.view.center = screen.center
//      }
//    } else {
//      alpha = 0.0
//      view.frame = CGRect(screen.center, .center, size)
//      subpages.last!.frame = view.bounds
//      view.scale(1.2)
//      animate {
//        alpha = 1.0
//      }
//      jellyAnimation {
//        self.view.scale(1)
//      }
//    }
//    
//    ended()
//    
//    return true
//  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func resolutionChanged() {
    maxHeight = max(screen.height - 50,minHeight)
    set(height: min(height, maxHeight))
//    view.center = screen.center
    super.resolutionChanged()
  }
  
  override var screenFrame: DFrame {
    return { [unowned self] in
      self.cframe()
    }
  }
  func cframe() -> CGRect {
    return CGRect(screen.center, .center, Size(EventPreview.width, height))
  }
  
  func set(height: CGFloat) {
    var height = max(height,minHeight)
    height = min(height,maxHeight)
    guard self.height != height else { return }
//    let offset = height - self.height
//    blur.frame.height = middle.height + bottom.height
    bottom.move(y: height, .bottom)
    resize(height: height, .center)
    blur.frame = bounds
    subpages.first!.frame = bounds
    middle.frame.h = height - top.height - bottom.height
    middle.content.frame.h = middle.frame.h
    self.height = height
  }
  
  func updateHeight() {
    let height = top.height + middle.height + bottom.height
    set(height: height)
  }
  
  func push(_ to: Subpage) {
    let offset = frame.width
    
    let from = subpages.last!
    to.parent = self
    to.frame = bounds
    to.frame.x = to.frame.width
    subpages.append(to)
    addSubview(to)
    animate ({
      from.frame.x -= offset
      to.frame.x -= offset
    }) {
      from.removeFromSuperview()
    }
  }
  
  func back() {
    guard subpages.count > 1 else { return }
    let offset = frame.width
    
    let from = subpages.removeLast()
    let to = subpages.last!
    to.frame = bounds
    to.frame.x -= offset
    addSubview(to)
    animate ({
      to.frame.x += offset
      from.frame.x += offset
    }) {
      from.removeFromSuperview()
    }
  }
  
  class Subpage: UIView {
    weak var parent: EventPreview?
    init() {
      super.init(frame: .zero)
      clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func back() {
      parent?.back()
    }
  }
}

extension EventPreview: TransitionCustomAnimations {
  func opening(transition: PageTransition, with state: TransitionState) {
    guard transition.isFromView else { return }
    switch state {
    case .preInit:
      self.blur.frame.y = self.frame.width
    case .preAnimation:
      self.blur.frame.y = 0.0
    default: break
    }
  }
  
  func closing(transition: PageTransition, with state: TransitionState) {
    guard transition.isFromView else { return }
    switch state {
//    case .preInit:
//      self.blur.frame.y = self.frame.width
    case .preAnimation:
      self.blur.frame.y = bounds.w
      print("pre animation:",frame.w,bounds.w)
    case .postAnimation:
      print("post animation:",frame.w,bounds.w)
    default: break
    }
  }
  
  func pushing(transition: PageTransition, with state: TransitionState) {
    
  }
  
  func back(transition: PageTransition, with state: TransitionState) {
    
  }
  
  func closing(transition: PageTransition, time: CGFloat, state: TransitionSlideState) {
    guard state == .willChange else { return }
    self.blur.frame.y = bounds.w * (1-time)
  }
  
  func back(transition: PageTransition, time: CGFloat, state: TransitionSlideState) {
    
  }
}

extension EventPreview: EventMainNotifications {
  func created(event: Event) {
    guard self.event == event else { return }
  }
  
  func created(content: Content, in event: Event) {
    guard self.event == event else { return }
  }
  
  func uploaded(preview: Content, in event: Event) {
    guard self.event == event else { return }
  }
  
  func uploaded(content: Content, in event: Event) {
    guard self.event == event else { return }
    self.middle.updateExport()
  }
  
  func updated(id event: Event, oldValue: ID) {
    guard self.event == event else { return }
  }
  
  func updated(name event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(startTime event: Event) {
    guard self.event == event else { return }
    self.top.startTimeChanged()
  }
  
  func updated(endTime event: Event) {
    guard self.event == event else { return }
    self.top.endTimeChanged()
  }
  
  func updated(coordinates event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(preview event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(contentAvailable event: Event) {
    guard self.event == event else { return }
  }
  
  
}

extension EventPreview: EventPublicNotifications {
  func updated(owner event: Event, oldValue: ID) {
    guard event.owner == .me || oldValue == .me else { return }
    if event.isOwner {
      self.middle.owned()
    } else {
      self.middle.unowned()
    }
    self.bottom.update()
  }
  
  func updated(status event: Event, oldValue: EventStatus) {
    guard self.event == event else { return }
    self.top.statusChanged()
  }
  func updated(privacy event: Event) {
    guard self.event == event else { return }
    self.middle.updatePrivacy()
  }
  func updated(options event: Event) {
    guard self.event == event else { return }
  }
  func updated(createdTime event: Event) {
    guard self.event == event else { return }
  }
  func updated(online event: Event) {
    guard self.event == event else { return }
  }
  func updated(onMap event: Event) {
    guard self.event == event else { return }
  }
  func updated(removed event: Event) {
    guard self.event == event else { return }
  }
  func updated(banned event: Event) {
    guard self.event == event else { return }
  }
  func updated(protected event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(content event: Event) {
    guard self.event == event else { return }
    self.info.photos = event.photos.count
    self.info.videos = event.videos.count
    self.middle.updateExport()
  }
  func added(content: Content, to event: Event) {
    guard self.event == event else { return }
    if content.type == .photo {
      self.info.photos += 1
    } else if content.type == .video {
      self.info.videos += 1
    }
    self.middle.updateExport()
  }
  func removed(content: Content, from event: Event) {
    guard self.event == event else { return }
    if content.type == .photo {
      self.info.photos -= 1
    } else if content.type == .video {
      self.info.videos -= 1
    }
    self.middle.updateExport()
  }
  
  func invited(user: ID, to event: Event) {
    guard event == self.event else { return }
    guard user.isMe else { return }
    self.middle.invited()
    self.bottom.update()
  }
  
  func uninvited(user: ID, from event: Event) {
    guard event == self.event else { return }
    guard user.isMe else { return }
    self.middle.uninvited()
    self.bottom.update()
  }
  
  func updated(views event: Event) {
    guard self.event == event else { return }
    self.info.views = event.views
  }
  func updated(comments event: Event) {
    guard self.event == event else { return }
    self.info.comments = event.commentsCount
  }
  func updated(current event: Event) {
    guard self.event == event else { return }
    self.info.current = event.current
  }
  
  func updated(banList event: Event) {
    guard self.event == event else { return }
  }
  
  
  
}

class EPBlock: UIView {
  unowned let page: EventPreview
  var event: Event { return page.event }
  init(frame: CGRect, page: EventPreview) {
    self.page = page
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
