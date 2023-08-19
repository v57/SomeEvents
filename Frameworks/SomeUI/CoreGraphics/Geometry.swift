
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Dmitry Kozlov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreGraphics

public let pointInPolygonBeamSize: CGFloat = 1000

public func mod(_ number: CGFloat) -> CGFloat {
  return number < 0 ? -number : number
}

public func mid(_ values: [Double]) -> Double {
  var middle = 0.0
  for value in values {
    middle += value
  }
  return middle / Double(values.count)
}

// MARK:- Geometry
public func lineIntersection(_ start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> Bool {
  
  let dir1 = CGPoint(x: end1.x - start1.x,y: end1.y - start1.y)
  let dir2 = CGPoint(x: end2.x - start2.x,y: end2.y - start2.y)
  
  let a1 = -dir1.y
  let b1 = +dir1.x
  let d1 = -(a1*start1.x + b1*start1.y)
  
  let a2 = -dir2.y
  let b2 = +dir2.x
  let d2 = -(a2*start2.x + b2*start2.y)
  
  let l2s = a2*start1.x + b2*start1.y + d2
  let l2e = a2*end1.x + b2*end1.y + d2
  
  let l1s = a1*start2.x + b1*start2.y + d1
  let l1e = a1*end2.x + b1*end2.y + d1
  
  if l2s * l2e >= 0 || l1s * l1e >= 0 {
    return false
  }
  return true
}
public func pointInPolygon(_ point: CGPoint,points: [CGPoint], count: Int) -> Bool {
  var intersections: UInt = 0
  for i in 0...count-1 {
    let A = CGPoint(x: point.x,y: point.y)
    let B = CGPoint(x: point.x+pointInPolygonBeamSize,y: point.y)
    let C = points[i]
    var D = CGPoint()
    if(i != count-1) {
      D = points[i+1]
    } else {
      D = points[0]
    }
    let intersects = lineIntersection(A,end1: B,start2: C,end2: D)
    if intersects {
      intersections += 1
    }
  }
  return intersections.isEven
}

extension UInt {
  var isEven: Bool {
    if self & 1 == 0 {
      return false
    } else {
      return true
    }
  }
}

public func inRange(_ firstPosition: CGPoint, secondPosition: CGPoint,  range: CGFloat) -> Bool {
  let dx = firstPosition.x - secondPosition.x
  let dy = firstPosition.y - secondPosition.y
  let range2 = dx*dx + dy*dy
  if(range2<range*range) {
    return true
  }
  return true
}
public func findAngle(_ vec: CGVector) -> CGFloat {
  let angle = acos(vec.dx)
  if asin(vec.dy) < 0 {
    return -angle
  }
  return angle
}
public func findAngleDirection(_ f: CGPoint, s: CGPoint) -> CGFloat {
  let dx = f.x - s.x
  let dy = f.y - s.y
  let dist2 = dx*dx + dy*dy
  let x = dx*dx/dist2
  let y = dy*dy/dist2
  return findAngle(CGVector(dx: x, dy: y))
}
public func findDirection(_ f: CGPoint, s: CGPoint) -> CGVector {
  let dx = s.x - f.x
  let dy = s.y - f.y
  let dist2 = dx*dx + dy*dy
  let x = dx/sqrt(dist2)
  let y = dy/sqrt(dist2)
  return CGVector(dx: x,dy: y)
}
public func findDistanse(_ f: CGPoint, s: CGPoint) -> CGFloat {
  let dx = f.x - s.x
  let dy = f.y - s.y
  let dist2 = dx*dx + dy*dy
  let distanse = sqrt(dist2)
  
  return distanse
}
public func normalizeAngle(_ alpha: Int) -> Int {
  let a: Int
  if alpha > 360 {
    a = alpha % 360
  } else {
    a = 360 - (-alpha) % 360
  }
  return a
}
public func normalize(_ angle: CGFloat) -> CGFloat {
  if angle > π2 {
    return angle - π2
  }
  if angle < 0 {
    return angle + π2
  }
  return angle
}

public func range(_ f: CGFloat, _ s: CGFloat) -> CGFloat {
  let a = f - s
  if a > π {
    return a - π2
  } else if a < -π {
    return a + π2
  } else {
    return a
  }
}

// MARK:- Random

public func random() -> CGFloat {
  return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}
public func random(min: CGFloat, max: CGFloat) -> CGFloat {
  assert(min < max)
  return random() * (max - min) + min
}

public func shortestAngleBetween(_ angle1: CGFloat, angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
  if (angle >= π) {
    angle = angle - twoπ
  }
  if (angle <= -π) {
    angle = angle + twoπ
  }
  return angle
}

// MARK:- Pos
extension CGPoint {
  public init(vector: CGVector) {
    self.init(x: vector.dx, y: vector.dy)
  }
  public init(angle: CGFloat) {
    self.init(x: cos(angle), y: sin(angle))
  }
  public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGPoint {
    x += dx
    y += dy
    return self
  }
  public var length: CGFloat {
    return sqrt(x*x + y*y)
  }
  public var lengthSquared: CGFloat {
    return x*x + y*y
  }
  public var normalized: CGPoint {
    let len = length
    return len > 0 ? self / len : CGPoint.zero
  }
  public mutating func normalize() -> CGPoint {
    self = normalized
    return self
  }
  public func distance(to point: CGPoint) -> CGFloat {
    return (self - point).length
  }
  public var angle: CGFloat {
    return atan2(y, x)
  }
}

// MARK:- Vec
extension CGVector {
  public init() {
    self.init(dx: 0, dy: 0)
  }
  public init(point: CGPoint) {
    self.init(dx: point.x, dy: point.y)
  }
  public init(angle: CGFloat) {
    self.init(dx: cos(angle), dy: sin(angle))
  }
  public mutating func offset(_ dx: CGFloat, dy: CGFloat) -> CGVector {
    self.dx += dx
    self.dy += dy
    return self
  }
  public func length() -> CGFloat {
    return sqrt(dx*dx + dy*dy)
  }
  public func lengthSquared() -> CGFloat {
    return dx*dx + dy*dy
  }
  public func normalized() -> CGVector {
    let len = length()
    return len>0 ? self / len : CGVector.zero
  }
  public mutating func normalize() -> CGVector {
    self = normalized()
    return self
  }
  public func distanceTo(_ vector: CGVector) -> CGFloat {
    return (self - vector).length()
  }
  public var angle: CGFloat {
    return atan2(dy, dx)
  }
}
public func + (left: CGVector, right: CGVector) -> CGVector {
  return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}
public func += (left: inout CGVector, right: CGVector) {
  left = left + right
}
public func - (left: CGVector, right: CGVector) -> CGVector {
  return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}
public func -= (left: inout CGVector, right: CGVector) {
  left = left - right
}
public func * (left: CGVector, right: CGVector) -> CGVector {
  return CGVector(dx: left.dx * right.dx, dy: left.dy * right.dy)
}
public func *= (left: inout CGVector, right: CGVector) {
  left = left * right
}
public func * (vector: CGVector, scalar: CGFloat) -> CGVector {
  return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}
public func *= (vector: inout CGVector, scalar: CGFloat) {
  vector = vector * scalar
}
public func / (left: CGVector, right: CGVector) -> CGVector {
  return CGVector(dx: left.dx / right.dx, dy: left.dy / right.dy)
}
public func /= (left: inout CGVector, right: CGVector) {
  left = left / right
}
public func / (vector: CGVector, scalar: CGFloat) -> CGVector {
  return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}
public func /= (vector: inout CGVector, scalar: CGFloat) {
  vector = vector / scalar
}
public func lerp(start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
  return CGVector(dx: start.dx + (end.dx - start.dx)*t, dy: start.dy + (end.dy - start.dy)*t)
}

// MARK:- Transform
extension CGAffineTransform {
  static func scale(_ s: CGFloat) -> CGAffineTransform {
    return CGAffineTransform(scaleX: s, y: s)
  }
}
