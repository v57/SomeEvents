//
//  Event.swift
//  faggot
//
//  Created by Димасик on 30/01/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge

class EventPage: ScrollPage, EventDelegate {
  var event: Event
  
  var topView: EventPageTop!
  var contentView: EventPhotosView!
  //  let commentsView: CommentsView
  
  override var transition: PageTransition {
    didSet {
      if transition.isFromView {
        swipable(scrollView: scrollView)
      }
    }
  }
  
  lazy var resumeButton: FButton = { [unowned self] in
    let button = FButton(text: self.event.isStarted ? "Resume" : "Start", icon: #imageLiteral(resourceName: "EventResume"), position: 0)
    button.touch { [unowned self] in
      self.event.start()
        .autorepeat(self)
    }
    return button
    }()
  lazy var photoButton: FButton = { [unowned self] in
    let button = FButton(text: "Camera", icon: #imageLiteral(resourceName: "EventCamera"), position: 1)
    button.open { [unowned self] in
      EventCamera(event: self.event)
    }
    return button
    }()
  lazy var libraryButton: FButton = { [unowned self] in
    let button = FButton(text: "Library", icon: #imageLiteral(resourceName: "EventLibrary"), position: 3)
    button.touch { [unowned self] in
      self.openLibrary()
    }
    return button
    }()
  let commentsButton = FButton(text: "Comments", icon: #imageLiteral(resourceName: "EventComments"), position: 4)
  lazy var inviteButton: FButton = { [unowned self] in
    let button = FButton(text: "Invite", icon: #imageLiteral(resourceName: "EventInvite"), position: 5)
    button.touch { [unowned self] in
      self.invite(from: self.inviteButton)
    }
    return button
    }()
  let settingsButton = FButton(text: "More", icon: #imageLiteral(resourceName: "EventMore"), position: -1)
  
  
  
  //  let help = Help()
  //  let helpButton: InfoButton
  
  var buttons: FButtonList
  var eventOverlay: Overlay?
  func set(overlay type: OverlayType) {
    showsViews = false
    eventOverlay?.removeFromSuperview()
    eventOverlay = Overlay(type: type)
    addSubview(eventOverlay!)
  }
  func removeOverlay() {
    showsViews = true
    eventOverlay = eventOverlay?.destroy()
  }
  
  init(event: Event) {
    //    helpButton = InfoButton(pos: Pos(screen.width - 20, 50), anchor: _right, help: help)
    
    buttons = FButtonList()
    buttons.offset = 20
    buttons.boffset = 40 + buttons.offset
    buttons.height = 70
    
    let effect = UIBlurEffect(style: .extraLight)
    let blur = DFVisualEffectView(effect: effect)
    blur.clipsToBounds = true
    blur.layer.cornerRadius = 18
    
    //    commentsView = CommentsView(frame: CGRect(0,150, screen.width, screen.height - bottomSize), comments: event.commentsArray)
    
    
    //    let bo: CGFloat = 110
    //    let by: CGFloat = screen.height - 90
    
    self.event = event
    super.init()
    
    //    buttons.dframe = { CGRect(0,screen.height-h+10,screen.width,h) }
    //    blur.dframe = { CGRect(0,screen.height-h,screen.width,h) }
    
    blur.dframe = { [unowned self] in
      let o: CGFloat = 12
      let o2 = o*2
      let width = min(screen.width-o2,self.buttons.contentSize.width)
      //      CGRect(0,screen.height-h,screen.width,h)
      return CGRect(Pos(screen.width-o,screen.bottom-o),.bottomRight,Size(width,70))
    }
    buttons.dframe = {
      var frame = blur.frame
      frame.y += 10
      frame.h -= 20
      return frame
    }
    
    buttons.contentSizeChanged = { [unowned self] in
      blur.updateFrame()
      self.buttons.updateFrame()
    }
    
    topView = EventPageTop(event: event, page: self)
    contentView = EventPhotosView(event: event, page: self)
    
    if event.status == .paused {
      buttons.insert(resumeButton, animated: true)
    }
    
    if event.invited.contains(.me) && event.status != .paused {
      buttons.insert(photoButton, animated: false)
      if event.status == .ended {
        buttons.insert(libraryButton, animated: false)
      }
    }
    buttons.insert(commentsButton, animated: false)
    if event.owner.isMe {
      buttons.insert(inviteButton, animated: false)
    }
    buttons.insert(settingsButton, animated: false)
    //    buttons.buttons.forEach { $0.tintColor = .black }
    addSubview(blur)
    addSubview(buttons)
    
    commentsButton.open {
      EventComments(event: event)
    }
    
    settingsButton.open {
      EventPreview(event: event)
    }
    
    //    let privateHelp = HelpButton()
    //    privateHelp.title = "Private"
    //    privateHelp.text = "Тип кароч да?Событие можно сделать приватным, для друзей, для подписчиков и публичное\nПриватное\nПриватное событие могут просматривать только приглашённые пользователи\n\nДля друзей - тока друзя\nДля подпишиков - друзя и подпищики\n\nПубличное видят все, еше оно отображается на карте ок?\n\nВ любой момен можно заприватить события и все, кто в нём сидит - выйдут из него"
    
    //    privateHelp.position = Pos(screen.center.x, 50)
    //    privateHelp.size = Size(70,70)
    //    privateHelp.anchor = _center
    //    help.append(privateHelp)
    
    //    inviteButton.actions = self
    //    
    //    adds([currentLabel, viewsLabel, commentsLabel, completeLabel, completeIcon, inviteLabel, inviteButton, privateLabel, privateIcon])
    scrollView.contentSize = CGSize(0,topView.frame.height+20)
    scrollView.contentInset.top += 20
    scrollView.contentInset.bottom += blur.frame.height + 20
    scrollView.addSubview(topView)
    scrollView.showsVerticalScrollIndicator = false
    scrollView.alwaysBounceVertical = true
    //    topView.addSubview(helpButton)
    scrollView.addSubview(contentView)
    contentView.move(Pos(screen.center.x,topView.frame.height), _top)
    
    if transition.isFromView {
      swipable(scrollView: scrollView)
    }
    
    updateState()
    
    event.open()
    
  }
  
  func updateState() {
    let isInvited = event.invited.contains(.me)
    if event.isBanned {
      set(overlay: .banned)
    } else if event.isRemoved {
      set(overlay: .deleted)
    } else if event.isPrivateForMe {
      set(overlay: .private)
    } else {
      removeOverlay()
    }
    
    if event.status == .paused && event.isOwner {
      if event.isStarted {
        self.resumeButton.text = "Resume"
      } else {
        self.resumeButton.text = "Start"
      }
      buttons.insert(self.resumeButton, animated: true)
    } else {
      buttons.remove(self.resumeButton, animated: true)
    }
    if isInvited {
      if event.status == .paused {
        buttons.remove(self.photoButton, animated: true)
      } else {
        buttons.insert(self.photoButton, animated: true)
      }
    }
    
    if event.status == .ended && isInvited {
      buttons.insert(self.libraryButton, animated: true)
    } else {
      buttons.remove(self.libraryButton, animated: true)
    }
  }
  
  var showsViews = true {
    didSet {
      guard showsViews != oldValue else { return }
      let state = !showsViews
      topView.isHidden = state
      contentView.isHidden = state
      buttons.isHidden = state
      if showsViews {
        for cell in contentView.objects {
          guard !cell.isPreviewLoaded else { continue }
          cell.updatePreview()
        }
      }
    }
  }
  
  func invite(from button: FButton) {
    button.loading = true
    account.friends.loadUsers { friends in
      screen.orientations = .portrait
      screen.orientation = .portrait
      
      let page = PickerPage(friends: friends, invited: self.event.invited)
      page.picker.event = self.event
      page.transition = .from(button: button)
      main.push(page)
      button.loading = false
    }
  }
  
  override func closed() {
    event.close()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView2) {
    topView.scrollViewDidScroll(scrollView)
  }
  
  func openHelp() {
    
  }
  
  func updateCurrentViews(_ count: Int) {
    //    currentLabel.text = String(count)
  }
  
  func updateTotalViews(_ count: Int) {
    //    viewsLabel.text = String(count)
  }
  
  func updateComments(_ count: Int) {
    //    commentsLabel.text = String(count)
  }
  
  func contentAdded(_ content: Content) {
    switch content.type {
    case .photo:
      eventPhotoAdded(content)
    case .video:
      eventVideoAdded(content)
    }
  }
  
  func newContent(_ content: Content) {
    switch content.type {
    case .photo:
      let content = eventPhotoAdded(content)
      content?.uploading = true
    case .video:
      let content = eventVideoAdded(content)
      content?.uploading = true
    }
  }
  
  func remove(content: Content) {
    contentView.remove(content.id, animated: true)
  }
  
  func contentPreviewLoaded(_ content: Int64) {
    contentView.findContent(content)?.updatePreview()
  }
  
  func contentLoaded(_ content: Int64) {
    contentView.findContent(content)?.uploading = false
  }
  
  func removed() {
  }
  
  func banned() {
  }
  
  func privated() {
    
  }
  
  func stopped() {
    
  }
  func resumed() {
    
  }
  func ended() {
    
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var lockedView: UIImageView!
  var lockedTitle: Label!
  var showsLocked = false {
    didSet {
      if showsLocked != oldValue {
        if showsLocked {
          let image = UIImage(named: "ELocked")
          lockedView = UIImageView(image: image)
          lockedView.center = screen.center
          lockedView.alpha = 0.0
          lockedTitle = Label(frame: CGRect(screen.center.x,lockedView.frame.bottom.y + 20,0,0), text: "faggotfest", font: .ultraLight(24), color: .dark, alignment: .center, fixHeight: true)
          display(lockedView)
          display(lockedTitle)
        } else {
          lockedTitle = lockedTitle.destroy()
          lockedView = lockedView.destroy()
        }
      }
    }
  }
  
  
  
  ////////////////
  // MARK:- camera
  ////////////////
  
  
  
  func addImages(_ images: [UIImage]) {
    for image in images {
      event.addPhoto(image)
    }
  }
  //  func openVideoCamera() {
  //    let camera = VideoCamera()
  //    camera.handler = { [unowned self] url in
  //      self.event.addVideo(url)
  //    }
  //    main.push(camera)
  //  }
  func openLibrary() {
    ImagePicker.openLibrary { [unowned self] image, info in
      self.event.addPhoto(image)
    }
  }
  
  //////////////////
  // MARK:- delegate
  //////////////////
  
  
  @discardableResult
  func eventVideoAdded(_ video: Content) -> EventCell! {
    return contentView.new(content: video, animated: false)
  }
  
  @discardableResult
  func eventPhotoAdded(_ photo: Content) -> EventCell! {
    return contentView.new(content: photo, animated: false)
  }
}


extension EventPage {
  enum OverlayType {
    case `private`, deleted, banned
    var title: String {
      switch self {
      case .banned: return "Event is banned"
      case .deleted: return "Event is deleted"
      case .private: return "Event is private"
      }
    }
  }
  class Overlay: DFView {
    let label: DCLabel
    init(type: OverlayType) {
      label = DCLabel(text: type.title, color: .black, font: .light(32))
      label.dcenter = { screen.center }
      super.init(frame: .zero)
      dframe = { screen.frame }
      addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

class EventPageTop: DFView {
  let titleLabel: DCLabel
  private let currentLabel: UILabel
  //  let currentIcon: SImageView
  
  private let viewsLabel: UILabel
  //  let viewsIcon: SImageView
  
  private let commentsLabel: UILabel
  //  let commentsIcon: SImageView
  
  //  private let inviteButton: FButton
  //  private let completeButton: FButton
  //  private let privacyButton: FButton
  weak var page: EventPage!
  let event: Event
  init(event: Event, page: EventPage) {
    self.event = event
    self.page = page
    titleLabel = DCLabel(text: event.name, color: .dark, font: .ultraLight(36))
    titleLabel.dcenter = { Pos(screen.center.x,screen.top+NBHeight/2) }
    
    
    
    viewsLabel = UILabel(pos: Pos(screen.width / 5, 100), anchor: .center, text: "\(event.views) views", color: .black, font: .normal(11))
    
    
    currentLabel = UILabel(pos: Pos(screen.width / 2, 100), anchor: .center, text: "\(event.current) current", color: .black, font: .normal(11))
    
    commentsLabel = UILabel(pos: Pos(screen.width - screen.width / 5, 100), anchor: .center, text: "\(event.commentsCount) comments", color: .black, font: .normal(11))
    
    //    let bo: CGFloat = 110
    //    let ty: CGFloat = 140
    
    //    inviteButton = FButton(pos: Pos(screen.center.x - bo, ty), _top, text: "Invite\nFriends")
    //    completeButton = FButton(pos: Pos(screen.center.x, ty), _top, text: "Complete\nEvent")
    //    privacyButton = FButton(pos: Pos(screen.center.x + bo, ty), _top, text: "Privacy")
    
    super.init(frame: .zero)
    dframe = { CGRect(0,0,screen.width,100) }
    
    //    inviteButton.touch { [unowned self] in
    //
    //    }
    
    
    addSubview(titleLabel)
    //    addSubviews(inviteButton, completeButton, privacyButton)
    addSubviews(currentLabel,viewsLabel,commentsLabel)
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    currentLabel.center = Pos(screen.width / 2, 100)
    viewsLabel.center = Pos(screen.width / 5, 100)
    commentsLabel.center = Pos(screen.width - screen.width / 5, 100)
  }
  
  func set(name: String) {
    titleLabel.text = name
    titleLabel.fixFrame(true)
  }
  
  func set(current: Int) {
    currentLabel.text = "\(current) current"
  }
  func set(views: Int) {
    viewsLabel.text = "\(views) views"
  }
  func set(comments: Int) {
    commentsLabel.text = "\(comments) comments"
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView2) {
    let y = scrollView.contentOffset.y
    if y < 0 {
      dframe = { CGRect(0,y,screen.width,100) }
    } else if frame.y < 0 {
      dframe = { CGRect(0,0,screen.width,100) }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension EventPage: ContentNotifications {
  func uploaded(content: Content) {
    guard event.id == content.eventid else { return }
    self.contentLoaded(content.id)
  }
  func previewUploaded(content: Content) {
    guard event.id == content.eventid else { return }
    self.contentPreviewLoaded(content.id)
  }
}

extension EventPage: EventMainNotifications {
  func created(event: Event) {
    guard self.event == event else { return }
  }
  
  func created(content: Content, in event: Event) {
    guard self.event == event else { return }
    self.newContent(content)
  }
  
  func uploaded(preview: Content, in event: Event) {
    guard self.event == event else { return }
    contentView.findContent(preview.id)?.updatePreview()
  }
  
  func uploaded(content: Content, in event: Event) {
    guard self.event == event else { return }
    contentView.findContent(content.id)?.uploading = false
  }
  
  func updated(id event: Event, oldValue: ID) {
    guard self.event == event else { return }
  }
  
  func updated(name event: Event) {
    guard self.event == event else { return }
    self.topView.set(name: event.name)
  }
  
  func updated(startTime event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(endTime event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(coordinates event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(preview event: Event) {
    guard self.event == event else { return }
  }
  
  func updated(contentAvailable event: Event) {
    guard self.event == event else { return }
    guard event.isContentAvailable else { return }
    for content in self.contentView.objects {
      content.updatePreview()
    }
  }
}

extension EventPage: EventPublicNotifications {
  func updated(owner event: Event, oldValue: ID) {
    guard self.event == event else { return }
    if event.owner.isMe {
      self.buttons.insert(self.inviteButton, animated: true)
    } else {
      self.buttons.remove(self.inviteButton, animated: true)
    }
  }
  func updated(status event: Event, oldValue: EventStatus) {
    guard self.event == event else { return }
    self.updateState()
  }
  func updated(privacy event: Event) {
    guard self.event == event else { return }
    self.updateState()
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
    for content in event.content.reversed() {
      self.contentView.insert(content: content, animated: false)
    }
  }
  func added(content: Content, to event: Event) {
    guard self.event == event else { return }
    self.contentAdded(content)
  }
  func removed(content: Content, from event: Event) {
    guard self.event == event else { return }
    self.remove(content: content)
  }
  
  func invited(user: ID, to event: Event) {
    guard self.event == event else { return }
    guard user.isMe else { return }
    self.buttons.insert(self.photoButton, animated: true)
  }
  func uninvited(user: ID, from event: Event) {
    guard self.event == event else { return }
    guard user.isMe else { return }
    self.buttons.remove(self.photoButton, animated: true)
    self.buttons.remove(self.inviteButton, animated: true)
  }
  
  func updated(views event: Event) {
    guard self.event == event else { return }
    self.topView.set(views: event.views)
  }
  func updated(comments event: Event) {
    guard self.event == event else { return }
    self.topView.set(comments: event.commentsCount)
  }
  func updated(current event: Event) {
    guard self.event == event else { return }
    self.topView.set(current: event.current)
  }
  
  func updated(banList event: Event) {
    guard self.event == event else { return }
  }
  
}
