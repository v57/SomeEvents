//
//  UIImage.swift
//  Some
//
//  Created by Дмитрий Козлов on 02/09/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeFunctions

extension CGImage {
  public var isPng: Bool {
    let alphaInfo = self.alphaInfo
    return !(alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast || alphaInfo == .none)
  }
}

extension UIImage {
  public func jpg(_ quality: CGFloat = 1) -> Data {
    guard let data = UIImageJPEGRepresentation(self, quality) else { fatalError("can't convert UIImage to jpg") }
    return data
  }
  
  public func png() -> Data {
    guard let data = UIImagePNGRepresentation(self) else { fatalError("can't convert UIImage to png") }
    return data
  }
  
  public var isPng: Bool {
    return cgImage?.isPng ?? false
  }
  
  
  public var isJpg: Bool {
    return !isPng
  }
  
  public func saveToAlbum() {
    
  }
  
  public func resize(size: CGSize, _ retina: Bool = true) -> UIImage {
    let size = Size(round(size.width),round(size.height))
    let frame = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, retina ? screen.retina : 1)
    draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  
  public func limit(minSize: CGFloat, _ retina: Bool = true) -> UIImage {
    let min = self.size.min
    guard min > minSize else { return self }
    var scale = min / minSize
    var size = self.size / scale
    
    let maxSize = minSize * 2
    let max = size.max
    guard max > maxSize else { return resize(size: size, retina) }
    scale = max / maxSize
    size = self.size / scale
    return resize(size: size, retina)
  }
  
  public func limit(maxSize: CGFloat, _ retina: Bool = true) -> UIImage {
    let max = self.size.max
    guard max > maxSize else { return self }
    let scale = max / maxSize
    let size = self.size / scale
    return resize(size: size, retina)
  }
  
  public func thumbnail(_ size: CGSize, _ retina: Bool = true) -> UIImage {
    let scale = min(self.size.width / size.width, self.size.height / size.height)
    let newSize = self.size / scale
    let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
    UIGraphicsBeginImageContextWithOptions(size, false, retina ? screen.retina : 1)
    draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  
  public func thumbnail(size: CGSize, cornerRadius: CGFloat, retina: Bool = true) -> UIImage {
    let scale = min(self.size.width / size.width, self.size.height / size.height)
    let newSize = self.size / scale
    let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
    UIGraphicsBeginImageContextWithOptions(size, false, retina ? screen.retina : 1)
    
    let context = UIGraphicsGetCurrentContext()!
    context.addPath(UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius).cgPath)
    context.clip()
    
    draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  
  public func fill(_ size: CGSize, scale: CGFloat = 0) -> UIImage {
    var sc = scale
    if sc == 0 {
      sc = self.scale
    }
    
    let scale = min(self.size.width / size.width, self.size.height / size.height)
    let newSize = self.size / scale
    let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
    UIGraphicsBeginImageContextWithOptions(size, false, sc)
    draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  
  public func cornerRadius(_ radius: CGFloat, size: CGSize) -> UIImage {
    let rect = CGRect(0,0,size.width,size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()!
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.clip()
    
    self.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext()
    return output!
  }
  public func withAlpha(_ alpha: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, screen.retina)
    
    let ctx = UIGraphicsGetCurrentContext()
    let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
    
    ctx?.scaleBy(x: 1, y: -1)
    ctx?.translateBy(x: 0, y: -area.size.height)
    ctx?.setBlendMode(CGBlendMode.multiply)
    ctx?.setAlpha(alpha)
    
    ctx?.draw(self.cgImage!, in: area)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return newImage!
  }
  public func profilePhoto(_ width:CGFloat) -> UIImage  {
    let rect = CGRect(0,0,width,width)
    UIGraphicsBeginImageContextWithOptions(self.size, false, screen.retina)
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: width/2).cgPath)
    ctx?.clip();
    self.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output!
  }
  public func averageHexColor() -> String {
    
    let rgba = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let context: CGContext = CGContext(data: rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    return String(NSString(format: "%2X%2X%2X", rgba[0],rgba[1],rgba[2]))
  }
  public func decode() {
    UIGraphicsBeginImageContext(CGSize(width: 1,height: 1))
    UIGraphicsGetCurrentContext()?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
    UIGraphicsEndImageContext()
  }
  public func decode2() -> UIImage {
    let frame = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  public func decode3() -> UIImage {
    guard let imageRef = self.cgImage else {
      return self //failed
    }
    let width = imageRef.width
    let height = imageRef.height
    let colourSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    guard let imageContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colourSpace, bitmapInfo: bitmapInfo) else {
      return self //failed
    }
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    imageContext.draw(imageRef, in: rect)
    if let outputImage = imageContext.makeImage() {
      let cachedImage = UIImage(cgImage: outputImage, scale: scale, orientation: imageOrientation)
      return cachedImage
    }
    return self //failed
  }
  static let colorSpace = CGColorSpaceCreateDeviceRGB()
  public func decode4() -> UIImage {
    let imageRef = cgImage!
    let colorspaceRef = UIImage.colorSpace
    let hasAlpha = imageRef.isPng
    // iOS display alpha info (BRGA8888/BGRX8888)
    var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
    if hasAlpha {
      bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue
    } else {
      bitmapInfo |= CGImageAlphaInfo.noneSkipFirst.rawValue
    }
    
    let width = imageRef.width
    let height = imageRef.height
    
    // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
    // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipLast
    // to create bitmap graphics contexts without alpha info.
    
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorspaceRef, bitmapInfo: bitmapInfo) else { return self }
    // Draw the image into the context and retrieve the new bitmap image without alpha
    context.draw(imageRef, in: CGRect(0,0,width,height))
    guard let imageRefWithoutAlpha = context.makeImage() else { return self }
    let imageWithoutAlpha = UIImage(cgImage: imageRefWithoutAlpha, scale: scale, orientation: imageOrientation)
    return imageWithoutAlpha
  }
  public func circle() -> UIImage {
    let rect = CGRect(0,0,size.width,size.width)
    
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(ovalIn: rect).cgPath)
    UIGraphicsGetCurrentContext()?.clip()
    
    self.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output!
  }
  public func circle(_ width: CGFloat) -> UIImage {
    let rect = CGRect(0,0,width,width)
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, screen.retina)
    UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(ovalIn: rect).cgPath)
    UIGraphicsGetCurrentContext()?.clip()
    
    self.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output!
  }
}

extension CGImage {
  public var ui: UIImage {
    return UIImage(cgImage: self, scale: screen.retina, orientation: .up)
  }
}


public class ImageEditor {
  
  public class func createMask(_ image: CGImage, mask: CGImage) -> CGImage {
    let imageMask = CGImage(maskWidth: mask.width,
                            height: mask.height,
                            bitsPerComponent: mask.bitsPerComponent,
                            bitsPerPixel: mask.bitsPerPixel,
                            bytesPerRow: mask.bytesPerRow,
                            provider: mask.dataProvider!,
                            decode: nil,
                            shouldInterpolate: true
    );
    let maskedImage = image.masking(imageMask!)!
    return maskedImage;
  }
  public class func cutImage(_ image: UIImage!, width: CGFloat, height: CGFloat) -> [[UIImage]] {
    let scale = image.scale
    
    let iconWidth: Int = Int(image.size.width / width * scale)
    let iconHeight: Int = Int(image.size.height / height * scale)
    
    var array = [[UIImage]]()
    for i in 0...Int(width)-1 {
      var secondArray = [UIImage]()
      for j in 0...Int(height)-1 {
        let rect = CGRect(x: iconWidth * i, y: iconHeight * j, width: iconWidth, height: iconHeight)
        let cgImage = image.cgImage
        let resultCG = cgImage?.cropping(to: rect)!
        let result = UIImage(cgImage: resultCG!, scale: scale, orientation: .up)
        secondArray.append(result)
      }
      array.append(secondArray)
    }
    return array
  }
  
  //  public class func transparentJPG(image: UIImage) -> UIImage? {
  //    let size = image.size
  //
  //    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
  //    let context = CGBitmapContextCreate(bitmapData, UInt(size.width), UInt(size.height), CUnsignedLong(8),  CUnsignedLong(bitmapBytesPerRow), colorSpace, bitmapInfo)
  //    CGContextSetShouldAntialias(context, false)
  //    let imageRef = CGBitmapContextCreateImage(context)
  //
  //    return result
  //  }
  
  /*
   -(UIImage *)changeWhiteColorTransparent: (UIImage *)image
   {
   CGImageRef rawImageRef=image.CGImage;
   
   const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
   
   UIGraphicsBeginImageContext(image.size);
   CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
   {
   //if in iphone
   CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
   CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
   }
   
   CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
   UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
   CGImageRelease(maskedImageRef);
   UIGraphicsEndImageContext();
   return result;
   }
   */
  
  public class func resizeImage(_ image: UIImage, size: CGSize, scale: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, scale);
    image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result!;
  }
  
  public class func colorImage(_ img: UIImage!, color: UIColor) -> UIImage! {
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, screen.retina)
    color.setFill()
    UIRectFill(rect)
    let tempColor = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let maskRef = img.cgImage
    let maskcg = CGImage(maskWidth: (maskRef?.width)!,
                         height: (maskRef?.height)!,
                         bitsPerComponent: (maskRef?.bitsPerComponent)!,
                         bitsPerPixel: (maskRef?.bitsPerPixel)!,
                         bytesPerRow: (maskRef?.bytesPerRow)!,
                         provider: (maskRef?.dataProvider!)!, decode: nil, shouldInterpolate: false);
    
    let maskedcg = tempColor?.cgImage?.masking(maskcg!)!
    let result = UIImage(cgImage: maskedcg!, scale: screen.retina, orientation: .up)
    
    return result
  }
  
  
  public class func combineImages(_ images: [UIImage], size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let center = CGPoint(x: size.width/2.0, y: size.height/2.0)
    for i in 0...images.count-1 {
      let image = images[i]
      let centerRect = CGRect(center: center, size: image.size)
      if i == 0 {
        image.draw(in: centerRect)
      } else {
        image.draw(in: centerRect, blendMode: CGBlendMode.normal, alpha: 1.0)
      }
    }
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!;
  }
  public class func fill(color: UIColor, size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()!
    
    let frame = CGRect(origin: .zero, size: size)
    
    context.setFillColor(color.cgColor)
    context.fill(frame)
    context.drawPath(using: .fill)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  public class func fill(color: UIColor, size: CGSize, cornerRadius: CGFloat) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()!
    
    let frame = CGRect(origin: .zero, size: size)
    
    context.setFillColor(color.cgColor)
    let path = CGPath(roundedRect: frame, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    context.addPath(path)
    context.drawPath(using: .fill)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  public class func circle(_ size: CGSize, fillColor: UIColor? = nil, strokeColor: UIColor? = nil, lineWidth: CGFloat = 1) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()
    let stroke: Bool = (strokeColor != nil && lineWidth > 0)
    let fill: Bool = fillColor != nil
    
    var frame = CGRect(origin: CGPoint(), size: size)
    
    if stroke {
      frame = CGRect(x: lineWidth, y: lineWidth, width: size.width - lineWidth*2, height: size.height - lineWidth*2)
      context?.setStrokeColor(strokeColor!.cgColor)
      context?.setLineWidth(lineWidth)
    }
    if fill {
      context?.setFillColor(fillColor!.cgColor)
    }
    context?.addEllipse(in: frame)
    context?.drawPath(using: fill ? stroke ? CGPathDrawingMode.fillStroke : CGPathDrawingMode.fill : CGPathDrawingMode.stroke)
    
    let result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result!;
  }
  public class func textWithShadow(_ text: String, font: UIFont, color: UIColor, radius: CGFloat, stroke: Bool) -> UIImage {
    let size = CGSize(width: 100,height: 30)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 3)
    let context = UIGraphicsGetCurrentContext()
    if radius > 0 {
      context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 255)
      context?.setShadow(offset: CGSize(), blur: radius)
    }
    var attributes = [NSAttributedStringKey: Any]()
    attributes[.font] = font
    attributes[.foregroundColor] = color
    var strokeAttributes = [NSAttributedStringKey: Any]()
    strokeAttributes[.font] = font
    strokeAttributes[.foregroundColor] = color
    strokeAttributes[.strokeColor] = UIColor.black
    strokeAttributes[.strokeWidth] = 1
    NSAttributedString(string: text, attributes: attributes).draw(at: CGPoint(x: radius,y: radius))
    if stroke {
      NSAttributedString(string: text, attributes: strokeAttributes).draw(at: CGPoint(x: radius,y: radius))
    }
    
    let result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result!;
  }
  public class func circle(_ size: CGSize, fillColor: UIColor?, strokeColor: UIColor?, lineWidth: CGFloat, radius: CGFloat) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    let context = UIGraphicsGetCurrentContext()
    let stroke: Bool = (strokeColor != nil && lineWidth > 0)
    let fill: Bool = fillColor != nil
    
    var frame = CGRect(origin: CGPoint(), size: size)
    
    if stroke {
      frame = CGRect(size.center, _center, CGSize(radius,radius))//CGRect(x: lineWidth, y: lineWidth, width: size.width - lineWidth*2, height: size.height - lineWidth*2)
      context?.setStrokeColor(strokeColor!.cgColor)
      context?.setLineWidth(lineWidth)
    }
    if fill {
      context?.setFillColor(fillColor!.cgColor)
    }
    context?.addEllipse(in: frame)
    context?.drawPath(using: fill ? stroke ? CGPathDrawingMode.fillStroke : CGPathDrawingMode.fill : CGPathDrawingMode.stroke)
    
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  
  public class func roundedCorners(_ image: UIImage, radius: CGFloat, size: CGSize) -> UIImage {
    let rect = CGRect(0,0,size.width,size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    UIGraphicsGetCurrentContext()?.clip()
    
    image.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output!
  }
  public class func roundedCorners(_ image: UIImage, radius: CGFloat) -> UIImage {
    return roundedCorners(image, radius: radius, size: image.size)
  }
  public class func circleImage(_ image: UIImage, size: CGSize) -> UIImage {
    let rect = CGRect(0,0,size.width,size.height)
    
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(ovalIn: rect).cgPath)
    UIGraphicsGetCurrentContext()?.clip()
    
    image.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output!
  }
  
  public class func square(_ image: UIImage, size: CGSize) -> UIImage {
    return square(resize(image, size: size, ratio: true))
  }
  
  public class func center(_ image: UIImage, size: CGSize) -> UIImage {
    let w = image.size.width
    let h = image.size.height
    let frame = CGRect((w-size.width)/2,(h-size.height)/2,size.width,size.height)
    return image.cgImage!.cropping(to: frame)!.ui
  }
  
  public class func square(_ image: UIImage) -> UIImage {
    let frame: CGRect
    let w = image.size.width
    let h = image.size.height
    if w > h {
      frame = CGRect((w-h)/2,0,h,h)
    } else {
      frame = CGRect(0,(h-w)/2,h,h)
    }
    return image.cgImage!.cropping(to: frame)!.ui
  }
  
  public class func resize(_ image: UIImage, size: CGSize, ratio: Bool) -> UIImage {
    if image.size.width == size.width && image.size.height == size.height {
      return image
    }
    let frame: CGRect
    if ratio {
      let scale = min(image.size.width / size.width, image.size.height / size.height)
      let newSize = image.size / scale
      frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
    } else {
      frame = CGRect(origin: CGPoint(), size: size)
    }
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    image.draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
  public class func circle(_ image: UIImage, size: CGSize) -> UIImage {
    let scale = min(image.size.width / size.width, image.size.height / size.height)
    let newSize = image.size / scale
    let frame = CGRect(origin: CGPoint((size.width-newSize.width) / 2,(size.height-newSize.height) / 2), size: newSize)
    UIGraphicsBeginImageContextWithOptions(size, false, screen.retina)
    UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(ovalIn: CGRect(origin: CGPoint(), size: size)).cgPath)
    UIGraphicsGetCurrentContext()?.clip()
    
    image.draw(in: frame)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
}

