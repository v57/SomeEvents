//
//  Community.swift
//  Some Events
//
//  Created by Димасик on 9/14/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

private extension CGFloat {
  static var communityChat: CGFloat = 0
  static var news: CGFloat = 1
  static var about: CGFloat = 2
  static var titleX: CGFloat = .margin + 20
}

class CommunityPage: Page {
//  private let titleLabel: DPLabel
//  private let subtitleLabel: DPLabel
  private let scrollView: UIScrollView
  private let chatTitle = CommunityTitleView(title: "Community Chat", frame: titleFrame(for: .communityChat))
  private let newsTitle = CommunityTitleView(title: "News", frame: titleFrame(for: .news))
  
  let chatView: ChatView
  let newsChatView: ChatView
  
  override init() {
//    titleLabel = DPLabel(text: "Welcome to community", color: .black, font: .normal(32))
//    titleLabel.autoresizeFont()
//    titleLabel.maxSize = { Size(screen.width - 30, 0) }
//    titleLabel.dpos = { Pos(.titleX, 70).topLeft }
    
//    subtitleLabel = DPLabel(text: "This app exists only because of you", color: .black, font: .normal(22))
//    subtitleLabel.numberOfLines = 0
//    subtitleLabel.maxSize = { Size(screen.width - 30, 0) }
    
    scrollView = UIScrollView(frame: screen.frame)
    scrollView.contentSize.width = screen.width * 2
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.bounces = false
    
    chatView = ChatView(frame: subpageFrame(for: .communityChat))
    chatView.dframe = { subpageFrame(for: .communityChat) }
    
    newsChatView = ChatView(frame: subpageFrame(for: .news))
    newsChatView.dframe = { subpageFrame(for: .news) }
    newsChatView.gravity = .top
    newsChatView.inputType = .none
    
    super.init()
    
//    subtitleLabel.dpos = { [unowned self] in
//      return Pos(.titleX,self.titleLabel.frame.bottom.y + 6).topLeft
//    }
    
    addSubview(scrollView)
    
//    scrollView.addSubview(titleLabel)
//    scrollView.addSubview(subtitleLabel)
    scrollView.addSubview(chatTitle)
    scrollView.addSubview(newsTitle)
    scrollView.addSubview(chatView)
    scrollView.addSubview(newsChatView)
    
    chatView.set(chat: .community)
    newsChatView.set(chat: .news)
    chatView.input.textView.placeholder = "Feel free to ask something..."
  }
  
  override func resolutionChanged() {
    let page = scrollView.page
    scrollView.frame = screen.frame
    scrollView.contentSize.width = screen.width * 2
    scrollView.contentOffset.x = CGFloat(page) * screen.width
    chatTitle.frame = titleFrame(for: .communityChat)
    newsTitle.frame = titleFrame(for: .news)
//    chatView.frame = subpageFrame(for: .communityChat)
    super.resolutionChanged()
  }
  
  override func keyboardMoved() {
    chatView.keyboardMoved()
    newsChatView.keyboardMoved()
  }
  
  override func closed() {
    chatView.bye()
    newsChatView.bye()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private func titleFrame(for position: CGFloat) -> CGRect {
  return CGRect(screen.width * position + .margin, screen.top,screen.width - .margin2,CommunityTitleView.height)
}

private func subpageFrame(for position: CGFloat) -> CGRect {
  let y = screen.top+CommunityTitleView.height
  return CGRect(screen.width * position, y, screen.width, screen.height - y)
}

private class CommunityTitleView: UIView {
  static var height: CGFloat = UIFont.title1.lineHeight + 10
  let label: UILabel
  let line: UIView
  init(title: String, frame: CGRect) {
    label = UILabel(text: title, color: .black, font: .title1, maxWidth: frame.width)
    label.autoresizeFont()
    label.textAlignment = .center
    label.center.x = frame.size.center.x
    line = UIView(frame: CGRect(0, frame.height - screen.pixel, frame.width, screen.pixel))
    line.backgroundColor = .lightGray
    super.init(frame: frame)
    addSubview(label)
    addSubview(line)
  }
  
  override func resolutionChanged() {
    label.center.x = frame.size.center.x
    line.frame.w = frame.w
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NewsView: DFView {
  static var width: CGFloat = 282
  var news = [Post]()
  init() {
    super.init(frame: .zero)
    news.append(Post(title: "Community update", description: "We added community page where you can see all news, ask something in open chat or support this app by donating"))
    news.append(Post(title: "Notifications update", description: "We added more notifications. Now you can better interact with them. Swipe notifications to hide them. New settings allows you to hide some types of notifications"))
    news.append(Post(title: "iPad update", description: "New interface for iPad! Better experiense and more powerful controls of your event"))
    news.append(Post(title: "Feed update", description: "Now you can see your friends timeline.\nFriend events now appears on map."))
    news.append(Post(title: "Map update", description: "Added timeline.\nWanna go somewhere or wanna see whats happend in 20 september around the world? Just open map and set time to see events.\n\nAlso you can filter events on map"))
    news.append(Post(title: "Chat update", description: "Added chat so you can send messages to your friends. Also make group conversations.\nUpdated comments. You can send photos, coordinates, youtube videos, image urls"))
    set(news: news)
  }
  
  func set(news: [Post]) {
    self.news = news
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Post {
  var title: String
  var description: String
  init(title: String, description: String) {
    self.title = title
    self.description = description
  }
}

extension UIView {
  func addBackground(radius: CGFloat) {
    backgroundColor = .white(0.2)
    clipsToBounds = true
    layer.cornerRadius = radius
    layer.borderColor = UIColor.black(0.1).cgColor
    layer.borderWidth = 0.5
    layer.masksToBounds = false
    layer.shouldRasterize = true
    layer.rasterizationScale = screen.retina
  }
}

class PostView: UIView {
  let titleLabel: UILabel
  let descriptionLabel: UILabel
  init(post: Post, width: CGFloat) {
    titleLabel = UILabel(text: post.title, color: .black, font: .bold(18), maxWidth: width - 24, numberOfLines: 0)
    titleLabel.frame.origin = Pos(12,9)
    descriptionLabel = UILabel(text: post.description, color: .black, font: .normal(14), maxWidth: width - 24, numberOfLines: 0)
    descriptionLabel.frame.origin = titleLabel.frame.bottomLeft
    
    super.init(frame: CGRect(0,0,width,descriptionLabel.frame.bottom.y + 12))
    
    addSubview(titleLabel)
    addSubview(descriptionLabel)
    
    addBackground(radius: 17)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
