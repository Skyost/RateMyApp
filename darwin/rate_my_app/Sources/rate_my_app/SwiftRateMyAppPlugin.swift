#if canImport(Flutter)
    import Flutter
#elseif canImport(FlutterMacOS)
    import FlutterMacOS
#endif
import StoreKit
#if canImport(UIKit)
    import UIKit
#endif

public class SwiftRateMyAppPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        #if canImport(Flutter)
            let messenger = registrar.messenger()
        #elseif canImport(FlutterMacOS)
            let messenger = registrar.messenger
        #endif
        let channel = FlutterMethodChannel(name: "rate_my_app", binaryMessenger: messenger)
        let instance = SwiftRateMyAppPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case "launchNativeReviewDialog":
            result(requestReview())
        case "isNativeDialogSupported":
            result(true)
        case "launchStore":
            guard let appId = arguments?["appId"] as? String, !appId.isEmpty else {
                result(2)
                return
            }

            if openUrl(link: "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review") {
                result(0)
            } else {
                result(openUrl(link: "https://itunes.apple.com/app/id\(appId)") ? 1 : 2)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestReview() -> Bool {
        #if canImport(UIKit)
            if #available(iOS 14.0, *) {
                let foregroundScene = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first { scene in
                        scene.activationState == .foregroundActive || scene.activationState == .foregroundInactive
                    }

                guard let scene = foregroundScene else {
                    return false
                }

                SKStoreReviewController.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview()
            }
        #else
            SKStoreReviewController.requestReview()
        #endif
        return true
    }

    private func openUrl(link: String) -> Bool {
        guard let url = URL(string: link) else {
            return false
        }
        #if canImport(UIKit)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return true
            }
            return false
        #else
            return NSWorkspace.shared.open(url)
        #endif
    }
}
