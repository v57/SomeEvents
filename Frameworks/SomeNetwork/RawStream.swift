//
//  StreamConnection.swift
//  Network
//
//  Created by Дмитрий Козлов on 9/19/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeFunctions

public enum StreamStatus {
  case disconnected, connecting, connected
}

private var streams = 0
class StreamConnection: NSObject, StreamDelegate {
  static var id = 0
  var id: Int
  private(set) var _input: InputStream?
  private(set) var _output: OutputStream?
  private var input: InputStream  { return _input! }
  private var output: OutputStream  { return _output! }
  var queue = DispatchQueue(label: "some.network.stream.\(Int.unique)")
  var onDisconnect: (()->())?
  var onConnect: (()->())?
  
  var response: Response?
  var streamStatus: Stream.Status {
    return input.streamStatus
  }
  var status = StreamStatus.disconnected
  
  var ip: String
  var port: Int
  
  init(ip: String, port: Int) {
    self.ip = ip
    self.port = port
    
    StreamConnection.id += 1
    id = StreamConnection.id
    
    super.init()
    
    streams += 1
    Swift.print("streams: \(streams)")
  }
  
  deinit {
    streams -= 1
    Swift.print("streams: \(streams)")
  }
  
  func process(_ path: KeyPath<Response, Bool>, _ value: Bool) {
    guard let response = response else { return }
    guard response[keyPath: path] else { return }
    self.response = nil
    response.completion(value)
  }
  
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    if eventCode.contains(.openCompleted) {
      print("connected")
      status = .connected
      onConnect?()
      process(\Response.onConnect, true)
    }
    if eventCode.contains(.hasSpaceAvailable) {
      print("ready to send")
      if let response = response, response.onSend {
        self.response = nil
        backgroundThread {
          response.completion(true)
        }
      }
//      process(\Response.onSend, true)
    }
    if eventCode.contains(.hasBytesAvailable) {
      print("ready to read")
      process(\Response.onRead, true)
    }
    if eventCode.contains(.errorOccurred) {
      print("disconnected by error")
      if status != .disconnected {
        status = .disconnected
        onDisconnect?()
      }
      process(\Response.onDisconnect, false)
    }
    if eventCode.contains(.endEncountered) {
      print("disconnected")
      if status != .disconnected {
        status = .disconnected
        onDisconnect?()
      }
      process(\Response.onDisconnect, false)
    }
  }
  
  func connect(completion: @escaping (Bool)->()) {
    switch status {
    case .connected:
      completion(true)
    case .connecting:
      response = Connect(completion: completion)
    case .disconnected:
      status = .connecting
      response = Connect(completion: completion)
      
      Stream.getStreamsToHost(withName: ip, port: port, inputStream: &_input, outputStream: &_output)
      
      input.delegate = self
      output.delegate = self
      
      input.schedule(in: .main, forMode: .defaultRunLoopMode)
      output.schedule(in: .main, forMode: .defaultRunLoopMode)
      
      input.open()
      output.open()
    }
  }
  
  func disconnect() {
    guard _input != nil && _output != nil else { return }
    input.close()
    output.close()
    onDisconnect?()
    status = .disconnected
  }
  
  func onSpaceAvailable(completion: @escaping (Bool)->()) {
    if output.hasSpaceAvailable {
      queue.async {
        completion(true)
      }
    } else {
      print("waiting for available space to send")
      response = Send(completion: completion)
    }
  }
  
  func onBytesAvailable(completion: @escaping (Bool)->()) {
    if input.hasBytesAvailable {
      queue.async {
        completion(true)
      }
    } else {
      print("waiting for read")
      response = Read(completion: completion)
    }
  }
  
  func send(stream: @escaping ()->(Data?), completion: @escaping (StreamResponse)->()) {
    onSpaceAvailable { [unowned self] success in
      guard success else {
        completion(.lostConnection)
        return
      }
      guard let data = stream() else {
        completion(.success)
        return
      }
      let count = data.count
      let sended = self.output.write(data: data, id: self.id)
      if sended == count {
        self.send(stream: stream, completion: completion)
      } else {
        self.disconnect()
        completion(.lostConnection)
      }
    }
  }
  
  func read(id: UInt16, stream: @escaping (Data)->(Bool), completion: @escaping (StreamResponse)->()) {
    onBytesAvailable { [unowned self] success in
      guard success else {
        completion(.lostConnection)
        return
      }
      
//      var data = Data(size: 8.kb)
//      let readed = self.input.read(data: &data)
      if let data = self.input.read() {
        switch SomeSettings.stream.debugSendRead {
        case .full:
          self.print("received \(data.count.bytesStringShort): \(data.hexString)")
        case .short:
          self.print("received \(data.count.bytesStringShort) bytes")
        case .none: break
        }
        let shouldContinue = stream(data)
        if shouldContinue {
          self.read(id: id, stream: stream, completion: completion)
        } else {
          completion(.success)
        }
      } else {
        self.disconnect()
        completion(.lostConnection)
      }
    }
  }
  
  func send(data: Data, completion: @escaping (StreamResponse)->()) {
    onSpaceAvailable { [unowned self] success in
      guard success else {
        completion(.lostConnection)
        self.print("lost connection on send")
        return
      }
      let count = data.count
      self.print("sending \(count) bytes")
      let sended = self.output.write(data: data, id: self.id)
      if sended == count {
        completion(.success)
      } else {
        self.disconnect()
        completion(.lostConnection)
      }
    }
  }
  
  func print(_ string: String) {
    guard SomeSettings.stream.debugStream else { return }
    Swift.print("stream \(id): \(string)")
  }
  
  func read(completion: @escaping (StreamDataResponse)->()) {
    onBytesAvailable { [unowned self] success in
      guard success else {
        completion(.lostConnection)
        return
      }
      var data = Data(size: 8192)
      let readed = self.input.read(data: &data)
      if readed > 0 {
        Swift.print("stream \(self.id) received \(readed) bytes (read)")
        data = data.subdata(in: 0..<readed)
        self.print("received \(readed) bytes: \(data.hexString)")
        completion(.success(data))
      } else {
        self.disconnect()
        completion(.lostConnection)
      }
    }
  }
}

extension Data {
  init(size: Int) {
    self.init(bytes: [UInt8](repeating: 0x0, count: size))
  }
}

extension InputStream {
  func read() -> Data? {
    var data = Data()
    var buffer = Data(size: 8.kb)
    while hasBytesAvailable {
      let count = read(data: &buffer)
      guard count > 0 else { return nil }
      data.append(buffer.subdata(in: 0..<count))
      if count == 0 {
        return nil
      } else {}
    }
    return data.isEmpty ? nil : data
  }
  func read(data: inout Data) -> Int {
    let count = data.count
    return data.withUnsafeMutableBytes { read($0, maxLength: count) }
  }
}

extension OutputStream {
  func write(data: Data, id: Int) -> Int {
    var c = _write(data: data)
    if SomeSettings.stream.debugStream {
      print("stream \(id): sended \(c)/\(data.count) bytes")
    }
    guard c > 0 else { return c }
    while c < data.count {
      let s = _write(data: data.subdata(in: c..<data.count))
      
      guard s > 0 else { return s }
      c += s
      if SomeSettings.stream.debugStream {
        print("stream \(id): sended \(c)/\(data.count) bytes")
      }
    }
    return c
  }
  private func _write(data: Data) -> Int {
    return data.withUnsafeBytes { write($0, maxLength: data.count) }
  }
}


extension StreamConnection {
  class Response {
    var completion: (Bool)->()
    var onRead: Bool { return false }
    var onSend: Bool { return false }
    var onConnect: Bool { return false }
    var onDisconnect: Bool { return false }
    init(completion: @escaping (Bool)->()) {
      self.completion = completion
    }
  }
  
  class Read: Response {
    override var onRead: Bool { return true }
    override var onDisconnect: Bool { return true }
  }
  class Send: Response {
    override var onSend: Bool { return true }
    override var onDisconnect: Bool { return true }
  }
  class Connect: Response {
    override var onConnect: Bool { return true }
    override var onDisconnect: Bool { return true }
  }
}
