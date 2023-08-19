//
//  recorder.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import AVFoundation

open class Recorder {
  open var url: URL
  open var audiRecorder: AVAudioRecorder?
  
  init() {
    url = URL(fileURLWithPath: NSTemporaryDirectory())
    url.appendPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    url.appendPathComponent("message.caf")
  }
  
  public class func requestPermissions(handler: @escaping (Bool)->()) {
    let audioSession = AVAudioSession.sharedInstance()
    audioSession.requestRecordPermission(handler)
  }
  
  open func start() throws {
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try audioSession.setActive(true)
    
    let url = self.url
    
    let settings: [String : Any] = [
      //      AVFormatIDKey:Int(kAudioFormatMPEG4AAC),
      //      AVNumberOfChannelsKey:1,
      //      AVEncoderBitRateKey:12000,
      //      AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
      AVFormatIDKey:Int(kAudioFormatAppleIMA4),
      //      AVSampleRateKey:44100.0,
      AVNumberOfChannelsKey:1,
      AVEncoderBitRateKey:12800,
      //      AVLinearPCMBitDepthKey:16,
      AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
    ]
    
    audiRecorder = try AVAudioRecorder(url: url, settings: settings)
    audiRecorder!.record()
    //    print(audiRecorder!.isRecording)
    //    print(audiRecorder!.record())
    //    print(audiRecorder!.isRecording)
  }
  @discardableResult
  open func stop() throws -> Voice {
    guard let audiRecorder = audiRecorder else { throw RecorderError.notStarted }
    let duration = audiRecorder.currentTime
    audiRecorder.stop()
    self.audiRecorder = nil
    let audio = Voice(url: url, duration: duration)
    return audio
  }
  deinit {
    _ = try? stop()
  }
}

public enum RecorderError: Error {
  case notStarted, noPermissions
  public var localizedDescription: String {
    switch self {
    case .notStarted: return "Запись ещё не началась"
    case .noPermissions: return "Разрешите доступ к микрофону"
    }
  }
}

open class Voice: NSObject {
  public let duration: TimeInterval
  public let url: URL
  func getData() -> Data? {
    return (try? Data(contentsOf: url))
  }
  init(url: URL, duration: TimeInterval) {
    self.duration = duration
    self.url = url
  }
}
