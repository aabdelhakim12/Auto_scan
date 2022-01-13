import 'package:flutter/material.dart';
import 'package:projectapp/splash.dart';

import 'bluetooth_app.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project 2 App Robot Controller',
        theme: ThemeData(
          primaryColor: Colors.blue[900],
        ),
        home: Splash(),
        routes: {
          BluetoothApp.routeName: (ctx) => BluetoothApp(),
        });
  }
}
