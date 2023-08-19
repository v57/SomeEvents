//
//  SomeStream.swift
//  Network
//
//  Created by Дмитрий Козлов on 9/20/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData

open class SomeStream2: SomeStream {
  public static var defaultKey: UInt64 = 0
  
  // encryption
  private var isListening = false
  private var key: UInt64 = defaultKey
  public var buffer = DataReader()
  public var responses = [DataReader]()
  private var responseWaiters = [(SomeReadOperation.Response)->()]()
  
  let locker = NSLock()
  func set(response: DataReader) {
    locker.lock()
//    print("stream \(stream.id): response received")
    if !responseWaiters.isEmpty {
      let waiter = responseWaiters.removeFirst()
      locker.unlock()
      waiter(.success(response))
    } else {
      responses.append(response)
      locker.unlock()
    }
  }
  func onResponse(response: @escaping (SomeReadOperation.Response)->()) {
    locker.lock()
    if responses.isEmpty {
      responseWaiters.append(response)
      locker.unlock()
    } else {
      let data = responses.removeFirst()
      locker.unlock()
      response(.success(data))
    }
  }
  
  public func set(key: UInt64) {
    self.key = key
  }
  
  open func notification(type: UInt8, data: DataReader) throws {
    
  }
  override func connect(completion: @escaping (Bool) -> ()) {
    set(key: SomeStream2.defaultKey)
    super.connect(completion: completion)
  }
  
  final
  func encrypt(data: DataWriter) {
//    print("encrypting:", data.data.hexString)
    data.encrypt(password: key)
//    print("encrypted:", data.data.hexString)
    data.replace(at: 0, with: Data(UInt32(data.count)))
  }
  
  final
  func decrypt(data: DataReader) {
//    print("decrypting:", data.bytes.hexString)
    data.decrypt(password: key, offset: 4)
//    print("decrypted:", data.data.hexString)
  }
  func readPackage(completion: @escaping (SomeReadOperation.Response)->()) {
    if isListening {
      onResponse(response: completion)
    } else {
      read(id: .random(), stream: { [unowned self] data in
        do {
          if let package = try self.append(buffer: data) {
            completion(.success(package))
            return false
          }
          return true
        } catch {
          self.disconnect()
          completion(.lostConnection)
          return false
        }
      }) { (response) in
        switch response {
        case .success:
          break
        case .lostConnection:
          completion(.lostConnection)
        }
      }
    }
  }
  func listen() {
    isListening = true
    read(id: .random(), stream: { [unowned self] data in
      do {
        if let package = try self.append(buffer: data) {
          self.set(response: package)
        }
        return true
      } catch {
        return false
      }
    }) { (response) in
      self.isListening = false
      switch response {
      case .success:
        self.disconnect()
      case .lostConnection:
        break
      }
      let waiters = self.responseWaiters
      self.responseWaiters.removeAll()
      for waiter in waiters {
        waiter(.lostConnection)
      }
    }
  }
  override func read(id: UInt16, stream: @escaping (Data) -> (Bool), completion: @escaping (StreamResponse) -> ()) {
    var shouldContinue = true
    if buffer.position < buffer.count {
      let bufferData = buffer.data[buffer.position..<buffer.count]
      shouldContinue = stream(bufferData)
    }
    if shouldContinue {
      super.read(id: id, stream: stream, completion: completion)
    } else {
      completion(.success)
    }
  }
  func append(buffer data: Data) throws -> DataReader? {
    buffer.data.append(contentsOf: data)
//    print("current buffer: \(buffer.data[buffer.position...].hexString)")
    do {
      while let package = try buffer.package() {
        decrypt(data: package)
        let type: UInt8 = try! package.next()
        if type == 0 {
          printSendRead(prefix: "received response", data: package.data)
          return package
        } else {
          printSendRead(prefix: "received notification", data: package.data)
          try? notification(type: type, data: package)
        }
      }
    } catch {
//      print("data.package() corrupted")
      throw error
    }
    return nil
  }
}
