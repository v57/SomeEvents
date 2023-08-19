//
//  Table.swift
//  Table-final 2
//
//  Created by Димасик on 4/25/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import Some

class ScrollView: UIScrollView, UIScrollViewDelegate {
  var didScroll: (() -> ())?
  override init(frame: CGRect) {
    super.init(frame: frame)
    delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    didScroll?()
  }
}

class CellCache: Cache<TableCell> {
  override init() {
    super.init()
    size = 200.mb
    capacity = 100
  }
}
let cache = CellCache()
open class TableView: DynamicCell {
  // properties
  public var cells = [TableCell]()
  public var offset: CGFloat = 0
  public var cameraInset = UIEdgeInsets.zero
  public var gap: CGFloat = 0
  public var cOffset: CGPoint = .zero
  public var frameSize: CGFloat = 0.0
  public var loadedRange: Range<Int> = 0..<0
  
  public var inset: UIEdgeInsets = .zero {
    didSet { scrollView?.contentInset = inset }
  }
  
  public var contentSize: CGSize = .zero {
    didSet {
      if useContentSize {
        scrollView?.contentSize = contentSize
      } else {
        scrollView?.frame.size = contentSize
      }
    }
  }
  
  // getters
  public var isHorizontal: Bool { return false }
  public var scrollView: UIScrollView! { return view as? UIScrollView }
  
  // overrides
  override open var size: CGSize {
    didSet {
      frameSize = frameHeight
      guard let scrollView = scrollView else { return }
      scrollView.frame.size = size
    }
  }
  override open func viewToLoad(frame: CGRect) -> UIView {
    let scrollView = ScrollView(frame: frame)
    scrollView.alwaysBounceVertical = true
    scrollView.contentInset = inset
    scrollView.contentSize = contentSize
    scrollView.contentOffset = cOffset
    scrollView.didScroll = { [unowned self, unowned scrollView] in
      self.cOffset = scrollView.contentOffset
      self.didScroll(offset: self.contentOffset)
    }
    return scrollView
  }
  override open func loaded() {
    check()
  }
  override open func unloaded() {
    unloadAll()
  }
  override open func didScroll(offset: CGFloat) {
    let offset = offset + topInset
    let o = offset - self.offset
    guard round(o) != 0 else { return }
    self.offset = offset
    check()
  }
  
  override open func update(frame: CGRect) {
    super.update(frame: frame)
  }
  
  //
  
  func animate(_ animated: Bool, _ animations: () -> ()) {
    animateif(animated, animations)
  }
  func animate(_ animated: Bool, _ animations: () -> (), _ completion: @escaping ()->()) {
    animateif(animated, animations, completion)
  }
  
  public func append(_ cell: TableCell, animated: Bool = false) {
    cell.table = self
    if !cells.isEmpty {
      contentHeight += gap
    }
    cell.index = cells.count
    cells.append(cell)
    set(offset: contentHeight, for: cell)
    contentHeight += height(for: cell)
    
    check()
  }
  public func insert(_ cell: TableCell, at index: Int, animated: Bool) {
    let position = offset(for: index)
    cell.table = self
    cell.index = index
    cells.insert(cell, at: index)
    set(offset: position, for: cell)
    
    if isLoaded {
      let range = loadedRange
      loadedRange.insert(index)
      if cell.isInCamera {
        if index == range.lowerBound {
          loadedRange.expandLeft(by: 1)
        } else if index == range.upperBound {
          loadedRange.expandRight(by: 1)
        }
        didEnter(cell: cell)
        if let cell = cell as? CellCustomAnimations {
          cell.willInsert()
          animate(animated, cell.insertAnimation, cell.didInsert)
        } else {
          cell.view.frame.h = 0
          animate(animated, {
            cell.view.frame.h = cell.size.height
          })
        }
      }
    }
//    print("inserting \(index) at \(loadedRange.shortDescription)")
//    print("\(loadedRange.shortDescription)")
    animate(animated, {
      offset(cells: cells.dropFirst(index + 1), by: height(for: cell) + gap, index: 1)
    })
    check()
  }
  public func remove(_ cell: TableCell, animated: Bool) {
//    let isAbove = cell.isAboveCamera
    
    var animated = animated
    
    if !loadedRange.contains(cell.index) {
      animated = false
    }
    
    if cell.isLoaded {
      cell.isLoaded = false
//      cell.view = cell.view.destroy(options: .vertical(.top), animated: animated)
      let view = cell.view!
      view.frame.h = cell.size.height
      
      Some.animate ({
        view.scale(0.1)
      }) {
        view.removeFromSuperview()
      }
      cell.view = nil
      cell.unloaded()
    } else if cell.view != nil {
      cache.remove(cell)
      cell.view = cell.view.destroy(animated: false)
      cell.unloaded()
    }
    
    
    loadedRange.remove(cell.index)
    cells.remove(at: cell.index)
    var cof = -height(for: cell)
    if cells.count > 0 {
      cof -= gap
    }
    
    animate(animated) {
      offset(cells: cells.dropFirst(cell.index), by: cof, index: -1)
    }
    check()
  }
  func offset(cells: ArraySlice<TableCell>, by offset: CGFloat, index: Int) {
    contentHeight += offset
    for cell in cells {
      let newValue = self.offset(for: cell) + offset
      set(offset: newValue, for: cell)
      cell.view?.frame.origin = cell.position
      cell.index += index
    }
  }
  
  func frame(for cell: TableCell) -> CGRect {
    var frame = CGRect(origin: cell.position, size: cell.size)
    if frame.w == 0 {
      frame.w = scrollView!.frame.w
    }
    if frame.h == 0 {
      frame.h = scrollView!.frame.h
    }
    return frame
  }
  var contentOffset: CGFloat {
    return scrollView!.contentOffset.y
  }
  var contentHeight: CGFloat {
    get { return contentSize.height }
    set { contentSize.height = newValue }
  }
  var topInset: CGFloat {
    return cameraInset.top
  }
  var bottomInset: CGFloat {
    return cameraInset.bottom
  }
  var frameHeight: CGFloat {
    return size.height
  }
  func offset(for cell: TableCell) -> CGFloat {
    return cell.position.y
  }
  func set(offset: CGFloat, for cell: TableCell) {
    cell.position.y = offset
  }
  func height(for cell: TableCell) -> CGFloat {
    return cell.size.height
  }
}

extension TableCell {
  var isAboveCamera: Bool {
    return cellBottom <= table!.top
  }
  
  var isBelowCamera: Bool {
    return cellTop >= table!.bottom
  }
  
  var isInCamera: Bool {
    return !isBelowCamera && !isAboveCamera
  }
  
  var cellTop: CGFloat {
    return table!.offset(for: self)
  }
  
  var cellBottom: CGFloat {
    return cellTop + table!.height(for: self)
  }
}

extension TableView {
  func check() {
    guard isLoaded else { return }
    if loadedRange.isEmpty {
      loadBottom()
    } else {
      checkTop()
      if !loadedRange.isEmpty {
        checkBottom()
      }
    }
  }
}

// private
extension TableView {
  func offset(for index: Int) -> CGFloat {
    if index > 0 {
      if index <= cells.count {
        return cells[index - 1].cellBottom + gap
      } else {
        return contentHeight
      }
    } else {
      return 0
    }
  }
  
  var cameraHeight: CGFloat {
    return frameSize - topInset - bottomInset
  }
  
  func unloadAll() {
    unload(loadedRange)
    loadedRange = 0..<0
  }
  
  var useContentSize: Bool {
    if let table = table {
      return table.isHorizontal != isHorizontal
    } else {
      return true
    }
  }
  
  func unload(_ range: Range<Int>) {
    guard !range.isEmpty else { return }
    print("unloading \(range.shortDescription) \(loadedRange.shortDescription)")
    assert(range.clamped(to: loadedRange).count == range.count)
//    let from = max(range.lowerBound,0)
//    let to = max(range.upperBound,0)
//    guard to > from else { return }
//    print("unloading \(from)..<\(to)")
    for cell in cells[range] {
      didLeave(cell: cell, shouldRemove: false)
    }
    loadedRange.remove(range)
  }
  
  func load(_ range: Range<Int>) {
    guard !range.isEmpty else { return }
//    print("loading \(range.shortDescription) \(loadedRange.shortDescription)")
    assert(range.clamped(to: loadedRange).isEmpty)
//    let from = max(range.lowerBound,0)
//    let to = max(range.upperBound,0)
//    guard to > from else { return }
//    print("loading \(from)..<\(to)")
    for cell in cells[range] {
      didEnter(cell: cell)
    }
    loadedRange.merge(with: range)
  }
  
  func didEnter(cell: TableCell) {
//    print("didEnter \(cell.index) \(ObjectIdentifier(cell).hashValue)")
    cell.load(to: scrollView!, frame: frame(for: cell))
//    let view = cell.viewToLoad(frame: frame(for: cell))
//    cell.view = view
//    scrollView!.addSubview(view)
//    cell.isLoaded = true
  }
  
  func didLeave(cell: TableCell, shouldRemove: Bool) {
    print("didLeave \(cell.index) \(ObjectIdentifier(cell).hashValue)")
    cell.unload(shouldRemove: shouldRemove)
//    cell.view.removeFromSuperview()
//    cell.view = nil
//    cell.unloaded()
  }
  
  
  func checkTop() {
    let start = loadedRange.lowerBound
    if cells[start].isInCamera {
      let loaded = range(from: start, reversed: true, until: { $0.isAboveCamera })
      load(loaded)
    } else {
      var unloaded = range(from: start, reversed: false, until: { !$0.isAboveCamera })
      unloaded.move(by: -1)
      unload(unloaded)
    }
  }
  
  func checkBottom() {
    let start = loadedRange.upperBound - 1
    if cells[start].isInCamera {
      var loaded = range(from: start, reversed: false, until: { $0.isBelowCamera })
      guard !loaded.isEmpty else { return }
      loaded.reduceRight(by: 1)
      load(loaded)
    } else {
      var unloaded = range(from: start, reversed: true, until: { !$0.isBelowCamera })
      unloaded.expandRight(by: 1)
      unload(unloaded)
    }
  }
  
  func loadBottom() {
    let unloaded = range(from: -1, reversed: false, until: { !$0.isAboveCamera })
//    unloaded.move(by: -1)
    var loaded = range(from: unloaded.upperBound - 1, reversed: false, until: { $0.isBelowCamera })
    loaded.move(by: -1)
    load(loaded)
  }
  
  func range(from: Int, reversed: Bool, until: (TableCell) -> Bool) -> Range<Int> {
    if reversed {
      guard from > -1 else { return 0..<0 }
      for i in (0..<from).reversed() {
        let cell = cells[i]
        if until(cell) {
          return i + 1..<from
        }
      }
      return 0..<from
    } else {
      let from = from + 1
      guard from < cells.count else { return 0..<0 }
      for i in from..<cells.count {
        let cell = cells[i]
        if until(cell) {
          return Range(from...i)
        }
      }
      return from..<cells.count
    }
  }
  
  var top: CGFloat { return offset }
  var bottom: CGFloat { return offset + cameraHeight }
}
