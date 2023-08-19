//
//  Swiper.swift
//  Some Events
//
//  Created by Дмитрий Козлов on 2017/11/27.
//  Copyright © 2017年 Dmitry Kozlov. All rights reserved.
//

import UIKit

//Parameter is the type of parameter passed in the selector
public class ClosureSelector<Parameter> {
  public let selector: Selector
  private let closure: (Parameter)->()
  
  init(closure: @escaping (Parameter)->()){
    self.selector = #selector(ClosureSelector.target)
    self.closure = closure
  }
  
  @objc func target( param: AnyObject) {
    closure(param as! Parameter)
  }
}
public class EmptyClosureSelector {
  public let selector: Selector
  private let closure: ()->()
  
  init(closure: @escaping ()->()) {
    self.selector = #selector(EmptyClosureSelector.target)
    self.closure = closure
  }
  
  @objc func target() {
    closure()
  }
}

private var handle: Int = 0
extension UIButton {
  func onTouch(_ action: @escaping ()->()) {
    add(on: .touchUpInside, action: action)
  }
  func add(on controlEvents: UIControlEvents, action: @escaping ()->()) {
    let closureSelector = EmptyClosureSelector(closure: action)
    objc_setAssociatedObject(self, &handle, closureSelector, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    self.addTarget(closureSelector, action: closureSelector.selector, for: controlEvents)
  }
}

extension SomePage {
  public func swipable(direction: SlideDirection = .down) {
    pageSwiper = PageSwiper()
    pageSwiper!.direction = direction
    pageSwiper!.set(page: self)
  }
  public func swipable(direction: SlideDirection = .down, view: UIView) {
    pageSwiper = PageSwiper()
    pageSwiper!.direction = direction
    pageSwiper!.set(page: self, view: view)
  }
  public func swipable(direction: SlideDirection = .down, scrollView: UIScrollView) {
    scrollViewSwiper = PageScrollViewSwiper()
    scrollViewSwiper!.direction = direction
    scrollViewSwiper!.set(page: self, scrollView: scrollView)
  }
}

public class PageSwiper: NSObject {
  public let gesture = UIPanGestureRecognizer()
  public var direction = SlideDirection.down
  public var started = false
  private weak var page: SomePage?
  public override init() {
    super.init()
    gesture.addTarget(self, action: #selector(swipe))
  }
  func set(page: SomePage, view: UIView) {
    self.page = page
    view.addGestureRecognizer(gesture)
  }
  func set(page: SomePage) {
    self.page = page
    self.page!.addGestureRecognizer(gesture)
  }
  @objc func swipe(gesture: UIPanGestureRecognizer) {
    guard let page = page else { return }
    guard page.areSwipesEnabled else { return }
    switch gesture.state {
    case .began:
      let position = gesture.location(in: main.view)
      page.transition.slideType = direction
      page.transition.swipeBegan(position: position)
      started = true
    case .changed:
      guard started else { return }
      let position = gesture.location(in: main.view)
      page.transition.swipeChanged(position: position)
    case .cancelled, .ended:
      guard started else { return }
      page.transition.swipeEnded(velocity: gesture.velocity(in: main.view))
      page.transition.slideType = .right
      started = false
    default: break
    }
  }
}
public class PageScrollViewSwiper: NSObject {
  public var direction: SlideDirection = .down
  public var state: TransitionDragState = .waiting
  
  private weak var scrollView: UIScrollView!
  private weak var page: SomePage!
  public func set(page: SomePage, scrollView: UIScrollView) {
    self.page = page
    self.scrollView = scrollView
    scrollView.panGestureRecognizer.addTarget(self, action: #selector(swipe))
  }
  
  @objc func swipe(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      let offset = scrollView.offsetTop
      if offset < 10 && offset > -10 {
        state = .starting
      }
    case .changed:
      switch state {
      case .starting:
        guard scrollView.offsetTop < 0 else { return }
        let position = gesture.location(in: main.view)
        page.transition.slideType = direction
        page.transition.swipeBegan(position: position)
        state = .dragging
        scrollView.bounces = false
      case .dragging:
        let position = gesture.location(in: main.view)
        page.transition.swipeChanged(position: position)
      default: break
      }
    case .cancelled, .ended:
      if state == .dragging {
        page.transition.swipeEnded(velocity: gesture.velocity(in: main.view))
        page.transition.slideType = .right
        scrollView.bounces = true
      }
      state = .waiting
    default:
      scrollView.bounces = true
    }
  }
}

//class ViewSwiper: NSObject {
//  weak var view: UIView?
//  override init() {
//    super.init()
//  }
//
//  @objc func swipe(gesture: UIPanGestureRecognizer) {
//    switch gesture.state {
//    case .began:
//      print("swipe began")
//      let position = gesture.location(in: main.view)
//      pageTransition.slideType = .down
//      pageTransition.swipeBegan(position: position)
//    case .changed:
//      print("swipe changed")
//      let position = gesture.location(in: main.view)
//      pageTransition.swipeChanged(position: position)
//    case .cancelled, .ended:
//      print("swipe ended")
//      pageTransition.swipeEnded(velocity: gesture.velocity(in: main.view))
//      pageTransition.slideType = .right
//    default: break
//    }
//  }
//}

