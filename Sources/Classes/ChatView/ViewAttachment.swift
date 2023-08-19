//
//  ViewAttachment.swift
//  Events
//
//  Created by Димасик on 3/30/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeData

enum TextViewContentType {
  case text(String)
  case attachment(AttachmentView)
  case otherAttachment(NSTextAttachment)
}

extension NSAttributedString {
  var range: NSRange {
    return NSRange(location: 0, length: length)
  }
//  func size(maxWidth: CGFloat) -> CGSize {
//    var width: CGFloat = 0
//    let container = NSTextContainer(size: CGSize(maxWidth,CGFloat.greatestFiniteMagnitude))
//    let layout = NSLayoutManager()
//    let storage = NSTextStorage(attributedString: self)
//    storage.addLayoutManager(layout)
//    layout.addTextContainer(container)
//    layout.enumerateLineFragments(forGlyphRange: range, using: { rect, rect2, cont, rang, some in
//      let t = (self as NSString).substring(with: rang)
//      let w = t.size(withAttributes: attributes).width + 12
//      width = Swift.max(w,width)
//    })
//    let height = self.height(font, width: width)
//    return CGSize(width,height)
//  }
}

extension CGRect {
  var bounds: CGRect {
    return CGRect(origin: .zero, size: size)
  }
}

extension NSMutableAttributedString {
  func append(_ attachment: AttachmentView) {
    if length > 0 {
      append("\n", inline: false)
    }
    append(attachmentPlaceholder) { attributes in
      attributes.attachment = attachment
//      attributes.paragraphStyle = .default
    }
  }
}

private extension String {
  subscript(range: NSRange) -> Substring {
    get {
      let stringRange = Range<String.Index>(range, in: self)!
      return self[stringRange]
    }
  }
  var isBackspace: Bool {
    let char = self.cString(using: String.Encoding.utf8)!
    return strcmp(char, "\\b") == -92
  }
  var startsWithNewline: Bool {
    return hasPrefix("\n")
  }
  var endsWithNewline: Bool {
    return hasSuffix("\n")
  }
}

class AttachmentView: NSTextAttachment {
  var views = [UITextView: UIView]()
  
  var placeholderText: String
  var userInfo: Any?
  var isFullWidth = false
  var size: CGSize {
    return CGSize(150,150)
  }
  
  init(placeholderText: String) {
    self.placeholderText = placeholderText
    super.init(data: placeholderText.data, ofType: "application/x-view")
    var bounds = CGRect(size: size)
    bounds.w += 5
    bounds.h += .margin
    self.bounds = bounds
  }
  
  func createView(for textView: UITextView) -> UIView {
    return UIView(size: size)
  }
  
//  final
  func view(for textView: UITextView) -> UIView {
    if let view = views[textView] {
      return view
    } else {
      let view = createView(for: textView)
      textView.addSubview(view)
      views[textView] = view
      return view
    }
  }
  final func unloaded(from textView: UITextView, animated: Bool) {
    guard let view = views[textView] else { return }
    views[textView] = nil
    view.removeFromSuperview()
  }
  
  deinit {
    views.values.forEach { $0.removeFromSuperview() }
  }
  
  func tapped() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var attributedString: NSAttributedString {
    return NSAttributedString(attachment: self)
  }
  func attributedString(with attrubutes: [NSAttributedStringKey: Any]) -> NSAttributedString {
    let string = NSMutableAttributedString(attributedString: attributedString)
    string.addAttributes(attrubutes, range: string.range)
    return string
  }
  
  override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
    return nil
  }
  override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
    var bounds = super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    if (isFullWidth) {
      bounds.w = lineFrag.width - textContainer!.lineFragmentPadding * 2;
    }
    return bounds;
  }
}

class MessageTextContainer: NSTextContainer {
  let layout = CustomLayoutManager()
  let textStorage: NSTextStorage
  lazy var minSize: CGSize = {
    var size = CGSize()
    layout.enumerateLineFragments(forGlyphRange: textStorage.range, using: { _, rect2, _, range, _ in
      size.height += rect2.height
      size.width = Swift.max(rect2.width,size.width)
    })
    return size
  }()
  
  init(width: CGFloat, string: NSAttributedString) {
    textStorage = NSTextStorage(attributedString: string)
    textStorage.addLayoutManager(layout)
    super.init(size: CGSize(width,.greatestFiniteMagnitude))
    layout.addTextContainer(self)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

let attachmentPlaceholder = "\u{fffc}"

class ReadTextView: UITextView {
  let customLayoutManager: CustomLayoutManager
  init(frame: CGRect, container: MessageTextContainer) {
    customLayoutManager = container.layout
    super.init(frame: frame, textContainer: container)
    backgroundColor = .clear
    contentInset = .zero
    textContainerInset = .zero
    isEditable = false
    isSelectable = false
    isScrollEnabled = false
    customLayoutManager.lastTextView = self
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  deinit {
    textStorage.enumerateAttribute(.attachment, in: textStorage.range, options: []) { value, range, stop in
      guard let value = value as? AttachmentView else { return }
      value.unloaded(from: self, animated: false)
    }
  }
  
  override func copy(_ sender: Any?) {
    rawText.saveToClipboard()
  }
  
  var rawText: String {
    let string = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: selectedRange))
    string.enumerateAttribute(.attachment, in: string.range, options: .reverse) { value, range, stop in
      guard let attach = value as? AttachmentView else { return }
      string.replaceCharacters(in: range, with: attach.placeholderText)
    }
    return string.string
  }
}

class CustomTextView: TextView {
  let paragraphStyle: NSParagraphStyle = .default
  let customLayoutManager: CustomLayoutManager
  
  init(frame: CGRect, container: MessageTextContainer) {
    customLayoutManager = container.layout
    super.init(frame: frame, textContainer: container)
    backgroundColor = .clear
    contentInset = .zero
    textContainerInset = .zero
    customLayoutManager.lastTextView = self
  }
  
  init(frame: CGRect) {
    customLayoutManager = CustomLayoutManager()
    let font = UIFont.body
    let container = NSTextContainer()
    container.widthTracksTextView = true
    let textStorage = NSTextStorage(string: "", attributes: [.font: font, .paragraphStyle: paragraphStyle])
    
    textStorage.addLayoutManager(customLayoutManager)
    customLayoutManager.addTextContainer(container)
    super.init(frame: frame, textContainer: container)
    customLayoutManager.lastTextView = self
    
    self.font = font
  }
  
  deinit {
    textStorage.enumerateAttribute(.attachment, in: textStorage.range, options: []) { value, range, stop in
      guard let value = value as? AttachmentView else { return }
      value.unloaded(from: self, animated: false)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func copy(_ sender: Any?) {
    rawText.saveToClipboard()
  }
  
  var rawText: String {
    let string = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: selectedRange))
    string.enumerateAttribute(.attachment, in: string.range, options: .reverse) { value, range, stop in
      guard let attach = value as? AttachmentView else { return }
      string.replaceCharacters(in: range, with: attach.placeholderText)
    }
    return string.string
  }
  
  var content: [TextViewContentType] {
    var array = [TextViewContentType]()
    textStorage.enumerateAttribute(.attachment, in: textStorage.range, options: .longestEffectiveRangeNotRequired) { attachment, range, stop in
      if let attachment = attachment as? AttachmentView {
        array.append(.attachment(attachment))
      } else if let attachment = attachment as? NSTextAttachment {
        array.append(.otherAttachment(attachment))
      } else if attachment == nil {
        let string = String(text[range]).cleaned
        if !string.isEmpty {
          array.append(.text(string))
        }
      }
    }
    return array
  }
  
  struct SelectedLines {
    var lines: [String]
    var startLine = -1
    var endLine = -1
    var currentIndex = 0
    var containsLettersBeforeLowerbound = false
    var containsLettersAfterUpperbound = false
    var range: NSRange
    var selectedLine = NSRange(location: 0, length: 0)
    
    func range(for line: Int) -> NSRange {
      guard line >= 0 && line < lines.count else { return NSRange() }
      var range = NSRange()
      range.length = lines[line].count
      guard line > 0 else { return range }
      for i in 0..<line-1 {
        range.location += lines[i].count
      }
      return range
    }
    
    var rangeBeforeLowerbound: NSRange {
      return NSRange(location: selectedLine.lowerBound, length: range.lowerBound - selectedLine.lowerBound)
    }
    var rangeAfterUpperbound: NSRange {
      return NSRange(location: range.upperBound, length: selectedLine.upperBound - range.upperBound)
    }
    
    init(text: String, range: NSRange) {
      self.range = range
      lines = text.lines
      
      for (line,text) in lines.enumerated() {
        let lineRange = NSRange(location: currentIndex, length: text.count + 1)
        if startLine == -1 && lineRange.contains(range.lowerBound) {
          startLine = line
          selectedLine.location = lineRange.lowerBound
          containsLettersBeforeLowerbound = range.lowerBound != lineRange.lowerBound
        }
        if endLine == -1 && lineRange.contains(range.upperBound) {
          endLine = line
          selectedLine.length = (currentIndex + text.count) - selectedLine.location
          containsLettersAfterUpperbound = range.upperBound != selectedLine.upperBound
          break
        }
        currentIndex += text.count + 1
      }
      
//      print("lines: \(lines.count)")
//      print("selected line text: \"\(text[selectedLine])\"")
//      print("contains letters before lowerbound: \(containsLettersBeforeLowerbound) \"\(text[rangeBeforeLowerbound])\"")
//      print("contains letters after upperbound: \(containsLettersAfterUpperbound) \"\(text[rangeAfterUpperbound])\"")
//      print("\(text[rangeBeforeLowerbound])\(String(text[range].map { _ in " " }))\(text[rangeAfterUpperbound])")
    }
  }
  
//  override func textViewDidChangeSelection(_ textView: UITextView) {
//    super.textViewDidChangeSelection(textView)
//    let lines = SelectedLines(text: textView.text, range: textView.selectedRange)
//  }
  
  override func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
    (textAttachment as? AttachmentView)?.tapped()
    return super.textView(textView, shouldInteractWith: textAttachment, in: characterRange)
  }
  
  func clear() {
    textStorage.beginEditing()
    textStorage.enumerateAttribute(.attachment, in: textStorage.range, options: .longestEffectiveRangeNotRequired) { attachment, range, stop in
      (attachment as? AttachmentView)?.unloaded(from: self, animated: true)
    }
    textStorage.replaceCharacters(in: textStorage.range, with: "")
    textStorage.endEditing()
  }
  
  override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    var shouldChange = super.textView(textView, shouldChangeTextIn: range, replacementText: text)
    guard shouldChange else { return false }
    
    textStorage.enumerateAttribute(.attachment, in: range, options: .longestEffectiveRangeNotRequired) { value, range, stop in
      guard let attachment = value as? AttachmentView else { return }
      self.textStorage.removeAttribute(.attachment, range: range)
      attachment.unloaded(from: textView, animated: true)
    }
    
    var text = text
    let lines = SelectedLines(text: textView.text, range: textView.selectedRange)
    
    if text.isBackspace &&
      range.length == 1 &&
      !lines.containsLettersBeforeLowerbound &&
      lines.containsLettersAfterUpperbound {
      let prange = lines.range(for: lines.startLine-1)
      if textStorage.containsAttachments(in: prange) {
        selectedRange.location -= 1
        return false
      }
    }
    
    if !text.startsWithNewline && textStorage.containsAttachments(in: lines.rangeBeforeLowerbound) {
      text = "\n"+text
      shouldChange = false
    }
    var srange = range
    srange.location += text.count
    srange.length = 0
    if !text.endsWithNewline && textStorage.containsAttachments(in: lines.rangeAfterUpperbound) {
      text = text+"\n"
      shouldChange = false
    }
    
    if !shouldChange {
      textStorage.beginEditing()
      textStorage.replaceCharacters(in: range, with: text)
      textStorage.endEditing()
      selectedRange = srange
    }
    
    return shouldChange
  }
  
  func insert(attachment: AttachmentView) {
    var range = selectedRange
    let lines = SelectedLines(text: text, range: selectedRange)
    
    if lines.containsLettersBeforeLowerbound {
      textStorage.beginEditing()
      textStorage.replaceCharacters(in: range, with: "\n")
      range.location = min(textStorage.editedRange.location + textStorage.editedRange.length, textStorage.length)
      textStorage.endEditing()
    }
    
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: range, with: attachmentPlaceholder)
    textStorage.addAttributes([.attachment: attachment, .font: font!, .paragraphStyle: paragraphStyle], range: textStorage.editedRange)
    range.location = min(textStorage.editedRange.location + textStorage.editedRange.length, textStorage.length)
    textStorage.endEditing()
    
    if lines.containsLettersAfterUpperbound {
      textStorage.beginEditing()
      textStorage.replaceCharacters(in: range, with: "\n")
      range.location = min(textStorage.editedRange.location + textStorage.editedRange.length, textStorage.length)
      textStorage.endEditing()
    }
    
    selectedRange = range
    textViewDidChange(self)
  }
  
  func insert(attachment: AttachmentView, at index: Int) {
    textStorage.beginEditing()
    textStorage.replaceCharacters(in: NSRange(location: index, length: 0), with: attachmentPlaceholder)
    textStorage.addAttributes([.attachment: attachment, .font: font!, .paragraphStyle: paragraphStyle], range: textStorage.editedRange)
    
    let range = NSRange(location: min(textStorage.editedRange.location + self.textStorage.editedRange.length, textStorage.length), length: 0)
    textStorage.endEditing()
    selectedRange = range
  }
  
  func remove(attachment: AttachmentView, removeNewLine: Bool) {
    textStorage.enumerateAttribute(.attachment, in: textStorage.range, options: [.longestEffectiveRangeNotRequired, .reverse]) { value, range, stop in
      guard let value = value as? AttachmentView else { return }
      guard value == attachment else { return }
      textStorage.removeAttribute(.attachment, range: range)
      textStorage.replaceCharacters(in: range, with: "")
      attachment.unloaded(from: self, animated: false)
      stop.pointee = true
    }
  }
}

class CustomLayoutManager: NSLayoutManager {
  weak var lastTextView: UITextView?
  override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
    super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
    textStorage?.enumerateAttribute(.attachment, in: glyphsToShow, options: .longestEffectiveRangeNotRequired) { value, range, stop in
      guard let attach = value as? AttachmentView else { return }
      var rect = boundingRect(forGlyphRange: range, in: textContainer(forGlyphAt: range.location, effectiveRange: nil)!)
      rect.origin += origin
//      rect.x += x
//      rect.y += y // + (rect.height - attach.view.bounds.height)
//      rect.height = attach.view.bounds.height
      guard let textView = self.lastTextView else { return }
      let view = attach.view(for: textView)
      view.frame.origin = rect.origin
      
    }
  }
}
