
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Dmitry Kozlov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import SomeFunctions

public var backgroundImage: UIImage? = UIImage(named: "Background")

public var previousKeyboardFrame = CGRect(0,0,0,0)
public var keyboardHeight: CGFloat = 0
public func keyboardInset(for view: UIView) -> CGFloat {
  if keyboardHeight == screen.bottomInsets {
    return keyboardHeight
  } else {
    var kheight = keyboardHeight
    kheight -= screen.height - (view.positionOnScreen.y + view.frame.h)
    return max(0,kheight)
  }
}

private var screenStatusBarWhite = UIApplication.shared.statusBarStyle == .lightContent ? false : true
private var screenStatusBarHidden = UIApplication.shared.isStatusBarHidden
extension SomeScreen {
  public var statusBarWhite: Bool {
    get {
      return screenStatusBarWhite
    }
    set {
      screenStatusBarWhite = newValue
      animate {
        main.setNeedsStatusBarAppearanceUpdate()
      }
    }
  }
  public var statusBarHidden: Bool {
    get {
      return screenStatusBarHidden
    }
    set {
      screenStatusBarHidden = newValue
      animate {
        main.setNeedsStatusBarAppearanceUpdate()
      }
    }
  }
}

open class SomeMain: UIViewController {
  public static var `default`: ()->SomeMain = { SomeMain() }
  
  public lazy var navigation = SomeNavigationBar()
  public var currentPage: SomePage {
    return pages.last!
  }
  public func find<T: SomePage>(page type: T.Type) -> T? {
    return SomeDebug.pages.allObjects.reversed().find(type)
  }
  public var pages = [SomePage]()
  public var isLoaded = false
  public var mainView = DFView()
  public var backgroundImageView: DFImageView!
  
  private var leftSwipeGesture: UIScreenEdgePanGestureRecognizer!
  private var rightSwipeGesture: UIScreenEdgePanGestureRecognizer!
  private var leftEdgeStartX: CGFloat = 0
  
//  func setDefaultOrientation() {
//    if UIDevice.current.orientation != UIDeviceOrientation.portrait {
//      let value = UIInterfaceOrientation.portrait.rawValue
//      UIDevice.current.setValue(value, forKey: "orientation")
//    }
//  }
  
  public var isAnimated = true
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    print("main: \(className(self))")
    guard !isLoaded else { return }
    DispatchQueue.main.async {
      self.viewDidLoad2()
    }
  }
  
  private func viewDidLoad2() {
    mainView.dframe = screen.dframe
    
    automaticallyAdjustsScrollViewInsets = false
    
    if backgroundImage != nil {
      backgroundImageView = DFImageView()
      backgroundImageView.dframe = screen.dframe
      backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
      backgroundImageView.clipsToBounds = true
//      backgroundImageView.layer.cornerRadius = 40
      backgroundImageView.image = backgroundImage
      view.backgroundColor = nil
    } else {
      view.backgroundColor = .mainBackground
    }
    
    leftSwipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SomeMain.leftEdgeSwipe))
    leftSwipeGesture.edges = .left
    view.addGestureRecognizer(leftSwipeGesture)
    
//    rightSwipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SomeMain.rightEdgeSwipe))
//    rightSwipeGesture.edges = .right
//    view.addGestureRecognizer(rightSwipeGesture)
    
    let notifications = NotificationCenter.default
    
    notifications.addObserver(self, selector: #selector(keyboardNotification(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
    notifications.addObserver(self, selector: #selector(rotate), name: .UIDeviceOrientationDidChange, object: nil)
    if #available(iOS 9.0, *) {
      notifications.addObserver(self, selector: #selector(checkLowPowerMode), name: .NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    view.addSubview(mainView)
    view.addSubview(navigation)
    
    pages = [loadingPage]
    if backgroundImageView != nil { mainView.addSubview(backgroundImageView) }
    bottomLayer()
    mainView.addSubview(currentPage)
    topLayer()
    
    if loadingTime > 0 {
      Timer.scheduledTimer(timeInterval: loadingTime, target: self, selector: #selector(NSObject.load), userInfo: nil, repeats: false)
    } else {
      load()
    }
  }
  
  open func lowPowerModeChanged() {
    pages.forEach { $0.lowPower() }
  }
  open var loadingTime: Double {
    return 0
  }
  open var loadingPage: SomePage {
    return MainLoading()
  }
  open func bottomLayer() {
    
  }
  open func topLayer() {
    
  }
  /// Main thread
  /// update some UI before loading
  open func preloading() {
    
  }
  /// Background thread
  /// Load your data base
  open func loading() {
    
  }
  /// Main thread
  /// if db.isEmpty { shows(StartPage()) } else { shows(ProfilePage()) }
  open func loaded() {
    print("loaded")
  }
  
  /// Page transition functions
  /// empty by default
  open func shouldOpen(from: SomePage?, to: SomePage) -> Bool {
    return true
  }
  
  open func willOpen(from: SomePage, to: SomePage) {
    
  }
  
  open func willClose(from: SomePage, to: SomePage) {
    
  }
  
  private func load() {
    preloading()
    backgroundThread {
      self.loading()
      mainThread {
        self.isLoaded = true
        if let test = SomePage.test() {
          self.show(test)
        } else {
          self.loaded()
        }
        app.notifications.mainLoaded()
      }
    }
  }
  
  public func lock(_ execute: ()->()) {
    isAnimated = false
    execute()
    isAnimated = true
  }
  
  public func push(_ page: SomePage?) {
    guard let page = page else { return }
    
    let transition = page.transition
    transition.push(left: currentPage, right: page, animated: isAnimated)
  }
  public var previousPage: SomePage? {
    return pages.right(1)
  }
  public func back() {
    let transition = currentPage.transition
    transition.right = currentPage
    transition.left = pages.right(1)
    transition.back(animated: isAnimated)
  }
  public func show(_ page: SomePage?) {
    guard let page = page else { return }
    let last = pages.last
    let closedPages = pages
    pages.removeAll()
    
    let transition = PageTransition.fade
    transition.push(left: last, right: page, animated: isAnimated)
    for page in closedPages {
      page._close()
    }
  }
  public func replace(last count: Int, with page: SomePage?) {
    guard let page = page else { return }
    let closed = pages.last(count)
    pages.removeLast(count)
//    pages.removeAll()
    
    let transition = page.transition
    transition.push(left: closed.last, right: page, animated: isAnimated)
    for page in closed {
      page.removeFromSuperview()
      page.overlay?.close()
      page.overlay?.closed()
      page._close()
    }
  }

  open func close(_ page: SomePage) {
    guard let index = pages.index(of: page) else { return }
    if page == currentPage {
      back()
    } else {
      page.closed()
      page.isClosed = true
      pages.remove(at: index)
    }
  }
  
  override open func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    pages.forEach { $0.memoryWarning() }
    // Dispose of any resources that can be recreated.
  }
  override open var preferredStatusBarStyle : UIStatusBarStyle {
    return screen.statusBarWhite ? .lightContent : .default
  }
  open override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
    return UIStatusBarAnimation.slide
  }
  override open var prefersStatusBarHidden : Bool {
    return screen.statusBarHidden
  }
  open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return screen.orientations }
  open func keyboardMoved() {
    let seq = mainView.subviews.reversed()
    for subview in seq {
      guard let page = subview as? SomePage else { continue }
      page.keyboardMoved()
      return
    }
    currentPage.keyboardMoved()
  }
  
  open func resolutionChanged() {
    _resolutionChanged()
  }
  
  override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    _viewWillTransition(to: size, with: coordinator)
    super.viewWillTransition(to: size, with: coordinator)
  }
}

private extension SomeMain {
  @objc func keyboardNotification(_ sender: Notification) {
    if let userInfo = (sender as NSNotification).userInfo {
      if previousKeyboardFrame.y == 0 {
        let fs = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.cgRectValue
        previousKeyboardFrame = fs
      }
      let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue
      keyboardHeight = screen.height - frameEnd.y
      if keyboardHeight < screen.bottomInsets {
        keyboardHeight = screen.bottomInsets
      }
      let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue!
      animateKeyboard(duration) {
        let c = isAnimating
        isAnimating = true
        self.keyboardMoved()
        isAnimating = c
      }
      previousKeyboardFrame = frameEnd
    }
  }
  @objc func checkLowPowerMode() {
    let changed = Device.updateLowPowerMode()
    if changed {
      lowPowerModeChanged()
    }
  }
  
  @objc func leftEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
    guard pages.count > 1 else {
      gesture.cancel()
      return
    }
    guard let page = pages.last else { return }
    guard page.isFullscreen else {
      gesture.cancel()
      return
    }
    page.transition.leftSwipe(gesture: gesture)
  }
  
  @objc func rightEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
    guard pages.count > 1 else {
      gesture.cancel()
      return
    }
    guard let page = pages.last else { return }
    guard page.isFullscreen else {
      gesture.cancel()
      return
    }
    page.transition.rightSwipe(gesture: gesture)
  }
  
  @objc func rotate() {
    currentPage.orientationChanged()
  }
  
}

private func statusBarAnimation(_ animation: @escaping ()->()) {
  UIView.animate(withDuration: 0.35, animations: animation)
}



/*
 
 public enum PushAnimation {
 case none, fade, push, back, modal, modalClose, show, slidePush, slideBack, blur
 }
extension SomeMain {
  public func push(_ page: SomePage?, from view: UIView, cornerRadius: CGFloat?) {
    guard let right = page else { return }
    let left = currentPage
    right.fromView = view
    right.fromCornerRadius = cornerRadius
    right.dframe = screen.dframe
    right.alpha = 1.0
    
    let fromFrame = view.frameOnScreen
    let pos = fromFrame.center
    
    let a = view.frame.size.min
    let s = a / screen.resolution.min
    let ss = a / screen.resolution.max
    
    let background = BackgroundTransitionView(frame: fromFrame, isSolid: right.pageBackground.isSolid)
    background.hide()
    
    let pv = view.superview
    let pa = view.alpha
    let pc = view.center
    view.removeFromSuperview()
    view.center = pos
    
    left.endEditing(true)
    left.willHide()
    right.willShow()
    
    navigation.push(right)
    
    mainView.addSubview(background)
    mainView.addSubview(right)
    mainView.addSubview(view)
    
    pages.append(right)
    
    right.frame.size = fromFrame.size / s
    right.scale(s)
    right.center = pos
    if let cornerRadius = cornerRadius {
      background.radius = cornerRadius
      right.cornerRadius = cornerRadius / s
    }
    
    animationSettings(time: 0.15, curve: .linear) {
      animate {
        view.alpha = 0.0
      }
    }
    
    self.view.isUserInteractionEnabled = false
    
    jellyAnimation2 ({
      background.show()
      background.set(frame: screen.frame)
      
      view.scale(1/s)
      view.center = screen.center //Pos(screen.center.x,view.frame.height/2)
      right.scale(1)
      //        to.center = screen.center
      right.frame = screen.frame
      right.cornerRadius = screen.cornerRadius
      
    }, {
      self.view.isUserInteractionEnabled = true
      
      background.completion()
      right.cornerRadius = 0
      
      left.removeFromSuperview()
      left.didHide()
      right.didShow()
      right.firstShow = false
      
      view.removeFromSuperview()
      view.alpha = pa
      view.center = pc
      view.scale(1.0)
      pv?.addSubview(view)
    })
  }
  
  func push(_ page: SomePage?, from: SomePage, to view: UIView, completion: @escaping ()->()) {
    guard let to = page else { return }
    
    let cornerRadius = from.fromCornerRadius
    from.fromView = nil
    from.fromCornerRadius = nil
    to.dframe = screen.dframe
    to.alpha = 1.0
    
    from.cornerRadius = screen.cornerRadius
    
    
    let a = view.frame.size.min
    let s = a / screen.resolution.min
    let ss = a / screen.resolution.max
    
    let vs = screen.resolution * ss
    
    let background = BackgroundTransitionView(frame: screen.frame, isSolid: from.pageBackground.isSolid)
    background.show()
    
    let pv = view.superview
    let pa = view.alpha
    let pc = view.center
    
    mainView.addSubview(to)
    
    let pos = view.centerPositionOnScreen
    let toFrame = view.frameOnScreen
    view.removeFromSuperview()
    
    mainView.addSubview(background)
    mainView.addSubview(from)
    mainView.addSubview(view)
    
    
    
    view.alpha = 0.0
    view.scale(1/s)
    view.center = screen.center //Pos(screen.center.x,view.frame.height/2)
    
    self.view.isUserInteractionEnabled = false
    
    wait(0.1) {
      animationSettings(time: 0.15, curve: .linear) {
        animate {
          view.alpha = pa
        }
      }
    }
    
    jellyAnimation2 ({
      //    animationSettings(time: 0.3, curve: .easeInOut) {
      //      animate({
      view.scale(1.0)
      view.center = pos
      
      from.scale(s)
      from.frame = toFrame
      //        from.center = pos
      
      background.hide()
      background.set(frame: toFrame)
      if let cornerRadius = cornerRadius {
        background.radius = cornerRadius
        from.cornerRadius = cornerRadius / s
      }
      
    }, {
      self.view.isUserInteractionEnabled = true
      from.cornerRadius = 0
      from.removeFromSuperview()
      
      completion()
      
      background.completion()
      view.removeFromSuperview()
      view.center = pc
      pv?.addSubview(view)
    })
    //    }
  }
  func backAnimation(from: SomePage, to: SomePage, completion: @escaping ()->()) {
    mainView.insertSubview(to, belowSubview: from)
    
    to.frame = screen.frame
    to.frame.width = 0
    to.alpha = 1.0
    animationSettings(time: 0.3, curve: .easeOut) {
      animate ({
        from.frame.x = screen.width
        to.dframe = screen.dframe
      }) {
        from.removeFromSuperview()
        completion()
      }
    }
  }
  
  func backAnimation2(from: SomePage, to: SomePage, completion: @escaping ()->()) {
    animationSettings(time: 0.3, curve: .easeOut) {
      animate ({
        from.alpha = 0.0
        to.alpha = 1.0
      }) {
        from.removeFromSuperview()
        completion()
      }
    }
  }
  
  public func swipeBlurs() {
    for page in pages {
      guard page != currentPage else { continue }
      guard !page.blurOverlays.isEmpty else { continue }
      guard page.alpha == 1 else { continue }
      animate ({
        page.dframe = { screen.frame.offsetBy(dx: -screen.width, dy: 0) }
      }) {
        page.removeBlurOverlay(animated: false)
        page.removeFromSuperview()
        page.alpha = 0
      }
    }
  }
}


extension SomeMain {
  
  open func push(_ page: SomePage?, animation: PushAnimation = .push, killall: Bool = false) {
    guard let page = page else { return }
    guard !(animation == .push && killall) else { return }
    guard shouldOpen(from: currentPage, to: page) else { return }
    
    let p = currentPage
    
    if killall && pages.count > 1 {
      willClose(from: p, to: page)
    } else {
      willClose(from: p, to: page)
    }
    
    if killall {
      for page in pages {
        pageClosed(page: page)
      }
      pages.removeAll()
    }
    
    
    p.endEditing(true)
    p.willHide()
    page.willShow()
    
    navigation.push(page)
    mainView.addSubviewSafe(page)
    pages.append(page)
    
    let pushEnded: ()->() = {
      p.didHide()
      page.didShow()
      page.firstShow = false
      if killall {
        self.pageClosed(page: p)
      }
    }
    
    if animation == .none {
      page.alpha = 1.0
      page.dframe = screen.dframe
      p.removeFromSuperview()
      p.alpha = 0.0
      
      pushEnded()
    } else if animation == .fade {
      page.alpha = 0.0
      page.dframe = screen.dframe
      animate ({
        page.alpha = 1.0
        p.alpha = 0.0
      }) {
        if p.alpha == 0.0 {
          p.removeFromSuperview()
        }
        pushEnded()
      }
    } else if animation == .blur {
      page.alpha = 0.0
      page.dframe = screen.dframe
      p.addBlurOverlay(closeOnTap: false, tapAction: nil)
      animate ({
        page.alpha = 1.0
      }) {
        pushEnded()
      }
    } else {
      var newStart: CGRect!
      var oldEnd: CGRect!
      var hideOld = true
      var hideNew = true
      var removeOld = true
      
      switch animation {
      case .push:
        var frame = screen.frame
        frame.width = 0
        newStart = screen.frame.offsetBy(dx: screen.width, dy: 0)
        oldEnd = frame
        hideNew = false
        hideOld = false
        removeOld = true
      case .back:
        newStart = screen.frame.offsetBy(dx: -screen.width / 2, dy: 0)
        oldEnd = screen.frame.offsetBy(dx: screen.width / 2, dy: 0)
      case .modal:
        newStart = screen.frame.offsetBy(dx: 0, dy: screen.height)
        oldEnd = screen.frame.offsetBy(dx: 0, dy: 0)
        hideNew = false
        hideOld = false
        removeOld = false
      case .modalClose:
        newStart = screen.frame.offsetBy(dx: 0, dy: -screen.height / 2)
        oldEnd = screen.frame.offsetBy(dx: 0, dy: screen.height / 2)
      case .show:
        newStart = screen.frame.offsetBy(dx: 0, dy: screen.height / 2)
        oldEnd = screen.frame.offsetBy(dx: 0, dy: -screen.height / 2)
      case .slidePush:
        newStart = screen.frame.offsetBy(dx: screen.width, dy: 0)
        oldEnd = screen.frame.offsetBy(dx: -screen.width, dy: 0)
        hideOld = false
        hideNew = false
      case .slideBack:
        newStart = screen.frame.offsetBy(dx: -screen.width, dy: 0)
        oldEnd = screen.frame.offsetBy(dx: screen.width, dy: 0)
        hideOld = false
        hideNew = false
      case .none, .fade, .blur:
        break
      }
      
      page.alpha = hideNew ? 0 : 1
      page.frame = newStart
      animationSettings(time: 0.3, curve: .easeOut) {
        animate ({
          if hideOld { page.alpha = 1.0 }
          if hideNew { p.alpha = 0.0 }
          page.dframe = screen.dframe
          p.frame = oldEnd
        }) {
          if removeOld {
            p.removeFromSuperview()
          }
          pushEnded()
        }
      }
    }
  }
  // Just animation function
  func pushBack(_ page: SomePage) {
    let p = currentPage
    willClose(from: p, to: page)
    
    let move = page.superview == nil
    
    p.endEditing(true)
    p.willHide()
    page.willShow()
    pages.removeLast()
    page.removeBlurOverlay()
    
    
    let completion = {
      p.didHide()
      self.pageClosed(page: p)
      SomeDebug.pagesClosed += 1
      page.didShow()
      page.firstShow = false
    }
    
    if let view = p.fromView, view.superview != nil {
      push(page, from: p, to: view, completion: completion)
    } else if move {
      backAnimation(from: p, to: page, completion: completion)
    } else {
      backAnimation2(from: p, to: page, completion: completion)
    }
    
    //    mainView.addSubviewSafe(page)
    //    let move = page.frame.origin != .zero
    //    if move {
    //      page.frame = screen.frame.offsetBy(dx: -screen.width/2, dy: 0)
    //    }
    //
    //    p?.endEditing(true)
    //    p?.willHide()
    //    page.willShow()
    //    currentPage = page
    //    page.removeBlurOverlay()
    //    animate(move ? 0.3 : 0.2, {
    //      page.alpha = 1.0
    //      p?.alpha = 0.0
    //      if move {
    //        page.dframe = screen.dframe
    //        p?.frame = screen.frame.offsetBy(dx: screen.width/2, dy: 0)
    //      }
    //    }, completion: {
    //      if let p = p {
    //        p.removeFromSuperview()
    //        p.didHide()
    //        self.pageClosed(page: p)
    //      }
    //      SomeDebug.pagesClosed += 1
    //      page.didShow()
    //      page.firstShow = false
    //    })
  }
 
 /// contains page.bye() and page.isClosed = true
 open func pageClosed(page: SomePage?) {
 guard let page = page else { return }
 page._close()
 }

}
*/
