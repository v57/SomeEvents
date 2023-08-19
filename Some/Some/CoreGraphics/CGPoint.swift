//
//  CGPoint.swift
//  mutating funcs
//
//  Created by Димасик on 02/09/16.
//  Copyright © 2016 Димасик. All rights reserved.
//

import CoreGraphics


extension CGPoint {
  public init(_ x: CGFloat, _ y: CGFloat) {
    self = CGPoint(x: x, y: y)
  }
  public static func == (left: CGPoint, right: CGPoint) -> Bool {
    return left.x == right.x && left.y == right.y
  }
  public static func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
  }
  public static func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
  }
  public static func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
  }
  public static func += (left: inout CGPoint, right: CGVector) {
    left = left + right
  }
  public static func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
  }
  public static func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
  }
  public static func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
  }
  public static func -= (left: inout CGPoint, right: CGVector) {
    left = left - right
  }
  public static func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
  }
  public static func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
  }
  public static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
  }
  public static func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
  }
  public static func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
  }
  public static func *= (left: inout CGPoint, right: CGVector) {
    left = left * right
  }
  public static func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
  }
  public static func /= (left: inout CGPoint, right: CGPoint) {
    left = left / right
  }
  public static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
  }
  public static func /= (point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
  }
  public static func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
  }
  public static func /= (left: inout CGPoint, right: CGVector) {
    left = left / right
  }
}
