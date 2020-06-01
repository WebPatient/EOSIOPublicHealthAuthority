import Flutter
import UIKit

public class SwiftFlutterExposureNotificationsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_exposure_notifications", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterExposureNotificationsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  	if (call.method == "getPlatformVersion") {
		  result("iOS " + UIDevice.current.systemVersion)
    } else 
    if (call.method == "showAlertDialog") {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Dialog: UIAlertController(swift)", message: "UIAlertController in swift", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);         
      }
    } else 
    if (call.method == "showContactInfo") {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Dialog: UIAlertController(swift)", message: "UIAlertController in swift", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil);         
      }
    }
  }
}
