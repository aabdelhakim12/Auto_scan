import 'package:flutter/material.dart';
import 'package:projectapp/widgets/joystick_dialog.dart';

class JoyStickSection {
  static joyStick(
      context,
      upFieldController,
      rightFieldController,
      leftFieldController,
      downFieldController,
      _sendTextMessageToBluetooth,
      _connected) {
    return Column(
      children: [
        Divider(),
        Text(
          "Click to use Joy Stick",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
        SizedBox(height: 20),
        IconButton(
          iconSize: 100,
          onPressed: () {
            return JoyStickDialog.showJoyStickComponents(
                context,
                upFieldController,
                rightFieldController,
                leftFieldController,
                downFieldController,
                _sendTextMessageToBluetooth,
                _connected);
          },
          icon: Image.asset(
            'assets/images/joystick.png',
          ),
        ),
        Divider(),
      ],
    );
  }
}
