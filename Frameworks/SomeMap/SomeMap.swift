//
//  SomeMap.swift
//  SomeMap
//
//  Created by Дмитрий Козлов on 4/1/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

@_exported import Some
@_exported import MapKit
import Some
import MapKit

public class DFMapView: MKMapView, DynamicFrame {
  public var dynamicFrame: DFrame?
}

extension CGFloat: DataRepresentable {
  public init(data: DataReader) throws {
    self = CGFloat(try data.double())
  }
  public func save(data: DataWriter) {
    data.append(Double(self))
  }
}

extension CLLocationCoordinate2D: DataRepresentable {
  public init(data: DataReader) throws {
    try self.init(latitude: data.next(), longitude: data.next())
  }
  public func save(data: DataWriter) {
    data.append(latitude)
    data.append(longitude)
  }
}

extension MKMapCamera: DataLoadable {
  public func load(data: DataReader) throws {
    centerCoordinate = try data.next()
    heading = try data.next()
    pitch = try data.next()
    altitude = try data.next()
  }
  public func save(data: DataWriter) {
    data.append(centerCoordinate)
    data.append(heading)
    data.append(pitch)
    data.append(altitude)
  }
  var isZero: Bool {
    return centerCoordinate.latitude == 0 && centerCoordinate.longitude == 0
  }
}

public class SomeMapManager: Manager, Saveable {
  public static let `default` = SomeMapManager()
  public var camera = MKMapCamera()
  
  public func save(data: DataWriter) throws {
    data.append(camera)
  }
  public func load(data: DataReader) throws {
    try data.load(camera)
  }
}

public class MapView: MKMapView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
    if !SomeMapManager.default.camera.isZero {
      setCamera(SomeMapManager.default.camera, animated: false)
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  deinit {
    SomeMapManager.default.camera = camera
  }
}

public class MapPreview: MKMapView {
  public init(frame: CGRect, location: CLLocationCoordinate2D) {
    super.init(frame: frame)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
