//
//  test-page.swift
//  faggot
//
//  Created by Димасик on 5/9/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeMap

#if debug
var testPage: Page?// = AlbumPage()// = TestChatPage() // ReportsPage()
#else
var testPage: Page? = nil
#endif

class TestMapPage: Page {
  var map = SomeMapPreview(coordinate: CLLocationCoordinate2D(latitude: 55.6, longitude: 37.5))
  override init() {
    super.init()
    map.frame = screen.frame
    addSubview(map)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class TestChatPage: Page {
  var chatView: ChatView
  override init() {
//    var frame = CGRect(0,0,320,480)
    chatView = ChatView(frame: screen.frame)
    chatView.dframe = { screen.frame }
//    frame.center = screen.center
    super.init()
    
//    let background = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//    background.clipsToBounds = true
//    background.cornerRadius = 4
//    background.frame = frame
//
//
//    addSubview(background)
//    background.contentView.
    addSubview(chatView)
    wait(1) {
      self.chatView.set(chat: Int64(1).event.comments)
    }
  }
  
  override func keyboardMoved() {
    chatView.keyboardMoved()
  }
  
  override func closed() {
    chatView.bye()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

/*

class NewEventTest: Page {
  let input = NewEventInput()
  override init() {
    super.init()
    addSubview(input)
  }
  override func keyboardMoved() {
    input.updateFrame()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NewEventInput: DFVisualEffectView, UITextFieldDelegate {
  let textField: UITextField
  init() {
    textField = TextField.init(placeholder: "Enter event name", font: .normal(24), color: .black, clearsOnSelect: false, returnKey: .done, leftOffset: 20)
//    textField.borderStyle = .roundedRect
    textField.autocorrectionType = .no
    let effect = UIBlurEffect(style: .light)
    super.init(effect: effect)
    contentView.addSubview(textField)
    clipsToBounds = true
    cornerRadius = .margin
    dframe = { CGRect(.margin, screen.height - keyboardHeight - 60 - .margin, screen.width - .margin2, 60) }
    textField.delegate = self
  }
  override func resolutionChanged() {
    textField.frame = CGRect(0,0,frame.width,frame.height)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()  
    return true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class LocatingView: UIView {
  let loader: LocationLoadingView
  let icon: UIImageView
  init() {
    let size = CGSize(60,60)
    icon = UIImageView(image: #imageLiteral(resourceName: "NELocating"))
    icon.center = size.center
    
    loader = LocationLoadingView(center: icon.center)
    super.init(frame: CGRect(origin: .zero, size: size))
    addSubview(icon)
    addSubview(loader)
  }
  
  func locating() {
    loader.animating = true
  }
  
  func located() {
    CATransaction.begin()
    CATransaction.setAnimationDuration(1)
    loader.shapeLayer.strokeEnd = 1.0
    CATransaction.commit()
    wait(1.5) {
      self.loader.shapeLayer.removeAllAnimations()
      
      CATransaction.begin()
      CATransaction.setAnimationDuration(1)
      self.loader.shapeLayer.strokeEnd = 0.0
      CATransaction.commit()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class LocationLoadingView: LoadingView {
  override func valueChanged() {
    shapeLayer.strokeEnd = self.value
  }
  override func startAnimating() {
    shapeLayer.strokeEnd = 0.85
    shapeLayer.add(loadingAnimation, forKey: "Loading Animation")
  }
  override func stopAnimating() {
    shapeLayer.removeAllAnimations()
    shapeLayer.strokeEnd = 1.0
  }
  override func draw() {
    shapeLayer.path = UIBezierPath(arcCenter: CGPoint(0,0), radius: radius - 5, startAngle: -.pi / 2, endAngle: .pi * 1.5 + 0.0001, clockwise: true).cgPath
    shapeLayer.position = CGPoint(x: 0, y: 0)
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = mainColor.cgColor
    shapeLayer.lineWidth = 2.0
    shapeLayer.lineCap = "round"
    shapeLayer.strokeStart = 0.0
    shapeLayer.strokeEnd = 0.0
    
    loadingAnimation.duration = 1.0
    loadingAnimation.repeatCount = Float.infinity
    loadingAnimation.fromValue = NSNumber(value:0.0)
    loadingAnimation.toValue = NSNumber(value: Double.pi*2)
    loadingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    loadingAnimation.isRemovedOnCompletion = false
    
    stopAnimation.fromValue = NSNumber(value:1.5)
    stopAnimation.toValue = NSNumber(value:1)
    stopAnimation.duration = 0.2
    stopAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    
    self.layer.addSublayer(shapeLayer)
  }
  private let radius: CGFloat = 25
  
  let shapeLayer = CAShapeLayer()
  
  private let loadingAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
  private let stopAnimation = CABasicAnimation(keyPath: "transform.scale")
  
  private let mainColor: UIColor
  private let bgColor: UIColor
  
  override func show() {
    alpha = 1.0
    transform = CGAffineTransform(scaleX: 1, y: 1)
  }
  
  override func hide() {
    if superview != nil {
      animate ({
        alpha = 0.0
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      }) {
        self.animating = false
      }
    } else {
      alpha = 0.0
      transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    }
  }
  
  override init(center: CGPoint) {
    mainColor = .system
    bgColor = .lightGray
    super.init(center: center)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class StackPage: Page {
  let stackView: UIStackView
  override init() {
    
    var views = [UIView]()
    for _ in 0..<10 {
      let label = UILabel(text: .random(count: .random(min: 10, max: 100), set: .symbols), color: .black, font: .normal(.random(min: 10, max: 30)))
      views.append(label)
    }
    
    stackView = UIStackView(arrangedSubviews: views)
    stackView.frame = screen.frame
    super.init()
    
    addSubview(stackView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func resolutionChanged() {
    super.resolutionChanged()
    stackView.frame = screen.frame
  }
}

extension UIView {
  public func screenshot(afterScreenUpdates: Bool = false) -> UIImage {
    if #available(iOS 10.0, *) {
      let rendererFormat = UIGraphicsImageRendererFormat.default()
      rendererFormat.opaque = isOpaque
      let renderer = UIGraphicsImageRenderer(size: bounds.size, format: rendererFormat)
      let snapshotImage = renderer.image { _ in
        drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
      }
      return snapshotImage
    } else {
      UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
      drawHierarchy(in: self.bounds, afterScreenUpdates: true)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image!
    }
  }
}

class SomeView: UIView {
  init(page: Int) {
    super.init(frame: screen.frame.offsetBy(dx: screen.width * CGFloat(page), dy: 0))
    backgroundColor = .randomForWhite()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIColor {
  func view(page: Page) -> UIView {
    let view = UIView(frame: screen.frame)
    view.backgroundColor = self
    return view
  }
}

enum JellyEffect {
  case low, medium
  var damping: CGFloat {
    switch self {
    case .low: return 0.7
    case .medium: return 0.5
    }
  }
  var velocity: CGFloat {
    switch self {
    case .low: return 2
    case .medium: return 3
    }
  }
}


class TestPage: Page {
  let view = UIView(frame: CGRect(50,0,50,50))
  let view2 = UIView(frame: CGRect(150,0,50,50))
  let view3 = UIView(frame: CGRect(250,0,50,50))
  let view4 = UIView(frame: CGRect(350,0,50,50))
  var a = false {
    didSet {
      for (i,view) in subviews.enumerated() {
        animate(index: i) {
          if self.a {
            view.resize(Size(100,100), .center)
          } else {
            view.resize(Size(50,50), .center)
          }
        }
      }
    }
  }
  override init() {
    super.init()
    let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
    addGestureRecognizer(tap)
    addSubview(view)
    addSubview(view2)
    addSubview(view3)
    addSubview(view4)
    subviews.forEach { $0.backgroundColor = .red }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func tap(gesture: UITapGestureRecognizer) {
    let pos = gesture.location(in: self)
    var contains = false
    for view in subviews {
      if view.frame.contains(pos) {
        contains = true
        break
      }
    }
    
    
    
    if contains {
      a = !a
    } else {
      for (i,view) in subviews.enumerated() {
        animate(index: i) {
          view.center.y = pos.y
        }
      }
    }
  }
  
  func animate(index: Int, animations  a: @escaping ()->()) {
    switch index {
    case 0:
      jellyAnimation(a)
    case 1:
      jellyAnimation2(a)
    case 2:
      jellyAnimation(a)
    case 3:
      jellyAnimation2(a)
    default: break
    }
  }
  
}

class TestPage3: Page, UIScrollViewDelegate {
  let view: DFScrollView
  var leftView: UIView?
  var rightView: UIView?
  var currentView: UIView!
  
  var hasLeft: Bool {
    return leftContent != nil
  }
  var hasRight: Bool {
    return rightContent != nil
  }
  
  var index = 0
  
  var currentContent: UIColor
  var leftContent: UIColor? {
    return contents.safe(index-1)
  }
  var rightContent: UIColor? {
    return contents.safe(index+1)
  }
  
  var contents = [UIColor]()
  override init() {
    for _ in 0..<5 {
      contents.append(.randomForWhite())
    }
    
    view = DFScrollView()
    view.dframe = { screen.frame }
    view.isPagingEnabled = true
    view.showsHorizontalScrollIndicator = false
    view.contentSize.width = screen.width * 3
    view.contentOffset.x = screen.width
    
    currentContent = contents.first!
    
    super.init()
    
    leftView = leftContent?.view(page: self)
    currentView = currentContent.view(page: self)
    currentView.frame.x = screen.width
    rightView = rightContent?.view(page: self)
    rightView?.frame.x = screen.width * 2
    
    view.delegate = self
    showsStatusBar = false
    
    index = 0
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
      left()
    } else if page == 2 {
      guard hasRight else { return }
      right()
    }
  }
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.contentInset.left = hasLeft ? 0 : -screen.width
    view.contentInset.right = hasRight ? 0 : -screen.width
  }
  
  func left() {
    index -= 1
    if !view.isDecelerating {
      view.contentInset.right = hasRight ? 0 : -screen.width
    }
    view.contentOffset.x += screen.width
    
    leftView!.frame.x += screen.width
    currentView.frame.x += screen.width
    
    rightView?.removeFromSuperview()
    rightView = currentView
    currentView = leftView!
    leftView = leftContent?.view(page: self)
    if let leftView = leftView {
      view.addSubview(leftView)
    }
  }
  func right() {
    index += 1
    if !view.isDecelerating {
      view.contentInset.left = hasLeft ? 0 : -screen.width
    }
    view.contentOffset.x -= screen.width
    
    rightView!.frame.x -= screen.width
    currentView.frame.x -= screen.width
    
    leftView?.removeFromSuperview()
    leftView = currentView
    currentView = rightView!
    rightView = rightContent?.view(page: self)
    if let rightView = rightView {
      rightView.frame.x = screen.width * 2
      view.addSubview(rightView)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

class TestPage2: Page {
  
  override init() {
    super.init()
    addProgress()
    addCompleted()
    addTap(self,#selector(tap))
  }
  
  @objc func tap() {
    let progress = CustomProgress.test()
//    progress.total = 100
//    wait(2) {
//      progress.completed = progress.total
//    }
    notification(text: "Downloading", progress: progress)
  }
  
  func notification(text: String, progress: ProgressProtocol) {
    let view = LoadingNView(progress: progress, title: text)
    view.display(animated: true)
    main.view.addSubview(view)
  }
  
  func notification(text: String) {
    let view = TextNView(title: text)
    view.display(animated: true)
    view.autohide = true
    main.view.addSubview(view)
  }
  
  func addProgress() {
    let view = LoadingView(center: screen.center)
    view.value = 0.3
    view.center = screen.center
    addSubview(view)
  }
  
  func addCompleted() {
    let view = LoadingView(center: screen.center)
    view.value = 1.0
    view.center = screen.center
    view.frame.x += 50
    addSubview(view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

*/
