//
//  StartPage.swift
//  Project-E
//
//  Created by Димасик on 09/10/15.
//  Copyright © 2015 Dmitry Kozlov. All rights reserved.
//

import Some

class StartPage: Page {
//  var loginView: LoginView!
//  override init() {
//    super.init()
//    loginView = LoginView(page: self)
//    addSubview(loginView)
//    self.showsStatusBar = true
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  override func keyboardMoved() {
//    self.loginView.keyboardHeightChanged()
//  }
  
  var input: FaggotField!
  let photoView: DCButton
  var nameLabel: DCLabel!
  var photo: UIImage?
  var topView: DFView
  var eventsView: EventsView!
  var s: Session?
  var isRunning = false
  
  weak var icloudButton: DCButton!
  
  override init() {
    topView = DFView()
    topView.dframe = { screen.frame }
    photoView = DCButton(frame: Size(90,90).frame)
    
    super.init()
    
    addSubview(topView)
    
    photoView.systemHighlighting()
    photoView.dcenter = { Pos(screen.center.x, screen.center.y - 140) }
    photoView.backgroundColor = .background
    photoView.circle()
    photoView.setImage(UIImage(named: "SPhoto"), for: .normal)
    photoView.add(target: self, action: #selector(pickPhoto))
    topView.addSubview(photoView)
    
    if session != nil {
      s = session
      let me = User.me
      photoView.user(self, user: me)
      nameLabel = DCLabel(text: me.name, color: .black, font: .bold(30))
      nameLabel.dcenter = { Pos(screen.center.x, screen.center.y - 70) }
      topView.addSubview(nameLabel)
      wait(1) {
        self.loginSuccess()
      }
    } else {
      input = FaggotField()
      input.dpos = { (Pos(screen.center.x,screen.center.y - 70), .top) }
      input.placeholder = "Enter your name"
      input.setup()
      input.hideKeyboardOnReturn = true
      input.done = { [unowned self] in
        self.signupButtonTapped()
      }
      addSubview(input)
      
      addTap(self,#selector(tap))
      
      if !accounts.storage.synced {
        let icloudButton = DCButton(image: #imageLiteral(resourceName: "iCloudFirstSync"))
        icloudButton.dcenter = { Pos(screen.right - 30,screen.bottom - 30) }
        icloudButton.systemHighlighting()
        self.icloudButton = icloudButton
        addSubview(icloudButton)
//        let loading = DownloadingView(center: icloudButton.bounds.center, color: .lightGray)
//        loading.animating = true
//        icloudButton.addSubview(loading)
        icloudButton.addTap(self, #selector(sync))
        accounts.storage.onFirstSync { [weak self] in
          self?.synced()
        }
      }
    }
  }
  
  func synced() {
    icloudButton?.removeFromSuperview()
  }
  @objc func sync() {
    accounts.storage.cloudStorage.synchronize()
  }
  
  func removeAvatar() {
    self.photoView.setImage(nil, for: .normal)
  }
  
  func set(session: Session) {
    guard !isRunning else { return }
    guard s == nil else { return }
    s = session
    input.text = session.name.profileDisplayName
    signupButtonTapped()
  }
  
  override func closed() {
    photoView.removeTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension StartPage: UploadNotifications {
  func uploading(avatar: UploadRequest) {
    avatar.subscribe(view: photoView, page: self)
  }
}

extension StartPage: UserMainNotifications {
  func updated(user: User, name: String) {
    guard user.isMe else { return }
    nameLabel?.set(text: user.name)
  }
  
  func updated(user: User, online: Bool) {
    guard user.isMe else { return }
    
  }
  
  func updated(user: User, deleted: Bool) {
    guard user.isMe else { return }
    
  }
  
  func updated(user: User, banned: Bool) {
    guard user.isMe else { return }
    
  }
  
  func updated(user: User, avatar: Bool) {
    guard user.isMe else { return }
    if avatar {
      photoView.user(self, user: user)
    } else {
      removeAvatar()
    }
  }
  
  
}

extension StartPage {
  func loginSuccess() {
    let profile = ProfilePage(start: self)
    main.lock {
      main.show(profile)
    }
    pushManager.processNotification()
//    let topHeight: CGFloat = 180
//    eventsView = EventsView(frame: screen.frame.offsetBy(dx: 0, dy: screen.height))
//    eventsView.contentInset.top = topHeight + 20
//    eventsView.alwaysBounceVertical = true
//    eventsView.currentPage = self
//    eventsView.didScroll = { [unowned self] scrollView in
//      let y = scrollView.contentOffset.y + scrollView.contentInset.top - 20
//      
//      let top = self.topView
//      if y > 0 {
//        top.dframe = { CGRect(0,-y,screen.width,topHeight) }
//      } else {
//        if top.frame.y != 0 {
//          top.dframe = { CGRect(0,0,screen.width,topHeight) }
//        }
//      }
//    }
////    eventsView.backgroundColor = UIColor(white: 0, alpha: 0.2)
//    insertSubview(eventsView, belowSubview: topView)
//    animate(1) {
//      nameLabel.dcenter = { Pos(screen.center.x, 155) }
//      photoView.dcenter = { Pos(screen.center.x, 85) }
//      eventsView.dframe = { screen.frame }
//    }
//    topView.dframe = { CGRect(0,0,screen.width,topHeight) }
//    serverThread {
//      mainThread {
//        let events = eventManager.get(User.me.events)
//        self.eventsView.set(events: events)
//      }
//    }
  }
}

extension StartPage {
  @objc func pickPhoto() {
    let page = PhotoPicker(from: photoView, camera: true, library: true, removable: false)
    page.picked = { image in
      let image = image.thumbnail(CGSize(512,512),false)
      self.photo = image
      self.photoView.setImage(ImageEditor.circle(image, size: CGSize(90,90)), for: .normal)
    }
    main.push(page)
  }
  
  func signupButtonTapped() {
    let name = input.text
    guard !name.isEmpty else { return }
    guard !license.shouldDisplay else {
      license.display { [weak self] in
        self?.signupButtonTapped()
      }
      return
    }
    animate {
      input.textField.alpha = 0.0
      input.nextButton?.alpha = 0.0
      input.placeholderLabel.alpha = 0.0
    }
    input.colAnimation {
      self.signup(name: name)
    }
  }
  
  func signupSuccess() {
    let nameLabel = input._label!
//    nameLabel.center += input.frame.origin
//    nameLabel.removeFromSuperview()
//    topView.addSubview(nameLabel)
    self.nameLabel = nameLabel
    input.colAnimationUp()
    animate ({
      input.textFieldBackground.alpha = 0.0
      photoView.dcenter = { Pos(screen.center.x, screen.center.y - 160) }
    }) {
//      let profile = ProfilePage(start: self)
//      main.show(profile)
    }
  }
  
  func signupFailed() {
    input.colAnimationBack()
    animate {
      input.textField.alpha = 1.0
      input.placeholderLabel.alpha = 1.0
      input.nextButton.alpha = 1.0
    }
  }
  
  func signup(name: String) {
    guard name.lengthOfBytes(using: String.Encoding.utf8) < 20 else {
      showError("your name is too long")
      return
    }
    
    self.isRunning = true
    
    let operations = request()
      .rename("signup")
    if session != nil {
      operations.easyLogin()
    } else {
      operations.signup(name: name)
    }
    operations.onFail { [unowned self] error in
      self.isRunning = false
    }
    operations.success {
      self.isRunning = false
      self.signupSuccess()
      if let photo = self.photo {
        account?.upload(avatar: photo)
      }
      wait(1) {
        self.imageUploaded()
      }
    }
  }
  
  func imageUploaded() {
    animate(1, {
      photoView.dcenter = { Pos(screen.center.x, 85) }
    }) {
      let profile = ProfilePage(start: self)
      main.show(profile)
    }
    guard let label = input._label else { return }
    label.removeFromSuperview()
    label.center += input.frame.origin
    topView.addSubview(label)
    move(label: label)
  }
  
  func move(label: DCLabel) {
    let duration: Double = 1
    
    let label2 = DCLabel()
    label2.text = label.text
    label2.font = label.font
    label2.sizeToFit()
    label2.center = label.center
    
    
    label.superview?.addSubview(label2)
    if #available(iOS 8.2, *) {
      label.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.ultraLight)
    } else {
      // Fallback on earlier versions
    }
    label.sizeToFit()
    label.center = label2.center
    label.transform = .init(scaleX: 0.75, y: 0.75)
    
    animate(duration/4) {
      label2.alpha = 0.0
    }
    
    animate(duration, {
      
      label.transform = .init(scaleX: 1, y: 1)
      label2.transform = label.transform.scaledBy(x: 1.5, y: 1.5)
      label.dcenter = { Pos(screen.center.x, 155) }
      label2.dcenter = { Pos(screen.center.x, 155) }
    }, completion: {
      label2.removeFromSuperview()
    })
  }
  
  func showError(_ error: String) {
    let label = Label(frame: CGRect(screen.center.x,screen.center.y - 100,0,0), text: error, font: .normal(14), color: .light, alignment: .center, fixHeight: true)
    label.alpha = 0
    addSubview(label)
    animate ({
      label.alpha = 1.0
      label.frame = label.frame.offsetBy(dx: 0,dy: 20)
    }) {
      wait(3) {
        label.destroy()
      }
    }
  }
  
  @objc func tap() {
    input.textField.resignFirstResponder()
  }
}

class LoadingViewAvatar: LoadingView {
  override func valueChanged() {
    shapeLayer.strokeEnd = self.value
  }
  override func draw() {
    let start: CGFloat = -.pi / 2
    let end: CGFloat = .pi * 1.5 + 0.0001
    shapeLayer.path = UIBezierPath(arcCenter: CGPoint(), radius: radius - 10, startAngle: start, endAngle: end, clockwise: true).cgPath
    shapeLayer.position = CGPoint(x: 0, y: 0)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = mainColor.cgColor
    shapeLayer.lineWidth = 2.0
    shapeLayer.strokeStart = 0.0
    shapeLayer.strokeEnd = 0.0
    
    self.layer.addSublayer(shapeLayer)
  }
  
  private let radius: CGFloat = 50
  
  private let shapeLayer = CAShapeLayer()
  
  private let mainColor: UIColor
  
  init(center: CGPoint, color: UIColor = .highlighted) {
    mainColor = color
    super.init(center: center)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


//class OfflineLoginView: UIVisualEffectView {
//    func hide() -> CreateEventView! {
//        animate ({
//            self.effect = nil
//        }) {
//            self.removeFromSuperview()
//        }
//        return nil
//    }
//    func show() {
//        animate {
//            self.effect = UIBlurEffect(style: .Light)
//        }
//    }
//    init() {
//        super.init(effect: nil)
//    }
//}
