//
//  stream.swift
//  Network
//
//  Created by Дмитрий Козлов on 9/19/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Foundation

public enum StreamError: Error {
  case lostConnection
}

open class SomeStream {
  public var queue: DispatchQueue {
    get { return stream.queue }
    set { stream.queue = newValue }
  }
  var stream: StreamConnection
  public var status: StreamStatus { return stream.status }
  public var ip: String {
    set {
      stream.ip = newValue
    } get {
      return stream.ip
    }
  }
  public var port: Int {
    set {
      stream.port = newValue
    } get {
      return stream.port
    }
  }
  
  public init(ip: String, port: Int) {
    stream = StreamConnection(ip: ip, port: port)
    stream.onDisconnect = { [weak self] in
      self?.disconnected()
    }
    stream.onConnect = { [weak self] in
      self?.connected()
    }
  }
  
  open func request() -> StreamOperations {
    return StreamOperations()
      .set(stream: self)
      .connect()
  }
  
  func connect(completion: @escaping (Bool)->()) {
    stream.connect(completion: completion)
  }
  public func disconnect() {
    stream.disconnect()
  }
  func send(data: Data, completion: @escaping (StreamResponse)->()) {
    stream.send(data: data, completion: completion)
  }
  func read(completion: @escaping (StreamDataResponse)->()) {
    stream.read(completion: completion)
  }
  func send(stream: @escaping ()->(Data?), completion: @escaping (StreamResponse)->()) {
    self.stream.send(stream: stream, completion: completion)
  }
  func read(id: UInt16, stream: @escaping (Data)->(Bool), completion: @escaping (StreamResponse)->()) {
    self.stream.read(id: id, stream: stream, completion: completion)
  }
  open func connected() {
    
  }
  open func disconnected() {
    
  }
}


enum StreamDataResponse {
  case success(Data), lostConnection
}

enum StreamResponse {
  case success, lostConnection
}

extension SomeStream: Equatable {
  public static func ==(lhs: SomeStream, rhs: SomeStream) -> Bool {
    return lhs === rhs
  }
}

extension SomeStream: Hashable {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
}
