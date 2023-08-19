//
//  EventPreview.bottom.swift
//  faggot
//
//  Created by Димасик on 3/24/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import UIKit


class EPBottomView: EPBlock {
  static let height: CGFloat = 50
  let leaveButton: UIButton
  let doneButton: UIButton
  let height: CGFloat = EPBottomView.height
  init(page: EventPreview, offset: CGFloat) {
    leaveButton = UIButton(type: .system)
    if page.event.invited.count == 1 && page.event.invited.contains(.me) {
      leaveButton.setTitle("Remove", for: .normal)
    } else {
      leaveButton.setTitle("Leave", for: .normal)
    }
    leaveButton.frame = CGRect(0,0,EventPreview.width / 2,height)
    leaveButton.titleLabel!.font = .normal(18)
    leaveButton.setTitleColor(.black, for: .normal)
    
    doneButton = UIButton(type: .system)
    doneButton.setTitle("Done", for: .normal)
    doneButton.frame = CGRect(EventPreview.width / 2,0,EventPreview.width / 2,height)
    doneButton.titleLabel!.font = .normal(18)
    doneButton.setTitleColor(.black, for: .normal)
    
    super.init(frame: CGRect(0,offset,EventPreview.width,height), page: page)
    
    leaveButton.add(target: self, action: #selector(leave))
    doneButton.add(target: self, action: #selector(done))
    
    backgroundColor = .black(0.1)
    
    leaveButton.isHidden = !event.invited.contains(.me)
    
    addSubview(leaveButton)
    addSubview(doneButton)
  }
  
  @objc func leave() {
    let event = page.event
    event.leave()
    .autorepeat()
    if event.owner.isMe {
      done()
    }
  }
  
  @objc func done() {
    page.close()
  }
  
  func update() {
    let isInvited = event.invited.contains(.me)
    let isOwner = isInvited && event.invited.count == 1
    if isOwner {
      leaveButton.setTitle("Remove", for: .normal)
    } else if isInvited {
      leaveButton.setTitle("Leave", for: .normal)
    }
    leaveButton.isHidden = !isInvited
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
