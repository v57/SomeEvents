//
//  CreateEvent.swift
//  faggot
//
//  Created by Димасик on 23/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeMap

private class Dots {
  let l = DCView(size: Size(10,10))
  let r = DCView(size: Size(10,10))
  var v = 0
  unowned let textField: UITextField
  init(textField: UITextField) {
    self.textField = textField
    textField.addSubview(l)
    textField.addSubview(r)
    
    l.circle()
    r.circle()
    l.backgroundColor = .black
    r.backgroundColor = .black
    l.alpha = 0
    r.alpha = 0
    
    update(text: "", animated: false)
  }
  
  func update(text: String, animated: Bool = true) {
    var moveAnimated = false//animated
    let font = textField.font!
    var text = text
    
    if text.isEmpty {
      text = textField.placeholder!
      moveAnimated = false
    }
    
    let width = text.width(font)
    let center = textField.bounds.size.center
    
    animateif(moveAnimated) {
      l.center = center - Pos(width/2+20,0)
      r.center = center + Pos(width/2+20,0)
    }
    guard animated else { return }
    l.shetBounce()
    r.shetBounce()
    l.alpha = 1
    r.alpha = 1
    self.v += 1
    let v = self.v
    wait(0.5) {
      guard v == self.v else { return }
      animate {
        self.l.alpha = 0
        self.r.alpha = 0
      }
    }
  }
}

class CreateEventView: Page, UITextFieldDelegate {
  override var isFullscreen: Bool { return false }
  //    var eventName = ""
  var eventType = EventType.common
  
  var name: String {
    return input.string
  }
  var coordinate: CLLocationCoordinate2D?
  var time: Time
  
  let input: DFTextField
  private let dots: Dots
  let backButton = DCButton(image: #imageLiteral(resourceName: "BackDark"))
  let backLabel = DCLabel(text: "Cancel", color: .dark, font: .ultraLight(16))
  lazy var doneButton: DCButton = { [unowned self] in
    let button = DCButton(image: #imageLiteral(resourceName: "NextDark"))
    button.dcenter = { Pos(screen.width-50,screen.height-keyboardHeight-55) }
    button.add(target: self, action: #selector(done))
    button.systemHighlighting()
    return button
  }()
  lazy var doneLabel: DCLabel = { [unowned self] in
    let label = DCLabel(text: "Create", color: .dark, font: .ultraLight(16))
    label.dcenter = { Pos(screen.width-50,screen.height-keyboardHeight-24) }
    return label
  }()
  
  let laterButton: FButton
  let nowButton: FButton
  let whenLabel: DCLabel
  
  let placeButton: FButton
  let timeButton: FButton
  
  let exportAlbum: DPButton
  
  lazy var mapView: SomeMapPreview = { [unowned self] in
    let mapView = SomeMapPreview()
    mapView.dframe = { [unowned self] in
      var top = self.placeButton.frame.bottom + Pos(0,12)
      top.x = screen.center.x
      let dist = self.doneButton.frame.left.x - self.backButton.frame.right.x
      let bottom = self.backButton.frame.top - Pos(0,12)
      var size = bottom.y - top.y
      let altSize = screen.height - 12 - top.y
      if altSize < dist {
        size = altSize
      }
      size = min(screen.width - 24, size)
      return CGRect(top, .top, Size(size,size))
    }
    self.addSubview(mapView)
    return mapView
  }()
  
  let df = DateFormatter()
  
  override init() {
    df.doesRelativeDateFormatting = true
    df.timeStyle = .none
    df.dateStyle = .medium
    
    input = DFTextField()
    input.dframe = {
//      if screen.width < 360 {
//        return CGRect(10,90,screen.width - 20,50)
//      } else {
//        return CGRect(50,90,screen.width - 100,50)
//      }
      return CGRect(10,90,screen.width - 20,50)
    }
      
    input.returnKeyType = .done
    input.text = ""
    input.font = .ultraLight(48)
    input.textColor = .dark
    input.tintColor = .clear
    input.textAlignment = .center
    input.attributedPlaceholder = NSAttributedString(string: "Event name", attributes: [.foregroundColor: UIColor.dark])
    
    dots = Dots(textField: input)
    
    exportAlbum = DPButton(text: "Export album", font: .normal(17), color: .white)
    exportAlbum.backgroundColor = .system
    exportAlbum.layer.cornerRadius = 4
    exportAlbum.frame.size.height = 35
    exportAlbum.dpos = { Pos(screen.center.x,screen.height-keyboardHeight - 55).center }
    
    laterButton = FButton(text: "Later", icon: #imageLiteral(resourceName: "NELater"))
    laterButton.dcenter = { Pos(screen.center.x-87,236) }
    laterButton.alpha = 0.0
    
    nowButton = FButton(text: "Now", icon: #imageLiteral(resourceName: "NENow"))
    nowButton.dcenter = { Pos(screen.center.x+87,236) }
    nowButton.alpha = 0.0
    
    whenLabel = DCLabel(text: "When?", color: .dark, font: .ultraLight(22))
    whenLabel.dcenter = { Pos(screen.center.x,216) }
    whenLabel.alpha = 0.0
    
    placeButton = FButton(text: "Where?", icon: #imageLiteral(resourceName: "NELocation"))
    placeButton.dcenter = { Pos(screen.center.x-87,236) }
    placeButton.alpha = 0.0
    
    timeButton = FButton(text: "Tomorrow\n12:00", icon: #imageLiteral(resourceName: "NEWhen"))
    timeButton.dcenter = { Pos(screen.center.x+87,236) }
    timeButton.alpha = 0.0
    
    backButton.systemHighlighting()
    
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year,.month,.day,.hour], from: Date())
    components.hour = 0
    time = Time(calendar.date(from: components)!.timeIntervalSince1970) + 129600
    
    super.init()
    
    background = .blur(.light)
    transition = .fade
    
    input.delegate = self
    addSubview(input)
    addSubview(exportAlbum)
    
    frame = screen.frame
    addTap(self, #selector(CreateEventView.tap))
    
    backButton.dcenter = { Pos(50,screen.height-keyboardHeight - 55) }
    backButton.add(target: self, action: #selector(back))
    backLabel.dcenter = { Pos(50,screen.height-keyboardHeight - 24) }
    
    nowButton.touch { [unowned self] in
      if GPS.status.isRestricted {
        MapViewController.show(startCoordinate: self.coordinate) { location in
          self.now(at: location)
        }
      } else {
        let event = self.now(at: .zero)
        GPS.requestLocation({ location in
          event.move(lat: location.lat, lon: location.lon)
        }, fail: { error in
          MapViewController.show(startCoordinate: self.coordinate) { location in
            event.move(lat: location.lat, lon: location.lon)
          }
        })
      }
    }
    laterButton.touch { [unowned self] in self.later() }
    placeButton.touch { [unowned self] in self.setPlace() }
    timeButton.touch { [unowned self] in self.setTime() }
    exportAlbum.onTouch { [unowned self] in self.export() }
    
    addSubviews(laterButton,nowButton,whenLabel,placeButton,timeButton)
    
    addSubview(backLabel)
    addSubview(backButton)
    
    showsBackButton = false
    
    //        for view in [laterButton,laterLabel,nowButton,nowLabel,whenLabel,placeButton,placeLabel,timeButton,timeLabel] {
    //            view.shows = true
    //        }
  }
  
  override func keyboardMoved() {
    exportAlbum.updateFrame()
    backLabel.updateFrame()
    backButton.updateFrame()
  }
  
  override func didShow() {
    input.becomeFirstResponder()
  }
  
  var showsType = false {
    didSet {
      let views: [UIView] = [laterButton,nowButton,whenLabel]
      animate {
        exportAlbum.alpha = showsType ? 0.0 : 1.0
        for view in views {
          view.alpha = showsType ? 1.0 : 0.0
        }
      }
    }
  }
  
  @discardableResult
  func now(at coordinate: CLLocationCoordinate2D) -> Event {
    let lat = Float(coordinate.latitude)
    let lon = Float(coordinate.longitude)
    let event = eventManager.create(self.input.text!, lat: lat, lon: lon, time: .now)
    
//    main.swipeBlurs()
    main.back()
    let page = EventPage(event: event)
    main.push(page)
//    main.replace(last: 1, with: page)
//    main.push(page, animation: PushAnimation.fade)
//    main.close(self)
    return event
  }
  func later() {
    let views: [UIView] = [laterButton,nowButton,whenLabel]
    let views2: [UIView] = [placeButton,timeButton]
    animate {
      for view in views {
        view.alpha = 0.0
      }
      for view in views2 {
        view.alpha = 1.0
      }
    }
  }
  func setPlace() {
    MapViewController.show(startCoordinate: coordinate) { coordinate in
      self.set(coordinate: coordinate)
    }
    
//    let placePicker = PlacePicker()
//    placePicker.handler = { [unowned self] lat, lon in
//      self.lat = lat
//      self.lon = lon
//      self.placeButton.text = "Somewhere"
//
//      self.display(self.doneButton)
//      self.display(self.doneLabel)
//    }
//    main.push(placePicker)
  }
  
  func set(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    placeButton.text = "Somewhere"
    
    display(doneButton)
    display(doneLabel)
    
    mapView.set(coordinate: coordinate, animated: false)
  }
  func set(date: Date) {
    time = date.time
    var string = df.string(from: date)
    string.addLine(time.timeFormat)
    timeButton.text = string
  }
  
  func setTime() {
    let picker = DatePicker()
    picker.view.minimumDate = Date()
    picker.view.setDate(time.date, animated: false)
    picker.completion = { [unowned self] date in
      self.set(date: date)
    }
    main.push(picker)
  }
  @objc func done() {
    guard name.count > 0 && time > Time.now else { return }
    let lat = coordinate?.lat ?? 0
    let lon = coordinate?.lon ?? 0
    let event = eventManager.create(name, lat: lat, lon: lon, time: time)
    
    main.back()
    let page = EventPage(event: event)
    main.push(page)
  }
  func export() {
    main.back()
    let page = AlbumPage()
    main.push(page)
  }
  @objc func back() {
    main.back()
  }
  
  @objc func tap() {
    input.resignFirstResponder()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let oldText = textField.text!
    let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    
    if oldText.isEmpty && !newText.isEmpty {
      showsType = true
    } else if newText.isEmpty && !oldText.isEmpty {
      showsType = false
    }
    dots.update(text: newText)
    return true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
