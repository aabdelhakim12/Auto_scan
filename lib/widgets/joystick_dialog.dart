import 'package:control_pad/views/joystick_view.dart';
import 'package:flutter/material.dart';

class JoyStickDialog {
  static showJoyStickComponents(
    context,
    upFieldController,
    rightFieldController,
    leftFieldController,
    downFieldController,
    Function _sendTextMessageToBluetooth,
    _connected,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color.fromRGBO(227, 227, 227, 1),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel, color: Colors.red, size: 35)),
          Center(
              child: Text('Use joy stick to move',
                  style: TextStyle(color: Colors.blue, fontSize: 20))),
          Container(
            margin: EdgeInsets.all(50),
            child: JoystickView(
              interval: Duration(
                milliseconds: 200,
              ),
              showArrows: true,
              backgroundColor: Colors.greenAccent,
              innerCircleColor: Colors.redAccent,
              onDirectionChanged: (degrees, distance) {
                // print(degrees);
                // print(distance);

                if (_connected && distance >= 0.5) {
                  if (degrees > 45 && degrees < 135) {
                    _sendTextMessageToBluetooth('ri');
                  } else if (degrees > 225 && degrees < 315) {
                    _sendTextMessageToBluetooth('le');
                  } else if ((degrees > 0 && degrees < 45) ||
                      (degrees > 315 && degrees < 360)) {
                    _sendTextMessageToBluetooth('up');
                  } else if (degrees > 135 && degrees < 225) {
                    _sendTextMessageToBluetooth('dn');
                  }
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
