//
//  CameraControls.swift
//  Some Events
//
//  Created by Димасик on 10/25/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import AVFoundation

extension Camera {
  var flashMode: AVCaptureDevice.FlashMode {
    get {
      return cameraManager.flashMode
    } set {
      cameraManager.flashMode = newValue
      flashButton.setImage(newValue.icon, for: .normal)
    }
  }
  func nextFlashMode() {
    guard !isLocked else { return }
    if videoStatus == .recording {
      switch flashMode {
      case .off: flashMode = .on
      default: flashMode = .off
      }
    } else {
      flashMode = flashMode.next
    }
  }
  var isIdle: Bool {
    return photoStatus == .idle && videoStatus == .idle
  }
  var isLocked: Bool {
    return locks > 0
  }
  func lock() {
    locks += 1
  }
  func unlock() {
    assert(locks > 0, "camera is already unlocked")
    locks -= 1
  }
}

extension AVCaptureDevice.FlashMode {
  var next: AVCaptureDevice.FlashMode {
    switch self {
    case .off: return .on
    case .on: return .auto
    case .auto: return .off
    }
  }
  var icon: UIImage {
    switch self {
    case .off: return #imageLiteral(resourceName: "CTorchOff")
    case .on: return #imageLiteral(resourceName: "CTorchOn")
    case .auto: return #imageLiteral(resourceName: "CTorchAuto")
    }
  }
}
