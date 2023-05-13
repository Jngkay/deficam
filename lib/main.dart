import 'package:deficam/camscreen.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:deficam/reportsScreen.dart';
import 'package:flutter/material.dart';
import 'package:deficam/splashScreen.dart';
import 'package:camera/camera.dart';
import 'package:deficam/classifyScreen.dart';
import 'package:firebase_core/firebase_core.dart';

//List<CameraDescription> cameras = List.empty(growable: true);
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const deficamApp());
}

class deficamApp extends StatelessWidget {
  const deficamApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: splashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}



/*
import 'package:camera/camera.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: splashScreen(
          // Pass the appropriate camera to the TakePictureScreen widget.
          ),
    ),
  );
}
*/