//
//  Range.swift
//  Table-final 2
//
//  Created by Димасик on 5/1/18.
//  Copyright © 2018 Димасик. All rights reserved.
//

import Foundation

extension Range where Bound == Int {
  mutating func left() {
    self = lowerBound - 1..<upperBound - 1
  }
  
  mutating func upLeft() {
    self = lowerBound..<upperBound - 1
  }
  
  mutating func right() {
    self = lowerBound + 1..<upperBound + 1
  }
  
  mutating func upRight() {
    self = lowerBound..<upperBound + 1
  }
  
  mutating func left(by offset: Int) {
    self = lowerBound - offset..<upperBound - offset
  }
  
  mutating func expandLeft(by offset: Int) {
    self = lowerBound - offset..<upperBound
  }
  
  mutating func expandRight(by offset: Int) {
    self = lowerBound..<upperBound + offset
  }
  
  mutating func reduceLeft(by offset: Int) {
    self = lowerBound + offset..<upperBound
  }
  
  mutating func reduceRight(by offset: Int) {
    self = lowerBound..<upperBound - offset
  }
  
  mutating func move(by offset: Int) {
    self = lowerBound + offset..<upperBound + offset
  }
  
  mutating func merge(with range: Range<Int>) {
    if isEmpty {
      self = range
    } else if lowerBound == range.upperBound {
      expandLeft(by: range.count)
    } else if upperBound == range.lowerBound {
      expandRight(by: range.count)
    }
  }
  
  mutating func remove(_ range: Range<Int>) {
    if lowerBound == range.lowerBound {
      reduceLeft(by: range.count)
    } else if upperBound == range.upperBound {
      reduceRight(by: range.count)
    }
  }
  
  mutating func remove(_ element: Int) {
    if element < lowerBound {
      left()
    } else if element < upperBound {
      upLeft()
    }
  }
  
  mutating func insert(_ element: Int) {
    if element <= lowerBound {
      right()
    } else if element < upperBound {
      upRight()
    }
  }
  
  mutating func insert2(_ element: Int) {
    if element <= lowerBound {
      right()
    } else if element <= upperBound {
      upRight()
    }
  }
  
  var shortDescription: String {
    let a = lowerBound
    let b = upperBound - 1
    if a == b {
      return a.description
    } else if a - b == 1 {
      return "\(lowerBound)..<\(upperBound)"
    } else {
      return "\(a)...\(b)"
    }
  }
}
