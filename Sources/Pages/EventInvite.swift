//
//  Invite.swift
//  faggot
//
//  Created by Димасик on 07/04/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class PickerPage: Page {
  var picker: FriendPicker!
  override var isFullscreen: Bool {
    return false
  }
  init(friends: [User], invited: Set<Int64>) {
    super.init()
    swipable()
    background = .blur(.light)
    
    picker = FriendPicker(friends: friends, invited: invited, page: self)
    addSubview(picker)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class FriendPicker: UIView, UIScrollViewDelegate {
  let centerView: UIButton
  
  let leftSV: UIScrollView2
  let rightSV: UIScrollView2
  let topSV: UIScrollView2
  
  let cx: CGFloat
  let centerSize: CGFloat
  let centerRadius: CGFloat
  let radius: CGFloat
  let buttonSize: CGFloat
  let buttonOffset: CGFloat
  let position = screen.center
  let count: CGFloat = 10
  let offset: CGFloat
  var maxAngle: CGFloat = 0
  let circleSize: CGFloat
  
  let pickedView: ScrollView
  
  var event: Event?
  
  weak var page: Page?
  
  let invitedLabel: UILabel
  
  var anyActivity = false {
    didSet {
      guard anyActivity != oldValue else { return }
      centerView.setTitle("Done", for: .normal)
    }
  }
  
  init(friends: [User], invited: Set<Int64>, page: Page) {
    self.page = page
    
    
    centerSize = 140
    buttonSize = 50
    let ans: CGFloat = 10
    
    centerRadius = centerSize / 2
    radius = centerRadius + buttonSize / 2 + ans
    let ans2 = ans+ans
    
    
    
    offset = π * 2 / count
    buttonOffset = radius * offset
    circleSize = π * 2 * radius
    contentSize = -buttonOffset
    
    let s = centerSize + buttonSize + buttonSize + ans2 + ans2
    let ba = buttonSize+ans2
    
    cx = s/2
    let c = Pos(cx,cx)
    centerView = UIButton(frame: Rect(c,_center,Size(centerSize, centerSize)))
    centerView.systemHighlighting()
    centerView.setTitle("Select users\nto invite", for: .normal)
    if let label = centerView.titleLabel {
      label.textAlignment = .center
      label.autoresizeFont()
      label.font = .normal(36)
      label.numberOfLines = 2
    }
    centerView.backgroundColor = .background
    centerView.circle()
    
    leftSV = UIScrollView2(frame: CGRect(0, 0, ba, s))
    leftSV.alwaysBounceVertical = true
    leftSV.showsVerticalScrollIndicator = false
    rightSV = UIScrollView2(frame: CGRect(s-ba, 0, ba, s))
    rightSV.alwaysBounceVertical = true
    rightSV.showsVerticalScrollIndicator = false
    topSV = UIScrollView2(frame: CGRect(0,0,s,ba))
    topSV.alwaysBounceHorizontal = true
    topSV.showsHorizontalScrollIndicator = false
    
    invitedLabel = UILabel(frame: CGRect(0,s-30,s,30))
    invitedLabel.font = .body
    invitedLabel.text = "Invited: \(invited.count)"
    
    pickedView = ScrollView(frame: CGRect(0,s,s,ba+60))
    pickedView.alwaysBounceHorizontal = true
    pickedView.alwaysBounceVertical = false
    pickedView.showsHorizontalScrollIndicator = false
    pickedView.contentSize = Size(40,0)
    pickedView.createMask(false)
    
    super.init(frame: Rect(position.x - cx, position.y - cx, s, pickedView.frame.bottom.y))
    
    leftSV.delegate = self
    rightSV.delegate = self
    topSV.delegate = self
    
    addSubviews(centerView,topSV,leftSV,rightSV,pickedView)
    addSubview(invitedLabel)
    
    centerView.add(target: self, action: #selector(done))
    
    for friend in friends {
      let b = UserView(user: friend, size: buttonSize, page: page)
      if invited.contains(friend.id) {
        addPicked(b)
      } else {
        b.center = Pos(cx+radius,cx)
        addButton(b)
      }
    }
    
    let me = UserView(user: .me, size: buttonSize, page: page)
    addPicked(me)
//
//    for i in 0..<50 {
//      let b = UserView(user: nil, size: buttonSize)
//      addButton(b)
//    }
    
    scrollViewDidScroll(topSV)
    
    addTap(self, #selector(tap(_:)))
    pickedView.addTap(self, #selector(tap2(_:)))
    
  }
  
  @objc func tap(_ gesture: UITapGestureRecognizer) {
    let pos = gesture.location(in: self)
    for (i,button) in buttons.enumerated() where !button.isHidden {
      if button.frame.contains(pos) {
        button.photo.shetBounce()
        pick(i)
        break
      }
    }
  }
  
  @objc func tap2(_ gesture: UITapGestureRecognizer) {
    let pos = gesture.location(in: pickedView)
    for (i,button) in picked.enumerated() {
      if button.frame.contains(pos) {
        button.photo.shetBounce()
        unpick(i)
        break
      }
    }
  }
  
  private var buttons = [UserView]()
  private var picked  = [UserView]()
  
  @objc func done() {
    guard let event = event else { return }
    var old = event.invited
    var new = Set<Int64>()
    new.insert(.me)
    for view in picked {
      guard let user = view.user else { continue }
      new.insert(user.id)
    }
    let (added, removed) = old.merge(to: new)
    event.invite(users: added)
    event.uninvite(users: removed)
//    page?.removeBlurOverlay()
//    destroy()
    screen.orientations = .all
    main.back()
  }
  
  private var contentSize: CGFloat = 0
  private func addButton(_ button: UserView) {
    addSubview(button)
    maxAngle += offset
    move(button,CGFloat(buttons.count),v)
    buttons.append(button)
    contentSize += buttonOffset
    
    let cs = topSV.frame.width + (contentSize - circleSize / 2)
    scs(cs, false)
  }
  private func addPicked(_ button: UserView) {
    let o = buttonSize + 10
    let x = 20 + CGFloat(picked.count) * o
    let y: CGFloat = 12
    button.move(Pos(x,y), .topLeft)
    pickedView.contentSize = pickedView.contentSize + Size(o,0)
    pickedView.addSubview(button)
    picked.insert(button)
  }
  
  var v: CGFloat = 0.0 {
    didSet {
      for (i,button) in buttons.enumerated() {
        move(button,CGFloat(i),v)
      }
    }
  }
  
  private func pick(_ index: Int) {
    let button = buttons[index]
    guard button.isPickable else { return }
    button.invite()
    buttons.remove(at: index)
    
    let o = buttonSize + 10
    let x: CGFloat = 20
    let y: CGFloat = 12
    
    let px = pickedView.frame.x
    let py = pickedView.frame.y
    
    let c = picked.count
    
    pickedView.contentSize = pickedView.contentSize + Size(o,0)
    animate ({
      pickedView.contentOffset = Pos()
      button.move(Pos(x+px,y+py), .topLeft)
      for b in picked {
        b.offset(x: o)
      }
    }) {
      let x = x + CGFloat(self.picked.count - c - 1) * o
      button.removeFromSuperview()
      button.move(Pos(x,y), .topLeft)
      self.pickedView.addSubview(button)
    }
    
    picked.insert(button, at: 0)
    
    sca(-1)
    
    animate {
      guard buttons.count != index else { return }
      
      for i in index..<buttons.count {
        move(buttons[i],CGFloat(i),self.v)
      }
    }
    
    invitedLabel.text = "Invited: \(picked.count)"
    anyActivity = true
  }
  
  private func unpick(_ index: Int) {
    let b = picked[index]
    guard b.isPickable else { return }
    b.uninvite()
    picked.remove(at: index)
    buttons.insert(b, at: 0)
    
    b.removeFromSuperview()
    addSubview(b)
    
    let o = buttonSize + 10
    let x = b.frame.x - pickedView.contentOffset.x
    let y = b.frame.y
    
    let px = pickedView.frame.x
    let py = pickedView.frame.y
    
    b.move(Pos(x+px,y+py), .topLeft)
    
    sca(1)
    
    animate {
      if topSV.contentOffset.x != 0 {
        topSV.contentOffset = Pos()
      } else {
        for (i,b) in buttons.enumerated() {
          move(b, CGFloat(i), v)
        }
      }
      pickedView.contentSize = Size(pickedView.contentSize.width-o,0)
      guard picked.count != 0 else { return }
      for i in index..<picked.count {
        let b = picked[i]
        b.offset(x: -o)
      }
    }
    
    invitedLabel.text = "Invited: \(picked.count)"
    anyActivity = true
  }
  
  private func sca(_ count: Int) {
    contentSize += buttonOffset * CGFloat(count)
    let cs = topSV.frame.width + (contentSize - circleSize / 2)
    if count < 0 && topSV.contentOffset.x + topSV.frame.width > cs {
      animate {
        scs(cs, true)
      }
    } else {
      scs(cs, false)
    }
  }
  
  private func scs(_ cs: CGFloat, _ delegate: Bool) {
    if !delegate {
      leftSV.delegate = nil
      rightSV.delegate = nil
      topSV.delegate = nil
    }
    leftSV.contentSize = CGSize(0,cs)
    rightSV.contentSize = CGSize(0,cs)
    topSV.contentSize = CGSize(cs,0)
    if !delegate {
      leftSV.delegate = self
      rightSV.delegate = self
      topSV.delegate = self
    }
  }
  private func sco(_ cs: CGFloat, _ delegate: Bool) {
    if !delegate {
      leftSV.delegate = nil
      rightSV.delegate = nil
      topSV.delegate = nil
    }
    let csh = max(topSV.contentSize.width - topSV.frame.width,0)
    leftSV.contentOffset = Pos(0,csh-cs)
    rightSV.contentOffset = Pos(0,cs)
    topSV.contentOffset = Pos(cs,0)
    if !delegate {
      leftSV.delegate = self
      rightSV.delegate = self
      topSV.delegate = self
    }
  }
  
  private func move(_ button: UserView, _ p: CGFloat, _ o: CGFloat) {
    let q = π//1.5*π+π/6+π/12
    let r = radius
    let a = o / r
    let angle = p * offset - a
    let ao = π/6
    if angle < 0 {
      if angle < -ao {
        button.isHidden = true
        button.alpha = 0.0
      } else {
        let alpha = (ao + angle) / ao
        button.isHidden = false
        button.alpha = alpha
      }
    } else if angle > q {
      let mx = q + ao
      if angle > mx {
        button.isHidden = true
        button.alpha = 0.0
      } else {
        let alpha = (ao - angle + q) / ao
        button.isHidden = false
        button.alpha = alpha
      }
    } else {
      button.isHidden = false
      button.alpha = 1.0
    }
    
    guard !button.isHidden else { return }
    
    let cs = cos(angle)
    let sn = sin(angle)
    let c = cs * r
    let s = sn * r
    button.center = Pos(cx - c, cx - s)
    button.move(cos: cs, sin: sn)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let csh = max(topSV.contentSize.width - topSV.frame.width,0)
    let contentOffset: CGFloat
    
    if scrollView == leftSV {
      contentOffset = csh - scrollView.contentOffset.y
    } else if scrollView == rightSV {
      contentOffset = scrollView.contentOffset.y
    } else {
      contentOffset = scrollView.contentOffset.x
    }
    
    sco(contentOffset, false)
    
    if scrollView == leftSV {
      v = csh - scrollView.contentOffset.y
    } else if scrollView == rightSV {
      v = scrollView.contentOffset.y
    } else if scrollView == topSV {
      v = scrollView.contentOffset.x
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    leftSV.stopDecelerating()
    rightSV.stopDecelerating()
    topSV.stopDecelerating()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UIScrollView {
  func stopDecelerating() {
    let d = delegate
    delegate = nil
    let o = contentOffset
    setContentOffset(o, animated: false)
    delegate = d
  }
}






























private class UserView: UIView {
  let photo: UIImageView
  let label: UILabel
  let user: User!
  weak var page: Page?
  var isPickable: Bool
  init(user: User!, size: CGFloat, page: Page) {
    let isMe = user?.isMe ?? false
    self.page = page
    self.user = user
    self.isPickable = !isMe
    photo = UIImageView(frame: CGRect(0,0,size,size))
    photo.circle()
    photo.contentMode = .scaleAspectFill
    photo.backgroundColor = .background
    
    var name = "some user"
    if isMe {
      name = "YOU"
    } else if let username = user?.name {
      name = username
    }
    
    label = UILabel(text: name, color: .black, font: .normal(11))
    label.textAlignment = .center
    label.numberOfLines = 3
    
    super.init(frame: CGRect(0,0,size,size))
    isUserInteractionEnabled = false
    addSubview(photo)
    addSubview(label)
    
    if user.hasAvatar {
      loadPhoto(user)
    }
    
    invite()
  }
  
  func move(cos: CGFloat, sin: CGFloat) {
    let anchor = Anchor(0.5 + cos / 2, 0.5 + sin / 2)
    let radius = photo.frame.width / 2 + 10
    let center = photo.frame.width / 2
    let x = -cos * radius + center
    let y = -sin * radius + center
    label.move(Pos(x,y), anchor)
  }
  
  func uninvite() {
    label.fixFrame(true)
  }
  func invite() {
    alpha = 1.0
    let text = label.text!
    label.frame.size = text.size(label.font!, maxWidth: photo.frame.width+4)
    let radius = photo.frame.width / 2 + 10
    let center = photo.frame.width / 2
    let x = center
    let y = radius + center
    label.move(Pos(x,y), .top)
  }
  
  func loadPhoto(_ user: User) {
    guard let page = page else { return }
    photo.user(page, user: user)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

//class Invite: Page {
//    var completion: (id: Int64) -> Void
//    init(completion: (id: Int64) -> Void) {
//        self.completion = completion
//        super.init()
//        showsStatusBar = false
//        ok()
//    }
//
//    func ok() {
//        serverThread {
//            let users = account.friends
//            for (i,id) in users.enumerate() {
//                serverRequest(&self.isClosed) {
//                    let user = try Server.userMain(id)
//                    mainThread {
//                        let view = UserView(index: i, user: user, invite: self)
//                        self.addSubview(view)
//                    }
//                }
//            }
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
