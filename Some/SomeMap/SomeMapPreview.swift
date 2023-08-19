//
//  SomeMapPreview.swift
//  Events
//
//  Created by Димасик on 4/3/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import MapKit

open class SomeMapPreview: DFMapView {
  public var coordinate: CLLocationCoordinate2D?
  public let annotation = MKPointAnnotation()
  
  public init() {
    super.init(frame: .zero)
    setup()
  }
  public init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init(frame: .zero)
    setup()
  }
  private func setup() {
    showsUserLocation = false
    layer.cornerRadius = 12
    
    if let coordinate = coordinate {
      set(coordinate: coordinate, animated: false)
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func disableUserInteractions() {
    isZoomEnabled = false
    isScrollEnabled = false
    isRotateEnabled = false
    isPitchEnabled = false
  }
  public func enableUserInteractions() {
    isZoomEnabled = true
    isScrollEnabled = true
    isRotateEnabled = true
    isPitchEnabled = true
  }
  
  public func set(coordinate: CLLocationCoordinate2D, animated: Bool) {
//    let shouldAddAnnotation = self.coordinate == nil
    self.coordinate = coordinate
    
    let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
    let region = MKCoordinateRegion(center: coordinate, span: span)
    setRegion(region, animated: animated)
    annotation.coordinate = coordinate
    addAnnotation(annotation)
  }
}
