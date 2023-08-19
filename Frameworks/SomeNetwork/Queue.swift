//
//  Queue.swift
//  StreamNetwork
//
//  Created by Дмитрий Козлов on 9/26/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData

public enum CompletionStatus {
  case success, failed(error: Error?), lostConnection
}

public enum CompletionAction {
  case next, stop, restart
}

extension Time {
  public static var retryTime: Time = 5
}

private func print(_ item: String) {
  guard SomeSettings.stream.debugQueue else { return }
  Swift.print(item)
}

public class StreamQueue {
  public static var completed: ((StreamOperation, CompletionStatus, CompletionAction)->())?
  var completedOperations = [CompletedOperation]()
  var operations = [StreamOperation]()
  var thread: DispatchQueue
  var isRunning = false
  var isEnabled = true
  var isPaused = false
  public var isEmpty: Bool {
    var a = false
    thread.sync {
      a = operations.isEmpty
    }
    return a
  }
  public var count: Int {
    return operations.count
  }
  public var url: FileURL?
  var name: String
  public init(name: String) {
    self.name = name
    thread = DispatchQueue(label: "some.network.queue.\(name)")
  }
  public func add(_ operation: StreamOperation) {
    guard isEnabled || operation is DataLoadable else { return }
    
    thread.async {
      if let op = operation as? StreamOperations {
        switch op.overrideMode {
        case .weak:
          if self.contains(operations: op.name) {
            return
          }
        case .strong:
          self._remove(operations: op.name)
        case .none:
          break
        }
      }
      
      self.operations.append(operation)
      print("\(self.name).add(\(operation.name))")
      self.nextOperation()
    }
  }
  public func remove(operations name: String) {
    thread.async {
      self._remove(operations: name)
    }
  }
  private func contains(operations name: String) -> Bool {
    for o in self.operations {
      guard let o = o as? StreamOperations else { continue }
      guard o.name == name else { continue }
      return true
    }
    return false
  }
  private func _remove(operations name: String) {
    var ids = [Int]()
    for (i,o) in self.operations.enumerated() {
      guard let o = o as? StreamOperations else { continue }
      guard o.name == name else { continue }
      ids.append(i-ids.count)
    }
    for id in ids {
      if self.isRunning && id == 0 { continue }
      self.operations.remove(at: id)
    }
  }
  private func nextOperation() {
    guard isEnabled else { return }
    guard !isRunning else { return }
    guard !isPaused else { return }
    while let operation = operations.first {
      if let operation = operation as? StreamOperations, operation.shouldSkip {
        removeFirst(.success, .next, "skipped")
        continue
      } else {
        isRunning = true
        print("\(name).running()")
        operation.completed = self.completed
        operation._print("run()",name)
        operation.run()
        return
      }
    }
  }
  func completed(operation: StreamOperation, status: CompletionStatus, action: CompletionAction) {
    thread.async {
      StreamQueue.completed?(operation,status,action)
      self.isRunning = false
      switch action {
      case .next, .stop:
        self.removeFirst(status, action, "")
        if operation is DataRepresentable {
          self.save()
        }
        self.nextOperation()
      case .restart:
        self.nextOperation()
      }
    }
  }
  
  func removeFirst(_ s: CompletionStatus, _ a: CompletionAction, _ c: String) {
    let o = operations.removeFirst()
    complete(o,s,a,c)
    if operations.isEmpty {
      print("main: idle")
    }
  }
  
  public func disable() {
    thread.async {
      self.isEnabled = false
      guard !self.isPaused else { return }
      self.disconnect()
      self.operations = self.operations.filter { $0 is DataLoadable }
    }
  }
  public func pause() {
    thread.async {
      guard !self.isPaused else { return }
      self.isPaused = true
      guard self.isEnabled else { return }
      self.disconnect()
    }
  }
  public func resume() {
    thread.async {
      guard self.isPaused else { return }
      self.isPaused = false
      guard self.isEnabled else { return }
      self.nextOperation()
    }
  }
  
  private func disconnect() {
    var streams = Set<SomeStream>()
    for operation in self.operations {
      if let stream = operation.stream {
        streams.insert(stream)
      }
    }
    for stream in streams {
      stream.disconnect()
    }
  }
  public func save() {
    guard let url = url else { return }
    let data = DataWriter()
    for operation in operations {
      if let binary = operation as? DataRepresentable {
        binary.save(data: data)
        operation._print("save()")
      }
    }
    data.encrypt(password: 0xe26f1a8a31b7089e)
    try? data.write(to: url)
  }
  public func load() {
    guard let url = url else { return }
    guard let data = DataReader(url: url) else { return }
    data.decrypt(password: 0xe26f1a8a31b7089e)
    guard let loadOperations = Stream.loadOperations else { return }
    do {
      let operations = try loadOperations(data)
      guard !operations.isEmpty else { return }
      thread.async {
        for operation in operations {
          self.operations.append(operation)
          operation._print("load()")
        }
        self.nextOperation()
      }
    } catch {
      
    }
  }
}

public protocol Queue {
  static var completed: ((StreamOperation, CompletionStatus, CompletionAction) -> ())? { get set }
  var isEmpty: Bool { get }
  var url: FileURL? { get set }
  
  func add(_ operation: StreamOperation)
  func disable()
  func pause()
  func resume()
  func save()
  func load()
}
protocol InternalQueue {
  var name: String { get }
  var completedOperations: [SomeNetwork.CompletedOperation] { get set }
  var thread: DispatchQueue { get set }
  var isRunning: Bool { get set }
  var isEnabled: Bool { get set }
  var isPaused: Bool { get set }
  
  func completed(operation: StreamOperation, status: CompletionStatus, action: CompletionAction)
}

extension Stream {
  static let thread = DispatchQueue(label: "some.network.stream")
  public static var loadOperations: ((DataReader)throws->[StreamOperation])?
}

extension StreamOperation: Equatable {
  public static func ==(lhs: StreamOperation, rhs: StreamOperation) -> Bool {
    return lhs === rhs
  }
}
extension StreamOperation: Hashable {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
}
