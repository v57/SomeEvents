//
//  Connect.swift
//  Events
//
//  Created by Димасик on 2/14/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

extension StreamOperations {
  @discardableResult
  func connectOperation() -> Self {
    let request = ConnectRequest(stream: server)
    add(request)
    return self
  }
  @discardableResult
  func connectOperation(stream: SomeStream2) -> Self {
    let request = ConnectRequest(stream: stream)
    add(request)
    return self
  }
}

var someKeys = Keys(size: 1024)

private class ConnectRequest: Request {
  var options = ConnectionOptions.Set()
  var key: UInt64 = 0
  var keys: Keys!
  var stream: SomeStream2
  init(stream: SomeStream2) {
    self.stream = stream
    super.init(name: "connect")
    
    set(stream: stream)
    skipOn { stream.status == .connected }
    
    if stream == server {
      if session != nil {
        options.insert(.auth)
        #if debug
          options.insert(.debug)
        #endif
      }
      connecting()
      connect()
      listen()
      main()
      connected()
      easyLogin()
      sub()
    } else {
      options.insert(.auth)
      options.insert(.file)
      connect()
      main()
    }
  }
  
  private func main() {
    send { [unowned self] data in
      self.send(data: data)
    }
    read { [unowned self] data in
      if self.keys != nil {
        try self.response(rsa: data)
      } else {
        fatalError("under construction")
      }
    }
  }
  
  func send(data: DataWriter) {
    data.append(AppVersion.client)
    request(rsa: data)
  }
  
  func request(rsa data: DataWriter) {
    keys = someKeys//Keys(size: 1024)
    data.append(ConnectionSecurity.rsa2)
    data.append(keys.publicKey)
  }
  func response(rsa data: DataReader) throws {
    try data.response()
    var keyData: Data = try data.next()
    try keys.unlock(data: &keyData)
    if keyData.count == 8 {
      let key: UInt64 = keyData.convert()
      let index: Int64 = try data.next()
      serverManager.serverKey = ServerKey(index: index, key: key)
      stream.set(key: key)
    } else {
      fatalError("key size != 8 (\(keyData.count)")
    }
//    (lldb) po data.data.hexString
//    "00000000 0000ca80 003feb4f 13ad0c54 d71f8c4d 5d4cb214 49767d84 cf685121 059d9682 21700e33 b7dfec2f b0bfda50 2cfe921a 71a6f507 91af25b3 b85985a1 5a29fee6 c06619ba 0a59025c 7f9bee87 7fe1b702 d1de4279 1a9c33b0 78091235 3d4534d4 fd30ff4f 6d6aeb10 2ac06b6b b6696ae2 9980e5d6 c71db5a5 e86e5e68 9a77658b d629fa37 bd"
//
//    (lldb) po publicKey.hexString
//    "30818902 818100c3 6bb2560d 8b9dc273 ae335807 4783a0cf 6a82ac1e 3a3d3c35 e81d2c0f 00b6f786 962d5dd6 158bf5b7 c1884955 594a77d0 d8088d6c 2520c524 2e58d084 614593bf 55909c8c 5beb7e01 ac651394 f7f6de47 4fcdce9f 72d497a2 ded7c01b 6d2b09af 6733e481 5af8dc91 3ae985b9 dff48b20 ae0bc6c1 9d4a794a 0a26165d 8c2f7102 03010001 "
//
//    (lldb) po keyData.hexString
//    "3feb4f13 ad0c54d7 1f8c4d5d 4cb21449 767d84cf 68512105 9d968221 700e33b7 dfec2fb0 bfda502c fe921a71 a6f50791 af25b3b8 5985a15a 29fee6c0 6619ba0a 59025c7f 9bee877f e1b702d1 de42791a 9c33b078 0912353d 4534d4fd 30ff4f6d 6aeb102a c06b6bb6 696ae299 80e5d6c7 1db5a5e8 6e5e689a 77658bd6 29fa37bd "
  }
  
//  func send(fast data: DataWriter) {
//    let keys = someKeys//Keys(size: 1024)
//    keys.tag = "some".data
//    key = UInt64.random()
//    var keyData = Data(key)
//    keys.lock(data: &keyData)
//    
//    data.append(AppVersion.client)
//    data.append(keys.publicKey)
//    print("sending key \(key), size: \(keyData.count)")
//    data.append(keyData)
//    let c = data.count
//    
//    data.append(options)
//    if options.contains(.debug) {
//      data.append(usersManager.serverDatabaseVersion)
//    }
//    if options.contains(.auth) {
//      data.append(session!.id)
//      data.append(session!.password)
//    }
//    if options.contains(.file) {
//      
//    } else if options.contains(.auth) {
//      let me = User.me
//      data.append(cmd.auth)
//      data.append(session!.id)
//      data.append(session!.password)
//      data.append(me.isMainLoaded)
//      data.append(me.mainVersion)
//      data.append(me.publicProfileVersion)
//      data.append(account.privateProfileVersion)
//      
//      let subs = subscriber.subs.keys.filter { $0.isValid }
//      data.append(UInt8(subs.count))
//      for sub in subs {
//        data.append(sub)
//      }
//    }
//    data.encrypt(password: key, from: c)
//  }
  func read(data: DataReader) throws {
    try data.processProfile()
    server.loginned = true
    
    let count: Int = try data.intCount()
    for _ in 0..<count {
      let subscription: Subscription = try data.subscription()
      let response: Response = try data.next()
      if response == .ok {
        do {
          try subscription.subscribed(response: data)
          if settings.debug.subscriptions {
            subscription.description.notification(title: "Subscribed", emoji: "🖥")
          }
        } catch {
          "Cannot parse sub response for \(subscription)".error(title: "Subscription error")
        }
      } else {
        subscription.process(error: response)
        "Cannot subscribe to \(subscription). (\(response))".error(title: "Subscription error")
      }
    }
  }
  
  @discardableResult
  func connecting() -> StreamOperations {
    success {
      ConnectingNotification.current?.connecting()
      ConnectingNotification.unique { $0.init().display() }
    }
    return self
  }
  @discardableResult
  func connected() -> StreamOperations {
    success {
      notifications["Connecting"]?.hide(animated: true)
    }
    return self
  }
  
  func process(response: Response, data: DataReader) throws {
    switch response {
    case .wrongPassword:
      signup(name: session!.name)
    case .wrongDB:
      usersManager.serverDatabaseVersion = try data.next()
      signup(name: session!.name)
    default:
      throw response
    }
  }
}
