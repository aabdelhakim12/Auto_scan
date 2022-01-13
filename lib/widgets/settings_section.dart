import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SettingSection {
  static settingSection() {
    return Column(children: [
      GestureDetector(
        onTap: () => FlutterBluetoothSerial.instance.openSettings(),
        child: Row(
          children: [
            IconButton(
              iconSize: 20,
              icon: Icon(Icons.settings),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
      Divider(),
      Text(
        "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    ]);
  }
}
