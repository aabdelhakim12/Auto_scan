import 'package:flutter/material.dart';
import 'package:projectapp/bluetooth_app.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      useLoader: false,
      gradientBackground: LinearGradient(colors: [
        Colors.cyan[900],
        Colors.blueGrey,
      ]),
      seconds: 2,
      navigateAfterSeconds: BluetoothApp(),
      title: Text(
        'Auto Scan',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      photoSize: 150,
      image: Image.asset(
        'assets/images/auto.png',
      ),
    );
  }
}
