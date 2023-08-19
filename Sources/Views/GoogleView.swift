//
//  GoogleView.swift
//  Events
//
//  Created by Димасик on 2/22/18.
//  Copyright © 2018 Dmitry Kozlov. All rights reserved.
//

//import UIKit
//import GoogleMobileAds
//import Some
import SomeFunctions

let google = Google()
class Google: Manager {
  /*
  private let video = GoogleVideo()
 */
  func setup() {
    /*
    GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544~1458002511")
    video.setup()
 */
  }
  func start() {
    
  }
  /*
  @discardableResult
  final func displayAd(for content: Content, completion: @escaping ()->()) -> Bool {
    
    guard !content.isDownloaded else { return false }
    guard video.isReady && video.shouldPlay else { return false }
    video.display(completion: completion)
    return true
  }
  final func view(size: GADAdSize) -> DPView {
    return GoogleView(size: size)
  }
 */
}
/*
private class GoogleVideo {
  let timeout: Time = 15 * .minute
  var lastPlayed: Time = 0
  let delegate = GoogleVideoDelegate()
  
  var isReady: Bool {
    return GADRewardBasedVideoAd.sharedInstance().isReady
  }
  var shouldPlay: Bool {
    return Time.now - timeout > lastPlayed
  }
  init() {
  }
  func setup() {
    GADRewardBasedVideoAd.sharedInstance().delegate = delegate
    GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
  }
  func display(completion: @escaping ()->()) {
    lastPlayed = .now
    delegate.closed = completion
    GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: main)
  }
}
private class GoogleVideoDelegate: NSObject, GADRewardBasedVideoAdDelegate {
  var closed: (()->())?
  
  
  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                          didRewardUserWith reward: GADAdReward) {
    print("Reward received with currency: \(reward.type), amount \(reward.amount).")
  }
  
  func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
    print("Reward based video ad is received.")
  }
  
  func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Opened reward based video ad.")
  }
  
  func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad started playing.")
  }
  
  func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad is closed.")
  }
  
  func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
    print("Reward based video ad will leave application.")
  }
  
  func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                          didFailToLoadWithError error: Error) {
    print("Reward based video ad failed to load.")
  }
}

extension GADAdSize {
  static let s320x50 = kGADAdSizeBanner
  static let s320x100 = kGADAdSizeLargeBanner
  static let s300x250 = kGADAdSizeMediumRectangle
  static let s468x60 = kGADAdSizeFullBanner
  static let s728x90 = kGADAdSizeLeaderboard
  static let s120x600 = kGADAdSizeSkyscraper
  static let portrait = kGADAdSizeSmartBannerPortrait
  static let landscape = kGADAdSizeSmartBannerLandscape
}
private class GoogleView: DPView, GADBannerViewDelegate {
  let bannerView: GADBannerView
  let label: UILabel
  init(size: GADAdSize) {
    
    bannerView = GADBannerView(adSize: size)
    bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
    bannerView.rootViewController = main
    bannerView.cornerRadius = .margin
    label = UILabel(pos: size.size.center, anchor: .center, text: "AD", color: .black, font: .bold(40))
    super.init(frame: CGRect(origin: .zero, size: size.size))
    
    addSubview(label)
    bannerView.delegate = self
    bannerView.load(GADRequest())
    addBackground(radius: .margin)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    addSubview(bannerView)
    bannerView.bounce()
  }
  
  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
              didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }
  
  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }
  
  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }
  
  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }
  
  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}
*/
