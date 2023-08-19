//
//  GPS.swift
//  faggot
//
//  Created by Димасик on 19/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import CoreLocation

private var managers = Set<GPS>()

extension CLAuthorizationStatus {
  var isAuthorized: Bool {
    switch self {
    case .authorizedAlways, .authorizedWhenInUse: return true
    default: return false
    }
  }
  var isRestricted: Bool {
    switch self {
    case .denied, .restricted: return true
    default: return false
    }
  }
  var isChecked: Bool {
    switch self {
    case .notDetermined: return false
    default: return true
    }
  }
}

extension CLLocationCoordinate2D {
  init(lat: Float, lon: Float) {
    self.init(latitude: Double(lat), longitude: Double(lon))
  }
  init?(event: Event){
    if event.isOnMap {
      self.init(lat: event.lat, lon: event.lon)
    } else {
      return nil
    }
  }
  static var zero: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: 0, longitude: 0)
  }
  var lat: Float { return Float(latitude) }
  var lon: Float { return Float(longitude) }
}
extension Event {
  func move(to coordinate: CLLocationCoordinate2D) {
    self.move(lat: coordinate.lat, lon: coordinate.lon)
  }
}

extension CLLocation {
  var lat: Float { return Float(coordinate.latitude) }
  var lon: Float { return Float(coordinate.longitude) }
}

class GPS: NSObject, CLLocationManagerDelegate {
  var handler: (_ location: CLLocation)->()
  var fail: ((Error?)->())?
  let manager = CLLocationManager()
  static var status: CLAuthorizationStatus { return CLLocationManager.authorizationStatus() }
  init(handler: @escaping (_ location: CLLocation)->()) {
    self.handler = handler
    super.init()
    manager.delegate = self
  }
  func requestLocation() {
    manager.requestWhenInUseAuthorization()
  }
  class func requestLocation(_ handler: @escaping (_ location: CLLocation)->(), fail: ((Error?)->())? = nil) {
    let gps = GPS(handler: handler)
    gps.fail = fail
    gps.requestLocation()
    managers.insert(gps)
    CLLocationManager.authorizationStatus()
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    handler(locations.last!)
    managers.remove(self)
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("gps error: \(error.localizedDescription)")
    fail?(error)
  }
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      manager.requestLocation()
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .denied:
      fail?(nil)
    case .restricted:
      fail?(nil)
    }
  }
}
