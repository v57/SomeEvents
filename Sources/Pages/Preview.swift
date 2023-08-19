//
//  Preview.swift
//  faggot
//
//  Created by Димасик on 25/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import AVFoundation
import AVKit

class Previews: Page, UIScrollViewDelegate {
  let view: UIScrollView2
  var leftView: UIView?
  var rightView: UIView?
  var currentView: UIView!
  
  var index: Int
  
  
  private var _leftIndex: Int?
  private var _leftContent: Content?
  private var _rightIndex: Int?
  private var _rightContent: Content?
  private var currentContent: Content
  
  let event: Event
  
  init(event: Event, content: Content) {
    self.event = event
    
    view = UIScrollView2(frame: screen.frame)
    view.isPagingEnabled = true
    view.showsHorizontalScrollIndicator = false
    view.contentSize.width = screen.width * 3
    view.contentOffset.x = screen.width
    
    currentContent = content
    
    if let index = event.content.index(of: content) {
      self.index = index
    } else {
      index = 0
    }
    
    super.init()
    
    background = .color(.black)
    swipable(direction: .any)
    
    currentView = (content as! PhysicalContent).view(page: self)
    currentView.frame.x = screen.width
    (currentView as? PreviewProtocol)?.isOpened = true
    leftView = nextLeftContent()?.view(page: self)
    rightView = nextRightContent()?.view(page: self)
    rightView?.frame.x = screen.width * 2
    
    view.delegate = self
    showsStatusBar = false
    
    addSubview(view)
    
    if let leftView = leftView {
      view.addSubview(leftView)
    }
    if let rightView = rightView {
      view.addSubview(rightView)
    }
    view.addSubview(currentView)
  }
  
  override func resolutionChanged() {
    view.frame = screen.frame
    view.contentSize.width = screen.width * 3
    view.contentOffset.x = screen.width
    leftView?.frame = screen.frame
    currentView.frame = screen.frame.offsetBy(dx: screen.width, dy: 0)
    rightView?.frame = screen.frame.offsetBy(dx: screen.width * 2, dy: 0)
    super.resolutionChanged()
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let page = scrollView.page
    if page == 0 {
      guard hasLeft else { return }
      if leftView == nil {
        leftView = currentLeftContent()?.view(page: self)
      }
      left()
    } else if page == 2 {
      guard hasRight else { return }
      if rightView == nil {
        rightView = currentRightContent()?.view(page: self)
      }
      right()
    }
  }
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.contentInset.left = hasLeft ? 0 : -screen.width
    view.contentInset.right = hasRight ? 0 : -screen.width
    (currentView as? VideoPlayer)?.pause()
  }
  
  func left() {
    index -= 1
    if !view.isDecelerating {
      view.contentInset.right = hasRight ? 0 : -screen.width
    }
    view.contentOffset.x += screen.width
    
    leftView!.frame.x += screen.width
    currentView.frame.x += screen.width
    
    (currentView as? PreviewProtocol)?.isOpened = false
    rightView?.removeFromSuperview()
    rightView = currentView
    currentView = leftView!
    _rightContent = currentContent
    currentContent = _leftContent!
    changed()
    leftView = nextLeftContent()?.view(page: self)
    currentRightContent()
    (currentView as? PreviewProtocol)?.isOpened = true
    if let leftView = leftView {
      view.addSubview(leftView)
    }
    currentChanged()
  }
  func currentChanged() {
    print(leftIndex,index,rightIndex)
  }
  func right() {
    index += 1
    if !view.isDecelerating {
      view.contentInset.left = hasLeft ? 0 : -screen.width
    }
    view.contentOffset.x -= screen.width
    
    rightView!.frame.x -= screen.width
    currentView.frame.x -= screen.width
    
    (currentView as? PreviewProtocol)?.isOpened = false
    leftView?.removeFromSuperview()
    leftView = currentView
    currentView = rightView!
    _leftContent = currentContent
    currentContent = _rightContent!
    changed()
    rightView = nextRightContent()?.view(page: self)
    currentLeftContent()
    (currentView as? PreviewProtocol)?.isOpened = true
    if let rightView = rightView {
      rightView.frame.x = screen.width * 2
      view.addSubview(rightView)
    }
    currentChanged()
  }
  
  func changed() {
    guard let page = main.previousPage as? EventPage else { return }
    guard let transition = self.transition as? PageTransitionFromView else { return }
    guard let view = page.contentView.findContent(currentContent.id) else { return }
    transition.set(view: view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK:- Content finders
private extension Previews {
  var leftIndex: Int {
    get {
      return _leftIndex ?? index
    } set {
      _leftIndex = newValue
    }
  }
  var rightIndex: Int {
    get {
      return _rightIndex ?? index
    } set {
      _rightIndex = newValue
    }
  }
  
  
  var hasLeft: Bool {
    var index = self.index - 1
    return _nextLeftContent(index: &index) != nil
  }
  var hasRight: Bool {
    var index = self.index + 1
    return _nextRightContent(index: &index) != nil
  }
  
  @discardableResult
  func currentLeftContent() -> PhysicalContent? {
    var index = self.index - 1
    guard let content = _nextLeftContent(index: &index) else { return nil }
    _leftIndex = index
    _leftContent = content as? Content
    return content
  }
  
  @discardableResult
  func currentRightContent() -> PhysicalContent? {
    var index = self.index + 1
    guard let content = _nextRightContent(index: &index) else { return nil }
    _rightIndex = index
    _rightContent = content as? Content
    return content
  }
  
  func nextLeftContent() -> PhysicalContent? {
    var index = leftIndex - 1
    guard let content = _nextLeftContent(index: &index) else { return nil }
    _leftIndex = index
    _leftContent = content as? Content
    return content
  }
  
  func nextRightContent() -> PhysicalContent? {
    var index = rightIndex + 1
    let i = index
    guard let content = _nextRightContent(index: &index) else { return nil }
    print(i,index)
    _rightIndex = index
    _rightContent = content as? Content
    return content
  }
  
  
  
  private func _nextLeftContent(index: inout Int) -> PhysicalContent? {
    while index >= 0 {
      if let content = event.content.safe(index),
        content.isAvailable && content is PhysicalContent {
        return content as? PhysicalContent
      }
      index -= 1
    }
    return nil
  }
  private func _nextRightContent(index: inout Int) -> PhysicalContent? {
    while index < event.content.count {
      if let content = event.content.safe(index),
        content.isAvailable && content is PhysicalContent {
        return content as? PhysicalContent
      }
      index += 1
    }
    return nil
  }
}


//let players = VideoPlayerCache()
//class VideoPlayerCache {
//  var players = [AVPlayerViewController]()
//  func next() -> AVPlayerViewController {
//    for player in players {
//      guard player.parent == nil else { continue }
//      return player
//    }
//    let vc = AVPlayerViewController()
//    players.append(vc)
//    return vc
//  }
//}

private class VideoPlayerBackground: DFImageView {
  let playButton: DFButton
  var handler: (()->())?
  let content: VideoContent
  init(page: Page, content: VideoContent) {
    self.content = content
    playButton = DFButton(frame: .zero)
    playButton.systemHighlighting()
    playButton.setImage(#imageLiteral(resourceName: "PreviewPlay"), for: .normal)
    super.init(frame: screen.frame)
    clipsToBounds = true
    contentMode = .scaleAspectFit
    preview(page, content: content, preset: .none)
    isUserInteractionEnabled = true
    dframe = { screen.frame }
    playButton.dframe = { screen.frame }
    playButton.add(target: self, action: #selector(tap))
    addSubview(playButton)
  }
  
  @objc func tap() {
    guard let handler = handler else { return }
    handler()
//    google.displayAd(for: content, completion: handler)
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class VideoPlayer: UIView, PreviewProtocol {
  var isOpened: Bool = false {
    didSet {
      isOpened ? open() : close()
    }
  }
  var vc: AVPlayerViewController?
  lazy var player = AVPlayer(url: self.url)
  private var background: VideoPlayerBackground?
  let url: URL
  init(page: Page, url: URL, content: VideoContent) {
    self.url = url
    background = VideoPlayerBackground(page: page, content: content)
    super.init(frame: .zero)
    addSubview(background!)
    background?.handler = { [unowned self] in
      self.play()
    }
  }
  
  override var frame: CGRect {
    didSet {
      vc?.view.frame = bounds
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func open() {
    
  }
  func close() {
    pause()
  }
  
  func play() {
    print("preview: playing video from \(url)")
    background = background?.destroy(animated: false)
    let vc = AVPlayerViewController()
    vc.player = player
    vc.showsPlaybackControls = true
    
    main.addChildViewController(vc)
    vc.view.frame = screen.frame
    self.addSubview(vc.view)
    vc.didMove(toParentViewController: main)
    self.vc = vc
    player.play()
  }
  
  func pause() {
    player.pause()
  }
  
  deinit {
    if let vc = vc {
      player.pause()
      vc.willMove(toParentViewController: nil)
      vc.view.removeFromSuperview()
      vc.removeFromParentViewController()
    }
    vc = nil
  }
}


protocol ImageDisplayable: class {
  func set(image: UIImage?)
  var backgroundColor: UIColor? { get set }
}
protocol PreviewProtocol: class {
  var isOpened: Bool { get set }
}

extension UIImageView: ImageDisplayable {
  func set(image: UIImage?) {
    self.image = image
  }
}
extension UIButton: ImageDisplayable {
  func set(image: UIImage?) {
    self.setImage(image, for: .normal)
  }
}
class ZoomView: UIScrollView, UIScrollViewDelegate, ImageDisplayable, PreviewProtocol {
  var isOpened: Bool = false {
    didSet {
      isOpened ? open() : close()
    }
  }
  func open() {
    
  }
  
  func close() {
    zoomScale = 1
  }
  
  let imageView: UIImageView
  var isUpdated = false
  override init(frame: CGRect) {
    imageView = UIImageView(frame: frame)
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .black
    super.init(frame: frame)
    addSubview(imageView)
    delegate = self
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
  }
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    update()
  }
  func update() {
    if (imageView.frame.width < frame.width) {
      imageView.frame.x = (frame.width - imageView.frame.width) / 2.0
    } else {
      imageView.frame.x = 0.0
    }
    
    if (imageView.frame.height < frame.height) {
      imageView.frame.y = (frame.height - imageView.frame.height) / 2.0
    } else {
      imageView.frame.y = 0.0
    }
  }
  func set(image: UIImage?) {
    guard let image = image else { return }
    imageView.image = image
    guard !isUpdated else { return }
    isUpdated = true
    updateView()
    setup()
  }
  func updateView() {
    guard let size = imageView.image?.size else { return }
    let sw = size.width / frame.width
    let sh = size.height / frame.height
    let s = max(sw,sh)
    let center = imageView.center
    imageView.frame.size = CGSize(width: size.width / s, height: size.height / s)
    imageView.center = center
  }
  func setup() {
    maximumZoomScale = 4
    alwaysBounceHorizontal = true
    let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
    gesture.numberOfTapsRequired = 2
    gesture.numberOfTouchesRequired = 1
    addGestureRecognizer(gesture)
  }
  @objc func doubleTap(gesture: UITapGestureRecognizer) {
    if zoomScale == 4 {
      setZoomScale(1, animated: true)
    } else {
      let position = gesture.location(in: imageView)
      let size = imageView.frame.size / 4
      zoom(to: CGRect(position,.center,size), animated: true)
    }
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    zoomScale = 1
    updateView()
    imageView.center = bounds.center
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

