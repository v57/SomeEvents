
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

// MARK:- #TextView
open class TextView: UITextView, UITextViewDelegate {
  open var limit = 0
  
  open var mentions: NSArray?
  
  open weak var  textViewDelegate: TextViewDelegate?
  
  open var verticalAlignment = false
  open var image: UIImage?
  
  open override var contentOffset: CGPoint {
    didSet {
      guard !isDragging && !isDecelerating else { return }
      guard contentOffset.y != oldValue.y else { return }
      if contentOffset.y + frame.size.height > contentSize.height {
        contentOffset.y = contentSize.height - frame.size.height
      }
    }
  }
  open override var contentSize: CGSize {
    didSet {
      guard contentSize.height != oldValue.height else { return }
      checkHeight()
    }
  }
  
  open var autohighlightHashtags = false {
    willSet {
      if newValue {
        highlightHashtags()
      }
    }
  }
  
  open var attributedInput = false {
    didSet {
      if oldValue != attributedInput {
        if attributedInput {
          attributedFont = font!.copy() as! UIFont
          mutableAttributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: attributedFont])
        }
      }
    }
  }
  open var attributedFont: UIFont!
  private var mutableAttributedString: NSMutableAttributedString!
  
//  override open var contentSize: CGSize {
//    didSet {
//      guard contentSize != oldValue else { return }
//      if selectedRange.length == text.count {
//
//      }
////      textViewDelegate?.textViewContentSizeChanged?(self, oldValue: oldValue)
//    }
//  }
  
  
  override open var attributedText: NSAttributedString! {
    didSet {
      if placeholder != nil {
        placeholderLabel?.isHidden = attributedText.string.count > 0
      }
    }
  }
  
  open var placeholder: String? {
    didSet {
      if placeholder != nil {
        if placeholderLabel == nil {
          let font: UIFont = self.font ?? .normal(16)
          placeholderLabel = UILabel(frame: CGRect(x: self.frame.origin.x + 5, y: self.frame.origin.y + textContainerInset.top - 1, width: bounds.size.width - 15, height: font.lineHeight))
          placeholderLabel!.textAlignment = NSTextAlignment.left
          placeholderLabel!.font = font
          placeholderLabel!.textColor = .placeholder
          placeholderLabel!.isHidden = text.count > 0
        }
        placeholderLabel!.text = placeholder
        if placeholderLabel!.superview == nil {
          superview?.addSubview(placeholderLabel!)
        }
      }
    }
  }
  
  override open func removeFromSuperview() {
    super.removeFromSuperview()
    placeholderLabel?.removeFromSuperview()
  }
  
  open func placeholderToCenter() {
    placeholderLabel!.frame = CGRect(x: self.frame.origin.x + 5, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
  }
  
  open var lines: Int = 0 {
    didSet {
      if lines != oldValue {
        if verticalAlignment {
          let offset = (frame.size.height - textContainerInset.top - textContainerInset.bottom - font!.lineHeight * CGFloat(lines)) / 2
          contentInset = UIEdgeInsets(top: max(offset,0), left: 0, bottom: 0, right: 0)
        }
      }
    }
  }
  
  private var visibleLines = 0
  open var placeholderLabel: UILabel?
  private var previousHeight: CGFloat = 0
  
  override public init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    loaded()
  }
  public init(frame: CGRect, text: String, font: UIFont?, color: UIColor?, alignment: NSTextAlignment) {
    super.init(frame: frame, textContainer: nil)
    self.text = text
    self.font = font
    self.textColor = color
    self.textAlignment = alignment
    self.isEditable = false
    self.backgroundColor = .clear
    delegate = self
  }
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loaded()
  }
  private func loaded() {
//    linkTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.hashtag]
//    font = .body
    previousHeight = contentSize.height
    delegate = self
  }
  
  override open func didMoveToSuperview() {
    if superview != nil {
      if verticalAlignment {
        visibleLines = Int((frame.size.height - textContainerInset.top - textContainerInset.bottom) / font!.lineHeight)
        let width = frame.size.width - textContainerInset.left - textContainerInset.right
        let height = text.height(font!, width: width)
        lines = max(Int(height / font!.lineHeight),1)
      }
      if self.placeholderLabel != nil {
        self.superview!.addSubview(self.placeholderLabel!)
      }
    }
  }
  
  open func setImage(_ image: UIImage, width: CGFloat) {
    self.image = image
    isSelectable = false
    isEditable = false
    let scale = image.size.width / width
    let textAttachment = NSTextAttachment()
    textAttachment.image = ImageEditor.roundedCorners(image, radius: 5, size: image.size / scale)
    attributedText = NSAttributedString(attachment: textAttachment)
    addTap(self, #selector(tapImage))
  }
  
  open func addImage(_ image: UIImage, width: CGFloat) -> CGFloat {
    
    print(font!.pointSize)
    let scale = image.size.width / width
    let height = image.size.height / scale
    let textAttachment = NSTextAttachment()
    textAttachment.image = ImageEditor.roundedCorners(image, radius: 5, size: CGSize(width, height))
    
    let aimage = NSAttributedString(attachment: textAttachment)
    print(font!.pointSize)
    
    mutableAttributedString.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: attributedFont]))
    mutableAttributedString.append(aimage)
    mutableAttributedString.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: attributedFont]))
    attributedText = mutableAttributedString
    
    return height
  }
  
  @objc open func tapImage() {
    if image != nil {
      textViewDelegate?.textViewImageSelected?(self, image: image!)
    }
  }
  
  public func checkHeight() {
    guard let font = font else { return }
    if contentSize.height != previousHeight {
      lines = Int((contentSize.height - textContainerInset.top - textContainerInset.bottom) / font.lineHeight)
      textViewDelegate?.textViewContentSizeChanged?(self, oldValue: CGSize(contentSize.width,previousHeight))
      previousHeight = contentSize.height
    }
  }
  
  open func textViewDidChange(_ textView: UITextView) {
    checkHeight()
    
    if placeholder != nil {
      placeholderLabel?.isHidden = text.count > 0
    }
    
    if autohighlightHashtags {
      highlightHashtags()
    }
    
    /*
     // iOS 7+ bug
     let line = caretRectForPosition(selectedTextRange!.start)
     let overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top);
     if overflow > 0 {
     var offset = textView.contentOffset;
     offset.y += overflow + 7;
     UIView .animateWithDuration(0.2, animations: {
     self.contentOffset = offset
     })
     }
     */
    
    textViewDelegate?.textViewDidChange?(self)
  }
  
  open func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    let a =  textViewDelegate?.textViewShouldBeginEditing?(self)
    return a ?? true
  }
  open func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    let a =  textViewDelegate?.textViewShouldEndEditing?(self)
    return a ?? true
  }
  open func textViewDidBeginEditing(_ textView: UITextView) {
    textViewDelegate?.textViewDidBeginEditing?(self)
  }
  open func textViewDidEndEditing(_ textView: UITextView) {
    textViewDelegate?.textViewDidEndEditing?(self)
  }
  open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let delegateAnswer =  textViewDelegate?.textView?(self, shouldChangeTextIn: range, replacementText: text)
    if attributedInput {
      mutableAttributedString.replaceCharacters(in: range, with: NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: attributedFont]))
      attributedText = mutableAttributedString
      selectedRange = NSMakeRange(range.location + range.length + 1, 0)
      return false
    }
    
    if limit != 0 {
      let string = (self.text as NSString).replacingCharacters(in: range, with: text)
      if string.count > limit {
        return false
      }
    }
    return delegateAnswer ?? true
  }
  open func textViewDidChangeSelection(_ textView: UITextView) {
    textViewDelegate?.textViewDidChangeSelection?(self)
  }
  open func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
    let a =  textViewDelegate?.textView?(self, shouldInteractWith: textAttachment, in: characterRange)
    return a ?? true
  }
  open func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    let a =  textViewDelegate?.textView?(self, shouldInteractWith: URL, in: characterRange)
    if a != nil {
      return a!
    }
    if URL.scheme == "tag" {
      let text = URL.host!.removingPercentEncoding!
      textViewDelegate?.textViewHashtagTapped?(self, hashtag: text)
    } else if URL.scheme == "user" {
      textViewDelegate?.textViewMentionTapped?(self, useid: URL.host!)
    }
    return false
  }
  
  open func highlightHashtags() {
    if text != nil {
      attributedText = highlightText(text!, mentions: mentions, attributes: [.font: self.font!], editable: isEditable)
    }
  }
}

private func highlightText(_ text: String, mentions: NSArray?, attributes: [NSAttributedStringKey : Any], editable: Bool) -> NSAttributedString {
  let m = mentions != nil && mentions!.count > 0
  
  let at = NSMutableAttributedString(string: text, attributes: attributes)
  
  var tracing = false
  var length = 0
  var start = 0
  var word = ""
  var hashtag = false
  
  var mc = 0
  
  for (i, c) in text.enumerated() {
    let cs = c == " "
    let ch = c == "#"
    let cm = c == "@"
    if tracing {
      if cs || ch || cm {
        if length > 1 {
          let range = NSMakeRange(start+1, length-1)
          let symbolRange = NSMakeRange(start, 1)
          if hashtag {
            let encodedSearchString = NSString(string: "tag://\(word)").addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)
            let url = URL(string: encodedSearchString!)
            at.addAttribute(NSAttributedStringKey.link, value: url!, range: range)
          } else if m {
            at.addAttribute(NSAttributedStringKey.link, value: URL(string: "user://" + (mentions!.object(at: mc) as! String))!, range: range)
            mc += 1
          } else {
            at.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hashtag, range: range)
          }
          at.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hashtagSymbol, range: symbolRange)
        }
        if ch || cm {
          hashtag = ch
          word = String(c)
          start = i
          length = 1
        } else {
          tracing = false
        }
      }
      else {
        length += 1
        word.append(c)
      }
    } else {
      if ch || cm {
        hashtag = ch
        tracing = true
        start = i
        length = 1
        word = String(c)
      }
    }
  }
  if tracing {
    if editable && length == 1 {
      let symbolRange = NSMakeRange(start, 1)
      at.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hashtagSymbol, range: symbolRange)
    } else if length > 1 {
      let symbolRange = NSMakeRange(start, 1)
      at.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hashtagSymbol, range: symbolRange)
      let range = NSMakeRange(start+1, length-1)
      at.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hashtag, range: range)
    }
  }
  return at
}

@objc public protocol TextViewDelegate: UITextViewDelegate {
  @objc optional func textViewMentionTapped(_ textView: TextView, useid: String)
  @objc optional func textViewHashtagTapped(_ textView: TextView, hashtag: String)
  @objc optional func textViewContentSizeChanged(_ textView: TextView, oldValue: CGSize)
  @objc optional func textViewImageSelected(_ textView: TextView, image: UIImage)
  
}
