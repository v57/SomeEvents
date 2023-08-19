//
//  CameraPhoto.swift
//  Some Events
//
//  Created by Димасик on 10/25/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

extension Camera {
  func takePhoto() {
    guard !isLocked else { return }
    guard isIdle else { return }
    photoButton.capturing = true
    openCamera {
      self.startCapturing()
    }
  }
}

private extension Camera {
  func startCapturing() {
    photoStatus = .capturing
//    photoCaptured(image: nil, error: nil)
    cameraManager.capturePictureWithCompletion(photoCaptured(image:error:))
  }
  func photoCaptured(image: UIImage?, error: NSError?) {
    photoStatus = .idle
    photoButton.capturing = false
    self.view.scale(0.9)
    jellyAnimation2 {
      self.view.scale(1.0)
    }
    closeCameraIfNeeded()
    guard let image = image else { return }
    
    photoCaptured(image)
    image.save(to: "Events")
  }
  func showPreview(image: UIImage) {
    let view = UIImageView(frame: screen.frame)
    view.clipsToBounds = true
    view.layer.cornerRadius = 16
    view.contentMode = .scaleAspectFill
    view.image = image
    view.backgroundColor = .black
    view.scale(0.4)
    jellyAnimation {
      view.scale(0.8)
    }
    view.center = screen.center
    addSubview(view)
    wait(3) {
      view.removeFromSuperview()
    }
  }
}
