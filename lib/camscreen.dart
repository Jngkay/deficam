import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();
  String _predictedClass = '';

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    for (var item in output!) {
      final className = item['label'] as String;
      final recommendation = await getRecommendationForClass(className);
      item['recommendation'] = recommendation;
    }
    setState(() {
      _output = output!;
      _loading = false;
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

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image);
    /*  final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final savedImage = await _image.copy('${appDir.path}/$fileName');
    
    // Upload image and prediction to Firebase storage
    final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    final uploadTask = storageRef.putFile(savedImage);
    await uploadTask.whenComplete(() => print('Image uploaded'));*/
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  void _saveImageAndPrediction() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'image_$timestamp.jpg';
    final localFilePath = '${directory.path}/$fileName';
    final localFile = await _image.copy('${directory.path}/$fileName');
    print('Image saved locally: ${localFile.path}');
    print('Predicted class: ${_output[0]['label']}');

    final compressedImage = await compressImage(_image, localFilePath);
    print('Image compressed and saved locally: ${compressedImage.path}');

    // Save predicted class to a text file
    final predictionFileName =
        '${fileName.replaceAll('.jpg', '')}_prediction.txt';
    final predictionFile =
        await File('${directory.path}/$predictionFileName').create();
    await predictionFile.writeAsString(_output[0]['label']);

    final recoFileName =
        '${fileName.replaceAll('.jpg', '')}_recommendation.txt';
    final recomendationFile =
        await File('${directory.path}/$recoFileName').create();
    await recomendationFile.writeAsString(
      _output[0]['recommendation'],
    );

    if (await compressedImage.exists() && await predictionFile.exists()) {
      print('Files saved successfully');
    } else {
      print('File save failed');
    }
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

  void _saveToFirebase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(_image.path);
    final predFile = File('${appDir.path}/${fileName.split('.').first}.txt');
    final savedImage = await _image.copy('${appDir.path}/$fileName');
    final predText =
        'The plant is suffering from a lack of ${_output[0]['label']}';
    await predFile.writeAsString(predText);

    // Upload prediction to Firebase storage
    final predStorageRef = FirebaseStorage.instance
        .ref()
        .child('predictions/${fileName.split('.').first}.txt');
    final predUploadTask = predStorageRef.putFile(predFile);
    await predUploadTask.whenComplete(() => print('Prediction uploaded'));

    // Upload image and prediction to Firebase storage
    final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    final uploadTask = storageRef.putFile(savedImage);
    await uploadTask.whenComplete(() => print('Image uploaded'));

    // Print a message to indicate that the image and prediction were saved
    print('Image and prediction saved to Firebase');
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext) {
                                    return dashboardScreen();
                                  }));
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: pickImage,
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 200,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 17),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      'Capture using camera',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: pickGalleryImage,
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 200,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 17),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      'Capture using gallery picker',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )),
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              ElevatedButton(
                                onPressed: _saveImageAndPrediction,
                                child: Text('Save image and prediction'),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: _loading == true
                                    ? null
                                    : Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Image.file(
                                                  _image,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            _output.isNotEmpty
                                                ? Text(
                                                    'Plant Status :  ${_output[0]['label']} \nRecommendation: ${_output[0]['recommendation']}',
                                                  )
                                                : Container(),
                                            Divider(
                                              height: 25,
                                              thickness: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
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
    );
  }
}



/* 

return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text('Nutrient Deficiency Classification'),
      ),
      body: Container(
        color: Colors.lightBlueAccent,
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 50),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Center(
                  child: _loading == true
                      ? null
                      : Container(
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.width * 0.5,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              _output.isNotEmpty
                                  ? Text(
                                      'The plant is suffering from a lack of ${_output[0]['label']}',
                                    )
                                  : Container(),
                              Divider(
                                height: 25,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 200,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Capture using camera',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: pickGalleryImage,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 200,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 17),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'Capture using gallery picker',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: _saveImageAndPrediction,
                      child: Text('Save image and prediction'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _saveToFirebase,
                      child: Text('Save image and prediction online'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );

*/