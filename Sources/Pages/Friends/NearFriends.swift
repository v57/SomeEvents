//
//  NearFriends.swift
//  Some Events
//
//  Created by Димасик on 10/23/17.
//  Copyright © 2017 Dmitry Kozlov. All rights reserved.
//

import Some
import SomeBridge
import MultipeerConnectivity

class NearFriends: NSObject {
  var browser: MCNearbyServiceBrowser!
  var advertiser: MCNearbyServiceAdvertiser!
  var insertUser: ((Int64)->())?
  override init() {
    super.init()
    let me = MCPeerID(displayName: "\(ID.me)")
    advertiser = MCNearbyServiceAdvertiser(peer: me, discoveryInfo: nil, serviceType: "some-events")
    browser = MCNearbyServiceBrowser(peer: me, serviceType: "some-events")
    browser.delegate = self
  }
  var isRunning = false
  func start() {
    isRunning = true
    print("near friends: starting ")
    advertiser.startAdvertisingPeer()
    browser.startBrowsingForPeers()
  }
  func stop() {
    isRunning = false
    print("near friends: stopping ")
    advertiser.stopAdvertisingPeer()
    browser.stopBrowsingForPeers()
  }
  
  deinit {
    stop()
  }
}

extension NearFriends: MCNearbyServiceBrowserDelegate {
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    print("near friends: found peer \(peerID.displayName)")
    guard let id = Int64(peerID.displayName) else { return }
    guard id >= 0 else { return }
    guard !id.isMe else { return }
    self.insertUser?(id)
  }
  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    print("near friends: lost peer \(peerID.displayName)")
  }
  func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    print("near friends error: \(error)")
    wait(5) { [weak self] in
      guard self != nil else { return }
      guard self!.isRunning else { return }
      self!.start()
    }
  }
}
