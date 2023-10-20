import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BatteryIndicator extends StatefulWidget {
  const BatteryIndicator({super.key});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level';
  static const EventChannel eventChannel =
      EventChannel('samples.flutter.event/bluetooth');
  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.method/bluetooth');
  String _bluetoothStatus = 'Bluetooth status';
  String _bleState = 'not';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final double result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
      print(result);
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    setState(() {
      print(batteryLevel);
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getBluetoothState() async {
    String bluetoothState;
    try {
      final String? result =
          await methodChannel.invokeMethod('getBluetoothState');
      bluetoothState = '$result%';
    } on PlatformException {
      bluetoothState = 'Failed to get battery level.';
    }
    setState(() {
      _bleState = bluetoothState;
    });
  }

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object? event) {
    setState(() {
      _bluetoothStatus = "Bluetooth status: ${event == 'on' ? 'on' : 'off'}";
      _getBluetoothState();
    });
  }

  void _onError(Object error) {
    setState(() {
      _bluetoothStatus = 'Battery status: unknown.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Battery Percentage ---->'),
      //   actions: [
      //     Text(_batteryLevel),
      //   ],
      // ),
      backgroundColor: Colors.blue,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_batteryLevel),
              ElevatedButton(
                onPressed: () {
                  _getBatteryLevel();
                },
                child: const Text('Get Battery Percentage'),
              ),
              Text('Bluetooth Status: $_bluetoothStatus'),
              Text('Bluetooth Status: $_bleState'),
            ],
          ),
        ),
      ),
    );
  }
}
