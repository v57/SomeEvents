//
//  CameraView.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

#if debug
class EmptyPage: Page {
  override init() {
    super.init()
    showsStatusBar = false
    showsBackButton = false
    addTap(self, #selector(tap))
  }
  
  @objc func tap() {
    cameraView.tap()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

let cameraView = CameraView()
class CameraView: UIView {
  let cameraManager = CameraManager()
  let view = UIView(frame: screen.frame)
  let blur = UIVisualEffectView(frame: screen.frame)
  var effect = UIBlurEffectStyle.light
  init() {
    blur.effect = UIBlurEffect(style: .light)
    super.init(frame: screen.frame)
    backgroundColor = .black
    cameraManager.flashMode = .off
    cameraManager.shouldRespondToOrientationChanges = true
    cameraManager.shouldKeepViewAtOrientationChanges = false
    cameraManager.writeFilesToPhoneLibrary = settings.saveContentToLibrary
    cameraManager.addPreviewLayerToView(view)
    addSubview(view)
    addSubview(blur)
    
  }
  
  @objc func tap() {
    switch effect {
    case .light:
      effect = .extraLight
    case .extraLight:
      effect = .dark
    case .dark:
      effect = .light
    default: break
    }
    blur.effect = UIBlurEffect(style: effect)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func resolutionChanged() {
    frame = screen.frame
    view.frame = screen.frame
    blur.frame = screen.frame
    cameraManager.previewLayer?.frame = view.bounds
    super.resolutionChanged()
  }
}
#endif
