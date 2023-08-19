
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Dmitry Kozlov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

open class SLabel: SView {
  open var pos: Pos {
    didSet {
      view?.move(pos,anchor)
    }
  }
  open var text: String {
    didSet {
      guard view != nil else { return }
      guard text != oldValue else { return }
      let mutable = NSMutableAttributedString(attributedString: view.attributedText!)
      mutable.mutableString.setString(text)
      let newSize = mutable.size()
      view.attributedText = mutable
      view.resize(newSize, anchor)
    }
  }
  open var font: UIFont
  open var anchor: Anchor
  open var color: Color
  
  open var lines = 1
  open var maxWidth: CGFloat = 0
  open var autoresize = false
  open var maxX: CGFloat {
    get {
      return pos.x - maxWidth
    }
    set {
      maxWidth = maxX - pos.x
    }
  }
  
  open var view: UILabel!
  
  
  open override func getView() -> UIView {
    let font = self.font
    
    var attributes = [NSAttributedStringKey: Any]()
    attributes[.font] = font
    attributes[.foregroundColor] = color
    let style = NSMutableParagraphStyle()
    style.alignment = anchor.alignment
    attributes[.paragraphStyle] = style
    
    let string = NSAttributedString(string: text, attributes: attributes)
    
    var size = string.size()
    if maxWidth > 0 && size.width > maxWidth {
      size.width = maxWidth
      if lines == 0 {
        size.height = text.height(font, width: maxWidth)
      } else if lines > 1 {
        size.height = font.lineHeight * CGFloat(lines)
      }
    }
    
    view = UILabel(frame: CGRect(pos,anchor,size))
    view.numberOfLines = lines
    view.attributedText = string
    if autoresize {
      view.adjustsFontSizeToFitWidth = true
      view.minimumScaleFactor = 0.5
    }
    return view
  }
  
  open override func destroy(_ animated: Bool) {
    view = nil
  }
  
  public override init() {
    self.pos = Pos()
    self.text = ""
    self.font = UIFont(14)
    self.color = .dark
    self.anchor = _c
  }
  
  public init(pos: Pos, text: String!, font: UIFont, color: Color, anchor: Anchor) {
    self.pos = pos
    self.text = text ?? ""
    self.font = font
    self.anchor = anchor
    self.color = color
  }
}
