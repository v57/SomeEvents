//
//  AppDelegate.swift
//  faggot
//
//  Created by Димасик on 18/02/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

//
// launch
// setup
//
// firstLaunch
// newVersion
// newBuild
//
// bottomLayer
// topLayer
//
// preloading
// loading
// loaded
//

// TODO: better invitation menu
// TODO: favorite friends
// * TODO: remove download from queue on fail

// Camera
// TODO: fix camera orientation
// TODO: create video content on recording
// TODO: animated video recording button

// Event
// TODO: uploading content
// TODO: start video content timer in event page

// Content
// TODO: custom video player
// TODO: update content viewer

import Some

let main: Main! = Main()
class Main: SomeMain {
  var npages: [Page] {
    var array = [Page]()
    for page in pages {
      guard let page = page as? Page else { continue }
      array.append(page)
    }
    return array
  }
  /// Main thread
  
  let readonlyLayer = UIView(frame: Rect(0,0,0,0))
  
  override func topLayer() {
    view.addSubview(main.navigation.leftButton)
    #if debug
      Debug.topLayer()
    #endif
    view.addSubview(readonlyLayer)
  }
  
  /// Main thread
  /// update some UI before loading
  override func preloading() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTap))
    tap.numberOfTouchesRequired = 2
    view.addGestureRecognizer(tap)
    
    google.setup()
  }
  
  /// Background thread
  /// Load your data base or something
  override func loading() {
    ceo.start()
//    loginManager.testProfile()
    
//    let removeMeLater = false
//    if let data = loginManager.db!.documentsURL.reader {
//      try? loginManager.load(data: data)
//    }
    
    if let session = session {
      if account == nil {
        account = Account(session: session)
      }
      login()
    }
  }
  
  /// Main thread
  /// if account.valid { shows(ProfilePage()) } else { shows(StartPage()) }
  override func loaded() {
    navigation.effect = UIBlurEffect(style: .light)
    ceo.isLoaded = true
    main.lock {
      show(StartPage())
    }
  }
  
  func login() {
    ceo.login()
  }
  func logout() {
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    ceo.memoryWarning()
  }
  
  #if debug
  override var canBecomeFirstResponder: Bool {
    return true
  }
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      shake()
    }
  }
  #endif
  
  @objc func twoFingerTap() {
//    monitoring.hide()
//    animate {
//      monitoring.shows = !monitoring.shows
//    }
  }
  
  weak var keyboardSubscriber: KeyboardSubscriber?
  override func keyboardMoved() {
    super.keyboardMoved()
    keyboardSubscriber?.keyboardMoved()
  }
  
  var firstPage: Page {
    return SomePage.first as! Page
  }
  
  func alert(title: String? = nil, message: String? = nil) {
    let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
    vc.add("Ok", action: nil)
    present(vc, animated: true, completion: nil)
  }
  
  open func alert(error: Error) {
    alert(title: error.localizedDescription, message: nil)
  }
}
protocol KeyboardSubscriber: class {
  func keyboardMoved()
}

class Page: SomePage {
  static var current: Page? { return main.currentPage as? Page }
  var theme = Theme.dark
  let _notifications = ServerNotifictaions()
  var notifications: ServerNotifictaions {
    if !Thread.current.isMainThread {
      mainThread {
        main.alert(title: "Some error", message: "calling notifications from other thread")
      }
    }
    return _notifications
  }
}

@UIApplicationMain
class Faggot: SomeApp {
  override func setup() {
    
    #if debug
      Debug.launch()
    #endif
    
    SomeMain.default = { main }
    SomeCeo.default = { ceo }
    SomeAppNotifications.default = { AppNotifications() }
    
    SomePage.test = { testPage }
    
    saveOnDidEnterBackground = true
    
    createDirectories()
    
    backgroundImage = UIImage(named: "Background")
    
    SomeSettings.photoAlbumName = "Events"
    SomeSettings.showsNavigationBar = false
    SomeSettings.statusBarWhite = false
    SomeSettings.showsStatusBar = true
    SomeSettings.lowPowerMode.disableAnimations = false
    
    UIColor.mainBackground = .white
    UIColor.background = .lightGray // custom(0x000fff, alpha: 0.2)
    UIColor.dark = .black
    UIColor.navigationBackground = .clear
  }
}

class AppNotifications: SomeAppNotifications {
  override func opened(remote notification: PushNotification) throws {
    pushManager.insert(push: notification.userInfo)
  }
  override func registered() {
    pushManager.set(token: token!)
  }
  override func registerFailed(error: Error) {
    print("push error: \(error)")
  }
}
