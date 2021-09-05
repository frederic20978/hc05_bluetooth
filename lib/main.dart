import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hc05_bluetooth/selectDevice.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "hc05_bluetooth",
      home: FutureBuilder(
          future: FlutterBluetoothSerial.instance.requestEnable(),
          builder: (context, future) {
            if (future.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Container(
                  height: double.infinity,
                  child: Center(
                    child: Icon(
                      Icons.bluetooth_disabled,
                      size: 200.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
              );
            } else if (future.connectionState == ConnectionState.done) {
              // return MyHomePage(title: 'Flutter Demo Home Page');
              return Home();
            } else {
              return Home();
            }
          }),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SelectBondedDevicePage(checkAvailability: false);
  }
}
