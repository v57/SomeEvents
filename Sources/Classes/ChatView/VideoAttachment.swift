//
//  VideoAttachment.swift
//  Events
//
//  Created by Димасик on 4/3/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Some

class RawVideoAttachment: AttachmentView {
  let url: FileURL
  init(url: FileURL) {
    self.url = url
    super.init(placeholderText: "(video)")
  }
  
  override func createView(for textView: UITextView) -> UIView {
    let imageView = UIImageView(frame: CGRect(size: size))
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleToFill
    imageView.backgroundColor = .black
    imageView.cornerRadius = 12
    imageView.setBorder(.black, screen.pixel)
    
    let video = Video(url: url)
    video.preview(.resize(size: imageView.frame.size)) { [weak imageView] image in
      guard let image = image else { return }
      mainThread {
        imageView?.image = image
      }
    }
    
    let duration = Time(video.asset.duration.seconds).duration
    let durationLabel = UILabel(text: duration, color: .white, font: .normal(10))
    durationLabel.frame.size = durationLabel.frame.size + CGSize(4,4)
    durationLabel.backgroundColor = .black
    durationLabel.textAlignment = .center
    durationLabel.clipsToBounds = true
    durationLabel.cornerRadius = 4
    durationLabel.move(Pos(150 - .miniMargin, 150 - .miniMargin), .bottomRight)
    imageView.addSubview(durationLabel)
    return imageView
  }
  
  override func tapped() {
    let video = Video(url: url)
    video.play()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class VideoAttachment: StorableAttachment {
  override var size: CGSize {
    return Size(Cell.maxTextWidth - 20)
  }
  let message: Message
  let body: VideoMessage
  
  var url: FileURL {
    return body.url(message: message)
  }
  init(message: Message, body: VideoMessage) {
    self.message = message
    self.body = body
    super.init(placeholderText: "(video)")
  }
  
  override func createView(for textView: UITextView) -> UIView {
    return VideoView(frame: CGRect(size: size), message: message, body: body)
  }
  
  override func tapped() {
    let video = Video(url: url)
    video.play()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private class VideoView: StorableAttachmentView {
  let imageView: UIImageView
  var url: URL {
    return body.link(for: message).url
  }
  let message: Message
  let body: VideoMessage
  var uploadingTag: TagLabel!
  lazy var playButton: UIButton = {
    let playButton = UIButton(frame: CGRect(size: CGSize(100,100)))
    playButton.systemHighlighting()
    playButton.setImage(#imageLiteral(resourceName: "PreviewPlay"), for: .normal)
    playButton.add(target: self, action: #selector(play))
    playButton.center = imageView.center
    return playButton
  }()
  
  init(frame: CGRect, message: Message, body: VideoMessage) {
    self.message = message
    self.body = body
    let size = frame.size
    imageView = UIImageView(frame: frame)
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleToFill
    imageView.backgroundColor = .black
    imageView.cornerRadius = 12
    imageView.setBorder(.black, screen.pixel)
    
    super.init(frame: frame)
    let url = self.url
    
    addSubview(imageView)
    
    let duration = Time(body.videoData.duration).duration
    let durationLabel = TagLabel(text: duration)
    durationLabel.move(Pos(size.width - .miniMargin, size.height - .miniMargin), .bottomRight)
    imageView.addSubview(durationLabel)
    
    if body.isDownloaded {
      let video = Video(url: url)
      video.preview(.resize(size: imageView.frame.size)) { [weak imageView] image in
        guard let image = image else { return }
        mainThread {
          imageView?.image = image
        }
      }
    } else {
      imageView.backgroundColor = .black
    }
    if body.isUploaded || body.isDownloaded {
      addSubview(playButton)
    }
    if !body.isUploaded {
      uploadingTag = TagLabel(text: "Uploading")
      uploadingTag.move(Pos(.margin,.margin), .topLeft)
      addSubview(uploadingTag)
      if let upload = body.upload(for: message) {
        uploading(with: upload)
      }
    }
  }
  
  override func uploaded() {
    uploadingTag = uploadingTag?.destroy()
    if playButton.superview == nil {
      addSubview(playButton)
    }
  }
  
  @objc func play() {
    let video = Video(url: url)
    video.play()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class TagLabel: UILabel {
  init(text: String) {
    let size = text.size(.caption1) + Size(4,4)
    super.init(frame: CGRect(size: size))
    font = .caption1
    self.text = text
    textColor = .white
    backgroundColor = .black
    textAlignment = .center
    clipsToBounds = true
    cornerRadius = 4
//    optimizeCorners()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
