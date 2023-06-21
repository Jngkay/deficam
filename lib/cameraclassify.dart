import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:deficam/dbHelper.dart';

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
  double? confidence;
  File? capturedImage;
  DateTime? captureTime;

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
    if (timer?.isActive == false)
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
      timer = Timer(Duration(seconds: 5), classifyStillImage);
    }
  }

  void classifyImage(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 3, // Number of classification results to obtain
      threshold: 0.5, // Confidence threshold for classification
    );

    if (recognitions != null && recognitions.isNotEmpty) {
      for (var item in recognitions) {
        final className = item['label'] as String;
        final recommendation = await getRecommendationForClass(className);
        item['recommendation'] = recommendation;
      }
    }

    setState(() {
      if (recognitions != null && recognitions.isNotEmpty) {
        prediction = recognitions[0]['label'];
        confidence = recognitions[0]['confidence'];
        capturedImage = imageFile;
        captureTime = DateTime.now();
      } else {
        prediction = 'Unknown';
        confidence = null;
        capturedImage = null;
        captureTime = null;
      }
    });
  }

  Future<String> getRecommendationForClass(String className) async {
    final jsonContent =
        await rootBundle.loadString('assets/recommendations.json');
    final recommendations = jsonDecode(jsonContent) as Map<String, dynamic>;

    if (recommendations.containsKey(className)) {
      final recommendation = recommendations[className] as String;
      return recommendation;
    } else {
      throw Exception('Recommendation not found for class: $className');
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                'Classification Result',
                textAlign: TextAlign.left,
                style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              if (capturedImage != null)
                Image.file(
                  capturedImage!,
                  width: 150,
                  height: 150,
                ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                height: 1,
                color: Colors.grey[350],
              ),
              SizedBox(
                height: 15,
              ),
              if (prediction != null)
                Text(
                  'Deficiency Classification: ',
                  style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal),
                ),
              Text(
                '$prediction',
                style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
              if (confidence != null)
                Text(
                  'Confidence:',
                  style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal),
                ),
              Text(
                '${confidence!.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Foliar Fertilizer Recommendation: ',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (prediction != null)
                FutureBuilder<String>(
                  future: getRecommendationForClass(prediction!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await DBHelper.saveResult(
                    prediction: prediction!,
                    confidence: confidence!,
                    imagePath: capturedImage!.path,
                    captureTime: captureTime!,
                  );
                  Navigator.pop(context); // Close the dialog
                  timer?.cancel();
                  classifyStillImage();
                },
                child: Text('Save result'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  timer?.cancel();
                  classifyStillImage();
                },
                child: Text('Retake'),
              ),
            ]),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController?.pausePreview();
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
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 20,
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: 100.0,
                    child: Center(
                      child: Text(
                        "Classify",
                        style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF88BF3B),
                            Color(0xFF178F3E),
                          ]),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                          topLeft: Radius.circular(40)),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 5, top: 10),
                              child: IconButton(
                                color: Colors.white,
                                icon: Icon(Icons.arrow_back_ios),
                                iconSize: 20,
                                onPressed: () {
                                  cameraController?.pausePreview();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext) {
                                    return dashboardScreen();
                                  }));
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Stack(
                            children: <Widget>[
                              Text('Please hold for five(5) seconds'),
                              CameraPreview(cameraController!),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isCapturing) // Display capture indicator when capturing an image
                                      Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 10),
                                          Text('Classifying...'),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 60,
                                left: 80,
                                right: 80,
                                bottom: 60,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors
                                          .red, // Customize the color of the border
                                      width:
                                          2.0, // Customize the width of the border
                                    ),
                                  ),
                                  width: 250,
                                  height: 350,
                                  child: Column(children: [
                                    Text(
                                      'Prediction: $prediction',
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                            onPressed: (() {
                              timer?.cancel();
                              _showDialog();
                            }),
                            child: Text('View Result'))
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 60.0,
                  left: 20.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: Colors.white, width: 2.0),
                          color: Colors.white),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
