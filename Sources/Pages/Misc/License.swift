//
//  License.swift
//  Events
//
//  Created by Димасик on 3/16/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some


let license = License()
class License: Manager, CustomPath {
  let fileName = "aa.db"
  let currentVersion = 1
  var acceptedVersion = 0
  var shouldDisplay: Bool {
    return acceptedVersion < currentVersion
  }
  
  func save(data: DataWriter) throws {
    data.append(acceptedVersion)
  }
  func load(data: DataReader) throws {
    acceptedVersion = try data.next()
    acceptedVersion = 0
  }
  
  func accepted() {
    acceptedVersion = currentVersion
    try? save(ceo: ceo)
  }
  
  func display(onAccept: @escaping ()->()) {
    guard shouldDisplay else { return }
    let page = LicensePage(displayButtons: true)
    page.onAccept = onAccept
    main.push(page)
  }
}

extension String {
  func attributed(_ attributes: (inout StringAttributes)->()) -> NSAttributedString {
    var editor = StringAttributes()
    attributes(&editor)
    return NSAttributedString(string: self, attributes: editor.attributes)
  }
}
extension NSMutableAttributedString {
  func append(_ text: String, inline: Bool = false) {
    let inline = inline || length == 0
    if inline {
      append(NSAttributedString(string: text, attributes: [.font: UIFont.body]))
    } else {
      append(NSAttributedString(string: "\(text)\n", attributes: [.font: UIFont.body]))
    }
  }
  func append(_ text: String, inline: Bool = false, attributes: (inout StringAttributes)->()) {
    let inline = inline || length == 0
    if inline {
      append(text.attributed(attributes))
    } else {
      append("\(text)\n".attributed(attributes))
    }
  }
  static func += (left: NSMutableAttributedString, right: NSAttributedString) {
    left.append(right)
  }
}
struct StringAttributes {
  var attributes = [NSAttributedStringKey: Any]()
  var font: UIFont? {
    get { return attributes[.font] as? UIFont  }
    set { attributes[.font] = newValue }
  }
  var paragraphStyle: NSParagraphStyle {
    get { return attributes[.paragraphStyle] as? NSParagraphStyle ?? .default  }
    set { attributes[.paragraphStyle] = newValue }
  }
  var foregroundColor: UIColor {
    get { return attributes[.foregroundColor] as? UIColor ?? .black }
    set { attributes[.foregroundColor] = newValue }
  }
  var backgroundColor: UIColor? {
    get { return attributes[.backgroundColor] as? UIColor  }
    set { attributes[.backgroundColor] = newValue }
  }
  var ligature: Int {
    get { return attributes[.ligature] as? Int ?? 0 }
    set { attributes[.ligature] = newValue }
  }
  var kern: Double {
    get { return attributes[.kern] as? Double ?? 0.0  }
    set { attributes[.kern] = newValue }
  }
  var strikethroughStyle: Int {
    get { return attributes[.strikethroughStyle] as? Int ?? 0  }
    set { attributes[.strikethroughStyle] = newValue }
  }
  var underlineStyle: Int {
    get { return attributes[.underlineStyle] as? Int ?? 0  }
    set { attributes[.underlineStyle] = newValue }
  }
  var strokeColor: UIColor? {
    get { return attributes[.strokeColor] as? UIColor  }
    set { attributes[.strokeColor] = newValue }
  }
  var strokeWidth: Double {
    get { return attributes[.strokeWidth] as? Double ?? 0.0  }
    set { attributes[.strokeWidth] = newValue }
  }
  var shadow: NSShadow? {
    get { return attributes[.shadow] as? NSShadow  }
    set { attributes[.shadow] = newValue }
  }
  var textEffect: String? {
    get { return attributes[.textEffect] as? String  }
    set { attributes[.textEffect] = newValue }
  }
  var attachment: NSTextAttachment? {
    get { return attributes[.attachment] as? NSTextAttachment  }
    set { attributes[.attachment] = newValue }
  }
  var link: NSURL? {
    get { return attributes[.link] as? NSURL  }
    set { attributes[.link] = newValue }
  }
  var baselineOffset: Double {
    get { return attributes[.baselineOffset] as? Double ?? 0.0 }
    set { attributes[.baselineOffset] = newValue }
  }
  var underlineColor: UIColor? {
    get { return attributes[.underlineColor] as? UIColor  }
    set { attributes[.underlineColor] = newValue }
  }
  var strikethroughColor: UIColor? {
    get { return attributes[.strikethroughColor] as? UIColor  }
    set { attributes[.strikethroughColor] = newValue }
  }
  var obliqueness: Double {
    get { return attributes[.obliqueness] as? Double ?? 0.0  }
    set { attributes[.obliqueness] = newValue }
  }
  var expansion: Double {
    get { return attributes[.expansion] as? Double ?? 0.0  }
    set { attributes[.expansion] = newValue }
  }
  var verticalGlyphForm: Int {
    get { return attributes[.verticalGlyphForm] as? Int ?? 0  }
    set { attributes[.verticalGlyphForm] = newValue }
  }
}

extension NSAttributedString {
  static func with(text: String, font: UIFont? = nil, color: UIColor? = nil) -> NSAttributedString {
    var attributes = [NSAttributedStringKey: Any]()
    if let font = font {
      attributes[.font] = font
    }
    if let color = color {
      attributes[.foregroundColor] = color
    }
    return NSAttributedString(string: text, attributes: attributes)
  }
}

class LicensePage: Page {
  var onAccept: (()->())?
  private static let text: NSAttributedString = {
    let text = NSMutableAttributedString()
    text.append("App rules\n\n") { attributes in
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .center
      attributes.paragraphStyle = paragraph
      attributes.font = .navigationBarLarge
    }
//    text.addLine("Photo / Video content") { attributes in
//      attributes.font = .title1
//    }
    text.append("Main Rules") { attributes in
      attributes.font = .title2
    }
    text.append("""
  1. No Violence and Graphic Content
  2. No Nudity

""") { $0.font = UIFont.body.monoNumbers }
    
    
    text.append("Event rules") { $0.font = .title2 }
    text.append("""
  1. Only real photos/videos from event allowed
  2. Don't edit your photos/videos (like adding filters or text on photo)

""") { $0.font = UIFont.body.monoNumbers }
    
    text.append("Text rules") { $0.font = .title2 }
    text.append("""
  1. No toxicity
  2. No spam (including url links in your nickname)

""") { $0.font = UIFont.body.monoNumbers }
    return text
  }()
  let textView: UITextView
  var declineButton: UIButton!
  var acceptButton: UIButton!
  init(displayButtons: Bool) {
    textView = UITextView(frame: screen.frame)
    textView.contentInset.top = screen.top
    textView.contentInset.left = .margin
    textView.contentInset.right = .margin
    textView.attributedText = LicensePage.text
    textView.isEditable = false
    textView.backgroundColor = nil
    
    
    super.init()
    
    addSubview(textView)
    
    
    if displayButtons {
      let effect = UIBlurEffect(style: .light)
      let background = DCVisualEffectView(effect: effect)
      background.frame = CGRect(0,0,200,60)
      background.dcenter = { Pos(screen.center.x, screen.height - 40) }
      //    background.addBackground(radius: 8)
      background.cornerRadius = 12
      background.clipsToBounds = true
      
      declineButton = UIButton(type: .system)
      declineButton.setTitle("Decline", for: .normal)
      declineButton.setTitleColor(.red, for: .normal)
      declineButton.frame = CGRect(0,0,100,60)
      background.contentView.addSubview(declineButton)
      
      acceptButton = UIButton(type: .system)
      acceptButton.setTitle("Accept", for: .normal)
      acceptButton.frame = CGRect(100,0,100,60)
      background.contentView.addSubview(acceptButton)
      addSubview(background)
      
      declineButton.add(target: self, action: #selector(decline))
      acceptButton.add(target: self, action: #selector(accept))
    }
  }
  
  @objc func accept() {
    main.back()
    license.accepted()
    onAccept?()
  }
  @objc func decline() {
    main.back()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func resolutionChanged() {
    super.resolutionChanged()
    textView.frame = screen.frame
  }
}

private let licenseText = """
App rules
Main Rules
1. No Violence and Graphic Content
2. No Nudity

Event rules
1. Only real photos/videos from event allowed
2. Don't edit your photos/videos (like adding filters or text on photo)

Text rules
1. No toxicity
2. No spam (including url links in your nickname)

"""
