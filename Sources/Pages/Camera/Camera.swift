//
//  Camera.swift
//  Some Events
//
//  Created by Димасик on 8/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import AVFoundation
import AVKit
import Some

enum VideoStatus {
  case idle, starting, recording, ending
}
enum PhotoStatus {
  case idle, capturing
}
enum CameraStatus {
  case opened, closed, opening, shouldBeClosed
}

class Camera: Page {
  var photoCaptured: (_ image: UIImage)->() = {_ in}
  var videoCaptured: (_ url: FileURL)->() = {_ in}
  
  let view = UIView()
  
  lazy var timer: TimerView = { [unowned self] in
    let timer = TimerView()
    self.addSubview(timer)
    return timer
  }()
  lazy var closedView: ClosedCameraView = { [unowned self] in
    let view = ClosedCameraView()
    view.onOpenCamera = { [unowned self] in
      self.switchShowsCamera()
    }
    return view
  }()
  let videoButton: CaptureButton
  let photoButton: CaptureButton
  let flashButton: Button
  let flipButton: Button
  let doneButton: Button
  let showsButton: Button
  
  let remote: CameraButtons
  
  let cameraManager = CameraManager()
  
  var orientation: UIInterfaceOrientation = .current
  
  var videoStatus: VideoStatus = .idle
  var photoStatus: PhotoStatus = .idle
  var cameraStatus: CameraStatus = .opened
  var locks = 0
  override var areSwipesEnabled: Bool {
    return videoStatus == .idle && photoStatus == .idle
  }
  
  override init() {
    let defaultFlash: AVCaptureDevice.FlashMode = .off
    
    photoButton = CaptureButton(type: .photo)
    videoButton = CaptureButton(type: .video)
    flashButton = Button(image: defaultFlash.icon)
    flipButton = Button(image: #imageLiteral(resourceName: "CFlip"))
    doneButton = Button(image: #imageLiteral(resourceName: "CClose"))
    showsButton = Button(image: #imageLiteral(resourceName: "CBatteryOn"))
    var buttons = [[UIView]]()
    buttons.append([doneButton, photoButton])
    buttons.append([showsButton, flashButton])
    buttons.append([flipButton, videoButton])
    
    remote = CameraButtons(buttons: buttons)
    
    super.init()
    
    backgroundColor = .black
    
    view.frame = screen.frame
    view.clipsToBounds = true
    view.isOpaque = true
    remote.dpos = { Pos(screen.width-12,screen.bottom-12).bottomRight }
    
    showsBackButton = false
    showsStatusBar = false
    
    swipable(direction: .any)
    
    addSubview(view)
    addSubview(remote)
    cameraManager.flashMode = defaultFlash
    cameraManager.shouldRespondToOrientationChanges = true
    cameraManager.shouldKeepViewAtOrientationChanges = false
    cameraManager.writeFilesToPhoneLibrary = settings.saveContentToLibrary
    cameraManager.addPreviewLayerToView(view)
    cameraManager.recordingStarted = { [unowned self] in
      self.recordingStarted()
    }
    photoButton.touch { [unowned self] in
      self.takePhoto()
    }
    videoButton.touch { [unowned self] in
      self.videoRecording()
    }
    doneButton.touch { [unowned self] in
      self.done()
    }
    showsButton.touch { [unowned self] in
      self.switchShowsCamera()
    }
    flipButton.touch { [unowned self] in
      self.cameraManager.cameraDevice = self.cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    flashButton.touch { [unowned self] in
      self.nextFlashMode()
    }
  }
  
  func done() {
    main.back()
  }
  
  override func resolutionChanged() {
    view.frame = screen.frame
    cameraManager.previewLayer?.frame = view.bounds
    super.resolutionChanged()
  }
  
  func orientationChanged(deviceOrientation: UIDeviceOrientation) {
    if cameraStatus == .opened || cameraStatus == .shouldBeClosed {
      orientation = screen.orientation
    }
  }
  
  override var animateScreenTransitions: Bool {
    return cameraStatus == .closed
  }
  
  override func orientationChanged() {
    orientationChanged(deviceOrientation: UIDevice.current.orientation)
  }
  
  override func willShow() {
    screen.orientations = .all
    //    screen.orientations = .portrait
    //    screen.orientation = .portrait
    main.navigation.leftButton.shows = false
  }
  
  override func willHide() {
    screen.orientations = .allButUpsideDown
    //    screen.orientations = .all
    main.navigation.leftButton.shows = true
  }
  
  override func closed() {
    cameraManager.stopCaptureSession()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIDeviceOrientation {
  var angle: CGFloat {
    let orientation: CGFloat
    switch self {
    case .landscapeLeft:
      orientation = 0.5
    case .landscapeRight:
      orientation = 1.5
    case .portraitUpsideDown:
      orientation = 1
    default:
      orientation = 0
    }
    return π * orientation
  }
}

