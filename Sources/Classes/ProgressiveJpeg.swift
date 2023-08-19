//
//  ProgressiveJpeg.swift
//  Events
//
//  Created by Димасик on 2/19/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import Some
import ImageIO

// for displaying progressive images
import Accelerate
// for making progressive images
import MobileCoreServices

class DownloadSimulator {
  var data: Data
  var position = 0
  var download: SomeDownload! {
    didSet {
      guard download != nil else { return }
      download.total = Int64(data.count)
    }
  }
  var isCompleted: Bool {
    return position >= data.count
  }
  init(data: Data) {
    self.data = data
  }
  func reset() {
    position = 0
  }
  func next(_ count: Int) {
    if position + count < data.count {
      download.append(data: data[position..<position+count])
      position += count
    } else {
      download.append(data: data[position...])
      position = data.count
    }
  }
}

extension ImageFormat {
  static var progressive: ImageFormat {
    return ProgressiveJpgFormat(quality: 1.0)
  }
  static func progressive(_ quality: CGFloat) -> ImageFormat {
    return ProgressiveJpgFormat(quality: quality)
  }
}
class ProgressiveJpgFormat: ImageFormat {
  override var name: String { return "progressive \(quality) "}
  let quality: CGFloat
  init(quality: CGFloat) {
    self.quality = quality
    super.init()
  }
  override func process(image: UIImage) -> Data {
    return image.progressive(quality: quality)
  }
}

extension UIImage {
  func progressive(quality: CGFloat) -> Data {
    let data = NSMutableData()
    let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil)!
    
    var properties = [CFString: Any]()
    properties[kCGImageDestinationLossyCompressionQuality] = quality
    properties[kCGImagePropertyOrientation] = imageOrientation.tiff
    properties[kCGImagePropertyJFIFDictionary] = [kCGImagePropertyJFIFIsProgressive: true]
    
    CGImageDestinationAddImage(destination, cgImage!, properties as NSDictionary)
    CGImageDestinationFinalize(destination)
    
    return data as Data
  }
  func properties() -> [CFString: Any] {
    let data = jpg()
    return UIImage.properties(from: data)
  }
  static func properties(from data: Data) -> [CFString: Any] {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return [:] }
    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) else { return [:] }
    return properties as! [CFString: Any]
  }
}

extension UIImageOrientation {
  var tiff: Int {
    switch self {
    case .up:
      return 1
    case .down:
      return 3
    case .left:
      return 8
    case .right:
      return 6
    case .upMirrored:
      return 2
    case .downMirrored:
      return 4
    case .leftMirrored:
      return 7
    case .rightMirrored:
      return 5
    }
  }
}

enum ImageType {
  case png, jpg, progressive
}

class ProgressiveImage {
  static var states: [Int] = [10,20,25,30,50,1000000]
  var onUpdate: ((UIImage,Bool)->())!
  var shouldUpdate: ()->(Bool) = { true }
//  var cpuTime = 0.0
  var state = 0
  private var imageSource: CGImageSource = CGImageSourceCreateIncremental(nil)
  private var size: CGSize = .zero
  private var type: ImageType = .progressive
  private var scannedByte: Int = 0
  private var sosCount: Int = 0
  private var lock = NSLock()
  var version: Int = 0
  
  let download: SomeDownload
  init(download: SomeDownload) {
    self.download = download
    download.dataReceived.subscribe(self) { download in
      self.version += 1
      let v = self.version
      mainThread {
        if #available(iOS 10.0, *) {
          Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { timer in
            guard self.version == v else { return }
            self.updated()
            }
        } else {
          self.updated()
        }
      }
    }
  }
  
  func update(image: UIImage, last: Bool) {
    let name = download.url!.lastPathComponent
    print("[\(name)] setting image")
    onUpdate(image,last)
  }
  
  func updated() {
    let name = download.url!.lastPathComponent
    lock.lock()
    defer { lock.unlock() }
    if download.isDownloaded {
      print("[\(name)] downloaded")
      imageThread {
        if let data = self.download.data, let image = UIImage(data: data)?.decode4() {
          if let url = self.download.url {
            url.fileURL.cache(image: image)
          }
          mainThread {
            self.update(image: image, last: true)
          }
        } else if let url = self.download.url, let image = url.fileURL.cachedImage {
          mainThread {
            self.update(image: image, last: true)
          }
        } else {
          print("[\(name)] data not found")
        }
      }
    } else if type == .progressive, let data = download.data {
      print("[\(name)] updating \(shouldUpdate())")
      guard shouldUpdate() else { return }
      let progress = data.count * 100 / Int(download.total)
      guard progress >= ProgressiveImage.states[state] else { return }
      state += 1
      while progress >= ProgressiveImage.states[state] {
        state += 1
      }
      
      while sosCount < 2 && scannedByte < data.count {
        if scannedByte > 0 {
          scannedByte -= 1
        }
        //check if we have a complete scan
        //SOS marker
        let scanMarker = Data(bytes: [0xFF,0xDA])
        
        //scan one byte back in case we only got half the SOS on the last data append
        let scanRange = Range<Int>(NSRange(location: scannedByte, length: data.count - scannedByte))!
        
        let sosRange = data.range(of: scanMarker, options: [], in: scanRange)
        if let sosRange = sosRange {
          scannedByte = sosRange.upperBound
          sosCount += 1
        } else {
          scannedByte = scanRange.upperBound
        }
      }
      if let image = currentImage {
        update(image: image, last: state == ProgressiveImage.states.count - 1)
      }
    }
  }
  
  var currentImage: UIImage? {
    guard let data = download.data else { return nil }
    guard sosCount >= 2 else { return nil }
    if size.width <= 0 || size.height <= 0 {
      let imageProperties = UIImage.properties(from: data)
      guard !imageProperties.isEmpty else { return nil }
      
      if size.width <= 0, let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat {
        size.width = pixelWidth
      }
      if size.height <= 0, let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat {
        size.height = pixelHeight
      }
      
      let hasAlpha = imageProperties[kCGImagePropertyHasAlpha] as? Bool ?? false
      let jpegProperties = imageProperties[kCGImagePropertyJFIFDictionary] as? [CFString: Any]
      let isProgressive = jpegProperties?[kCGImagePropertyJFIFIsProgressive] as? Bool ?? false
      if isProgressive {
        type = .progressive
      } else if hasAlpha {
        type = .png
      } else {
        type = .jpg
      }
    }
    guard type == .progressive else { return nil }
    guard size != .zero else { return nil }
    guard size.width < 10000 && size.height < 10000 else { return nil }
    let image = UIImage(data: data)
    return image
  }
}


