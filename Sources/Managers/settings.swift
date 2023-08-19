//
//  settings.swift
//  faggot
//
//  Created by Димасик on 5/7/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit
import SomeData
import SomeBridge

var settings = Settings()
var statistics = Statistics()
private var debugOptions = DebugOptions()
private var testOptions = TestOptions()

enum SettingsOptions: UInt8 {
  case sendOnReturn
  case disablePhotoCompression
  case showsLabels
  case saveContentToLibrary
  case saveAvatarsToLibrary
  case stripPhotoLocations
}

struct Statistics: DataRepresentable {
  var options = StatisticsOptions.Set64()
  init() {}
  init(data: DataReader) throws {
    options = try data.next()
  }
  func save(data: DataWriter) {
    data.append(options)
  }
}

enum StatisticsOptions: UInt8 {
  case reportsConfirmed
}

struct Settings: DataRepresentable {
  var options = SettingsOptions.Set()
  var eventCreationPrivacy = EventPrivacy.public
  
  init() {}
  init(data: DataReader) throws {
    options = try data.next()
    eventCreationPrivacy = try data.next()
  }
  func save(data: DataWriter) {
    data.append(options)
    data.append(eventCreationPrivacy)
  }
  
  var sendOnReturn: Bool {
    get { return options[.sendOnReturn] }
    set { options[.sendOnReturn] = newValue }
  }
  var disablePhotoCompression: Bool {
    get { return options[.disablePhotoCompression] }
    set { options[.disablePhotoCompression] = newValue }
  }
  var showsLabels: Bool {
    get { return options[.showsLabels] }
    set { options[.showsLabels] = newValue }
  }
  var saveContentToLibrary: Bool {
    get { return options[.saveContentToLibrary] }
    set { options[.saveContentToLibrary] = newValue }
  }
  var saveAvatarsToLibrary: Bool {
    get { return options[.saveAvatarsToLibrary] }
    set { options[.saveAvatarsToLibrary] = newValue }
  }
  var stripPhotoLocations: Bool {
    get { return options[.stripPhotoLocations] }
    set { options[.stripPhotoLocations] = newValue }
  }
  var compressQuality: CGFloat {
    return disablePhotoCompression ? 1.0 : 0.6
  }
  var previewQuality: CGFloat {
    return 0.6
  }
  var debug: DebugOptions {
    get { return debugOptions }
    set { debugOptions = newValue }
  }
  var test: TestOptions {
    get { return testOptions }
    set { testOptions = newValue }
  }
}


extension Options where Enum == StatisticsOptions {
  var reportsConfirmed: Bool {
    get { return self[.reportsConfirmed] }
    set { self[.reportsConfirmed] = newValue }
  }
}

let settingsManager = SettingsManager()
class SettingsManager: Manager, Saveable {
  func load(data: DataReader) throws {
    settings = try data.next()
    statistics = try data.next()
  }
  func save(data: DataWriter) throws {
    data.append(settings)
    data.append(statistics)
  }
}
