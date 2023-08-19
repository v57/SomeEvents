//
//  OView2.swift
//  faggot
//
//  Created by Димасик on 28/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

/*
import Some


private let w:CGFloat = 90
private let o:CGFloat = 7
private let h:CGFloat = 125
private let wo:CGFloat = w+o

class OView2: UIScrollView2, UIScrollViewDelegate {
  init(y: CGFloat, events: [Event]) {
    super.init(frame: Rect(0,y,screen.width,h+60))
    
    for (i,event) in events.enumerated() {
      let view = OSubview2(x: 10 + CGFloat(i) * wo, event: event)
      addSubview(view)
    }
    contentSize = Size(CGFloat(events.count) * wo+o + 6, 0)
    
    showsHorizontalScrollIndicator = false
    
    delegate = self
  }
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    if !decelerate {
      
      let x = round((scrollView.contentOffset.x - 10) / wo)
      animate {
        scrollView.contentOffset = Pos(x * wo + 10,0)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class OSubview2: UIView {
  let title: SLabel
  init(x: CGFloat, event: Event) {
    title = SLabel(pos: Pos(w/2,h+5), text: event.name, font: .light(14), color: .dark, anchor: _top)
    
    title.lines = 3
    
    title.maxWidth = w
    
    super.init(frame: Rect(x,0,w,h))
    backgroundColor = UIColor(white: 0, alpha: 0.2)
    
    append(title)
    title.shows = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


*/
