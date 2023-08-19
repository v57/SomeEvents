//
//  StringUI.swift
//  Some
//
//  Created by Дмитрий Козлов on 02/09/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit

extension String {
  public func size(_ font: UIFont) -> CGSize {
    return self.size(withAttributes: [NSAttributedStringKey.font : font])
  }
  public func width(_ font: UIFont) -> CGFloat {
    return self.size(withAttributes: [NSAttributedStringKey.font : font]).width
  }
  public func height(_ font: UIFont, width: CGFloat) -> CGFloat {
    return self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size.height
  }
  public func numberOfLines(_ font: UIFont, width: CGFloat) -> Int {
    return Int(self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size.height / font.lineHeight)
  }
  public func size(_ font: UIFont, maxWidth: CGFloat) -> CGSize {
    guard maxWidth > 0 else { return size(font) }
    let attributes = [NSAttributedStringKey.font: font]
    var width: CGFloat = 0
    let container = NSTextContainer(size: CGSize(maxWidth,.greatestFiniteMagnitude))
    let layout = NSLayoutManager()
    let storage = NSTextStorage(string: self, attributes: attributes)
    storage.addLayoutManager(layout)
    layout.addTextContainer(container)
    var height: CGFloat = 0
    layout.enumerateLineFragments(forGlyphRange: NSRange(location: 0,length: self.count), using: { rect, rect2, cont, rang, stop in
      height += rect2.size.height
      width = Swift.max(rect2.size.width,width)
    })
    return CGSize(width,height)
  }
  public func image(font: UIFont) -> UIImage {
    let size = self.size(font)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    defer { UIGraphicsEndImageContext() }
//    UIColor.white.set()
    let rect = CGRect(origin: .zero, size: size)
//    UIRectFill(rect)
    (self as NSString).draw(in: rect, withAttributes: [NSAttributedStringKey.font: font])
    return UIGraphicsGetImageFromCurrentImageContext()!
  }
  
  public func saveToClipboard() {
    UIPasteboard.general.string = self
  }
}
