import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart';

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
      home: const MyHomePage(title: 'Main page'),
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
  LatLng curPos = LatLng(0, 0);

  bool ambulanceInRange = false;

  @override
  void initState() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    Future.delayed(Duration.zero, () async {
      //Handle push notifications

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_noti');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      const androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "flutter_background example app",
        notificationText:
            "Background notification for keeping the example app running in the background",
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
            name: 'background_icon',
            defType: 'drawable'), // Default is ic_launcher from folder mipmap
      );
      bool success;
      success =
          await FlutterBackground.initialize(androidConfig: androidConfig);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    });
    final periodicTimer =
        Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      _getLocation();
      final queryParams = {
        "lat": "${curPos.latitude}",
        "lon": "${curPos.longitude}"
      };
      String temp = "";
      var uri = Uri.http("20.175.230.31", "/inrange", queryParams);
      //debugPrint(uri.toString());
      final resp = await http.get(uri).timeout(
            const Duration(seconds: 3),
          );
      temp = resp.body;
      try {
        ambulanceInRange = jsonDecode(temp)['val'];
      } catch (e) {
        ambulanceInRange = false;
        debugPrint(e.toString());
      }
      if (ambulanceInRange) {
        Future.delayed(Duration.zero, () async {
          setState(() {});
          const AndroidNotificationDetails androidNotificationDetails =
              AndroidNotificationDetails('your channel id', 'your channel name',
                  channelDescription: 'your channel description',
                  importance: Importance.max,
                  priority: Priority.high,
                  ticker: 'ticker');
          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidNotificationDetails);
          await flutterLocalNotificationsPlugin.show(
              0, 'Alert', 'Ambulance in proximity', notificationDetails,
              payload: 'item x');
        });
      }
    });
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
          visible: ambulanceInRange,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: const DecoratedBox(
                decoration:
                    BoxDecoration(color: Color.fromARGB(199, 219, 27, 27))),
          )),
    );
  }
}
