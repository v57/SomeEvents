//
//  RequestType.swift
//  Some Events
//
//  Created by Димасик on 10/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData

enum RequestType: UInt8 {
  case uploadContent
  case upload
  static func fill(operations: inout [RequestType: SaveableRequest.Type]) {
    operations[.upload] = UploadRequest.self
    operations[.uploadContent] = UploadContentRequest.self
  }
}

protocol SaveableRequest: DataRepresentable {
  var type: RequestType { get }
  init(data: DataReader) throws
  func save(data: DataWriter)
}
