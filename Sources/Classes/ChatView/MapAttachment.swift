//
//  MapAttachment.swift
//  Events
//
//  Created by Димасик on 4/3/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeMap



class RawCoordinateAttachment: AttachmentView {
  override func createView(for textView: UITextView) -> UIView {
    let view = SomeMapPreview(coordinate: coordinate)
    view.disableUserInteractions()
    view.frame = CGRect(size: size)
    view.setBorder(.black, screen.pixel)
    return view
  }
  var coordinate: CLLocationCoordinate2D
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init(placeholderText: "(\(coordinate.latitude),\(coordinate.longitude))")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class CoordinateAttachment: AttachmentView {
  override var size: CGSize {
    return Size(Cell.maxTextWidth - 20)
  }
  override func createView(for textView: UITextView) -> UIView {
    let view = SomeMapPreview(coordinate: coordinate)
    view.disableUserInteractions()
    view.frame = CGRect(size: size)
    view.setBorder(.black, screen.pixel)
    return view
  }
  var coordinate: CLLocationCoordinate2D
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    super.init(placeholderText: "(\(coordinate.latitude),\(coordinate.longitude))")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
