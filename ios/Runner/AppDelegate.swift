import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CBCentralManagerDelegate, FlutterStreamHandler {
  private var centralManager: CBCentralManager!
  private var eventSink: FlutterEventSink?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

          guard let bleController = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
          }
          let bluetoothStateMethodChannel = FlutterMethodChannel(name: "samples.flutter.method/bluetooth", binaryMessenger: bleController.binaryMessenger)

          bluetoothStateMethodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in 
            guard call.method == "getBluetoothState" else {
              result(FlutterMethodNotImplemented)
              return
            }
            self?.getBluetoothState(result: result)
          })
        let bluetoothStateEventChannel = FlutterEventChannel(name: "samples.flutter.event/bluetooth", binaryMessenger: bleController.binaryMessenger)

        bluetoothStateEventChannel.setStreamHandler(self)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlterKey: false])

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)


        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                                  binaryMessenger: controller.binaryMessenger)
            batteryChannel.setMethodCallHandler({
              [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
              // This method is invoked on the UI thread.
              guard call.method == "getBatteryLevel" else {
                result(FlutterMethodNotImplemented)
                return
              }
              self?.receiveBatteryLevel(result: result)
            })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
    private func getBluetoothState(result: FlutterResult) {
      if(self.centralManager.state == .poweredOn){
        result("Yes");
      } else {
        result("No");
      }
    }

    func onListen(withArguments arguments: Any?,eventSink: @escaping FlutterEventSink) -> FlutterError? {
                   self.eventSink = eventSink
                   return nil
               }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
           eventSink = nil
           return nil
       }

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
   guard let eventSink = eventSink else {
        return
      }
             switch central.state {
                 case .poweredOn:
                   eventSink("on")


                 case .poweredOff:
                 eventSink("off")

                     // Alert user to turn on Bluetooth
                 case .resetting:
                 eventSink("resetting")

                     // Wait for next state update and consider logging interruption of Bluetooth service
                 case .unauthorized:
                 eventSink("unauthorized")

                     // Alert user to enable Bluetooth permission in app Settings
                 case .unsupported:
                  eventSink("unsupported")

                     // Alert user their device does not support Bluetooth and app will not work as expected
                 case .unknown:
                  eventSink("unknown")

                  default:
                  eventSink("not available")

                    // Wait for next state update
             }
         }

    private func receiveBatteryLevel(result: FlutterResult) {
      let device = UIDevice.current
      device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery level not available.",
                            details: nil))
      } else {
        print(Float(device.batteryLevel))
        result(Float(device.batteryLevel))
      }
    }
}
