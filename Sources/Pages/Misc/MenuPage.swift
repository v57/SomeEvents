//
//  MenuPage.swift
//  faggot
//
//  Created by Димасик on 3/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some

class Menu: Page {
  var backgroundView: DFView
  
  var pframe: CGRect
  var psuperview: UIView
  var pview: UIView
  
  let blur: DFVisualEffectView
  
  init(view: UIView) {
    pframe = view.frame
    psuperview = view.superview!
    pview = view
    var frame = view.frame
    frame.origin = view.positionOnScreen
    view.frame = frame
    
    backgroundView = DFView(frame: frame)
    backgroundView.backgroundColor = UIColor(white: 0.7, alpha: 0.5)
    backgroundView.layer.cornerRadius = 10
    
    let effect = UIBlurEffect(style: .light)
    blur = DFVisualEffectView(effect: effect)
    blur.dframe = { screen.frame }
    super.init()
    addSubview(blur)
    //addSubview(backgroundView)
    //addSubview(view)
    
    boopAnimation()
    
    addTap(self,#selector(tap))
  }
  
  @objc func tap() {
    close()
  }
  
  func boopAnimation() {
    animate ({
      backgroundView.resize(backgroundView.frame.size * 1.3, .center)
    }) {
      self.moveAnimation()
    }
  }
  
  func moveAnimation() {
    let dframe = start()
    animate ({
      backgroundView.dframe = dframe
    }) {
      
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  override func customTransition(with page: SomePage?, ended: @escaping () -> ()) -> Bool {
//
//    return true
//  }
  
  func close() {
    main.back()
  }
  
  func start() -> () -> CGRect {
    return { CGRect(screen.center.x - 100, screen.center.y - 100, 200, 200) }
  }
}

class EventMenu: Menu {
  init(view: UIView, event: Event) {
    super.init(view: view)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
