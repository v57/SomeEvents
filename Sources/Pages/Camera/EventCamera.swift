//
//  EventCamera.swift
//  Some Events
//
//  Created by Димасик on 2017/11/27.
//  Copyright © 2017年 Dmitry Kozlov. All rights reserved.
//

import Some

class EventCamera: Camera {
  init(event: Event) {
    super.init()
    photoCaptured = { photo in
//      do {
//        let photo = photo.thumbnail(Size(180,180),false)
//        print("current: \(photo.jpg(0.6).count) \(photo.size * photo.scale)")
//      }
//      do {
//        let photo = photo.thumbnail(Size(180,180),false)
//        print("old: \(photo.jpg(0.8).count) \(photo.size * photo.scale)")
//      }
//      do {
//        let photo = photo.limit(minSize: 180,false)
//        print("updated 180: \(photo.progressive(quality: 0.6).count) \(photo.size * photo.scale)")
//      }
//      do {
//        let photo = photo.limit(minSize: 256,false)
//        print("updated 256: \(photo.progressive(quality: 0.6).count) \(photo.size * photo.scale)")
//      }
//      do {
//        let photo = photo.limit(minSize: 512,false)
//        print("updated 512: \(photo.progressive(quality: 0.6).count) \(photo.size * photo.scale)")
//      }
//      do {
//        let photo = photo.limit(minSize: 1024,false)
//        print("updated 1024: \(photo.progressive(quality: 0.6).count) \(photo.size * photo.scale)")
//      }
      
      event.addPhoto(photo)
    }
    videoCaptured = { url in
      event.addVideo(url)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
