//
//  EventCreatorSelecter.swift
//  Events
//
//  Created by Димасик on 5/16/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation
import Some
import SomeTable
import Photos
import SomeMap

// MARK:- Page
class EventCreatorSelecter: Page {
  fileprivate var collection: PHAssetCollection?
  fileprivate var table = Table()
  fileprivate var selectedContent = Set<PHAsset>()
  fileprivate let eventInfoView: EventInfoView
  private let doneButton = BlueButton(text: "Create")
  private var isFailed = false
  init(collection: PHAssetCollection?) {
    table.size = screen.resolution
    table.gap.vertical = .miniMargin
    table.gap.horizontal = .miniMargin
    table.insets.left = .margin
    table.insets.right = .margin
    eventInfoView = EventInfoView(title: collection?.localizedTitle ?? "")
    
    super.init()
    
    addSubview(table)
    table.view.addSubview(eventInfoView)
    table.insets.top = screen.top + NBHeight + eventInfoView.frame.height
    table.insets.bottom = 100
    self.collection = collection
    
    if let collection = collection {
      fetch(PHAsset.fetchAssets(in: collection, options: nil))
    } else {
      fetch(PHAsset.fetchAssets(with: nil))
    }
    doneButton.buttonActions.onTouch { [unowned self] in
      self.done()
    }
    doneButton.move(Pos(screen.right - .margin, screen.top + 2.5), .topRight)
    addSubview(doneButton)
  }
  private var version = 0
  
  func done() {
    var errors = 0
    version += 1
    let v = version
    
    if let text = eventInfoView.title.text, !text.isEmpty {
      
    } else {
      errors += 1
      let view = eventInfoView.title!
      view.becomeFirstResponder()
      if !isFailed {
        view.layer.cornerRadius = .margin
        view.setBorder(.red, 0.0)
      }
      view.set(borderWidth: 3.0, animated: true)
      wait(2) {
        guard v == self.version else { return }
        view.set(borderWidth: 0.0, animated: true)
      }
    }
    if eventInfoView.location == nil {
      errors += 1
      let view = eventInfoView.map!
      if !isFailed {
        view.setBorder(.red, 0.0)
      }
      view.set(borderWidth: 3.0, animated: true)
      wait(2) {
        guard v == self.version else { return }
        view.set(borderWidth: 0.0, animated: true)
      }
    }
    isFailed = true
    if errors == 0 {
      
    }
  }
  
  override func resolutionChanged() {
    doneButton.move(Pos(screen.right - .margin, screen.top + 2.5), .topRight)
    table.scrollView.edit {
      super.resolutionChanged()
//      table.size = screen.resolution
      table.resize(size: screen.resolution, animated: true)
//      table.update(frame: screen.frame)
    }
  }
  
  func fetch(_ fetch: PHFetchResult<PHAsset>) {
    weak var page: EventCreatorSelecter! = self
    newThread {
      var dates = MinMax<Time>()
      fetch.enumerateObjects(options: []) { asset, index, stop in
        guard page != nil else {
          stop.pointee = true
          return }
        if let date = asset.creationDate {
          dates.insert(date.time)
        }
        mainThread {
          if let location = asset.location?.coordinate {
            if page.eventInfoView.location == nil {
              page.eventInfoView.location = location
              page.eventInfoView.map.set(coordinate: location, animated: false)
            }
          }
          if page.collection != nil {
            page.selectedContent.insert(asset)
          }
          let cell = AssetCell(asset: asset, page: page)
          page.table.append(cell, animated: false)
        }
      }
      if !dates.isEmpty {
        mainThread {
          page?.eventInfoView.started.set(time: dates.min)
          page?.eventInfoView.ended.set(time: dates.max)
        }
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK:- Map
private class ECMap: SomeMapPreview {
  private var cachedFrame: CGRect!
  private var cachedPos: CGPoint!
  var isOpened: Bool = false
  private var _superview: UIView!
  weak var infoView: EventInfoView!
  
  lazy var closeView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .extraLight)
    let view = UIVisualEffectView(effect: effect)
    let button = UILabel(text: "Done", color: .black, font: .body)
    view.frame = button.frame * 2
    button.center = view.bounds.center
    view.contentView.addSubview(button)
    view.layer.cornerRadius = .margin
    view.clipsToBounds = true
    view.move(Pos(bounds.w - .margin,bounds.h),.topRight)
    view.buttonActions.onTouch { [unowned self] in
      self.close()
    }
    addSubview(view)
    return view
  }()
  lazy var centerView: UIImageView = { [unowned self] in
    let view = UIImageView(image: #imageLiteral(resourceName: "MapMyEvent"))
    view.alpha = 0.0
    addSubview(view)
    return view
  }()
  func set(frame: CGRect) {
    if isOpened {
      cachedFrame = frame
    } else {
      self.frame = frame
    }
  }
  func open() {
    _superview = self.superview
    isOpened = true
    cachedPos = self.frame.origin
    self.frame.origin = self.positionOnScreen
    centerView.center = frame.size.center
    cachedFrame = self.frame
    main.currentPage.addSubview(self)
    _ = closeView
    jellyAnimation2 {
      self.cornerRadius = screen.cornerRadius
      self.frame = screen.frame
      self.centerView.center = self.frame.size.center
      self.centerView.alpha = 1.0
//      shadowView.layer.shadowPath = CGPath(rect: shadowView.bounds, transform: nil)
//      self.shadowView.updateShadow(cornerRadius: .margin)
//      self.shadowView.layer.shadowOpacity = 0.0
//      frame = shadowView.bounds
      self.closeView.move(Pos(self.bounds.w - .margin,self.bounds.h - .margin),.bottomRight)
    }
    enableUserInteractions()
  }
  func close() {
    infoView.location = centerCoordinate
    isOpened = false
    animate ({
      self.cornerRadius = .margin
      self.frame = self.cachedFrame
      self.closeView.move(Pos(self.bounds.w - .margin,self.bounds.h),.topRight)
      self.centerView.center = self.frame.size.center
      self.centerView.alpha = 0.0
    }) {
      self.frame.origin = self.cachedPos
      self._superview.addSubview(self)
    }
    disableUserInteractions()
  }
  override func resolutionChanged() {
    if isOpened {
      centerView.center = frame.size.center
      self.frame = screen.frame
    }
  }
}

// MARK:- Date
private class DateView: UIView {
  var titleLabel: UILabel
  var dateLabel: UILabel
  var time: Time = .now
  init(title: String) {
    titleLabel = UILabel(text: title, color: .lightGray, font: .caption1)
    dateLabel = UILabel(text: "18 Aug", color: .system, font: .heavy(24))
    dateLabel.move(titleLabel.frame.bottomLeft,.topLeft)
    dateLabel.numberOfLines = 2
//    print(titleLabel.frame,dateLabel.frame,titleLabel.frame + dateLabel.frame)
    super.init(frame: titleLabel.frame + dateLabel.frame)
    addSubview(titleLabel)
    addSubview(dateLabel)
    
    dateLabel.buttonActions.onTouch { [unowned self] in
      self.open()
    }
  }
  
  func open() {
    let picker = DatePicker()
    picker.time = time
    picker.completion = { [unowned self] date in
      self.set(time: date.time)
    }
    
    let settings = FromViewSettings(view: dateLabel, cornerRadius: 0, isTransparent: true)
    settings.moveView = false
    settings.shouldHideView = false
    settings.insertIndex = 0
    picker.transition = .from(view: settings)
    main.push(picker)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func set(time: Time) {
    self.time = time
    dateLabel.set(text: time.uniFormat, anchor: .topLeft)
    frame.size = titleLabel.frame + dateLabel.frame
  }
}

private extension Time {
  var uniFormat: String {
    let now = Time.now
    var result = ""
    var max = Swift.max(now,self)
    max -= Swift.min(now,self)
    if max > 82800 {
      result.addLine(dateFormat("MMM dd"))
      if now.year != year {
        result.addLine("\(year)")
      }
    } else {
      result.addLine(dateFormat(time: .short))
    }
    return result
  }
}

private class BlueButton: UILabel {
  init(text: String) {
    let font: UIFont = .body
    let size = CGSize(width: text.width(font) + .margin2, height: 40)
    super.init(frame: CGRect(size: size))
    textAlignment = .center
    textColor = .white
    backgroundColor = .system
    clipsToBounds = true
    cornerRadius = 8
    self.font = font
    self.text = text
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class EventInfoView: UIView {
  var title: UITextField!
  var sendLocationsLabel: UILabel!
  var sendLocationsSwitch: UISwitch!
  var privacyLabel: UILabel!
  var privacyDescription: UILabel!
  var privacySwitch: UISwitch!
  var mapShadow: UIView!
  var map: ECMap!
  var minMapWidth: CGFloat { return 120 }
  var shouldSeparate: Bool { return screen.width <= 247 + minMapWidth + .margin }
  var location: CLLocationCoordinate2D?
  let started = DateView(title: "Started")
  let ended = DateView(title: "Ended")
  
  init(title: String) {
    super.init(frame: CGRect(0,0,screen.width,0))
    let shouldSeparate = self.shouldSeparate
    
    let width: CGFloat
    if shouldSeparate {
      width = screen.width - .margin2
    } else {
      width = screen.width - minMapWidth - .margin * 3
    }
    do {
      let textField = UITextField(frame: CGRect(.margin,0,screen.width - .margin2,50))
      textField.font = .largeTitle
      textField.placeholder = "Event name"
      textField.text = title
      addSubview(textField)
      self.title = textField
    }
    
    var y: CGFloat = 70
    
    mapShadow = UIView()
    
    map = ECMap()
    map.infoView = self
    map.clipsToBounds = true
    map.cornerRadius = .margin
    map.disableUserInteractions()
    mapShadow.addSubview(map)
    addSubview(mapShadow)
    
    sendLocationsLabel = UILabel(text: "Send locations", color: .black, font: .body, maxWidth: width - 50)
    sendLocationsLabel.frame.x = .margin
    sendLocationsSwitch = UISwitch(frame: .zero)
    sendLocationsSwitch.isOn = !settings.stripPhotoLocations
    sendLocationsSwitch.onTouch { settings.stripPhotoLocations = !$0 }
    moveViews(sendLocationsLabel, sendLocationsSwitch, &y)
    addSubviews(sendLocationsLabel,sendLocationsSwitch)
    
    y += .margin
    
    let isPublic = settings.eventCreationPrivacy == .public
    
    privacyLabel = UILabel(text: "Public event", color: .black, font: .body, maxWidth: width - 50)
    privacyLabel.frame.x = .margin
    privacySwitch = UISwitch(frame: .zero)
    privacySwitch.isOn = isPublic
    privacySwitch.onTouch { settings.eventCreationPrivacy = $0 ? .public : .private }
    moveViews(privacyLabel, privacySwitch, &y)
    addSubviews(privacyLabel,privacySwitch)
    
    y += .margin
    
    started.frame.x = .margin
    started.frame.y = y
    ended.frame.x = .margin + 100
    ended.frame.y = y
    addSubviews(started,ended)
    
    y += 100
    
    if shouldSeparate {
      mapShadow.frame = CGRect(.margin,y + .margin,width,width)
      map.frame = mapShadow.bounds
      y += screen.width
      sendLocationsSwitch.frame.x = width - sendLocationsSwitch.frame.w
      privacySwitch.frame.x = width - privacySwitch.frame.w
    } else {
      sendLocationsSwitch.frame.x = 170
      privacySwitch.frame.x = 170
      
      let x = 170 + UISwitch.size.width + .margin
      var w = screen.width - x - .margin
      w = min(w, y - 70 - .margin)
      mapShadow.frame = CGRect(x,70,w,w)
      map.frame = mapShadow.bounds
    }
    
    mapShadow.buttonActions
      .set(shadow: .rounded(radius: .margin))
      .onTouch { [unowned self] in
      if !self.map.isOpened {
        self.map.open()
      }
    }
    
    frame.origin.y = -y
    frame.size.height = y
    
    addTap(#selector(tap))
  }
  
  @objc func tap() {
    title.resignFirstResponder()
  }
  
  func moveViews(_ view1: UIView, _ view2: UIView, _ y: inout CGFloat) {
    let h1 = view1.frame.height
    let h2 = view2.frame.height
    if h1 > h2 {
      view1.frame.y = y
      view2.frame.y = y + (h1-h2)/2
      y += h1
    } else {
      view2.frame.y = y
      view1.frame.y = y + (h2-h1)/2
      y += h2
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update() {
    
  }
  
  override func resolutionChanged() {
    super.resolutionChanged()
    let shouldSeparate = self.shouldSeparate
    
    let width: CGFloat
    if shouldSeparate {
      width = screen.width - .margin2
    } else {
      width = screen.width - minMapWidth - .margin * 3
    }
    title.frame.w = screen.width - .margin2
    
    var y: CGFloat = 70
    
    y += max(sendLocationsLabel.frame.h, sendLocationsSwitch.frame.h)
    
    y += .margin
    
    y += max(privacyLabel.frame.h, privacySwitch.frame.h)
    
    y += .margin
    
    started.frame.y = y
    ended.frame.y = y
    
    y += 100
    
    if shouldSeparate {
      sendLocationsSwitch.frame.x = width - sendLocationsSwitch.frame.w
      privacySwitch.frame.x = width - privacySwitch.frame.w
      mapShadow.frame = CGRect(.margin,y + .margin,width,width)
      map.frame = mapShadow.bounds
      y += screen.width
    } else {
      let x = 170 + UISwitch.size.width + .margin
      var w = screen.width - x - .margin
      w = min(w,y - 70 - .margin)
      mapShadow.frame = CGRect(x,70,w,w)
      map.frame = mapShadow.bounds
      sendLocationsSwitch.frame.x = 170
      privacySwitch.frame.x = 170
    }
    mapShadow.updateShadow(cornerRadius: .margin)
    
    frame.origin.y = -y
    frame.size.height = y
    (superview as? UIScrollView)?.contentInset.top = screen.top + NBHeight + y
  }
}

private class AssetCell: SomeTable.Cell {
  let asset: PHAsset
  unowned var page: EventCreatorSelecter
  var isSelected: Bool {
    get { return page.selectedContent.contains(asset) }
    set {
      if newValue {
        page.selectedContent.insert(asset)
      } else {
        page.selectedContent.remove(asset)
      }
    }
  }
  
  static let width = cellWidth()
  
  static func cellWidth() -> CGFloat {
    let m: CGFloat = 180
    let c = Int(screen.resolution.min / m)
    if c < 3 {
      return screen.resolution.min / 3 - (CGFloat.margin * 4)
    } else {
      return m
    }
  }
  
  override func size(fitting: CGSize, max: CGSize) -> CGSize {
    return CGSize(AssetCell.width,AssetCell.width)
  }
  
  init(asset: PHAsset, page: EventCreatorSelecter) {
    self.asset = asset
    self.page = page
    super.init()
  }
  override func makeView() -> UIView {
    let view = AssetView(frame: frame)
    if page.collection != nil {
      view.buttonActions
        .onToggle { [unowned self] deselected in
          self.isSelected = !deselected
        }
        .set(toggle: !isSelected, style: .default)
    } else {
      view.cornerRadius = .margin
      view.buttonActions
        .onToggle { [unowned self] selected in
          self.isSelected = selected
        }
        .set(toggle: isSelected, style: .border)
    }
    view.set(image: asset)
    return view
  }
}

private class AssetView: UIImageView {
  var sync = false
  var dropShadow = false
  let options = PHImageRequestOptions()
  let size: CGSize
  override init(frame: CGRect) {
    size = frame.size
    super.init(frame: frame)
    options.deliveryMode = .opportunistic
    options.resizeMode = .exact
    options.isSynchronous = false
    options.isNetworkAccessAllowed = true
    options.progressHandler = { [weak self] progress, error, stop, info in
      guard let s = self else {
        stop.pointee = true
        return
      }
      s.progress(progress: progress, error: error, stop: stop, info: info)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var subs = CompletionSubscribers()
  func completion(_ execute: @escaping ()->()) {
    subs.subscribe(handler: execute)
  }
  
  @discardableResult
  func set(image: PHAsset) -> Self {
    subs.reset()
    if !sync {
      newThread {
        self._set(image: image)
      }
    } else {
      self._set(image: image)
    }
    return self
  }
  
  func progress(progress: Double, error: Error?, stop: UnsafeMutablePointer<ObjCBool>, info: [AnyHashable : Any]?) {
//    print(progress,error,info)
  }
  
  func _set(image asset: PHAsset) {
    let size = self.size
    weak var _imageView: AssetView? = self
    PHImageManager.default().requestImage(for: asset, targetSize: size * screen.retina, contentMode: .aspectFill, options: options) { (image, info) in
      imageThread {
        guard _imageView != nil else {
          print("no image view")
          return }
//        guard let data = data else {
//          print("no data for asset")
//          return }
//        guard var image = UIImage(data: data) else {
//          print("no image for asset")
//          return }
        guard var image = image else {
          print("no image for asset")
          return }
        image = UIImage.draw(size: size, retina: true) { context in
          let scale = min(image.width / size.width, image.height / size.height)
          let newSize = image.size / scale
          let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)

          context.addPath(UIBezierPath(roundedRect: CGRect(size: size), cornerRadius: .margin).cgPath)
          context.clip()

          image.draw(in: frame)
          if _imageView?.dropShadow ?? false {
            let s = CGSize(size.width,72)
            let shadow = UIImage.shadowGradient(size: s)
            shadow.draw(in: CGRect(0,size.height-s.height,s.width,s.height))
          }
        }
        mainThread {
          guard let view = _imageView else { return }
          if view.image == nil {
            view.buttonActions.set(shadow: .rounded(radius: .margin))
            self.subs.trigger()
          }
          view.image = image
        }
      }
    }
  }
}

private extension UIScrollView {
  func edit(code: ()->()) {
    let percentage = offsetPercentage
    code()
    scroll(to: percentage)
  }
  private var realContentHeight: CGFloat {
    return contentSize.height + contentInset.top + contentInset.bottom - frame.size.height
  }
  private var offsetPercentage: CGFloat {
    let o = contentOffset.y + contentInset.top
    return o / realContentHeight
  }
  private func scroll(to percentage: CGFloat) {
    contentOffset.y = realContentHeight * percentage
  }
}
