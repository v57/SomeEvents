//
//  Sub.swift
//  Some Events
//
//  Created by Димасик on 10/21/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge



extension StreamOperations {
  @discardableResult
  func sub() -> Self {
    let subs = subscriber.subs
    if let operation = SubRequest(subs: subs) {
      mainQueue.remove(operations: operation.name)
      add(operation)
    }
    return self
  }
}

private
class SubRequest: Request {
  var subs = Set<Subscription>()
  init?(subs: [Subscription: Int]) {
    subscriber.lock()
    for sub in subs.keys where sub.isValid {
      self.subs.insert(sub)
    }
    subscriber.unlock()
    guard self.subs.count <= 0xff else { return nil }
    super.init(name: "sub()")
    description = "subscribing (to \(subs.count) pages)"
    ops()
  }
  func ops() {
    override()
    skipOn { !server.loginned }
    
    #if debug
    if settings.debug.subscriptions {
      success {
        var description = "Subscribing to \(self.subs.count) pages"
        if !self.subs.isEmpty {
          description += ":\n"
          for sub in self.subs {
            description += "\(sub),"
          }
          description.removeLast()
        }
        description.notification(title: "Server subscriber", emoji: "🖥")
      }
    }
    #endif
    
    request { [unowned self] data in
      data.append(cmd.sub)
      data.append(UInt8(self.subs.count))
      for sub in self.subs {
        data.append(sub)
      }
    }
    read { [unowned self] data in
      mainThread {
        do {
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
        } catch {
          serverManager.process(error: error, operation: self)
        }
      }
    }
  }
}
