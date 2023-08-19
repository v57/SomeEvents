//
//  Map.swift
//  faggot
//
//  Created by Димасик on 30/01/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import SomeMap
import SomeBridge

private let mapEventIcon = UIImage(named: "MapEvent")!
private let mapMyEventIcon = UIImage(named: "MapMyEvent")
private let mapEventIconSize = mapEventIcon.size

class EventMarker: NSObject, MKAnnotation {
  override var hash: Int { return event.id.hashValue }
  let event: Event
  var coordinate: CLLocationCoordinate2D
  var title: String?
  init(event: Event) {
    self.event = event
    self.coordinate = CLLocationCoordinate2D(latitude: Double(event.lat), longitude: Double(event.lon))
    title = ""
  }
}

class Map: Page, MKMapViewDelegate {
  let map = MapView(frame: screen.frame)
  
  var markers = Set<EventMarker>()
  
  weak var loader: DownloadingView?
  var startCoordinate: CLLocationCoordinate2D?
  
  override func resolutionChanged() {
    super.resolutionChanged()
    loader?.center = screen.center
    map.frame = screen.frame
  }
  
  var showsPublic: Bool
  init(showsMy: Bool, showsPublic: Bool) {
    self.showsPublic = showsPublic
    
    super.init()
    
    let loader = DownloadingView(center: screen.center)
    loader.animating = true
    addSubview(loader)
    
    self.loader = loader
    
//    blur.addTap(self, #selector(hideEventView))
    
    
    statusBarWhite = false
    theme = Theme.light
    
    addSubview(map)
    
    
    map.showsBuildings = true
    map.showsUserLocation = true
    map.alpha = 0.0
    if #available(iOS 9.0, *) {
      map.showsCompass = true
    }
    if let coordinate = startCoordinate {
      map.centerCoordinate = coordinate
    } else {
//      map.userTrackingMode = .follow
    }
    map.delegate = self
    if showsMy {
      set(events: .my)
    }
    if showsPublic {
      updateMarkers()
      mapManager.open()
    }
  }
  
  override func closed() {
    if showsPublic {
      mapManager.close()
    }
  }
  
  func updateMarkers() {
    
  }
  
  var showsMap = false {
    didSet {
      if showsMap != oldValue {
        animate {
          if showsMap {
            map.alpha = 1
          } else {
            map.alpha = 0
          }
        }
      }
    }
  }
  
  func removeEvent(_ event: Event) {
    for annotation in map.annotations where annotation is EventMarker {
      let marker = annotation as! EventMarker
      if marker.event == event {
        map.removeAnnotation(marker)
        break
      }
    }
  }
  
  func removeEvent(_ id: Int64) {
    for annotation in map.annotations where annotation is EventMarker {
      let marker = annotation as! EventMarker
      if marker.event.id == id {
        map.removeAnnotation(marker)
        break
      }
    }
  }
  
  func set(events: [Event]) {
    for event in events {
      guard event._canLoadContent else { return }
      insert(event: event)
    }
//    events.updateCoordinates()
//      .autorepeat(self)
//      .success { [weak self] in
//        guard self != nil else { return }
//        for event in events {
//          self!.insert(event: event)
//        }
//    }
  }
  
  func insert(event: Event) {
    guard !(event.lat == 0 && event.lon == 0) else { return }
    let marker = EventMarker(event: event)
    insert(marker: marker)
  }
  
  func insert(marker: EventMarker) {
    guard !markers.contains(marker) else { return }
    markers.insert(marker)
    map.addAnnotation(marker)
  }
  
  func remove(marker: EventMarker) {
    guard markers.contains(marker) else { return }
    markers.remove(marker)
    map.removeAnnotation(marker)
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is EventMarker {
      let event = (annotation as! EventMarker).event
      let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "EventMarker")
      view.image = event.isMy() ? mapMyEventIcon : mapEventIcon
      
      let label = Label(frame: CGRect(mapEventIconSize.width / 2,mapEventIconSize.height + 10,0,0), text: event.name, font: .normal(12), color: .dark, alignment: .center, fixHeight: true)
      view.addSubview(label)
      return view
    } else {
      return nil
    }
  }
  
  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    for view in views {
      view.bounce()
    }
  }
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let eventMarker = view.annotation as? EventMarker {
      mapView.deselectAnnotation(view.annotation, animated: false)
      let page = EventPage(event: eventMarker.event)
      main.push(page)
    }
  }
  
  func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
    showsMap = true
    loader?.animating = false
    loader?.removeFromSuperview()
  }
  
  func newEvent(_ event: Event) {
    let marker = EventMarker(event: event)
    map.addAnnotation(marker)
  }
  
//  func showEvent(_ event: Event) {
//    selectedEvent = event
//    showsEvent = true
//  }
  
//  var selectedEvent: Event!
//  var selectedEventView: MapEventView!
//  var showsEvent = false {
//    didSet {
//      if showsEvent != oldValue {
//        if showsEvent {
//          guard selectedEvent != nil else { return }
//          showsBlur = true
//          selectedEventView = MapEventView(event: selectedEvent)
//          selectedEventView.addTap(self,#selector(hideEventView))
//          display(selectedEventView)
//        } else {
//          showsBlur = false
//          selectedEventView = selectedEventView?.destroy()
//          selectedEvent = nil
//        }
//      }
//    }
//  }
  
//  @objc func hideEventView() {
//    showsEvent = false
//  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension Map: MapNotifications {
  func map(set events: [Event]) {
    assert(Thread.current.isMainThread)
    for event in events {
      insert(event: event)
    }
  }
  
  func map(insert event: Event) {
    insert(event: event)
  }
  
  func map(remove event: ID) {
    removeEvent(event)
  }
}

extension Map: EventMainNotifications {
  func created(event: Event) {
    
  }
  func created(content: Content, in event: Event) {
    
  }
  func uploaded(preview: Content, in event: Event) {
    
  }
  func uploaded(content: Content, in event: Event) {
    
  }
  func updated(id event: Event, oldValue: ID) {
    
  }
  func updated(name event: Event) {
    
  }
  func updated(startTime event: Event) {
    
  }
  func updated(endTime event: Event) {
    
  }
  func updated(coordinates event: Event) {
    for marker in self.markers {
      if marker.event == event {
        marker.coordinate = CLLocationCoordinate2D(latitude: Double(event.lat), longitude: Double(event.lon))
        break
      }
    }
  }
  func updated(preview event: Event) {
    
  }
  func updated(contentAvailable event: Event) {
    
  }
}

