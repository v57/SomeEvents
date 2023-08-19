//
//  UploadContent.swift
//  Some Events
//
//  Created by Димасик on 10/2/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import SomeNetwork
import SomeBridge

extension Server {
  @discardableResult
  func upload(content: Content, to event: Event) -> StreamOperations {
    return UploadContentRequest(content: content, event: event)
  }
}

private extension StreamOperations {
  @discardableResult
  func addPhoto(_ event: Event, content: PhotoContent) -> StreamOperations {
    request { data in
      data.append(cmd.addPhoto)
      data.append(event.id)
      data.append(content.photoData)
    }
    read { data in
      let message: Response = try data.next()
      if message == .ok {
        let id: ID = try data.next()
        print("added photo",id)
        thread.lock()
        content.set(id: id)
        thread.unlock()
      } else {
        print(":( not added")
        throw ServerError.noRights
      }
    }
    return self
  }
  
  @discardableResult
  func addVideo(_ event: Event, content: VideoContent) -> StreamOperations {
    request { data in
      data.append(cmd.addVideo)
      data.append(event.id)
      data.append(content.videoData)
    }
    read { data in
      try data.response()
      let id: ID = try data.next()
      print("added video (\(id))")
      thread.lock()
      content.set(id: id)
      thread.unlock()
    }
    return self
  }
}

class UploadContentRequest: Request, SaveableRequest {
  var type: RequestType { return .uploadContent }
  let content: Content
  let event: Event
  init(content: Content, event: Event) {
    self.content = content
    self.event = event
    super.init(name: "upload(content:)")
    ops(event: event, content: content)
    resume()
  }
  required init(data: DataReader) throws {
    let e: ID = try data.next()
    let c: ID = try data.next()
    guard let event = e.event else { throw corrupted }
    guard let content = event.find(content: c) else { throw corrupted }
    self.event = event
    self.content = content
    super.init()
    
    ops(event: event, content: content)
  }
  func save(data: DataWriter) {
    data.append(type)
    data.append(content.eventid)
    data.append(content.id)
  }
  func ops(event: Event, content: Content) {
    description = "creating content \(content.id)"
    
    set(stream: server)
    autorepeat()
    connectOperation()
    switch content.type {
    case .photo:
      addPhoto(event, content: content as! PhotoContent)
    case .video:
      addVideo(event, content: content as! VideoContent)
    }
    success {
      content.previewURL.whenReady {
        server.upload(type: content.previewUploadType)
      }
    }
  }
  func done() {
    server.upload(type: content.previewUploadType)
  }
}
