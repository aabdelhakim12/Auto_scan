// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'helper/helper.dart';
import 'widgets/settings_section.dart';

class DrawerS extends StatefulWidget {
  @override
  _DrawerSState createState() => _DrawerSState();
}

class _DrawerSState extends State<DrawerS> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;

  int _deviceState;
  double rating = 100;
  bool isDisconnecting = false;

  final textFieldController = TextEditingController();
  final testLEDONFieldController = TextEditingController();
  final testLEDOFFFieldController = TextEditingController();

  bool checkIfPressing = false;
  bool get isConnected => connection != null && connection.isConnected;

  List<BluetoothDevice> _devicesList = [];
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0;
    BluetoothHelper.enableBluetooth(_bluetoothState, getPairedDevices);

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.cyan[900],
                Colors.blueGrey,
              ]),
            ),
            padding: EdgeInsets.only(top: 25, left: 10),
            child: Text(
              'X-Ray',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Enable Bluetooth',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  activeColor: Colors.blue[900],
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value) {
                    future() async {
                      if (value) {
                        await FlutterBluetoothSerial.instance.requestEnable();
                      } else {
                        await FlutterBluetoothSerial.instance.requestDisable();
                      }

                      await getPairedDevices();
                      _isButtonUnavailable = false;

                      if (_connected) {
                        _disconnect();
                      }
                    }

                    future().then((_) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
          ),
          Divider(),
          SettingSection.settingSection(),
        ],
      ),
    );
  }

  void _disconnect() async {
    setState(() {
      _deviceState = 0;
    });

    await connection.close();
    BluetoothHelper.show(_scaffoldKey, 'Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }
}
