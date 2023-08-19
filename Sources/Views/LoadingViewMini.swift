//
//  LoadingViewMini.swift
//  faggot
//
//  Created by Димасик on 22/05/16.
//  Copyright © 2016 Dmitry Kozlov. All rights reserved.
//

import Some

class DownloadingView: LoadingView {
  var displayLogo: Bool { return false }
  override func valueChanged() {
    shapeLayer.strokeEnd = self.value
  }
  override func startAnimating() {
//    shapeLayer.strokeEnd = 0.0
    shapeLayer.strokeEnd = 0.85
    shapeLayer.add(loadingAnimation, forKey: "Loading Animation")
  }
  override func stopAnimating() {
    shapeLayer.removeAllAnimations()
    shapeLayer.strokeEnd = 1.0
  }
  override func draw() {
    if displayLogo {
      logo.center = CGPoint(0,0)
      self.addSubview(logo)
    }
    
    backgroundLayer.path = UIBezierPath(arcCenter: CGPoint(0,0), radius: radius - 5, startAngle: 0, endAngle: π2 - 0.0001, clockwise: true).cgPath
    backgroundLayer.position = .zero
    backgroundLayer.fillColor = UIColor.clear.cgColor
    backgroundLayer.strokeColor = bgColor.cgColor
    backgroundLayer.lineWidth = 2.0
    backgroundLayer.strokeStart = 0.0
    backgroundLayer.strokeEnd = 1.0
    
    shapeLayer.path = UIBezierPath(arcCenter: CGPoint(0,0), radius: radius - 5, startAngle: -.pi / 2, endAngle: .pi * 1.5 + 0.0001, clockwise: true).cgPath
    shapeLayer.position = .zero
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.strokeColor = mainColor.cgColor
    shapeLayer.lineWidth = 2.0
    shapeLayer.lineCap = "round"
    shapeLayer.strokeStart = 0.0
    shapeLayer.strokeEnd = 0.0
    
    loadingAnimation.duration = 1.0
    loadingAnimation.repeatCount = Float.infinity
    loadingAnimation.fromValue = NSNumber(value:0.0)
    loadingAnimation.toValue = NSNumber(value: Double.pi*2)
    loadingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    
    stopAnimation.fromValue = NSNumber(value:1.5)
    stopAnimation.toValue = NSNumber(value:1)
    stopAnimation.duration = 0.2
    stopAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
    
    self.layer.addSublayer(backgroundLayer)
    self.layer.addSublayer(shapeLayer)
  }
  
  private lazy var logo = UIImageView(image: UIImage(named: "LogoIcon"))
  private let radius: CGFloat = 15
  
  private let shapeLayer = CAShapeLayer()
  private let backgroundLayer = CAShapeLayer()
  
  private let loadingAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
  private let stopAnimation = CABasicAnimation(keyPath: "transform.scale")
  
  private let mainColor: UIColor
  private let bgColor: UIColor
  
  override func show() {
    alpha = 1.0
    scale(1.0)
  }
  
  override func hide() {
    if superview != nil {
      animate ({
        alpha = 0.0
        scale(0.1)
      }) {
        self.animating = false
      }
    } else {
      alpha = 0.0
      scale(0.1)
    }
  }
  init(center: CGPoint, color: UIColor) {
    mainColor = color
    bgColor = .lightGray
    super.init(center: center)
  }
  
  override init(center: CGPoint) {
    mainColor = .system
    bgColor = .lightGray
    super.init(center: center)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
