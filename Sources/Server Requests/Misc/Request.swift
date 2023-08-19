//
//  Request.swift
//  Events
//
//  Created by Димасик on 3/26/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork

class Request: StreamOperations {
  var description: String?
  private var _description: String {
    return description ?? name
  }
  
  override func completed() {
    guard settings.debug.requestSuccess else { return }
//    guard !lastIsRequest else { return }
    print(request: "\(_description) success")
  }
  
  override func running(operation: StreamOperation) {
    guard settings.debug.requestSending else { return }
    if operation is SomeRequestOperation {
      print(request: _description)
    }
  }
  
  override func failed(error: Error?) {
    guard settings.debug.requestFailed else { return }
    if let error = error {
      print(request: "\(_description) failed: \(error)")
    } else {
      print(request: "\(_description) failed")
    }
  }
}

//MARK:- Private
private extension Request {
  var lastIsRequest: Bool {
    if let operation = operations.last {
      return operation is Request
    } else {
      return false
    }
  }
  var containsRequest: Bool {
    return operations.contains { $0 is Request }
  }
}


//MARK:- Request descriptions

extension Int64 {
  var eventDescription: String {
    return "(event \(self))"
  }
  var contentDescription: String {
    return "(content \(self))"
  }
  var userDescription: String {
    return "(user \(self))"
  }
  var messageDescription: String {
    return "(message \(self))"
  }
}

extension Event {
  var requestDescription: String {
    return "(event \(id))"
  }
}

extension Content {
  var requestDescription: String {
    return "(content \(id))"
  }
}

extension User {
  var requestDescription: String {
    return "(event \(id))"
  }
}

extension Message {
  var requestDescription: String {
    return "(message \(index))"
  }
}
