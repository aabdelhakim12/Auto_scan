import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:projectapp/drawer.dart';
import 'dart:async';
import 'dart:convert';
import 'package:projectapp/helper/helper.dart';
import 'package:projectapp/widgets/app_bar_actions.dart';
import 'package:projectapp/widgets/get_device_items.dart';
// import 'package:projectapp/widgets/joystick_section.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class BluetoothApp extends StatefulWidget {
  static const routeName = '/mainscr';
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection connection;

  // ignore: unused_field
  int _deviceState;
  double rating = 100;

  bool isDisconnecting = false;

  final textFieldController = TextEditingController();
  final upFieldController = TextEditingController();
  final downFieldController = TextEditingController();
  final rightFieldController = TextEditingController();
  final leftFieldController = TextEditingController();

  final testLEDONFieldController = TextEditingController();
  final testLEDOFFFieldController = TextEditingController();

  bool checkIfPressing = false;
  bool get isConnected => connection != null && connection.isConnected;
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  String mode;
  // double _currentSliderValueA = 0;
  // double _currentSliderValueB = 0;
  // double _currentSliderValueC = 0;
  double _currentSliderValueX = 0;
  double _currentSliderValueY = 0;

  bool colora = false;
  bool colorb = false;
  bool colorc = false;
  bool colorx = false;
  bool colory = false;
  bool f = true;
  Color dose = Colors.green;

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

  int sec = 3;
  int msec = 50;
  // ignore: unused_field
  Timer _timer;

  void startTimer() {
    const oneSec = const Duration(milliseconds: 10);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        print('$sec : $msec');
        if (sec == 0 && msec == 0) {
          setState(() {
            timer.cancel();
            dose = Colors.green;
            sec = 3;
            msec = 50;
          });
        } else {
          dose = Colors.red;
          if (msec == 0) {
            setState(() {
              sec--;
              msec = 99;
            });
          }
          setState(() {
            msec--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerS(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Auto Scan"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          AppBarActions.appBarActions(getPairedDevices, _scaffoldKey),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.cyan[900],
              Colors.blueGrey,
            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  "paired devices",
                  style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Device:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      width: 200,
                      child: DropdownButtonFormField(
                        hint: Text('select device'),
                        isExpanded: true,
                        items: GetDeviceItems.getDeviceItems(_devicesList),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty ? _device : null,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: Size.fromWidth(_connected ? 135 : 112),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    backgroundColor: _connected ? Colors.red : Colors.blue[900],
                  ),
                  onPressed: _isButtonUnavailable
                      ? null
                      : _connected
                          ? _disconnect
                          : _connect,
                  child: Text(
                    _connected ? 'Disconnect' : 'Connect',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Divider(color: Colors.grey, thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text(
                  "Exposure",
                  style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Radio(
                      value: 'e',
                      groupValue: mode,
                      onChanged: (val) {
                        setState(() {
                          mode = val;
                        });
                      },
                    ),
                    GestureDetector(
                      onLongPress: () {
                        if (mode == 'e') {
                          _sendTextMessageToBluetooth('e');
                          print('expsure');
                          startTimer();
                        }
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            color: dose),
                        child: Center(
                            child: Text(
                          'Dose',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text('00:$sec.$msec',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Note: Long press for initiating dose',
                        style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
              ),

              Divider(color: Colors.grey, thickness: 1),
              Center(
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 45,
                ),
              ),
              // radiolist(
              //     Row(
              //       children: [
              //         Expanded(
              //           child: Slider(
              //             value: _currentSliderValueA,
              //             max: 100,
              //             min: 0,
              //             divisions: 20,
              //             label: _currentSliderValueA.round().toString(),
              //             onChanged: (double a) {
              //               if (mode == 'a')
              //                 setState(() {
              //                   _currentSliderValueA = a;
              //                 });
              //             },
              //             onChangeStart: (val) {
              //               setState(() {
              //                 colora = false;
              //               });
              //             },
              //           ),
              //         ),
              //         CircleAvatar(
              //           backgroundColor: colora ? Colors.green : Colors.red,
              //           child: TextButton(
              //             onPressed: () {
              //               if (mode == 'a')
              //                 setState(() {
              //                   dynamic sv = _currentSliderValueA.toInt();
              //                   _sendTextMessageToBluetooth(
              //                       'a' + sv.toString());
              //                   colora = true;
              //                 });
              //             },
              //             child: Text(
              //               'Go',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     'a',
              //     'A: ${_currentSliderValueA.toInt()}%'),
              // radiolist(
              //     Row(
              //       children: [
              //         Expanded(
              //           child: Slider(
              //             value: _currentSliderValueB,
              //             max: 100,
              //             min: 0,
              //             divisions: 20,
              //             label: _currentSliderValueB.round().toString(),
              //             onChanged: (double a) {
              //               if (mode == 'b')
              //                 setState(() {
              //                   _currentSliderValueB = a;
              //                 });
              //             },
              //             onChangeStart: (val) {
              //               colorb = false;
              //             },
              //           ),
              //         ),
              //         CircleAvatar(
              //           backgroundColor: colorb ? Colors.green : Colors.red,
              //           child: TextButton(
              //             onPressed: () {
              //               if (mode == 'b')
              //                 setState(() {
              //                   dynamic sv = _currentSliderValueB.toInt();
              //                   _sendTextMessageToBluetooth(
              //                       'b' + sv.toString());
              //                   colorb = true;
              //                 });
              //             },
              //             child: Text(
              //               'Go',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     'b',
              //     'B: ${_currentSliderValueB.toInt()}%'),
              // radiolist(
              //     Row(
              //       children: [
              //         Expanded(
              //           child: Slider(
              //             value: _currentSliderValueC,
              //             max: 100,
              //             min: 0,
              //             divisions: 20,
              //             label: _currentSliderValueC.round().toString(),
              //             onChanged: (double a) {
              //               if (mode == 'c')
              //                 setState(() {
              //                   _currentSliderValueC = a;
              //                 });
              //             },
              //             onChangeStart: (val) {
              //               colorc = false;
              //             },
              //           ),
              //         ),
              //         CircleAvatar(
              //           backgroundColor: colorc ? Colors.green : Colors.red,
              //           child: TextButton(
              //             onPressed: () {
              //               if (mode == 'c')
              //                 setState(() {
              //                   dynamic sv = _currentSliderValueC.toInt();
              //                   _sendTextMessageToBluetooth(
              //                       'c' + sv.toString());
              //                   colorc = true;
              //                 });
              //             },
              //             child: Text(
              //               'Go',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     'c',
              //     'C: ${_currentSliderValueC.toInt()}%'),
              // Divider(color: Colors.grey, thickness: 1),
              // Center(
              //     child: Icon(
              //   Icons.lightbulb_outlined,
              //   size: 40,
              // )),
              Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Radio(
                            value: 'x',
                            groupValue: mode,
                            onChanged: (value) {
                              setState(() {
                                mode = 'x';
                              });
                            },
                          ),
                          SleekCircularSlider(
                            appearance: CircularSliderAppearance(
                              counterClockwise: true,
                              customWidths:
                                  CustomSliderWidths(progressBarWidth: 15),
                              size: size.width * 0.45,
                              customColors: CustomSliderColors(
                                  dynamicGradient: true,
                                  progressBarColors: [
                                    Colors.yellow,
                                    Colors.yellow[600],
                                    Colors.orange,
                                    Colors.orange[600],
                                    Colors.red,
                                    Colors.red[600],
                                  ],
                                  trackColor: Colors.blue[900]),
                              angleRange: 300,
                              startAngle: 120,
                              infoProperties:
                                  InfoProperties(bottomLabelText: 'X-Axis'),
                            ),
                            initialValue: 0,
                            max: 100,
                            min: 0,
                            onChangeStart: (v) => colorx = false,
                            onChangeEnd: (value) {
                              setState(() {
                                _currentSliderValueX = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            backgroundColor: colorx ? Colors.green : Colors.red,
                            child: TextButton(
                              onPressed: () {
                                if (mode == 'x')
                                  setState(() {
                                    dynamic sv = _currentSliderValueX.toInt();
                                    _sendTextMessageToBluetooth(
                                        'x' + sv.toString());
                                    colorx = true;
                                  });
                              },
                              child: Text(
                                'Go',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        color: Colors.grey,
                        height: 300,
                      ),
                      Column(
                        children: [
                          Radio(
                            value: 'y',
                            groupValue: mode,
                            onChanged: (value) {
                              setState(() {
                                mode = 'y';
                              });
                            },
                          ),
                          SleekCircularSlider(
                            appearance: CircularSliderAppearance(
                              customWidths:
                                  CustomSliderWidths(progressBarWidth: 15),
                              size: size.width * 0.45,
                              customColors: CustomSliderColors(
                                  dynamicGradient: true,
                                  progressBarColors: [
                                    Colors.yellow,
                                    Colors.yellow[600],
                                    Colors.orange,
                                    Colors.orange[600],
                                    Colors.red,
                                    Colors.red[600],
                                  ],
                                  trackColor: Colors.blue[900]),
                              angleRange: 300,
                              startAngle: 60,
                              infoProperties:
                                  InfoProperties(bottomLabelText: 'Y-Axis'),
                            ),
                            initialValue: 0,
                            max: 100,
                            min: 0,
                            onChangeStart: (v) => colory = false,
                            onChangeEnd: (value) {
                              setState(() {
                                _currentSliderValueY = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          CircleAvatar(
                            backgroundColor: colory ? Colors.green : Colors.red,
                            child: TextButton(
                              onPressed: () {
                                if (mode == 'y')
                                  setState(() {
                                    dynamic sv = _currentSliderValueY.toInt();
                                    _sendTextMessageToBluetooth(
                                        'y' + sv.toString());
                                    colory = true;
                                  });
                              },
                              child: Text(
                                'Go',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
              Divider(color: Colors.grey, thickness: 1),
              Padding(
                padding: EdgeInsets.all(10),
                child: radiolist(
                    Text(
                      'Motion Control',
                      style: TextStyle(color: Colors.indigo, fontSize: 20),
                    ),
                    'j',
                    ''),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.cyan[900],
                        Colors.blueGrey,
                      ]),
                      borderRadius: BorderRadius.circular(150)),
                  width: 300,
                  height: 300,
                  child: Stack(
                    children: [
                      moButton('up', Colors.green, null, 0.0, 125.0, null,
                          Icons.arrow_upward),
                      moButton('le', Colors.pink, null, 100.0, 25.0, null,
                          Icons.arrow_back),
                      moButton('ri', Colors.red, null, 100.0, null, 25.0,
                          Icons.arrow_forward),
                      moButton('dn', Colors.blue, 0.0, null, 125.0, null,
                          Icons.arrow_downward),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      BluetoothHelper.show(_scaffoldKey, 'No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
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

  void _sendTextMessageToBluetooth(String message) async {
    connection.output.add(utf8.encode(message + "\r\n"));
    print(message);
    await connection.output.allSent;
    setState(() {
      _deviceState = -1; // device off
    });
  }

  Widget radiolist(Widget wi, String val, String tit) {
    return RadioListTile(
      subtitle: Text(tit),
      value: val,
      groupValue: mode,
      onChanged: (val) {
        setState(() {
          mode = val;
        });
      },
      title: wi,
    );
  }

  Widget moButton(String di, color, b, t, l, r, icon) {
    return Positioned(
      right: r,
      top: t,
      bottom: b,
      left: l,
      width: 50,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: color,
        child: IconButton(
            onPressed: () {
              if (mode == 'j') _sendTextMessageToBluetooth(di);
            },
            icon: Icon(
              icon,
              size: 30,
              color: Colors.white,
            )),
      ),
    );
  }
}
