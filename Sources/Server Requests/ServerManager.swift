//
//  ServerManager.swift
//  faggot
//
//  Created by Димасик on 14/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeNetwork
import SomeBridge

let server = Server(ip: address.ip, port: address.port)
var mainQueue = StreamQueue(name: "main")
var downloadQueue = StreamPriorityQueue(name: "download", concurrent: 15)
extension StreamQueue {
  static var upload = StreamQueue(name: "upload")
  static var previewUpload = StreamQueue(name: "uploadPreview")
}

func recursive<T>(_ value: T, _ path: KeyPath<T,T?>) -> T? {
  var v: T?
  while let parent = value[keyPath: path] {
    v = parent
  }
  return v
}
extension StreamOperation {
  var readableName: String {
    var operation: StreamOperation = self
    while let parent = operation.parent {
      operation = parent
    }
    return parent?.name ?? name
  }
}

class ServerKey: DataRepresentable {
  var index: Int64
  var key: UInt64
  var isOutdated = false
  init(index: Int64, key: UInt64) {
    self.index = index
    self.key = key
  }
  required init(data: DataReader) throws {
    index = try data.next()
    key = try data.next()
  }
  func save(data: DataWriter) {
    data.append(index)
    data.append(key)
  }
}

let serverManager = ServerManager()
class ServerManager: Manager, Saveable {
  var operations = [RequestType: SaveableRequest.Type]()
  var uploads = [FileURL: UploadRequest]()
  var downloads = [FileURL: DownloadRequest]()
  var notifications = [String]()
  
  var serverKey: ServerKey?
  
  func start() {
    NotificationCenter.default.addObserver(self, selector: #selector(networkChanged), name: NSNotification.Name(rawValue: "com.apple.system.config.network_change"), object: nil)
    RequestType.fill(operations: &operations)
    mainQueue.url = "sma.db".documentsURL
    StreamQueue.upload.url = "smb.db".documentsURL
    StreamQueue.previewUpload.url = "smc.db".documentsURL
    Stream.loadOperations = loadOperations
    Queue.completed = operationCompleted(operation:status:action:)
    StreamOperations.lostConnection = lostConnection
    SomeStream2.defaultKey = 0xc61b44fc24ebfd2c
  }
  
  func operationCompleted(operation: StreamOperation, status: CompletionStatus, action: CompletionAction) {
    #if debug
    switch status {
    case .success:
      return
    case .failed(error: let error):
      mainThread {
        if let error = error {
          self.process(error: error, operation: operation)
        }
      }
    case .lostConnection:
      return
    }
    #endif
  }
  
  func process(error: Error, operation: StreamOperation) {
    if let error = error as? Response {
      if error == Response.requestCorrupted {
        self.requestCorrupted(name: operation.readableName)
      } else {
        self.requestError(name: operation.readableName, error: error)
      }
    } else if error is DataError {
      self.responseCorrupted(name: operation.readableName)
    }
  }
  
  func requestCorrupted(name: String) {
    #if debug
      "request corrupted".notification(title: name, emoji: "⚠️")
    #endif
  }
  func requestError(name: String, error: Response) {
    #if debug
      "request failed: \(error)".notification(title: name, emoji: "⚠️")
    #endif
  }
  func responseCorrupted(name: String) {
    #if debug
      "response corrupted".notification(title: name, emoji: "⚠️")
      
    #endif
  }
  func notificationCorrupted(name: String) {
    #if debug
      "notification corrupted".notification(title: name, emoji: "⚠️")
    #endif
  }
  
  func loadOperations(data: DataReader) throws -> [StreamOperation] {
    var operations = [StreamOperation]()
    while data.position < data.count {
      let type: RequestType = try data.next()
      if let operation = try self.operations[type]?.init(data: data) {
        operations.append(operation as! StreamOperation)
      } else {
        throw corrupted
      }
    }
    return operations
  }
  func pause() {
    mainQueue.pause()
    downloadQueue.pause()
    StreamQueue.upload.pause()
    StreamQueue.previewUpload.pause()
    server.disconnect()
  }
  func resume(){
    mainQueue.resume()
    downloadQueue.resume()
    StreamQueue.upload.resume()
    StreamQueue.previewUpload.resume()
    server.connect()
  }
  func lostConnection() {
    mainThread {
      ConnectingNotification.current?.connectionFailed(wait: .retryTime)
    }
  }
  @objc func networkChanged() {
    server.disconnect()
  }
  func save(data: DataWriter) throws {
    mainQueue.save()
    downloadQueue.save()
    StreamQueue.upload.save()
    StreamQueue.previewUpload.save()
    
    if let key = serverKey, !key.isOutdated {
      data.append(true)
      data.append(key)
    } else {
      data.append(false)
    }
  }
  func load(data: DataReader) throws {
    mainQueue.load()
    downloadQueue.load()
    StreamQueue.upload.load()
    StreamQueue.previewUpload.load()
    
    print("server: loaded \(mainQueue.count) operations to main queue")
    print("server: loaded \(downloadQueue.count) operations to download queue")
    print("server: loaded \(StreamQueue.upload.count) operations to upload queue")
    print("server: loaded \(StreamQueue.previewUpload.count) operations to preview upload queue")
    
    serverKey = try data.next()
  }
  func close() {}
  func login() {
    guard !server.loginned else { return }
    server.connect()
//    newThread {
//      while true {
//        sleep(1)
//        network.printTree()
//      }
//    }
  }
}

extension StreamOperations {
  @discardableResult
  func request(_ command: cmd) -> Self {
    request { data in
      data.append(command)
    }
    return self
  }
  @discardableResult
  func signup(name: String) -> Self {
    rename("signup")
    request { data in
      data.append(cmd.signup)
      data.append(name)
    }
    read { data in
      try data.response()
      let id: Int64 = try data.next()
      let password: UInt64 = try data.next()
      
      let session = Session(id: id, password: password, name: name)
      print("signup completed. \(session)")
      accounts.set(newSession: session)
      
      server.loginned = true
    }
    return self
  }
  @discardableResult
  func autorepeat(_ page: Page?) -> Self {
    guard let page = page else { return self }
    autorepeat { [weak page] in
      return !(page?.isClosed ?? true)
    }
    return self
  }
  
  @discardableResult
  func resume() -> StreamOperations {
    DispatchQueue.main.async {
      mainQueue.add(self)
    }
    return self
  }
}

extension Page {
  func request() -> Request {
    let operations = server.request()
      .autorepeat(self)
    return operations
  }
}

class Server: SomeStream2 {
  var loginned = false
  open override func request() -> Request {
    let operations = Request()
      .set(stream: self)
      .connectOperation()
    DispatchQueue.main.async {
      mainQueue.add(operations)
    }
    return operations
  }
//  @discardableResult
//  func connectOperation() -> StreamOperations {
//    var a: UInt64 = 0
//    let operations = StreamOperations(name: "connect")
//      .skipOn { self.status == .connected }
//      .set(stream: self)
//      .connecting()
//      .connect()
//      .success {
//        self.set(key: 0xc61b44fc24ebfd2c)
//      }
//      .send { data in
//        data.append(AppVersion.client)
//        data.append(ConnectionSecurity.unsecured)
//        data.append(cmd.notification)
//      }
//      .read { data in
//        let q: UInt64 = try data.next()
//        AppVersion.server = try data.next()
//        AppVersion.minimum = try data.next()
//
//        a = UInt64.seed(skey, q)
//
//        if AppVersion.isOutdated {
//          AppVersion.outdated()
//          return
//        }
//
//        self.set(key: a &+ 0x65b6a144cc404b04)
//      }
//      .with(name: "question")
//      .send { data in
//        data.append(a)
//      }
//      .with(name: "answer")
//      .easyLogin()
//      .sub()
//      .connected()
//      .listen()
//    return operations
//  }
  func connect() {
    guard status == .disconnected else { return }
    request()
      .weakOverride()
      .autorepeat()
      .rename("connect()")
      .connectOperation()
  }
  override func connected() {
    if settings.debug.requestSuccess {
      print("main: connected")
    }
  }
  override func disconnected() {
    loginned = false
    if settings.debug.requestSending {
      print("main: disconnected")
    }
  }
  
  override func notification(type: UInt8, data: DataReader) throws {
    guard let command = subcmd(rawValue: type) else { return }
    mainThread {
      try? self.notification(command: command, data: data)
    }
  }
}


