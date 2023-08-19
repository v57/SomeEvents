//
//  GridTableView.swift
//  Table-final 2
//
//  Created by Димасик on 5/9/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import Some

public class GridTableView: TableView {
  
  public var gridInset = UIEdgeInsets.zero
  
  override public func remove(_ cell: TableCell, animated: Bool) {
//    testLoadedRange()
    let isLoaded = loadedRange.contains(cell.index)
    
    var animated = animated
    if !isLoaded {
      animated = false
    }
    
    if cell.isLoaded {
      cell.isLoaded = false
      //      cell.view = cell.view.destroy(options: .vertical(.top), animated: animated)
      let view = cell.view!
      view.frame.h = cell.size.height
      
      Some.animate ({
        view.scale(0.5)
        view.alpha = 0.0
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
    
    var ncells = Array(cellsInRow(with: cell))
    let testc = ncells.count
    ncells.remove(cell)
    assert(testc != ncells.count)
    
    
    
    loadedRange.remove(cell.index)
    cells.remove(at: cell.index)
    
    print(loadedRange)
    
    let swidth = self.size.width
    var width: CGFloat = cell.position.x
    var maxHeight: CGFloat = self.height(for: ncells)
    var height: CGFloat = cell.position.y
    var offset: CGFloat = maxHeight - cell.size.height
    
    var unchangedCells: Int?
    for i in cell.index..<cells.count {
      let cell = cells[i]
      let name = cell.description
      let cwidth = self.width(for: cell)
      let spaceLeft = swidth-width
      if spaceLeft >= cwidth {
        if cell.position.x == width {
          //          cell.index -= 1
          unchangedCells = i
          offset = height - cell.position.y
          break
        }
        maxHeight = max(maxHeight,cell.size.height)
        move(cell: cell, to: Pos(width,height), animated: animated)
//        testLoadedRange()
        if cell.isLoaded {
          print("\(name)", terminator: " ")
        }
      } else {
        if cell.position.x == gridInset.left {
          //          cell.index -= 1
          unchangedCells = i
          offset = (height + maxHeight + gap) - cell.position.y
          break
        }
        height += maxHeight + gap
        move(cell: cell, to: Pos(gridInset.left,height), animated: animated)
//        testLoadedRange()
        maxHeight = cell.size.height
        width = 0
        if cell.isLoaded {
          print("  +\(Int(maxHeight + gap))\n\(name)", terminator: " ")
        }
      }
      width += cwidth + gap
      cell.index -= 1
    }
//    testLoadedRange()
    //    height += maxHeight
    //    let newHeight = height
    if let index = unchangedCells, index < cells.count {
      //      let cell = cells[index]
      //      let o = height - cell.position.y
      self.offset(index, offset, -1, animated)
//      testLoadedRange()
    }
    
    
    contentHeight = contentHeight + offset
//    testLoadedRange()
    
    //    var cof = -height(for: cell)
    //    if cells.count > 0 {
    //      cof -= gap
    //    }
    //
    //    animate(animated) {
    //      offset(cells: cells.dropFirst(cell.index), by: cof, index: -1)
    //    }
    //    check()
  }
  
  func offset(_ from: Int, _ offset: CGFloat, _ index: Int, _ animated: Bool) {
    cells.from(from).forEach { $0.index += index }
    guard offset != 0 else {
      //      cells.from(from).forEach { $0.index += index }
      return
    }
    assert(index != 0)
    var unloaded: Int?
    for i in from..<cells.count {
      let cell = cells[i]
      //      cell.index += index
      let pos = Pos(cell.position.x,cell.position.y + offset)
      let oldPos = cell.position
      let v1 = loadedRange.contains(cell.index)
      //      print(offset,i,cell,v1)
      cell.position = pos
      let v2 = cell.isInCamera
      if !v2 {
        cell.position = oldPos
        unloaded = i
        break
      }
      if v1 != v2 {
        cell.position = oldPos
        load(at: cell.index)
        cell.position = pos
        animate(animated) {
          cell.update(frame: frame(for: cell))
        }
      } else {
        animate(animated) {
          cell.update(frame: frame(for: cell))
        }
      }
      //      if v1 != v2 {
      ////        cell.position = oldPos
      //        load(at: cell.index)
      ////        cell.position = pos
      //      }
      //      var animated = animated
      //      if cell.view != nil {
      //        animated = animated && (cell.isLoaded || (cell.view != nil && v1 != v2))
      //        animate(animated) {
      //          cell.update(frame: frame(for: cell))
      //        }
      //      }
    }
    if let from = unloaded {
      for i in from..<cells.count {
        let cell = cells[i]
        //        cell.index += index
        cell.position.y += offset
        if cell.view != nil {
          cell.update(frame: frame(for: cell))
        }
      }
    }
  }
  
  override public func update(frame: CGRect) {
    //    guard view.frame.size != frame.size else { return }
    super.update(frame: frame)
    
    //    testLoadedRange()
    
    let swidth = frame.width
    //    var cellsInRow = [TableCell]()
    var width: CGFloat = 0
    var height: CGFloat = 0
    var maxHeight: CGFloat = 0
    for cell in cells {
      let name = cell.description
      let cwidth = self.width(for: cell)
      let spaceLeft = swidth-width
      if spaceLeft >= cwidth {
        maxHeight = max(maxHeight,cell.size.height)
        move(cell: cell, to: Pos(width,height), animated: false)
        if cell.isLoaded {
          print("\(name)", terminator: " ")
        }
      } else {
        height += maxHeight + gap
        move(cell: cell, to: Pos(0,height), animated: false)
        maxHeight = cell.size.height
        width = 0
        if cell.isLoaded {
          print("  +\(Int(maxHeight + gap))\n\(name)", terminator: " ")
        }
      }
      width += cwidth + gap
    }
    
    contentHeight = height + maxHeight
    //    testLoadedRange()
    
    //    let cells = cellsInRow(with: self.cells.last!)
    //    let width = self.width(for: cells)
    //    let spaceLeft = self.width - width
    //    if spaceLeft >= self.width(for: cell) {
    //      cell.position.x = width
    //      cell.position.y = cells.first!.position.y
    //    } else {
    //      let h = max(height(for: cells),cell.size.height)
    //      contentHeight += gap + h
    //      cell.position.x = 0
    //      cell.position.y = contentHeight
    //    }
  }
  
  func testLoadedRange() {
    
    var rstart = -1
    var rend = 0
    for cell in cells where cell.isLoaded {
      if rstart == -1 { rstart = cell.index }
      rend = max(cell.index,rend)
    }
    
    var cstart = -1
    var cend = 0
    for cell in cells where cell.isInCamera {
      if cstart == -1 { cstart = cell.index }
      cend = max(cell.index,cend)
    }
    
    let a: Bool = cells[loadedRange.lowerBound].previous?.isLoaded ?? false
    let b: Bool = cells[loadedRange.upperBound-1].next?.isLoaded ?? false
    let c: Bool = rstart != cstart || rstart != loadedRange.lowerBound
    let d: Bool = rend != cend || rend != loadedRange.upperBound-1
    
    if a||b||c||d {
      print("""
        —— loaded ranges ——
        \(loadedRange.shortDescription) loadedRange
        \(rstart)...\(rend) isLoaded
        \(cstart)...\(cend) isInCamera
        """)
    }
    
    assert(!a)
    assert(!b)
    assert(!c)
    assert(!d)
  }
  
  func move(cell: TableCell, to pos: Pos, animated: Bool) {
    let oldValue = cell.position
    let v1 = loadedRange.contains(cell.index)
    cell.position = pos
    let v2 = cell.isInCamera
    var animated = animated
    if cell.view != nil {
      animated = animated && (cell.isLoaded || (cell.view != nil && v1 != v2))
      animate(animated) {
        cell.update(frame: frame(for: cell))
      }
    }
    //    print("\nloaded: \(loadedRange.shortDescription) moving \(cell.index)(\(cell)) \(v1)->\(v2)")
    guard v1 != v2 else { return }
    if v2 {
      let shouldMove = (animated && cell.view == nil)
      if shouldMove {
        cell.position = oldValue
      }
      noAnimation {
        load(at: cell.index)
      }
      if shouldMove {
        animate(true) {
          cell.update(frame: frame(for: cell))
        }
      }
    } else {
      unload(at: cell.index)
    }
    print("""
      <loaded>
      \(cells[loadedRange.lowerBound])
      ...
      \(cells[loadedRange.upperBound-1])
      <\\loaded>
      """)
  }
  
  func load(at index: Int) {
    assert(!loadedRange.contains(index))
    if index < loadedRange.lowerBound {
      load(index..<loadedRange.lowerBound)
    } else if index >= loadedRange.upperBound {
      load(loadedRange.upperBound..<index+1)
    }
  }
  
  func unload(at index: Int) {
    assert(loadedRange.contains(index))
    let cell = cells[index]
    if index == loadedRange.lowerBound {
      loadedRange.reduceLeft(by: 1)
      didLeave(cell: cell, shouldRemove: false)
    } else if index == loadedRange.upperBound - 1 {
      loadedRange.reduceRight(by: 1)
      didLeave(cell: cell, shouldRemove: false)
    } else {
      unload(index..<loadedRange.upperBound)
    }
  }
  
  func cellsInRow(with cell: TableCell) -> ArraySlice<TableCell> {
    var left = cell
    var right = cell
    while let c = left.previous {
      guard c.position.y == left.position.y else { break }
      left = c
    }
    while let c = right.next {
      guard c.position.y == right.position.y else { break }
      right = c
    }
    return cells[left.index...right.index]
  }
  func width<T: Collection>(for cells: T) -> CGFloat where T.Element == TableCell {
    var spaceLeft = (gap * CGFloat(cells.count))
    
    for cell in cells {
      spaceLeft += width(for: cell)
    }
    return spaceLeft
  }
  func width(for cell: TableCell) -> CGFloat {
    if cell.size.width == 0 {
      return size.width
    } else {
      return cell.size.width
    }
  }
  func height<T: Collection>(for cells: T) -> CGFloat where T.Element == TableCell {
    var height: CGFloat = 0
    for cell in cells {
      height = max(height,cell.size.height)
    }
    return height
  }
  
  override public func append(_ cell: TableCell, animated: Bool) {
    cell.table = self
    cell.index = cells.count
    
    if !cells.isEmpty {
      let cells = cellsInRow(with: self.cells.last!)
      var width = self.width(for: cells)
      width += gridInset.left
      let spaceLeft = self.size.width - gridInset.right - width
      if spaceLeft > self.width(for: cell) {
        print("\(cell)", terminator: " ")
        cell.position.x = width
        cell.position.y = cells.first!.position.y
      } else {
        print("\n\(cell)", terminator: " ")
        let h = height(for: cells)//max(height(for: cells),cell.size.height)
        //        if let cell = cell as? LineCell {
        //          print(h,cells.count)
        //        }
        //        if let cell = cell.previous as? LineCell {
        //          print(h,cells.count,"next")
        //        }
        contentHeight += gap + h
        cell.position.x = gridInset.left
        cell.position.y = contentHeight
      }
    } else {
      cell.position.x = gridInset.left
    }
    
    cells.append(cell)
    
    //    if cells.count > 1 {
    //      contentHeight += gap
    //    }
    //    set(offset: contentHeight, for: cell)
    
    //    contentHeight += height(for: cell)
    
    check()
    
    //    increment2d(&x, &y, width)
  }
}

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//  let output = items.map { "\($0)" }.joined(separator: separator)
//  Swift.print(output, separator: separator, terminator: terminator)
}
