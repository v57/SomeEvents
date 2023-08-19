//
//  ArrayPart.swift
//  Events
//
//  Created by Димасик on 3/3/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

import Foundation

//MARK:- ArrayPart
// 100% tested
protocol IndexedElement {
  var index: Int { get }
}

private extension Array {
  var lastIndex: Int {
    return count - 1
  }
  func contains(index: Int) -> Bool {
    return index >= 0 && index < count
  }
}
class ArrayPart<Element: IndexedElement> {
  var array = [Element]()
  var indexOffset = 0
  var size = 0
  
  var loadedBounds: Range<Int> {
    return indexOffset..<indexOffset + array.count
  }
  var lastLoaded: Int {
    return array.lastIndex + indexOffset
  }
  var lastIndex: Int {
    return size - 1
  }
  var isFirstLoaded: Bool {
    return indexOffset == 0
  }
  var isLastLoaded: Bool {
    return array.count + indexOffset == size
  }
  func index(for element: Element) -> Int {
    return element.index - indexOffset
  }
  func isLoaded(_ element: Element) -> Bool {
    return loadedBounds.contains(element.index)
  }
  init() {
    
  }
  init(array: [Element], size: Int) {
    if !array.isEmpty {
      self.array = array
      self.indexOffset = array.first!.index
    }
    self.size = size
  }
  subscript(index: Int) -> Element? {
    let index = index - indexOffset
    guard array.contains(index: index) else { return nil }
    return array[index]
  }
  func insert(_ element: Element, notify: Bool = true) {
    let index = self.index(for: element)
    if index == array.count {
      // append
      append(elements: [element], notify: notify)
    } else if array.contains(index: index) {
      // override
      replace(offset: index, with: [element], notify: notify)
    } else if index == -1 {
      // insert(at: 0)
      insert(elements: [element], notify: notify)
    } else {
      if index > array.count {
        size = max(size,index + 1)
      }
      insertFailed(for: [element])
    }
  }
  func insert(_ elements: [Element], notify: Bool = true) {
    guard !elements.isEmpty else { return }
    if array.isEmpty {
      indexOffset = elements.first!.index
      size = elements.last!.index + 1
      append(elements: elements, notify: notify)
      return
    } else {
      let start = elements.first!.index - indexOffset
      let end = elements.last!.index - indexOffset
      guard end >= -1 else {
        insertFailed(for: elements)
        return }
      guard start <= array.count else {
        size = max(size,elements.last!.index + 1)
        insertFailed(for: elements)
        return }
      
      if start == array.count {
        append(elements: elements, notify: notify)
      } else if end == -1 {
        insert(elements: elements, notify: notify)
      } else {
        var inserted = [Element]()
        var replaced = [Element]()
        var replacedOffset = 0
        var appended = [Element]()
        
        if start < 0 {
          inserted = Array(elements[..<(-start)])
          if end >= array.count {
            replaced = Array(elements[(-start)..<(array.count-start)])
            appended = Array(elements[(array.count-start)...])
          } else {
            replaced = Array(elements[(-start)...])
          }
        } else {
          replacedOffset = start
          if end >= array.count {
            appended = Array(elements[(array.count-start)...])
            replaced = Array(elements[..<(array.count-start)])
          } else {
            replaced = Array(elements[...(end-start)])
          }
        }
        
        if !inserted.isEmpty {
          insert(elements: inserted, notify: notify)
        }
        if !replaced.isEmpty {
          replace(offset: replacedOffset, with: replaced, notify: notify)
        }
        if !appended.isEmpty {
          append(elements: appended, notify: notify)
        }
      }
    }
  }
  private func insert(elements: [Element], notify: Bool) {
    array.insert(contentsOf: elements, at: 0)
    indexOffset -= elements.count
    if notify {
    added(first: elements)
    }
  }
  private func append(elements: [Element], notify: Bool) {
    let a = isLastLoaded
    if a {
      size += elements.count
    }
    array.append(contentsOf: elements)
    
    if notify {
    let b = isLastLoaded
    if a != b && !b {
      /*
       Очень редкая ситуация:
       нету интернета, написал сообщение появился интернет и добавилось больше 500 новых сообщений
       от сервера прийдёт тока 500
       надо удалить сначала отправленные сообщения, потом отобразить новые
       */
      updated(isLastLoaded: false)
    }
    added(last: elements)
    if a != b && b {
      /*
       Тут наоборот, если чат не был загружен полностью и
       пришло 100 сообщений и чат весь загрузился,
       то сначало надо добавить новые сообщения, потом добавить отправляемые
       */
      updated(isLastLoaded: true)
    }
    }
  }
  private func replace(offset: Int, with elements: [Element], notify: Bool) {
    for (i,element) in elements.enumerated() {
      array[i+offset] = element
    }
    if notify {
    replaced(elements: elements)
    }
  }
  func clear() {
    array.removeAll()
    indexOffset = 0
    size = 0
  }
  
  func set(size: Int) {
    guard self.size != size else { return }
    let a = isLastLoaded
    self.size = size
    let b = isLastLoaded
    if a != b {
      updated(isLastLoaded: b)
    }
  }
  
  func updated(isLastLoaded: Bool) {
    
  }
  func added(last elements: [Element]) {
    
  }
  func added(first elements: [Element]) {
    
  }
  func insertFailed(for elements: [Element]) {
    
  }
  func replaced(elements: [Element]) {
    
  }
}
