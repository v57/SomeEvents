//
//  CoordinateMessage.swift
//  Events
//
//  Created by Димасик on 4/7/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeData
import SomeBridge
import CoreLocation

class CoordinateMessage: MessageBodyType {
  var type: MessageType { return .coordinate }
  var string: String { return "(\(latitude),\(longitude))" }
  var latitude: Float
  var longitude: Float
  
  init(latitude: Float, longitude: Float) {
    self.latitude = latitude
    self.longitude = longitude
  }
  required init(data: DataReader) throws {
    latitude = try data.next()
    longitude = try data.next()
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(latitude)
    data.append(longitude)
  }
  
  func delete() {
    
  }
  func write(to string: NSMutableAttributedString, message: Message) {
    let location = CLLocationCoordinate2D(lat: latitude, lon: longitude)
    let attachment = CoordinateAttachment(coordinate: location)
    string.append(attachment)
  }
}
