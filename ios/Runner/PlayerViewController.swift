import AVFoundation
import UIKit
import GoogleInteractiveMediaAds

class PlayerViewController: UIViewController ,IMAAdsLoaderDelegate,IMAAdsManagerDelegate{
    var adsManager: IMAAdsManager!

    public var ContentURLString =
    "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"

    //"https://storage.googleapis.com/interactive-media-ads/media/bipbop.m3u8"
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    public var AdTagURLString = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="

    var adsLoader: IMAAdsLoader!

    var playerViewController: AVPlayerViewController!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black;
        setUpContentPlayer()
        setUpAdsLoader()
}
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated);
      requestAds()
    }
    func setUpAdsLoader() {
      adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self

    }
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
      adsManager = adsLoadedData.adsManager
        adsManager.delegate = self

      adsManager.initialize(with: nil)
    }
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
      // Play each ad once it has been loaded
      if event.type == IMAAdEventType.LOADED {
        adsManager.start()
      }
    }
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // Pause the content for the SDK to play ads.
           playerViewController.player?.pause()
           hideContentPlayer()
    }
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // Resume the content since the SDK is done playing ads (at least for now).
          showContentPlayer()
          playerViewController.player?.play()
    }
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
      // Fall back to playing content
      print("AdsManager error: " + (error.message ?? ""))
      showContentPlayer()
      playerViewController.player?.play()
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
      print("Error loading ads: " + (adErrorData.adError.message ?? ""))
      showContentPlayer()
      playerViewController.player?.play()
    }
    
    func requestAds() {
      // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.view, viewController: self)
      // Create an ad request with our ad tag, display container, and optional user context.
      let request = IMAAdsRequest(
          adTagUrl: self.AdTagURLString,
          adDisplayContainer: adDisplayContainer,
          contentPlayhead: contentPlayhead,
          userContext: nil)

      adsLoader.requestAds(with: request)
    }
    func setUpContentPlayer() {
        // Load AVPlayer with path to your content.
        guard let contentURL = URL(string: self.ContentURLString) else { return }
        let player = AVPlayer(url: contentURL)
        playerViewController = AVPlayerViewController()
        playerViewController.player = player

        // Set up your content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        );

        showContentPlayer()
    }

    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
      adsLoader.contentComplete()
    }
    func showContentPlayer() {
        self.addChild(playerViewController)
        playerViewController.view.frame = self.view.bounds
        self.view.insertSubview(playerViewController.view, at: 0)
        playerViewController.didMove(toParent: self)
    }

    func hideContentPlayer() {
        // The whole controller needs to be detached so that it doesn't capture  events from the remote.
        playerViewController.willMove(toParent: nil)
        playerViewController.view.removeFromSuperview()
        playerViewController.removeFromParent()
    }
}
