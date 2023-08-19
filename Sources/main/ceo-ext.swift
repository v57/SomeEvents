//
//  ceo.swift
//  Some Events
//
//  Created by Димасик on 10/29/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeMap
import SomeData

let ceo = Ceo()
class Ceo: SomeCeo {
  #if debug
  var hashes = [Int64: String]()
  #endif
  override init() {
    super.init()
    
    append(versions)
    
    
    append(usersManager)
    
    append(accounts)

//    append(loginManager)
//    append(icloud)
    
    append(downloadManager)
    
    append(eventManager)
    append(eventUploadManager)
    append(contentManager)
    append(listenerManager)
    
    append(notificationManager)
    append(reporter)
    
    append(pushManager)
    
    append(serverManager)
    
    append(google)
    append(license)
    append(SomeMapManager.default)
    append(settingsManager)
  }
  override func start() {
    super.start()
    load()
  }
  override func loadFailed(manager: Manager, error: Error) {
    mainThread {
      #if debug
        "cannot load manager \(manager): \(error)".error(title: "ceo")
      #endif
    }
  }
  final override func encrypt(data: DataWriter) {
    data.encrypt(password: 0x683a7ead25074ac7)
  }
  final override func decrypt(data: DataReader) {
    data.decrypt(password: 0x683a7ead25074ac7)
  }
  final override func pause() {
    save()
  }
}
