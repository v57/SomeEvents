//
//  TempExtensions.swift
//  Events
//
//  Created by Димасик on 6/1/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

public extension UIDevice {
  static var isCameraAvailable: Bool {
    return isFrontCameraAvailable || isBackCameraAvailable
  }
  static var isFrontCameraAvailable: Bool {
    return UIImagePickerController.isCameraDeviceAvailable(.front)
  }
  static var isBackCameraAvailable: Bool {
    return UIImagePickerController.isCameraDeviceAvailable(.rear)
  }
}
