//
//  CreateEvent2.swift
//  Events
//
//  Created by Dmitry on 23/03/2019.
//  Copyright © 2019 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeMap

//class CreateEventView2: Page, UITextFieldDelegate {
//  override var isFullscreen: Bool { return false }
//  //    var eventName = ""
//  var eventType = EventType.common
//  static func frame(page: CreateEventView2) -> CGRect {
//    let size = Size(screen.safeWidth - .margin2, min(CreateEventView2.maxHeight,page.height))
//    return Rect(Pos(screen.center.x,screen.bottom-keyboardHeight), .bottom, size)
//  }
//  static var maxHeight: CGFloat {
//    return screen.bottom - screen.topInsets - keyboardHeight
//  }
//  override var screenFrame: DFrame {
//    return { [unowned self] in
//      CreateEventView2.frame(page: self)
//    }
//  }
//  var height: CGFloat = 50 + .margin2
//  
//  let eventName: DFTextField
//  
//  override init() {
//    
//    eventName = DFTextField(frame: .zero)
//    
//    super.init()
////    background = .blur(.extraLight)
//    
//    cornerRadius = 20
//    
//    let inputBackground = DFVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//    inputBackground.dframe = { [unowned self] in Rect(self.bounds.top + Pos(0,.margin), .top, Size(self.bounds.size.width - .margin2, 50)) }
//    eventName.font = .heavy(30)
//    eventName.placeholder = "New event"
//    eventName.dframe = { [unowned self] in Rect(self.bounds.top + Pos(0,.margin), .top, Size(self.bounds.size.width - .margin2, 50)) }
//    inputBackground.addSubview(inputBackground)
//    addSubview(inputBackground)
//  }
//  override func keyboardMoved() {
//    updateFrame()
//  }
//  
//  override func didShow() {
//    eventName.becomeFirstResponder()
//  }
//  
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//}

