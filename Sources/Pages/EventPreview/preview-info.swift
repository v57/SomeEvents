//
//  EventPreview.info.swift
//  faggot
//
//  Created by Димасик on 3/24/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

private extension UILabel {
  func set(text: String) {
    self.text = text
    let newWidth = text.width(font!)
    guard frame.width != newWidth else { return }
    let offset = newWidth - frame.width
    frame.w = newWidth
    guard let subviews = superview?.subviews else { return }
    guard let index = subviews.index(of: self) else { return }
    let start = index + 1
    guard start < subviews.count else { return }
    for i in start..<subviews.count {
      let view = subviews[i]
      view.offset(x: offset)
    }
  }
}

class EPInfoView: EPBlock {
  let viewsIcon: UIImageView
  let viewsLabel: UILabel
  var views = -1 {
    didSet {
      guard views != oldValue else { return }
      viewsLabel.set(text: "\(views)")
    }
  }
  let currentIcon: UIImageView
  let currentLabel: UILabel
  var current = -1 {
    didSet {
      guard current != oldValue else { return }
      currentLabel.set(text: "\(current)")
    }
  }
  let commentsIcon: UIImageView
  let commentsLabel: UILabel
  var comments = -1 {
    didSet {
      guard comments != oldValue else { return }
      commentsLabel.set(text: "\(comments)")
    }
  }
  let photosIcon: UIImageView
  let photosLabel: UILabel
  var photos = -1 {
    didSet {
      guard photos != oldValue else { return }
      photosLabel.set(text: "\(photos)")
    }
  }
  let videosIcon: UIImageView
  let videosLabel: UILabel
  var videos = -1 {
    didSet {
      guard videos != oldValue else { return }
      videosLabel.set(text: "\(videos)")
    }
  }
  
  
  init(page: EventPreview) {
    
    let y: CGFloat = 15
    viewsIcon = UIImageView(pos: Pos(15,y), anchor: .left, image: #imageLiteral(resourceName: "EPViews"))
    viewsLabel = UILabel(pos: viewsIcon.frame.right + Pos(5,0), anchor: .left, text: "", color: .black, font: .normal(12))
    
    currentIcon = UIImageView(pos: viewsLabel.frame.right + Pos(5,0), anchor: .left, image: #imageLiteral(resourceName: "EPCurrent"))
    currentLabel = UILabel(pos: currentIcon.frame.right + Pos(5,0), anchor: .left, text: "", color: .black, font: .normal(12))
    
    commentsIcon = UIImageView(pos: currentLabel.frame.right + Pos(5,0), anchor: .left, image: #imageLiteral(resourceName: "EPComments"))
    commentsLabel = UILabel(pos: commentsIcon.frame.right + Pos(5,0), anchor: .left, text: "", color: .black, font: .normal(12))
    
    photosIcon = UIImageView(pos: commentsLabel.frame.right + Pos(5,0), anchor: .left, image: #imageLiteral(resourceName: "EPPhotos"))
    photosLabel = UILabel(pos: photosIcon.frame.right + Pos(5,0), anchor: .left, text: "", color: .black, font: .normal(12))
    
    videosIcon = UIImageView(pos: photosLabel.frame.right + Pos(5,0), anchor: .left, image: #imageLiteral(resourceName: "EPVideos"))
    videosLabel = UILabel(pos: videosIcon.frame.right + Pos(5,0), anchor: .left, text: "", color: .black, font: .normal(12))
    
    
    super.init(frame: CGRect(0,0,EventPreview.width,30), page: page)
    backgroundColor = UIColor(white: 0, alpha: 0.1)
    
    addSubview(viewsIcon)
    addSubview(viewsLabel)
    addSubview(currentIcon)
    addSubview(currentLabel)
    addSubview(commentsIcon)
    addSubview(commentsLabel)
    addSubview(photosIcon)
    addSubview(photosLabel)
    addSubview(videosIcon)
    addSubview(videosLabel)
    
    update()
  }
  
  func update() {
    views = event.views
    current = event.current
    comments = event.commentsCount
    photos = event.photos.count
    videos = event.videos.count
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
