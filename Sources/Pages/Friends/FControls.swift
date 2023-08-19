//
//  FControls.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import CoreBluetooth

extension CBUUID {
  convenience init(_ v1: UInt64, _ v2: UInt64) {
    let data = DataWriter()
    data.append(v1)
    data.append(v2)
    self.init(data: data.data)
  }
}

class FControls: Block {
  static var height: CGFloat = 40
  static let name = "Robu"
  static let uuid = CBUUID(0xd05600b437494864,0xa02992fbd95f9f0b)
  var manager: CBCentralManager!
  
  let appLink = Button(icon: #imageLiteral(resourceName: "FAppLink"), text: "Share app link", description: nil)
  let profileLink = Button(icon: #imageLiteral(resourceName: "FProfileLink"), text: "Share profile link", description: nil)
  let findFriends = Button(icon: #imageLiteral(resourceName: "FFindFriends"), text: "Find near friends", description: "Turn on bluetooth to use this feature")
  var insertUser: ((User)->())?
  
  var findStatus: Status = .idle {
    didSet {
      guard findStatus != oldValue else { return }
      switch findStatus {
      case .idle: stopScan()
      case .searching: scan()
      }
    }
  }
  
  
  init() {
    super.init(height: FControls.height * 3)
    manager = CBCentralManager(delegate: self, queue: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func scan() {
    guard findStatus == .searching else { return }
    guard manager.state == .poweredOn else { return }
    manager.scanForPeripherals(withServices: [FControls.uuid], options: nil)
  }
  
  func stopScan() {
    manager.stopScan()
  }
  
}

extension FControls: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      scan()
    default: break
    }
  }
  
  func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    guard let id = advertisementData["id"] as? Int64 else {
      print("found user without id")
      return }
    print("found user with id: \(id)")
    id.loadUser { [weak self] user in
      self?.insertUser?(user)
    }
  }
}

extension FControls {
  enum Status {
    case idle, searching
  }
}

extension FControls {
  class Button: UIView {
    let imageView: UIImageView
    let titleLabel: UILabel
    var descriptionLabel: UILabel?
    var action: (()->())?
    init(icon: UIImage, text: String, description: String?) {
      let h = FControls.height
      let h2 = h/2
      imageView = UIImageView(image: icon)
      imageView.contentMode = .center
      imageView.center = CGPoint(h2,h2)
      
      titleLabel = UILabel()
      
      super.init(frame: CGRect(0,0,0,h))
      addSubview(imageView)
      addSubview(titleLabel)
      if let descriptionLabel = descriptionLabel {
        addSubview(descriptionLabel)
      }
      addTap(#selector(tap))
    }
    
    func touch(action: @escaping ()->()) {
      self.action = action
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tap() {
      self.bounce()
    }
  }
}

