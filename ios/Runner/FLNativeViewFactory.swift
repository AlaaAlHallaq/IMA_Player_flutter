import UIKit
import Flutter
import AVKit
import GoogleInteractiveMediaAds

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    var player:AVPlayer!
   
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        static let kTestAppAdTagUrl =
          "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
          + "iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&"
          + "output=vast&unviewed_position_start=1&"
          + "cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="

    guard let videoURL = URL(string: "https://storage.googleapis.com/gvabox/media/samples/stock.mp4") else { return }
       
        let layerContainer = AutoLayoutLayerContainer()
            .useAutoLayout()
            .add(to: _view)
            .fillParent()
        
        
         player = AVPlayer.init(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        layerContainer.layer.addSublayer(playerLayer)
        layerContainer.onLayoutChanged = {
            playerLayer.frame = $0.bounds
        }
        
        player.play()
      
    }
}




extension UIView {
    func useAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
    return self
}
    func add(to parent: UIView) -> Self {
        parent.addSubview(self)
        return self
    }
    func fillParent() -> Self {
        
        if let parent = self.superview {
            self.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
            self.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
            self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        }
        return self
    }
}
class AutoLayoutLayerContainer : UIView {
    var onLayoutChanged: (UIView)-> () = { _ in }
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutChanged(self)
    }
}
