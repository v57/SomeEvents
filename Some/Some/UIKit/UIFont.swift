//
//  UIFont.swift
//  Some
//
//  Created by Димасик on 18/08/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import UIKit

extension UIFont {
  // http://tirania.org/s/a5d82df0.png
  // https://developer.apple.com/ios/human-interface-guidelines/visual-design/typography/
  public convenience init(_ size: CGFloat) {
    let systemFont = UIFont.systemFont(ofSize: size)
    self.init(name: systemFont.fontName, size: size)!
  }
  public static var navigationBarLarge: UIFont {
    if #available(iOS 11.0, *) {
      return UIFont.preferredFont(forTextStyle: .largeTitle).heavy
    } else {
      return .heavy(34)
    }
  }
  public static var largeTitle: UIFont {
    return .navigationBarLarge
  }
  public static var body: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
  }
  public static var title1: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
  }
  public static var title2: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.title2)
  }
  public static var title3: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.title3)
  }
  public static var footnote: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
  }
  public static var headline: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
  }
  public static var subheadline: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
  }
  public static var callout: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)
  }
  public static var caption1: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)
  }
  public static var caption2: UIFont {
    return UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption2)
  }
  public static func light(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func ultraLight(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.ultraLight)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func thin(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.thin)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func normal(_ size: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: size)
  }
  public static func semibold(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func bold(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func heavy(_ size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
      return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.heavy)
    } else {
      return UIFont.systemFont(ofSize: size)
    }
  }
  public static func mono(_ size: CGFloat) -> UIFont {
    return UIFont(name: "Menlo", size: size)!
  }
  public static func monoNumbers(_ size: CGFloat) -> UIFont {
    if #available(iOS 9.0, *) {
      return UIFont.monospacedDigitSystemFont(ofSize: size, weight: .regular)
    } else {
      return UIFont(name: "Menlo", size: size)!
    }
  }
  
  
  public var semibold: UIFont {
    return .semibold(pointSize)
  }
  public var light: UIFont {
    return .light(pointSize)
  }
  public var ultraLight: UIFont {
    return .ultraLight(pointSize)
  }
  public var thin: UIFont {
    return .thin(pointSize)
  }
  public var normal: UIFont {
    return .normal(pointSize)
  }
  public var bold: UIFont {
    return .bold(pointSize)
  }
  public var heavy: UIFont {
    return .heavy(pointSize)
  }
  public var mono: UIFont {
    return .mono(pointSize)
  }
  public var monoNumbers: UIFont {
    return .monoNumbers(pointSize)
  }
}
