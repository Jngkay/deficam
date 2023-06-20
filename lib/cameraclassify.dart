import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isCameraReady = false;
  String? prediction = '';
  Timer? timer;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    loadModel();
  }

  Future<void> initializeCamera() async {
    await Permission.camera.request();
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);

    await cameraController!.initialize();
    if (!mounted) return;

    setState(() {
      isCameraReady = true;
    });

    timer = Timer(Duration(seconds: 3), classifyStillImage);
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  void classifyStillImage() async {
    if (cameraController!.value.isTakingPicture) return;
    setState(() {
      isCapturing = true; // Set capturing flag to true during image capture
    });
    try {
      XFile imageFile = await cameraController!.takePicture();
      classifyImage(File(imageFile.path));
    } catch (e) {
      print('Error capturing image: $e');
    }
    setState(() {
      isCapturing = false; // Set capturing flag to false after image capture
    });
    if (mounted) {
      // Delay for 3 seconds before the next classification
      timer = Timer(Duration(seconds: 3), classifyStillImage);
    }
  }

  void classifyImage(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 3, // Number of classification results to obtain
      threshold: 0.5, // Confidence threshold for classification
    );

    setState(() {
      prediction = recognitions != null ? recognitions[0]['label'] : 'Unknown';
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    timer?.cancel();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return Container(); // Return an empty container while camera is initializing
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaf Classification'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(cameraController!),
                if (isCapturing) // Display capture indicator when capturing an image
                  Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Prediction: $prediction',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
