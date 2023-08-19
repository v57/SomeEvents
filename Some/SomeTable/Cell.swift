//
//  TableCell.swift
//  Table-final 2
//
//  Created by Димасик on 4/25/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import Some

public extension UIView {
  func addSubview(_ cell: LoadableView) {
    if let view = cell.view {
      addSubview(view)
    } else {
      let view = cell.viewToLoad(frame: CGRect(origin: cell.position, size: cell.size))
      view.clipsToBounds = true
      cell.view = view
      cell.loaded()
      addSubview(view)
    }
  }
  
  func addSubview(_ cell: TableCell) {
    if let view = cell.view {
      addSubview(view)
    } else {
      cell.load(to: self, frame: CGRect(origin: cell.position, size: cell.size))
//      let view = cell.viewToLoad(frame: CGRect(origin: cell.position, size: cell.size))
//      cell.view = view
//      cell.loaded()
//      addSubview(view)
    }
  }
}

open class LoadableView {
  public weak var view: UIView!
  open var position: CGPoint { return .zero }
  open var size: CGSize { return .zero }
  public var isLoaded: Bool { return view != nil }
  open func viewToLoad(frame: CGRect) -> UIView {
    let view = UIView(frame: frame)
    return view
  }
  open func loaded() {}
  open func unloaded() {}
}

public protocol CellCustomAnimations {
  func willInsert()
  func insertAnimation()
  func didInsert()
  
  func willRemove()
  func removeAnimation()
  func didRemove()
}

public protocol CellSignals {
  func topCellChanged(from: TableCell?, to: TableCell?)
  func bottomCellChanged(from: TableCell?, to: TableCell?)
}

open class DynamicCell: TableCell {
  private var _size: CGSize = .zero
  open override var size: CGSize {
    get { return _size }
    set { _size = newValue }
  }
}

open class TableCell: CustomStringConvertible {
  public weak var table: TableView?
  public weak var view: UIView!
  public var position: CGPoint = .zero
  public var index = 0
  
  public var isLoaded: Bool = false
  
  open var size: CGSize { return .zero }
  open var minSize: CGSize { return size }
  open var isUnloadable: Bool { return true }
  open var isCachable: Bool { return true }
  
  public init() {
  }
  
  open func loaded() {
  }
  
  open func unloaded() {
  }
  
  open func enteredVisibleArea() {
  }
  
  open func leavedVisibleArea() {
  }
  
  open func didScroll(offset: CGFloat) {
  }
  
  open func update(frame: CGRect) {
    view.frame = frame
  }
  open func viewToLoad(frame: CGRect) -> UIView {
    let view = UIView(frame: frame)
    //    view.backgroundColor = .lightGray
    //    view.frame.height -= 1
    return view
  }
  open var description: String {
    return "TableCell"
  }
}

extension UIView: Cachable {
  public var cacheSize: Int { return Int(frame.width * frame.height) }
}

extension TableCell {
  var previous: TableCell? { return table?.cells.safe(index-1) }
  var next: TableCell? { return table?.cells.safe(index+1) }
  func load(to superview: UIView, frame: CGRect) {
    assert(!isLoaded)
    if view != nil {
      if isCachable {
        view.isHidden = false
        cache.remove(self)
      }
      if view.superview == nil {
        superview.addSubview(self.view)
      }
      isLoaded = true
      update(frame: frame)
    } else {
      let view = self.viewToLoad(frame: frame)
//      view.clipsToBounds = true
      self.view = view
      superview.addSubview(self.view)
      isLoaded = true
      loaded()
    }
  }
  func unload(shouldRemove: Bool) {
    assert(isLoaded)
    
    if shouldRemove {
      purged()
    } else if isCachable {
      view.isHidden = true
      cache.append(self)
    } else if isUnloadable {
      purged()
    } else {
      /// cell не выгружается, ничего с ней не делаем
    }
    isLoaded = false
  }
}

extension TableCell: Cachable {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
  
  public static func == (lhs: TableCell, rhs: TableCell) -> Bool {
    return lhs === rhs
  }
  
  public var cacheSize: Int {
    if let view = view {
      return Int(view.frame.width * view.frame.height)
    } else {
      return 1
    }
  }
  
  public func purged() {
    view?.removeFromSuperview()
    view = nil
    unloaded()
  }
}
