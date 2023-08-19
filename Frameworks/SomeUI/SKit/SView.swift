
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


open class SView: Hashable {
  
  public static func == (l: SView, r: SView) -> Bool {
    return l._view == r._view
  }
  public var hashValue: Int { return _view.hashValue }
  
  open weak var superview: UIView!
  
  open var automove = false
  open var automoveKeyboard = false
  open var movef: (() -> Void)!
  open func updatePosition() {
    if automove && _view != nil {
      movef?()
    }
  }
  
  open var shows = false {
    didSet {
      if shows != oldValue {
        guard superview != nil else { return }
        updateAnimated()
        if shows {
          _view = getView()
          superview.display(_view, animated: animated)
        } else {
          destroy(animated)
          _view = _view.destroy(animated: true)
        }
      }
    }
  }
  private var animated = false
  private func updateAnimated() {
    animated = superview?.superview != nil
  }
  private var _view: UIView!
  open func destroy(_ animated: Bool) {
    
  }
  open func getView() -> UIView {
    return UIView(frame: CGRect(0,0,0,0))
  }
}
