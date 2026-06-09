import Flutter
import UIKit

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger
    
    if let registrar = self.registrar(forPlugin: "ARKitPlugin") {
      let factory = ARKitViewFactory(messenger: messenger)
      registrar.register(
        factory,
        withId: "arkit_flutter_plugin/view"
      )
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
