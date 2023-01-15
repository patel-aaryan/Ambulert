import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Main Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  LatLng curPos = LatLng(0, 0);

  Future _getLocation() async {
    Location location = Location();
    var _permissionGranted = await location.hasPermission();
    var _serviceEnabled = await location.serviceEnabled();
    var _loading = true;
    var _highAccuracy = true;
    _highAccuracy =
        await location.changeSettings(accuracy: LocationAccuracy.high);

    if (_permissionGranted != PermissionStatus.granted || !_serviceEnabled) {
      _permissionGranted = await location.requestPermission();
      _serviceEnabled = await location.requestService();
    } else {
      setState(() {
        _serviceEnabled = true;
        _loading = false;
      });
    }
    var _longitude;
    var _latitude;
    try {
      final LocationData currentPosition = await location.getLocation();
      setState(() {
        _longitude = currentPosition.longitude;
        _latitude = currentPosition.latitude;
        curPos = LatLng(_latitude, _longitude);
        _loading = false;
      });
    } on PlatformException catch (err) {
      _loading = false;
      debugPrint("-----> ${err.code}");
    }
  }

  int state = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            var uri = Uri.http("20.175.185.226", "/ambulance/");
            state = (state == 1) ? 0 : 1;
            var send = <String, String>{
              "ambulance_id": "3",
              "lat": curPos.latitude.toString(),
              "lon": curPos.longitude.toString(),
              "state": state.toString()
            };
            debugPrint(send.toString());
            var resp = await http.post(uri, body: send);
            debugPrint(resp.statusCode.toString());
          },
          child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.red),
              child: const Center(
                child: Text(
                  "EMERGENCY",
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ),
      ),
    );
  }
}
