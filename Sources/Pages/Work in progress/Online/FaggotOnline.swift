//
//  FaggotOnline.swift
//  faggot
//
//  Created by Димасик on 28/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

/*

import Some

class FaggotOnline: Page {
  
  let scrollView = UIScrollView2(frame: screen.frame)
  override init() {
    super.init()
    showsStatusBar = false
    
    let view1 = OView(y: 65, events: Array(User.me.events.events.first(5)), page: self)
    scrollView.addSubview(view1)
    
    let newReleases = Label(frame: CGRect(screen.width/12,230,0,0), text: "New Releases", font: .light(15), color: .dark, alignment: .left, fixHeight: true)
    
    let seeAll2 = Button(frame: CGRect(screen.width/5,screen.height-230,0,0), text: "See all >", font: .light(15), color: .dark)
    
    let view2 = OView2(y: 250, events: generateRandomEvents(20))
    scrollView.addSubview(view2)
    
    let future = Label(frame: CGRect(screen.width/12,430,0,0), text: "Future", font: .light(15), color: .dark, alignment: .left, fixHeight: true)
    
    let seeAll3 = Button(frame: CGRect(screen.width/5,430,0,0), text: "See all >", font: .light(15), color: .dark)
    
    
    let view3 = OView3(y: 450, events: generateRandomEvents(5))
    scrollView.addSubview(view3)
    
    let history = Button(pos: Pos(screen.width/5,screen.height-50), anchor: _center, name: "OHistory")
    history.defaultHighlighting = true
    
    let historyLabel = Label(frame: CGRect(screen.width/5,screen.height-20,0,0), text: "History", font: .light(15), color: .dark, alignment: .center, fixHeight: true)
    
    let messages = Button(pos: Pos(screen.width/5*2,screen.height-50), anchor: _center, name: "OMessages")
    messages.defaultHighlighting = true
    
    let messagesLabel = Label(frame: CGRect(screen.width/5*2,screen.height-20,0,0), text: "Messages", font: .light(15), color: .dark, alignment: .center, fixHeight: true)
    
    let friends = Button(pos: Pos(screen.width/5*3,screen.height-50), anchor: _center, name: "OFriends")
    friends.defaultHighlighting = true
    friends.touch {
//      main.push(FriendList())
    }
    
    let friendsLabel = Label(frame: CGRect(screen.width/5*3,screen.height-20,0,0), text: "Friends", font: .light(15), color: .dark, alignment: .center, fixHeight: true)
    
    let map = Button(pos: Pos(screen.width/5*4,screen.height-50), anchor: _center, name: "OMap")
    map.defaultHighlighting = true
    
    let mapLabel = Label(frame: CGRect(screen.width/5*4,screen.height-20,0,0), text: "Map", font: .light(15), color: .dark, alignment: .center, fixHeight: true)
    
    
    addSubviews(scrollView,history,historyLabel,messages,messagesLabel,friends,friendsLabel,map,mapLabel,newReleases,seeAll2,future,seeAll3)
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


func generateRandomEvents(_ count: Int) -> [Event] {
  let names = ["Faggotfest", "E4", "Anusville party", "Habe you seen chef pls", "Gay party", "2 guys one cup 2015", "Taylor Swift in dota 2", "ISISfest"]
  
  var events = [Event]()
  for i in 0..<count {
    let event = Event(id: Int64(i))
    
    event.name = names.any
    
    event.views = .random(min: 0, max: 300)
    event.current = .random(min: 0, max: 100)
    event.commentsCount = .random(min: 0, max: 300)
    
    // 1459123200 = 28 march 2015
    // 1490559200 = 28 march 2017
    event.startTime = Time(random(min: 1459123200, max: 1490559200))
    
    events.append(event)
  }
  return events
}
*/
