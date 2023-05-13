import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Check if Firebase is connected.
    bool connected = Firebase.apps.isNotEmpty;
    print('Firebase is connected: $connected');
  }

  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();

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
    setState(() {
      _output = output!;
      _loading = false;
    });

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final predFile = File('${appDir.path}/${fileName.split('.').first}.txt');
    final predText =
        'The plant is suffering from a lack of ${_output[0]['label']}';
    await predFile.writeAsString(predText);

    // Upload prediction to Firebase storage
    final predStorageRef = FirebaseStorage.instance
        .ref()
        .child('predictions/${fileName.split('.').first}.txt');
    final predUploadTask = predStorageRef.putFile(predFile);
    await predUploadTask.whenComplete(() => print('Prediction uploaded'));
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
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);
    final savedImage = await _image.copy('${appDir.path}/$fileName');
    classifyImage(savedImage);
    // Upload image and prediction to Firebase storage
    final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    final uploadTask = storageRef.putFile(savedImage);
    await uploadTask.whenComplete(() => print('Image uploaded'));
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    initializeFirebase();
    return Scaffold(
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
