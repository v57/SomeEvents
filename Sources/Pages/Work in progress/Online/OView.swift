//
//  OView.swift
//  faggot
//
//  Created by Димасик on 28/03/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

/*
import Some

class OView: UIScrollView2, UIScrollViewDelegate {
  init(y: CGFloat, events: [Event], page: Page) {
    // кароч создаём скролл с такими размерами
    super.init(frame: Rect(0,y,screen.width,120))
    
    for (i,event) in events.enumerated() {
      let view = OSubview(x: 10 + CGFloat(i) * 228, event: event, page: page)
      addSubview(view)
    }
    
    // размер скролла
    contentSize = Size(CGFloat(events.count * 228 + 12), 0)
    
    // тип надо штоб не показывался скролл тип кароч
    showsHorizontalScrollIndicator = false
    
    // кароч эта хуйня нужна чтоб выполнялась функция снизу при скролле
    delegate = self
  }
  
  // выполняется при отпускании пальца со скролла
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    
    // если тип не будет дальше скролиться по инерции
    // ( остановил палец и отпустил да )
    if !decelerate {
      
      // тут кароч высшая математика
      // round округляет
      let x = round((scrollView.contentOffset.x - 10) / 228)
      animate {
        // кароч передвигаем скрол
        scrollView.contentOffset = Pos(x * 228 + 10,0)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class OSubview: UIImageView {
  let title: SLabel
  init(x: CGFloat, event: Event, page: Page) {
    title = SLabel(pos: Pos(110,105), text: event.name, font: .light(26), color: .light, anchor: _bottom)
    
    // тип если текст не будет влезать, то уменьшится шрифт
    title.autoresize = true
    
    // собсно максимальная ширина текста
    title.maxWidth = 210
    
    super.init(frame: Rect(x,0,220,120))
    
    self.event(page, event: event, preset: .none)
    
    // устанавливаем прозрачность
    backgroundColor = UIColor(white: 0, alpha: 0.2)
    
    
    append(title)
    title.shows = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

*/
