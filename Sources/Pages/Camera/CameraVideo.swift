//
//  CameraVideo.swift
//  Some Events
//
//  Created by Димасик on 10/25/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

extension Camera {
  func videoRecording() {
    guard !isLocked else { return }
    if videoStatus == .recording {
      stopRecording()
    } else if videoStatus == .idle {
      videoButton.capturing = true
      jellyAnimation2 {
        self.remote.lift(-1,-1)
      }
      if flashMode == .auto {
        flashMode = .off
      }
      cameraManager.cameraOutputMode = CameraOutputMode.videoWithMic
      openCamera {
        self.startRecording()
      }
    }
  }
  func recordingStarted() {
    timer.start()
    videoStatus = .recording
    
    self.hideTimer()
    jellyAnimation2 {
      self.showTimer()
    }
  }
}

private extension Camera {
  func startRecording() {
    videoStatus = .starting
    
//    self.recordingStarted()
    cameraManager.startRecordingVideo()
  }
  
  func stopRecording() {
    timer.end()
    videoButton.capturing = false
    videoStatus = .ending
    
//    videoStopped()
    cameraManager.stopVideoRecording(videoCaptured(url:error:))
  }
  
  func videoCaptured(url: URL?, error: NSError?) {
    mainThread {
      self.videoStopped()
    }
    if let error = error {
      print("video recording failed: \(error)")
    } else {
      print("video recorded")
    }
    if let url = url, error == nil {
      print("video url: \(url)")
      let fileURL = FileURL(url: url)
      self.videoCaptured(fileURL)
    }
  }
  
  func videoStopped() {
    videoStatus = .idle
    cameraManager.cameraOutputMode = CameraOutputMode.stillImage
    closeCameraIfNeeded()
    videoButton.capturing = false
    jellyAnimation2 {
      self.hideTimer()
      self.remote.lift(1,1)
    }
  }
  
  func hideTimer() {
//    timer.dpos = { [unowned self] in
//      return Pos(self.remote.frame.x - .margin, screen.height).topRight
//    }
    timer.dpos = { [unowned self] in
      return Pos(screen.width, self.remote.frame.top.y - .margin).bottomLeft
    }
  }
  
  func showTimer() {
//    timer.dpos = { [unowned self] in
//      return (self.remote.frame.bottomLeft - Pos(.margin,0)).bottomRight
//    }
    timer.dpos = { [unowned self] in
      return (self.remote.frame.top - Pos(0,.margin)).bottom
    }
  }
  
}

