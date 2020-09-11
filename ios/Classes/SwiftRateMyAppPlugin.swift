import Flutter
import StoreKit
import UIKit

public class SwiftRateMyAppPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "rate_my_app", binaryMessenger: registrar.messenger())
        let instance = SwiftRateMyAppPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: [String: Any?] = (call.arguments ?? [:]) as! [String: Any?]
        switch call.method {
        case "launchNativeReviewDialog":
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                result(true)
            } else {
                result(false)
            }
        case "isNativeDialogSupported":
            if #available(iOS 10.3, *) {
                result(true)
            } else {
                result(false)
            }
        case "launchStore":
            let appId: String? = arguments["appId"] as! String?
            if appId == nil || appId!.isEmpty {
                result(2)
                return
            }

            if openURL(link: "itms-apps://itunes.apple.com/app/id\(appId!)?action=write-review") {
                result(0)
            } else {
                result(openURL(link: "https://itunes.apple.com/app/id\(appId!)") ? 1 : 2)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func openURL(link: String) -> Bool {
        guard let url = URL(string: link) else {
            return false
        }

        if #available(iOS 10.0, *) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return true
            }
            return false
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
                return true
            }
            return false
        }
    }
}
