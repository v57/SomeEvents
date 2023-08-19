//
//  debug.swift
//  faggot
//
//  Created by Димасик on 5/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//


/*
 d05600b437494864 a02992fbd95f9f0b - bluetooth: find friends
 683a7ead25074ac7 - ceo
 9b86fbe1d7770037 - accounts storage
 436906fcf5424ad4 - accounts.db
 b46c5f92427dd8e1 - push notifications
 995bf63afcd08216
 c04c82860f9d47dc - server auth key
 8cc435a5901045c1 - chat hash value
 b0598f9aebcaa718 - data hash
 72b7ae88462c45bd 82d2ca0c0a4f47f9
 e8e465d976824559 bc954147b823f4f4 f01cbdb3286f4df0 be95f4a6f9a62a87
 d49c1b426d424387 b3c6ba833c9a1147 e9e5dff51adc4db8 944047aaca679cf8
 823b065f2c2f44b3 902e3dc0b802e5db 03dd4970738f4283 8a7d1f484e45ded1
 8639252ba8024eb0 a49b18e399ee2a6c 4c7090825e3e45a0 9de430e116992443
 8493d0122382449a 9f98d5f5192c6626 3417349405684cda ae4f31d540df57fa
 9ce572ee4dc946b3 bd95cd7d88e15fb0 a9ee2284b810453f aab66b6b46cbcb55
 */

#if debug
  import Some
  import SomeNetwork

let screenEditor = ScreenEditor()
  
  // logs
  struct Debug {
    static func launch() {
//      UIColor.mainBackground = .white
      backgroundImage = nil
      
      settings.test.disableAutohideNotifications = true
      settings.test.alwaysDownloadImages = true
      settings.test.disableImageCache = true
      
      SomeSettings.debugFileURL = false
      SomeSettings.debugPages = false
      
      SomeSettings.stream.debugStream = true
      SomeSettings.stream.debugOperations = true
      SomeSettings.stream.debugQueue = true
      SomeSettings.stream.debugFileProgress = true
      SomeSettings.stream.debugSendRead = .none
      SomeSettings.stream.operationsHistory = 0
      settings.debug.request = true
      settings.debug.requestSending = true
      
      settings.debug.options = 0xffffffff
        settings.debug.options = 0
      
//      Settings.chatOfflineMode = true
      
      SomeSettings.debugCeo = false
      
      accounts.isEnabled = true
      
      print("""
        documents:
        \(FileURL.documents.path)

        """)
    }
    static func topLayer() {
//      main.view.addSubview(screenEditor)
      addServerMonitoring()
//      LicenseNotification.unique { $0.init().display() }
    }
  }
  
  func shake() {
    if !screenEditor.isHidden {
      screenEditor.reset()
    }
    screenEditor.isHidden = !screenEditor.isHidden
//    if 50%% {
//      let notification = TextNView(title: "Ты долбаеб")
//      notification.display()
//    } else {
//      let notification = FullNView(text: "Ты долбаеб")
//      notification.iconView.image = UIImage(named: "AppIcon")
//      notification.titleLabel.text = "Лох"
//      notification.display()
//    }
  }
  
  private func addMonitoring() {
//    monitoring.shows = true
  }
  
  private func addServerMonitoring() {
    serverDebug.isRunning = true
  }
  
  private func addCameraBackground() {
    main.mainView.insertSubview(cameraView, at: 1)
  }
  
  extension Accounts {
    func testProfile() {
      if let session = session {
        guard session.id != 0 && session.id != 1 else { return }
      }
//    if device == .ipad {
//      session = Session(id: 1, password: 1488, name: "Pussyri")
//    } else {
//      session = Session(id: 0, password: 1488, name: "LinO_dska")
//    }
      session = Session(id: 1, password: 12918729143833790001, name: "LinO_dska")
      account = Account(session: session!)
      User.me.publicOptions.insert(.avatar)
    }
  }
#endif

extension String {
  func error() {
    print(self)
    self.notification(title: "Error", emoji: "⚠️")
  }
  func error(title: String) {
    print("\(title): \(self)")
    self.notification(title: title, emoji: "⚠️")
  }
}

func print() {
  Swift.print()
}
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
  let output = items.map { "\($0)" }.joined(separator: separator)
  Swift.print(output, terminator: terminator)
}

func print(request items: Any) {
  guard settings.debug.request else { return }
  Swift.print("request:",items)
}

func print(accounts items: Any) {
  guard settings.debug.accounts else { return }
  Swift.print("accounts:",items)
}



enum TestOption: UInt8 {
  case alwaysDownloadImages
  case disableImageCache
  case disableAutohideNotifications
  case disableChatSending
}

enum DebugOption: UInt8 {
  case notifications
  case subscriptions
  
  case request
  case requestSending
  case requestSuccess
  case requestFailed
  
  case accounts
}

struct TestOptions {
  var options = TestOption.Set64()
  var alwaysDownloadImages: Bool {
    get { return options[.alwaysDownloadImages] }
    set { options[.alwaysDownloadImages] = newValue }
  }
  var disableImageCache: Bool {
    get { return options[.disableImageCache] }
    set { options[.disableImageCache] = newValue }
  }
  var disableAutohideNotifications: Bool {
    get { return options[.disableAutohideNotifications] }
    set { options[.disableAutohideNotifications] = newValue }
  }
  var disableChatSending: Bool {
    get { return options[.disableChatSending] }
    set { options[.disableChatSending] = newValue }
  }
}

struct DebugOptions {
  var options = DebugOption.Set64()
  var notifications: Bool {
    get { return options[.notifications] }
    set { options[.notifications] = newValue }
  }
  var subscriptions: Bool {
    get { return options[.subscriptions] }
    set { options[.subscriptions] = newValue }
  }
  var request: Bool {
    get { return options[.request] }
    set { options[.request] = newValue }
  }
  var requestSending: Bool {
    get { return options[.requestSending] }
    set { options[.requestSending] = newValue }
  }
  var requestSuccess: Bool {
    get { return options[.requestSuccess] }
    set { options[.requestSuccess] = newValue }
  }
  var requestFailed: Bool {
    get { return options[.requestFailed] }
    set { options[.requestFailed] = newValue }
  }
  var accounts: Bool {
    get { return options[.accounts] }
    set { options[.accounts] = newValue }
  }
}
