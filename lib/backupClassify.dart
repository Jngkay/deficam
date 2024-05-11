//this isthe backup file for the camera classify thatuses gallery picker and camera
//adjust some things  here to look like the presented

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:deficam/dbHelper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

class backupClassify extends StatefulWidget {
  @override
  State<backupClassify> createState() => _backupClassifyState();
}

class _backupClassifyState extends State<backupClassify> {
  bool _loading = true;
  bool _saving = false;
  late File _image;
  late List _output;
  final picker = ImagePicker();
  String _predictedClass = '';
  String _recommendation = '';

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isCameraReady = false;
  bool isCapturing = false;
  late Timer timer;
  double? confidence;
  bool isSaving = false;
  DateTime? captureTime;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    captureAndClassify();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
    Tflite.close();
  }

  void initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.high);
    await cameraController!.initialize();
    setState(() {
      isCameraReady = true;
    });
  }

  void captureAndClassify() async {
    while (true) {
      if (isCameraReady && !isCapturing) {
        try {
          setState(() {
            isCapturing = true;
          });

          XFile picture = await cameraController!.takePicture();
          await preprocessImage(File(picture.path));

          setState(() {
            _image = File(picture.path);
            _loading = false; // Show the captured image and prediction
          });
        } catch (e) {
          print('Error capturing image: $e');
        } finally {
          setState(() {
            isCapturing = false;
          });
        }
      }
      await Future.delayed(
          Duration(seconds: 3)); // Capture image every 3 seconds
    }
  }

  Future<void> classifyImage(List<List<List<int>>> imgArr) async {
    // Create the interpreter from  model file
    final interpreter =
        await Interpreter.fromAsset('assets/model/modelNEW.tflite');
    List<String> classNames = ["Healthy", "Nitrogen", "Potassium"];
    var numClasses = classNames.length;

    // model's input shape is [1, 150, 150, 3]
    var input = [imgArr]; // Wrap the preprocessed image data in another list

    // model's output shape is [1, num_classes]
    var output = List.filled(1 * numClasses, 0).reshape([1, numClasses]);

    // Run inference
    interpreter.run(input, output);

    // For example, finding the index with the highest probability
    var maxIndex = 0;
    var maxProb = output[0][0];
    for (var i = 1; i < numClasses; i++) {
      if (output[0][i] > maxProb) {
        maxIndex = i;
        maxProb = output[0][i];
      }
    }

    // Print all probabilities
    print('Class probabilities:');
    for (var i = 0; i < numClasses; i++) {
      print('${classNames[i]}: ${output[0][i]}');
    }

    var className = classNames[maxIndex];
    var recommendation = await getRecommendationForClass(className);
    // var maxProbPercentage = (maxProb * 10).toStringAsFixed(2);

    print(
        'Classified as class $maxIndex (${classNames[maxIndex]}) with probability $maxProb');

    setState(() {
      _predictedClass = className;
      _recommendation = recommendation;
    });
  }

  Future<List<List<List<int>>>> preprocessImage(File image) async {
    final bytes = await image.readAsBytes();
    final img = imglib.decodeImage(bytes);

    // Convert the image to RGB format if it's not already
    final rgbImage = imglib.copyRotate(img!, angle: 90);

    // Resize the image to the desired dimensions
    final resizedImg = imglib.copyResize(rgbImage, width: 150, height: 150);
    print('this is the img array $resizedImg');

    // Create a 3D list to store RGB values
    List<List<List<int>>> imgArr = [];

    // Get the bytes of the resized image in RGB format
    final resizedBytes = resizedImg.getBytes();

    // Calculate the number of bytes per pixel
    final bytesPerPixel = 3;

    // Loop through each pixel in the image and store its RGB value
    for (int y = 0; y < resizedImg.height; y++) {
      imgArr.add([]);
      for (int x = 0; x < resizedImg.width; x++) {
        final pixelIndex = (y * resizedImg.width + x) * bytesPerPixel;
        final red = resizedBytes[pixelIndex];
        final green = resizedBytes[pixelIndex + 1];
        final blue = resizedBytes[pixelIndex + 2];
        imgArr[y].add([red, green, blue]);
      }
    }
    print('this is the img array $imgArr');
    // Call classifyImage function with the preprocessed image data
    await classifyImage(imgArr);

    // Return the 3D list of RGB values
    return imgArr;
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

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/modelNEW.tflite', labels: 'assets/labels.txt');
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    preprocessImage(_image);
    // classifyImage(_image);
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    preprocessImage(_image);
    // classifyImage(_image);
  }

  void cancelButton() {
    setState(() {
      _loading = true; // Reset the loading state
      _output = []; // Clear the output list
      _predictedClass = ''; // Reset the predicted class variable
    });
  }

  Future<File> compressImage(File image, String targetPath) async {
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 60, // Adjust the quality as needed (0-100)
      minWidth: 300, // Adjust the width as needed
      minHeight: 300, // Adjust the height as needed
    );

    if (compressedImage != null) {
      return compressedImage;
    } else {
      throw Exception('Image compression failed');
    }
  }

//   _showDialog(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: Container(
//             padding: EdgeInsets.all(16),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Text(
//                 'Classification Result',
//                 textAlign: TextAlign.left,
//                 style: GoogleFonts.roboto(
//                   color: Colors.black,
//                   fontSize: 25.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               if (_image != null)
//                 Image.file(
//                   _image!,
//                   width: 150,
//                   height: 150,
//                 ),
//               SizedBox(
//                 height: 10,
//               ),
//               Divider(
//                 thickness: 1,
//                 height: 1,
//                 color: Colors.grey[350],
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               if (_predictedClass != null)
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 55,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Deficiency Classification: ',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           if (confidence != null)
//                             Text(
//                               'Confidence:',
//                               style: GoogleFonts.roboto(
//                                 color: Colors.black,
//                                 fontSize: 17.0,
//                                 fontWeight: FontWeight.normal,
//                               ),
//                             ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             'Foliar Fertilizer',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                           Text(
//                             'Recommendation: ',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       flex: 45,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             '$_predictedClass',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                             '${confidence!.toStringAsFixed(2)}',
//                             style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 17.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           if (_predictedClass != null)
//                             FutureBuilder<String>(
//                               future:
//                                   getRecommendationForClass(_predictedClass),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   return Text(
//                                     snapshot.data!,
//                                     style: GoogleFonts.roboto(
//                                       color: Colors.black,
//                                       fontSize: 17.0,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   );
//                                 } else if (snapshot.hasError) {
//                                   return Text(
//                                     'Error: ${snapshot.error}',
//                                     style: TextStyle(color: Colors.red),
//                                   );
//                                 }
//                                 return CircularProgressIndicator();
//                               },
//                             ),
//                           SizedBox(
//                             height: 8,
//                           ),
//                           Text(''),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               SizedBox(
//                 height: 30,
//               ),

//               //Loading Widget
//               if (isSaving)
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: CircularProgressIndicator(),
//                 ),

//               //Save Button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 120,
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       icon: Icon(
//                         Icons.save_alt_rounded,
//                         color: Colors.white,
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                       ),
//                       onPressed: isSaving
//                           ? null
//                           : () async {
//                               print("Saving Started");
//                               setState(() {
//                                 isSaving = true;
//                               });
//                               final classificationData = {
//                                 'prediction': _predictedClass,
//                                 'confidence': confidence,
//                                 'imagePath': _image.path,
//                                 'captureTime': captureTime!,
//                               };

//                               final primaryKey = await DBHelper.saveResult(
//                                 prediction:
//                                     classificationData['prediction'] as String,
//                                 confidence:
//                                     classificationData['confidence'] as double,
//                                 imagePath:
//                                     classificationData['imagePath'] as String,
//                                 captureTime: classificationData['captureTime']
//                                     as DateTime,
//                                 synced: true,
//                               );
//                               if (primaryKey != -1) {
//                                 print("Saving successful");
//                                 setState(() {
//                                   isSaving = false;
//                                 });
//                                 Timer(Duration(seconds: 2), () {
//                                   Navigator.pop(context);
//                                 });
//                               } else {
//                                 print('Error saving result');
//                               }
//                             },
//                       label: Text(
//                         'Save',
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 20,
//                   ),
//                   SizedBox(
//                     width: 120,
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       icon: Icon(
//                         Icons.restart_alt_rounded,
//                         color: Colors.white,
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         timer.cancel();
//                         captureAndClassify();
//                       },
//                       label: Text(
//                         'Retake',
//                         style: GoogleFonts.roboto(
//                           color: Colors.white,
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ]),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future<bool> _onWillPop() async {
//       return (await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text(
//                 'Confirm Close',
//                 style: GoogleFonts.roboto(
//                     fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//               content: Text(
//                 'Are you sure you want to close the application? Any unsaved changes will be lost.',
//                 style: GoogleFonts.roboto(fontSize: 15),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('No',
//                       style: GoogleFonts.roboto(
//                           fontSize: 14, fontWeight: FontWeight.bold)),
//                 ),
//                 TextButton(
//                     child: Text('Yes',
//                         style: GoogleFonts.roboto(
//                             fontSize: 14, fontWeight: FontWeight.bold)),
//                     onPressed: () {
//                       FlutterExitApp.exitApp(iosForceExit: true);
//                     }),
//               ],
//             ),
//           )) ??
//           false;
//     }

//     if (!isCameraReady) {
//       return Container(); // Return an empty container while camera is initializing
//     }

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         body: Column(
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height,
//               child: Stack(
//                 children: <Widget>[
//                   Positioned(
//                     top: 20,
//                     child: Container(
//                       color: Colors.white,
//                       width: MediaQuery.of(context).size.width,
//                       height: 100.0,
//                       child: Center(
//                         child: Text(
//                           "Classify",
//                           style: GoogleFonts.roboto(
//                               color: Colors.black,
//                               fontSize: 25.0,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 100,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Color(0xFF88BF3B),
//                               Color(0xFF178F3E),
//                             ]),
//                         borderRadius: BorderRadius.only(
//                             topRight: Radius.circular(40),
//                             topLeft: Radius.circular(40)),
//                       ),
//                       width: MediaQuery.of(context).size.width,
//                       height: MediaQuery.of(context).size.height,
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.only(left: 5, top: 10),
//                                 child: IconButton(
//                                   color: Colors.white,
//                                   icon: Icon(Icons.arrow_back_ios),
//                                   iconSize: 20,
//                                   onPressed: () {
//                                     cameraController?.pausePreview();
//                                     Navigator.push(context, MaterialPageRoute(
//                                         builder: (BuildContext) {
//                                       return dashboardScreen();
//                                     }));
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Stack(
//                               children: <Widget>[
//                                 Text('Please hold for five(5) seconds'),
//                                 // CameraPreview(cameraController!,
//                                 //     child: Container(height: 400)),

//                                 CameraPreview(cameraController!),
//                                 Positioned(
//                                   top: 60,
//                                   left: 80,
//                                   right: 80,
//                                   bottom: 60,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                         color: Colors
//                                             .red, // Customize the color of the border
//                                         width:
//                                             2.0, // Customize the width of the border
//                                       ),
//                                     ),
//                                     width: 250,
//                                     height: 350,
//                                     child: Column(children: [
//                                       Center(
//                                         child: Container(
//                                           width: double.infinity,
//                                           height: 30,
//                                           decoration: BoxDecoration(
//                                               color: Colors.white
//                                                   .withOpacity(0.5)),
//                                           child: Text(
//                                             'Prediction: $_predictedClass',
//                                             style: GoogleFonts.roboto(
//                                               color: Colors.black,
//                                               fontSize: 20.0,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       Center(
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             if (isCapturing) // Display capture indicator when capturing an image
//                                               Column(
//                                                 children: [
//                                                   SizedBox(
//                                                     height: 100,
//                                                   ),
//                                                   CircularProgressIndicator(),
//                                                   SizedBox(height: 10),
//                                                   Text(
//                                                     'Classifying...',
//                                                     style: GoogleFonts.roboto(
//                                                       color: Colors.white,
//                                                       fontSize: 20.0,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                           ],
//                                         ),
//                                       ),
//                                     ]),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Please hold the camera steady.',
//                                 style: GoogleFonts.roboto(
//                                   color: Colors.white,
//                                   fontSize: 18.0,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               )
//                             ],
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           SizedBox(
//                             width: 190,
//                             height: 50,
//                             child: ElevatedButton.icon(
//                                 icon: Icon(
//                                   Icons.remove_red_eye_outlined,
//                                   color: Colors.green[900],
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                 ),
//                                 onPressed: (() async {
//                                   timer.cancel();
//                                   await _showDialog(context);
//                                 }),
//                                 label: Text(
//                                   'View Result',
//                                   style: GoogleFonts.roboto(
//                                     color: Colors.green[900],
//                                     fontSize: 20.0,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 )),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 60.0,
//                     left: 20.0,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 20.0),
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(35),
//                             border: Border.all(color: Colors.white, width: 2.0),
//                             color: Colors.white),
//                         child: Image.asset(
//                           'assets/logo/logo.png',
//                           width: 80,
//                           height: 80,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    Future<bool> _onWillPop() async {
      return (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Confirm Close',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              content: Text(
                'Are you sure you want to close the application? Any unsaved changes will be lost.',
                style: GoogleFonts.roboto(fontSize: 15),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('No',
                      style: GoogleFonts.roboto(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                    child: Text('Yes',
                        style: GoogleFonts.roboto(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      FlutterExitApp.exitApp(iosForceExit: true);
                    }),
              ],
            ),
          )) ??
          false;
    }

    if (!isCameraReady) {
      return Container(); // Return an empty container while camera is initializing
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                                      Center(
                                        child: Container(
                                          width: double.infinity,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.5)),
                                          child: Text(
                                            'Prediction: $_predictedClass',
                                            style: GoogleFonts.roboto(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (isCapturing) // Display capture indicator when capturing an image
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 100,
                                                  ),
                                                  CircularProgressIndicator(),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'Classifying...',
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Please hold the camera steady.',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 190,
                            height: 50,
                            child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Colors.green[900],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: (() async {
                                  timer.cancel();
                                  await dialogResult(context);
                                }),
                                label: Text(
                                  'View Result',
                                  style: GoogleFonts.roboto(
                                    color: Colors.green[900],
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          )
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
      ),
    );
  }

  dialogResult(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (_image != null)
                Image.file(
                  _image,
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
              if (_predictedClass != null)
                Row(
                  children: [
                    Expanded(
                      flex: 55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deficiency Classification: ',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          if (confidence != null)
                            Text(
                              'Confidence:',
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 17.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Foliar Fertilizer',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            'Recommendation: ',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_predictedClass',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '${confidence!.toStringAsFixed(2)}',
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          if (_predictedClass != null)
                            FutureBuilder<String>(
                              future:
                                  getRecommendationForClass(_predictedClass),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    snapshot.data!,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 17.0,
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
                            height: 8,
                          ),
                          Text(''),
                        ],
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 30,
              ),

              //Loading Widget
              if (isSaving)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),

              //Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.save_alt_rounded,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              print("Saving Started");
                              setState(() {
                                isSaving = true;
                              });
                              final classificationData = {
                                'prediction': _predictedClass,
                                'confidence': confidence,
                                'imagePath': _image.path,
                                'captureTime': captureTime!,
                              };

                              final primaryKey = await DBHelper.saveResult(
                                prediction:
                                    classificationData['prediction'] as String,
                                confidence:
                                    classificationData['confidence'] as double,
                                imagePath:
                                    classificationData['imagePath'] as String,
                                captureTime: classificationData['captureTime']
                                    as DateTime,
                                synced: true,
                              );
                              if (primaryKey != -1) {
                                print("Saving successful");
                                setState(() {
                                  isSaving = false;
                                });
                                Timer(Duration(seconds: 2), () {
                                  Navigator.pop(context);
                                });
                              } else {
                                print('Error saving result');
                              }
                            },
                      label: Text(
                        'Save',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        timer.cancel();
                        captureAndClassify();
                      },
                      label: Text(
                        'Retake',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }
}
