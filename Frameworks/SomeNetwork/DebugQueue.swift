//
//  DebugQueue.swift
//  StreamNetwork
//
//  Created by Дмитрий Козлов on 10/20/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeData

extension SomeSettings {
  public struct stream {
    public static var debugStream = true
    public static var debugOperations = true
    public static var debugQueue = true
    public static var debugSendRead = SendReadType.short
    public static var debugFileProgress = false
    
    public static var operationsHistory = 0
    public static var sleepMode = false
    public static var sleepMsec = 100
    public enum SendReadType {
      case none, short, full
    }
  }
}

func printSendRead(prefix: String, data: Data) {
  switch SomeSettings.stream.debugSendRead {
  case .none:
    return
  case .short:
    print(prefix,data.count.bytesStringShort)
  case .full:
    print(prefix,data.count.bytesStringShort, data.hexString)
  }
}

extension Stream {
  static func debugSleep() {
    guard SomeSettings.stream.sleepMode else { return }
    usleep(useconds_t(SomeSettings.stream.sleepMsec * 1000))
  }
  static func debugSleep(completion: @escaping ()->()) {
    guard SomeSettings.stream.sleepMode else {
      completion()
      return }
    wait(Double(SomeSettings.stream.sleepMsec) / 1000, completion)
  }
}

struct CompletedOperation {
  let o: StreamOperation
  let s: CompletionStatus
  let a: CompletionAction
  let c: String
  func debug(to string: inout String) {
    string.addLine("\(o.name) \(s) \(a) \(c)")
  }
}

extension StreamOperation {
  func _print(_ string: String, _ prefix: String = "") {
    guard SomeSettings.stream.debugOperations else { return }
    var path = ""
    for parent in parents {
      path += parent.fullName
      path += "."
    }
    path += fullName
    path += "."
    var prefix = prefix
    if !prefix.isEmpty {
      prefix = "\(prefix)."
    }
    Swift.print("server: \(prefix)\(path)\(string)")
  }
  
  func debug(to string: inout String, prefix: String, running: Bool) {
    if let o = self as? StreamOperations {
      o.opsDebug(to: &string, prefix: prefix, running: running)
    } else {
      if running {
        string.addLine()
      }
      string.addLine(prefix+fullName)
      if running {
        string += " RUNNING"
      }
    }
    if running {
      string.addLine()
    }
  }
}

private extension StreamOperations {
  func opsDebug(to string: inout String, prefix: String, running: Bool) {
    string.addLine(prefix+name)
    guard debugMode == .full else { return }
    for i in 0..<operations.count {
      let operation = operations[i]
      operation.debug(to: &string, prefix: prefix + "   ", running: running && i == position)
    }
  }
}

extension StreamQueue {
  public func debug(to string: inout String) {
    string.addLine(name)
    if isRunning {
      string += " - running"
    } else {
      string += " - idle"
    }
    if !completedOperations.isEmpty {
      string.addLine("Completed:")
      for operation in completedOperations {
        operation.debug(to: &string)
      }
    }
    if isRunning {
      guard let first = operations.first else { return }
      string.addLine("Running:")
      first.debug(to: &string, prefix: "  ", running: true)
      guard operations.count > 1 else { return }
      string.addLine("Queue:")
      for operation in operations[1...] {
        operation.debug(to: &string, prefix: "  ", running: false)
      }
    } else {
      if !operations.isEmpty {
        string.addLine("Queue:")
        for operation in operations {
          operation.debug(to: &string, prefix: "  ", running: false)
        }
      }
    }
  }
  
  func complete(_ o: StreamOperation, _ s: CompletionStatus, _ a: CompletionAction, _ c: String) {
    guard SomeSettings.stream.operationsHistory > 0 else { return }
    let c = CompletedOperation(o: o, s: s, a: a, c: c)
    completedOperations.append(c, max: SomeSettings.stream.operationsHistory, override: .first)
  }
}

extension StreamPriorityQueue {
  public func debug(to string: inout String) {
    string.addLine(name)
    if running.isEmpty {
      string += " - idle"
    } else {
      string += " - running"
    }
    if !completedOperations.isEmpty {
      string.addLine("Completed:")
      for operation in completedOperations {
        operation.debug(to: &string)
      }
    }
    if !running.isEmpty {
      string.addLine("Running:")
      for o in running {
        o.debug(to: &string, prefix: "  ", running: true)
      }
    }
    if !operations.isEmpty {
      string.addLine("Queue:")
      for o in operations {
        o.debug(to: &string, prefix: "  ", running: false)
      }
    }
  }
  func complete(_ o: StreamOperation, _ s: CompletionStatus, _ a: CompletionAction, _ c: String) {
    let c = CompletedOperation(o: o, s: s, a: a, c: c)
    completedOperations.append(c, max: 4, override: .first)
  }
}
