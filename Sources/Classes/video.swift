//
//  audiovisual.swift
//  faggot
//
//  Created by Димасик on 25/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import AVFoundation
import AVKit
import Some

class Video {
  private var url: URL
  lazy var asset: AVURLAsset = { [unowned self] in
    return AVURLAsset(url: self.url)
  }()
  init(url: URL) {
    self.url = url
  }
  init(url: FileURL) {
    self.url = url.url
  }
  func preview(_ operation: ImageOperation, handler: @escaping (_ image: UIImage?)->()) {
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: asset.duration.seconds / 3, preferredTimescale: asset.duration.timescale)
    generator.generateCGImagesAsynchronously(forTimes:[NSValue(time: time)]) { time, image, duration, result, error in
      guard let image = image?.ui else {
        handler(nil)
        return
      }
      let processed = operation.process(image: image)
      mainThread {
        handler(processed)
      }
    }
  }
//  func preview(_ size: CGSize, handler: @escaping (_ image: UIImage?)->()) {
//    let generator = AVAssetImageGenerator(asset: asset)
//    generator.appliesPreferredTrackTransform = true
//    let time = CMTime(seconds: asset.duration.seconds / 3, preferredTimescale: asset.duration.timescale)
//    generator.generateCGImagesAsynchronously(forTimes:[NSValue(time: time)]) { time, image, duration, result, error in
//      guard let image = image?.ui else {
//        handler(nil)
//        return
//      }
//      let resized = image.thumbnail(size,false)
//      handler(resized)
//    }
//  }
  lazy var preview: UIImage? = {
    var img: UIImage?
    let asset = AVURLAsset(url: self.url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let time = CMTime(seconds: asset.duration.seconds / 3, preferredTimescale: asset.duration.timescale)
    
    let semaphore = DispatchSemaphore(value: 0)
    generator.generateCGImagesAsynchronously(forTimes:[NSValue(time: time)]) { time, image, duration, result, error in
      img = image?.ui
      semaphore.signal()
    }
    semaphore.wait()
    return img
  }()
  func play() {
//    let player = AVPlayer(url: URL(string: "http://avikam.com/wp-content/uploads/2016/09/SpeechRecognitionTutorial.mp4")!)
//    let playerController = AVPlayerViewController()
//    playerController.player = player
//    self.present(playerController, animated: true) {
//      player.play()
//    }
    
    let vc = AVPlayerViewController()
    vc.player = AVPlayer(url: url)
    vc.player!.play()
    main.present(vc)
  }
}

extension AVURLAsset {
  var resolution: CGSize? {
    if let track = tracks(withMediaType: .video).first {
      let size = __CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
      return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    return nil
  }
}

