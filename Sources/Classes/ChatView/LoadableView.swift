//
//  LoadableView.swift
//  Events
//
//  Created by Димасик on 4/6/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import UIKit

protocol LoadableViewProtocol: class {
  /// WARNING Add all overridable functions if you want to subclass this protocol
  /// and don't forget to add deinit function
  var view: UIView! { get set }
  var isLoaded: Bool { get }
  var size: CGSize { get }
  func loaded(view: UIView, animated: Bool)
  func unloaded(animated: Bool)
  func viewForLoad() -> UIView
  func loadView(to view: UIView, animated: Bool)
  func unloadView(animated: Bool)
}

extension LoadableViewProtocol {
  var isLoaded: Bool {
    return view != nil
  }
  var size: CGSize {
    return .zero
  }
  func loaded(view: UIView, animated: Bool) {
    
  }
  func unloaded(animated: Bool) {
    
  }
  func viewForLoad() -> UIView {
    return UIView(frame: CGRect(size: size))
  }
  func loadView(to view: UIView, animated: Bool) {
    if !isLoaded {
      self.view = viewForLoad()
      loaded(view: self.view, animated: animated)
    }
    view.addSubview(self.view)
  }
  func unloadView(animated: Bool) {
    guard isLoaded else { return }
    view.removeFromSuperview()
    unloaded(animated: animated)
  }
}

class LoadableView: LoadableViewProtocol {
  var view: UIView!
}
