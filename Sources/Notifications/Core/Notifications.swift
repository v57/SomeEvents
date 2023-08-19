//
//  Notifications.swift
//  SomeEvents
//
//  Created by Димасик on 12/5/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

//enum NViewStyle {
//  case full(UIView,String,String)
//  case title(String)
//  case loader(String)
//}

/*
 let a =
 """
 NTAdd@3x.png    NTDate@3x.png    NTPlay@3x.png
 NTAlarm@3x.png    NTFavorite@3x.png  NTProhibit@3x.png
 NTAudio@3x.png    NTHome@3x.png    NTSearch@3x.png
 NTBookmark@3x.png  NTInvitation@3x.png  NTShare@3x.png
 NTCapturePhoto@3x.png  NTLocation@3x.png  NTShuffle@3x.png
 NTCaptureVideo@3x.png  NTLove@3x.png    NTTask@3x.png
 NTCloud@3x.png    NTMail@3x.png    NTTaskCompleted@3x.png
 NTCompose@3x.png  NTMarkLocation@3x.png  NTTime@3x.png
 NTConfirmation@3x.png  NTMessage@3x.png  NTUpdate@3x.png
 NTContact@3x.png  NTPause@3x.png
 """
 var words = [String]()
 a.lines.forEach { words.append(contentsOf: $0.words) }
 words = words.flatMap {
 var cleaned = $0.cleaned
 cleaned.remove(prefix: "NT")
 cleaned.remove(suffix: "@3x.png")
 return cleaned.isEmpty ? nil : cleaned
 }
 */

/* pretty
print("enum NotificationIcons {")
for string in words {
  print("case \(string.prefix(1).lowercased() + string.dropFirst())")
}
print("""
 var icon: UIImage {
 switch self {
 """)
for string in words {
  print("""
    case .\(string.prefix(1).lowercased() + string.dropFirst()):
    return #imageLiteral(resourceName: "NT\(string)")
    """)
}
print("""
 }
 }
 """)
 */

/* weird
var result = ""
result += "enum NotificationIcons{"
result += "case \(words.first!.prefix(1).lowercased() + words.first!.dropFirst())"
for string in words.dropFirst() {
  result += ",\(string.prefix(1).lowercased() + string.dropFirst())"
}
result += ";var icon:UIImage{switch self{"
for string in words {
  result += "case .\(string.prefix(1).lowercased() + string.dropFirst()):return #imageLiteral(resourceName: \"NT\(string)\");"
}
result += "}}"
print(result)
*/

enum NotificationIcons{case add,date,play,alarm,favorite,prohibit,audio,home,search,bookmark,invitation,share,capturePhoto,location,shuffle,captureVideo,love,task,cloud,mail,taskCompleted,compose,markLocation,time,confirmation,message,update,contact,pause;var image: UIImage{switch self{case .add:return #imageLiteral(resourceName: "NTAdd");case .date:return #imageLiteral(resourceName: "NTDate");case .play:return #imageLiteral(resourceName: "NTPlay");case .alarm:return #imageLiteral(resourceName: "NTAlarm");case .favorite:return #imageLiteral(resourceName: "NTFavorite");case .prohibit:return #imageLiteral(resourceName: "NTProhibit");case .audio:return #imageLiteral(resourceName: "NTAudio");case .home:return #imageLiteral(resourceName: "NTHome");case .search:return #imageLiteral(resourceName: "NTSearch");case .bookmark:return #imageLiteral(resourceName: "NTBookmark");case .invitation:return #imageLiteral(resourceName: "NTInvitation");case .share:return #imageLiteral(resourceName: "NTShare");case .capturePhoto:return #imageLiteral(resourceName: "NTCapturePhoto");case .location:return #imageLiteral(resourceName: "NTLocation");case .shuffle:return #imageLiteral(resourceName: "NTShuffle");case .captureVideo:return #imageLiteral(resourceName: "NTCaptureVideo");case .love:return #imageLiteral(resourceName: "NTLove");case .task:return #imageLiteral(resourceName: "NTTask");case .cloud:return #imageLiteral(resourceName: "NTCloud");case .mail:return #imageLiteral(resourceName: "NTMail");case .taskCompleted:return #imageLiteral(resourceName: "NTTaskCompleted");case .compose:return #imageLiteral(resourceName: "NTCompose");case .markLocation:return #imageLiteral(resourceName: "NTMarkLocation");case .time:return #imageLiteral(resourceName: "NTTime");case .confirmation:return #imageLiteral(resourceName: "NTConfirmation");case .message:return #imageLiteral(resourceName: "NTMessage");case .update:return #imageLiteral(resourceName: "NTUpdate");case .contact:return #imageLiteral(resourceName: "NTContact");case .pause:return #imageLiteral(resourceName: "NTPause");}}}

enum ntf {
  case text(String)
  case eventDownload(Export)
  case view(NView)
  case upload(Content, UploadRequest)
  case connecting
  func display() {
    mainThread {
      Notifications.shared.send(self)
    }
  }
}

let notifications = Notifications.shared
class Notifications {
  static let shared = Notifications()
  var notifications = [String: NView]()
  static var top: CGFloat { return screen.top + 10 }
  static var offset: CGFloat { return 10 }
  var cells = [NView]()
  
  subscript(key: String) -> NView? {
    get { return notifications[key] }
    set { notifications[key] = newValue }
  }
  func unique(key: String, block: ()->()) {
    if notifications[key] == nil {
      block()
    }
  }
  func remove(key: String, animated: Bool) {
    guard let notification = notifications[key] else { return }
    notification.hide(animated: animated)
  }
  func replace(key: String, with view: NView, animated: Bool) {
    if let notification = notifications[key] {
      notification.hide(animated: animated)
    }
    view.display(animated: animated)
  }
  
  func send(_ type: ntf) {
//    switch type {
//    case .eventDownload(let progress):
//      NEventDownload(progress: progress)
//      .display(animated: true)
//    case .text(let text):
//      let view = TextNView(title: text)
//      view.display(animated: true)
//      view.autohide = true
//    case .view(let view):
//      view.display(animated: true)
//    case .upload(let content, let upload):
//      NContentUpload.unique(execute: { (t) in
//        t(content: content, upload: upload)
//      })
//    }
  }
}

protocol UniqueNotification {
  static var key: String { get }
  func updated()
}

extension UniqueNotification {
  static var current: Self? {
    return notifications[key] as? Self
  }
  static func unique(execute: (Self.Type)->()) {
    if let notification = notifications[key] {
      (notification as? Self)?.updated()
    } else {
      execute(Self.self)
    }
  }
  static func hide(animated: Bool) {
    notifications[key]?.hide(animated: animated)
  }
  func updated() {
    
  }
}

func sendNotification<T>(_ type: T.Type, _ body: (T)->()) {
  guard account != nil else { return }
  main.pages
    .compactMap { $0 as? T }
    .forEach(body)
}

extension String {
  func notification() {
    let view = TextNView(title: self)
    view.display(animated: true)
    view.autohide = true
    main.view.addSubview(view)
  }
  func notification(title: String, icon: NotificationIcons) {
    let view = FullNView(text: self)
    view.titleLabel.text = title
    view.iconView.image = icon.image
    view.display(animated: true)
    view.autohide = !settings.test.disableAutohideNotifications
    main.view.addSubview(view)
  }
  func notification(title: String, emoji: String) {
    let view = FullNView(text: self)
    view.titleLabel.text = title
    view.iconView.image = emoji.image(font: .normal(20))
    view.display(animated: true)
    view.autohide = !settings.test.disableAutohideNotifications
    main.view.addSubview(view)
  }
  func notification(title: String, image: UIImage? = nil) {
    let view = FullNView(text: self)
    view.titleLabel.text = title
    if let image = image {
      view.iconView.image = image
    }
    view.display(animated: true)
    view.autohide = !settings.test.disableAutohideNotifications
    main.view.addSubview(view)
  }
  func notification(progress: ProgressProtocol) {
    let view = LoadingNView(progress: progress, title: self)
    view.display(animated: true)
    main.view.addSubview(view)
  }
}
