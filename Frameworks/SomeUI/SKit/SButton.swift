
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

public protocol SButtonActions: class {
  func buttonPushed(_ button: SButton)
}

open class SButton: SView {
  open var pos: Pos {
    didSet {
      view?.move(pos, anchor)
    }
  }
  open var anchor: Anchor
  open var imageName: String!
  open var text: String!
  open var handler: (()->Void)!
  open var size: Size
  
  open var view: Button!
  
  open weak var actions: SButtonActions!
  
  public init(pos: Pos, size: Size = Size(), anchor: Anchor = _c, imageName: String! = nil, text: String! = nil, handler: (()->Void)! = nil) {
    self.pos = pos
    self.anchor = anchor
    self.imageName = imageName
    self.text = text
    self.size = size
    self.handler = handler
  }
  open override func getView() -> UIView {
    let size: Size
    let image: UIImage!
    if imageName != nil {
      image = UIImage(named: imageName)
    } else {
      image = nil
    }
    if image != nil && text == nil {
      size = image!.size
      view = Button(type: .system)
      view.frame = CGRect(pos, anchor, size)
      view.systemHighlighting()
    } else {
      size = self.size
      view = Button(frame: CGRect(pos, anchor, size))
    }
    
//    view = Button(frame: CGRect(pos, anchor, size))
    if text != nil {
      view.setTitle(text, for: UIControlState())
    }
    if imageName != nil {
      view.setImage(image, for: UIControlState())
    }
    view.touch { [weak self] in
      self?.push()
    }
    return view
  }
  func push() {
    actions?.buttonPushed(self)
    handler?()
  }
}
