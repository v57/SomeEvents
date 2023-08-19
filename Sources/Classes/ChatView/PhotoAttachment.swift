//
//  PhotoAttachment.swift
//  Events
//
//  Created by Димасик on 4/3/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class RawPhotoAttachment: AttachmentView {
  override func createView(for textView: UITextView) -> UIView {
    let imageView = UIImageView(frame: CGRect(size: size))
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleToFill
    imageView.image = photo
    imageView.cornerRadius = 12
    imageView.setBorder(.black, screen.pixel)
    return imageView
  }
  let photo: UIImage
  init(photo: UIImage) {
    self.photo = photo
    super.init(placeholderText: "(image)")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class PhotoAttachment: StorableAttachment {
  override var size: CGSize {
    return Size(Cell.maxTextWidth - 20)
  }
  override func createView(for textView: UITextView) -> UIView {
    return PhotoView(frame: CGRect(size: size), message: message, body: body)
  }
  let message: Message
  let body: PhotoMessage
  init(message: Message, body: PhotoMessage) {
    self.message = message
    self.body = body
    super.init(placeholderText: "(image)")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class PhotoView: StorableAttachmentView {
  let imageView: UIImageView
  var url: FileURL {
    return body.url(message: message)
  }
  let message: Message
  let body: PhotoMessage
  var uploadingTag: TagLabel!
  init(frame: CGRect, message: Message, body: PhotoMessage) {
    self.message = message
    self.body = body
    imageView = UIImageView(frame: frame)
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleToFill
    imageView.cornerRadius = 12
    imageView.setBorder(.black, screen.pixel)
    super.init(frame: frame)
    
    addSubview(imageView)
    
    let link = body.link(for: message)
    imageView.chatPhoto(.current, link: link, subscribe: true)
    
    if !body.isUploaded {
      uploadingTag = TagLabel(text: "Uploading")
      uploadingTag.move(Pos(.margin,.margin), .topLeft)
      addSubview(uploadingTag)
      if let upload = body.upload(for: message) {
        uploading(with: upload)
      }
    }
    
    imageView.addTap(self, #selector(tap))
  }
  
  @objc func tap() {
    
  }
  
  override func uploaded() {
    uploadingTag = uploadingTag?.destroy()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
