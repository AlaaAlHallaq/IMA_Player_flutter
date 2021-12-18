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
            binaryMessenger: messenger
        )
    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
extension NSObjectProtocol {
    @discardableResult
    func with(_ action: (Self)->()) -> Self {
        action(self)
        return self
    }
}

class ViewControllerHost: UIView {
    let vc: UIViewController
    init(vc: UIViewController) {
        self.vc = vc
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    weak var lastParentVC: UIViewController!
    func update() {
        if let newParent = findParentVC() {
            if newParent != lastParentVC {
                lastParentVC = newParent

                _ = vc.view
                    .useAutoLayout()
                    .add(to: self)
                    .fillParent()

                newParent.addChild(self.vc)
                self.vc.didMove(toParent: newParent)
            }
        } else {
            lastParentVC = nil
            self.vc.willMove(toParent: nil)
            self.vc.view.removeFromSuperview()
            self.vc.removeFromParent()
        }
    }

    func findParentVC() -> UIViewController? {
        var next: UIResponder? = self
        while next != nil {
            if let vc = next as? UIViewController {
                return vc
            }
            next = next?.next
        }
        return nil
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.update()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.update()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    var player: AVPlayer!

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view, args)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView,_ args: Any?) {
        let dict = args as? [String:Any?]
        let urlAds = dict?["urlAds"] as? String ?? ""
        let urlVideo = dict?["urlVideo"] as? String ?? ""

        let playerViewContrller = PlayerViewController()
        playerViewContrller.ContentURLString = urlVideo
        playerViewContrller.AdTagURLString = urlAds
        _ = ViewControllerHost(vc: playerViewContrller)
            .useAutoLayout()
            .add(to: _view)
            .fillParent()
    }

    func createNativeView2(view _view: UIView) {
        _ =
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

class AutoLayoutLayerContainer: UIView {
    var onLayoutChanged: (UIView) -> () = { _ in }
    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutChanged(self)
    }
}
