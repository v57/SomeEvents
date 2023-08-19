//
//  CameraCloser.swift
//  Some Events
//
//  Created by Димасик on 10/25/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

extension Camera {
  func switchShowsCamera() {
    guard isIdle && !isLocked else { return }
    switch cameraStatus {
    case .closed:
      openCamera()
      closedView.destroy(options: .scale(0.9), animated: true)
    case .opened:
      closeCamera()
      insertSubview(closedView, at: 0)
    default: break
    }
  }
  func openCamera(completion: @escaping ()->()) {
    if cameraStatus == .opened {
      completion()
    } else {
      openCamera()
      lock()
      wait(1) {
        self.cameraStatus = .shouldBeClosed
        self.unlock()
        completion()
      }
    }
  }
  func closeCameraIfNeeded() {
    guard cameraStatus == .shouldBeClosed else { return }
    closeCamera()
  }
}

private extension Camera {
  func openCamera() {
    showsButton.setImage(#imageLiteral(resourceName: "CBatteryOn"), for: .normal)
    jellyAnimation2 {
      for _ in 0..<2 {
        let rotation = CGAffineTransform(rotationAngle: .pi)
        self.showsButton.transform = self.showsButton.transform.concatenating(rotation)
      }
    }
    lock()
    cameraStatus = .opening
    cameraManager.resumeCaptureSession {
      self.unlock()
      self.cameraStatus = .opened
    }
    animate {
      self.view.alpha = 1.0
    }
  }
  func closeCamera() {
    showsButton.setImage(#imageLiteral(resourceName: "COpen"), for: .normal)
    jellyAnimation2 {
      for _ in 0..<2 {
        let rotation = CGAffineTransform(rotationAngle: .pi)
        self.showsButton.transform = self.showsButton.transform.concatenating(rotation)
      }
    }
    cameraStatus = .closed
    cameraManager.stopCaptureSession()
    animate {
      self.view.alpha = 0.0
    }
  }
}


class ClosedCameraView: UIView {
  let titleLabel: UILabel
  let descriptionLabel: UILabel
  let openButton: UIButton
  var onOpenCamera: (()->())?
  init() {
    let tfont = UIFont.normal(32)
    let title = "Camera closed"
    
    titleLabel = UILabel(frame: CGRect(0,0,title.width(tfont),tfont.lineHeight))
    titleLabel.text = title
    titleLabel.font = tfont
    titleLabel.textColor = .white
    titleLabel.isOpaque = true
    titleLabel.autoresizeFont()
    
    let description = """
This mode saves your battery.

Photo and video buttons will open camera, make photo or video and then close it back.
"""
    
    descriptionLabel = UILabel()
    descriptionLabel.numberOfLines = 0
    descriptionLabel.text = description
    descriptionLabel.font = .normal(14)
    descriptionLabel.isOpaque = true
    descriptionLabel.textColor = .white
    
    openButton = UIButton(frame: CGRect(0,0,200,50))
    openButton.clipsToBounds = true
    openButton.layer.cornerRadius = 18
    openButton.backgroundColor = .gray
    openButton.setTitle("Open camera", for: .normal)
    openButton.setTitleColor(.white, for: .normal)
    openButton.systemHighlighting()
    
    super.init(frame: screen.frame)
    
    openButton.add(target: self, action: #selector(open))
    updateFrames()
    
    isOpaque = true
    
    addSubview(titleLabel)
    addSubview(descriptionLabel)
    addSubview(openButton)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func open() {
    onOpenCamera?()
  }
  
  override func resolutionChanged() {
    frame = screen.frame
    updateFrames()
  }
  
  func updateFrames() {
    let x: CGFloat = screen.left + .margin
    let width: CGFloat = screen.right - screen.left - .margin2
    titleLabel.frame = CGRect(x, 20 + .margin, width, titleLabel.frame.height)
    let dheight = descriptionLabel.text!.height(.normal(14), width: width)
    descriptionLabel.frame = CGRect(origin: titleLabel.frame.bottomLeft, size: Size(width,dheight))
    openButton.move(descriptionLabel.frame.bottom + Pos(0,20), .top)
  }
}
