//
//  PriorityQueue.swift
//  SomeNetwork
//
//  Created by Дмитрий Козлов on 2/2/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeData

public class StreamPriorityQueue: Queue, InternalQueue {
  
  public static var completed: ((StreamOperation, CompletionStatus, CompletionAction) -> ())?
  
  public var isEmpty: Bool { return operations.isEmpty && completedOperations.isEmpty }
  public var concurrent = 1
  public var count: Int {
    return operations.count + running.count
  }
  public var runningCount: Int {
    return running.count
  }
  var completedOperations = [CompletedOperation]()
  var operations = Set<StreamOperation>()
  var running = Set<StreamOperation>()
  var thread: DispatchQueue
  var isRunning = false
  var isEnabled = true
  var isPaused = false
  public var url: FileURL?
  let name: String
  public init(name: String, concurrent: Int) {
    self.name = name
    self.concurrent = concurrent
    thread = DispatchQueue(label: "some.network.queue.\(name)")
  }
  public func add(_ operation: StreamOperation) {
    guard isEnabled || operation is DataLoadable else { return }
    thread.async {
      self.operations.insert(operation)
      self.nextOperation()
    }
  }
  func next() -> StreamOperation? {
    guard !operations.isEmpty else { return nil }
    var selected: StreamOperation!
    for operation in operations {
      if let previous = selected {
        if operation._priority > previous._priority {
          selected = operation
        }
      } else {
        selected = operation
      }
    }
    assert(!operations.isEmpty)
    operations.remove(selected)
    running.insert(selected)
    return selected
  }
  
  func nextOperation() {
    guard !isPaused else { return }
    guard isEnabled else { return }
    guard running.count < concurrent else { return }
    while let operation = next() {
      if let operation = operation as? StreamOperations, operation.shouldSkip {
        complete(operation, .success, .next, "skipped")
        continue
      } else {
        operation.completed = self.completed
        operation.run()
        return
      }
    }
  }
  func completed(operation: StreamOperation, status: CompletionStatus, action: CompletionAction) {
    thread.async {
      StreamQueue.completed?(operation,status,action)
      self.running.remove(operation)
      switch action {
      case .next, .stop:
        if operation is DataRepresentable {
          self.save()
        }
        self.complete(operation, status, action, "")
        self.nextOperation()
      case .restart:
        self.operations.insert(operation)
        self.nextOperation()
      }
    }
  }
  
  public func disable() {
    thread.async {
      self._disable()
    }
  }
  private func _disable() {
    isEnabled = false
    guard !isPaused else { return }
    operations = self.operations.filter { $0 is DataLoadable }
    disconnect()
  }
  public func pause() {
    thread.async {
      self._pause()
    }
  }
  private func _pause() {
    guard !isPaused else { return }
    isPaused = true
    guard isEnabled else { return }
    disconnect()
  }
  public func resume() {
    thread.async {
      self._resume()
    }
  }
  private func _resume() {
    guard isPaused else { return }
    isPaused = false
    guard isEnabled else { return }
    for _ in 0..<concurrent {
      nextOperation()
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
    if data.isEmpty {
      url.delete()
    } else {
      data.encrypt(password: 0xe86f1891767acfb6)
      try? data.write(to: url)
    }
  }
  public func load() {
    guard let url = url else { return }
    guard let loadOperations = Stream.loadOperations else { return }
    guard let data = DataReader(url: url) else { return }
    data.decrypt(password: 0xe86f1891767acfb6)
    do {
      let operations = try loadOperations(data)
      guard !operations.isEmpty else { return }
      thread.async {
        for operation in operations {
          self.operations.insert(operation)
          operation._print("load()")
        }
        for _ in 0..<self.concurrent {
          self.nextOperation()
        }
      }
    } catch {
      
    }
  }
}
