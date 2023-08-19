//
//  map-coordinate.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import MapKit


class MapViewController: UIViewController {
  weak var map: MKMapView!
  weak var pin: MKPinAnnotationView?
  let annotation = MKPointAnnotation()
  let manager = CLLocationManager()
  
  var completion: ((CLLocationCoordinate2D)->())?
  var startCoordinate: CLLocationCoordinate2D?
  
  class func show(in viewController: UIViewController? = main, startCoordinate: CLLocationCoordinate2D?, completion: @escaping (CLLocationCoordinate2D)->()) {
    guard let viewController = viewController else { return }
    let vc = MapViewController()
    vc.startCoordinate = startCoordinate
    vc.completion = completion
    let nc = UINavigationController(rootViewController: vc)
    nc.isToolbarHidden = false
    viewController.present(nc, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    let rightItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(send))
    navigationItem.setLeftBarButton(leftItem, animated: false)
    navigationItem.setRightBarButton(rightItem, animated: false)
    
    let map = MKMapView(frame: screen.frame)
    map.showsUserLocation = true
    //    map.userTrackingMode = .follow
    map.delegate = self
    view.addSubview(map)
    
    annotation.coordinate = map.centerCoordinate
    map.addAnnotation(annotation)
    
    self.map = map
    
    let locate = MKUserTrackingBarButtonItem(mapView: map)
    setToolbarItems([locate], animated: false)
    
    dot.backgroundColor = .black
    dot.circle()
    view.addSubview(dot)
  }
  
  let dot = UIView(frame: CGRect(0,0,2,2))
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if CLLocationManager.authorizationStatus() == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
    dot.center = map.convert(map.centerCoordinate, toPointTo: map) + Pos(-0.5,1)
    if let coordinate = startCoordinate {
      map.centerCoordinate = coordinate
    } else {
      map.userTrackingMode = .follow
    }
  }
  
  @objc func cancel() {
    dismiss(animated: true, completion: nil)
  }
  @objc func send() {
    completion?(map!.centerCoordinate)
    dismiss(animated: true, completion: nil)
  }
}


extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    annotation.coordinate = mapView.centerCoordinate
    pin?.animatesDrop = true
    pin?.setDragState(.starting, animated: false)
    pin?.setDragState(.ending, animated: true)
  }
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard !(annotation is MKUserLocation) else { return nil }
    var pin = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
    if let pin = pin {
      pin.annotation = annotation
    } else {
      pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
    }
    pin!.animatesDrop = true
    self.pin = pin
    return pin
  }
}
