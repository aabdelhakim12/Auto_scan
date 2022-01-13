import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/helper/helper.dart';

class AppBarActions {
  static appBarActions(getPairedDevices, _scaffoldKey) {
    return Column(
      children: [
        // ignore: deprecated_member_use
        FlatButton.icon(
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          label: Text(
            "Refresh",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          splashColor: Colors.deepPurple,
          onPressed: () async {
            // So, that when new devices are paired
            // while the app is running, user can refresh
            // the paired devices list.
            await getPairedDevices().then((_) {
              BluetoothHelper.show(_scaffoldKey, 'Device list refreshed');
            });
          },
        ),
      ],
    );
  }
}
