import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:deficam/camscreen.dart';
import 'package:intl/intl.dart';

class DataTableHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DataTableHistoryState();
  }
}

class DataTableHistoryState extends State<DataTableHistory> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<File> _imageFiles = [];
  List<String> _predictionTexts = [];
  List<String> _timestamps = [];
  List<String> _recommendationTexts = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _pageIndex = 0;
  int _selectedRowIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadImagesAndPredictions();
  }

  Future<void> _loadImagesAndPredictions() async {
    // try {
    final appDir = await getApplicationDocumentsDirectory();
    final files = await appDir.list().toList();
    final imageFiles = files
        .where((file) => file.path.endsWith('.jpg'))
        .map((file) => File(file.path))
        .toList();

    final predictionFiles =
        files.where((file) => file.path.endsWith('_prediction.txt')).toList();
    final predictionTexts = await Future.wait(
      predictionFiles.map((file) async => await File(file.path).readAsString()),
    );

    final recoFiles = files
        .where((file) => file.path.endsWith('_recommendation.txt'))
        .toList();
    final recommendationTexts = await Future.wait(
      recoFiles.map((file) async => await File(file.path).readAsString()),
    );
    final timestamps = imageFiles.map((file) {
      final stat = file.statSync();
      final modifiedDate = DateTime.fromMillisecondsSinceEpoch(
          stat.modified.millisecondsSinceEpoch);
      return DateFormat('yyyy-MM-dd hh:mm:ss').format(modifiedDate);
    }).toList();

    setState(() {
      _imageFiles = imageFiles;
      _predictionTexts = predictionTexts;
      _timestamps = timestamps;
      _recommendationTexts = recommendationTexts;
    });
    // } catch (error) {
    //   print(error);
    // }
  }

  Future<void> _uploadDataAndDeleteLocalCopy() async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('DeficamClassification');

    if (_selectedRowIndex >= 0 && _selectedRowIndex < _imageFiles.length) {
      // Get the selected row data
      final selectedImageFile = _imageFiles[_selectedRowIndex];
      final selectedPredictionText = _predictionTexts[_selectedRowIndex];
      final selectedRecommendationText =
          _recommendationTexts[_selectedRowIndex];

      final imagePath = 'images/${selectedImageFile.path.split('/').last}';
      final uploadTask = FirebaseStorage.instance
          .ref()
          .child(imagePath)
          .putFile(selectedImageFile);
      final TaskSnapshot uploadSnapshot = await uploadTask;

      // Upload image file
      final imageUrl = await uploadSnapshot.ref.getDownloadURL();

      // Save data to Firebase database
      final data = {
        'imageUrl': imageUrl,
        'predictionText': selectedPredictionText,
        'recommendationText': selectedRecommendationText,
      };
      await collectionRef.add(data);

      // Delete the local copy
      await selectedImageFile.delete();

      setState(() {
        // Remove the deleted data from the lists
        _imageFiles.removeAt(_selectedRowIndex);
        _predictionTexts.removeAt(_selectedRowIndex);
        _timestamps.removeAt(_selectedRowIndex);
        _recommendationTexts.removeAt(_selectedRowIndex);
        _selectedRowIndex = -1; // Reset the selected row index
      });

      // Show a snackbar to indicate successful upload and deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data uploaded and local copy deleted.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      DataColumn(
        label: Text('Image'),
      ),
      DataColumn(
        label: Text('Prediction'),
      ),
      DataColumn(
        label: Text('Timestamp'),
      ),
      DataColumn(
        label: Text('Recommendation'),
      ),
    ];
    return Scaffold(
      key: _scaffoldKey,
      body: Column(children: [
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
                      "History",
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
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (BuildContext) {
                                  return dashboardScreen();
                                }));
                              },
                            ),
                          ),
                        ],
                      ),
                      _imageFiles.isNotEmpty
                          ? SingleChildScrollView(
                              child: PaginatedDataTable(
                                showCheckboxColumn: true,
                                rowsPerPage: _rowsPerPage,
                                columnSpacing: 10,
                                availableRowsPerPage: [10, 25, 50],
                                onPageChanged: (pageIndex) {
                                  setState(() {
                                    _pageIndex = pageIndex;
                                  });
                                },
                                source: ImageDataTableSource(
                                  imageFiles: _imageFiles,
                                  predictionTexts: _predictionTexts,
                                  recommendationTexts: _recommendationTexts,
                                  pageIndex: _pageIndex,
                                  rowsPerPage: _rowsPerPage,
                                  selectedRowIndex: _selectedRowIndex,
                                  onSelectRow: (index) {
                                    setState(() {
                                      _selectedRowIndex = index!;
                                    });
                                  },
                                ),
                                columns: columns,
                              ),
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed:
                            _uploadDataAndDeleteLocalCopy, // Trigger the upload and deletion process
                        icon: Icon(
                          Icons.upload,
                          color: Colors.black,
                          size: 40,
                        ),
                        label: Text(
                          'Upload',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
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
      ]),
    );
  }
}

class ImageDataTableSource extends DataTableSource {
  final List<File> imageFiles;
  final List<String> predictionTexts;
  final List<String> recommendationTexts;
  final int pageIndex;
  final int rowsPerPage;
  final int? selectedRowIndex;
  final Function(int?) onSelectRow;

  ImageDataTableSource({
    required this.imageFiles,
    required this.predictionTexts,
    required this.pageIndex,
    required this.rowsPerPage,
    required this.recommendationTexts,
    required this.selectedRowIndex,
    required this.onSelectRow,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= imageFiles.length) {
      return null;
    }

    final imageFile = imageFiles[index];
    final predictionText = predictionTexts[index];
    final recommendationText = recommendationTexts[index];
    final dateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(imageFile.lastModifiedSync());

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Container(
          width: 50,
          height: 50,
          child: Image.file(imageFile),
        )),
        DataCell(Text(predictionText)),
        DataCell(Text(dateTime)),
        DataCell(Text(recommendationText)),
      ],
      selected: selectedRowIndex == index,
      onSelectChanged: (isSelected) {
        onSelectRow(isSelected! ? index : null);
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => imageFiles.length;

  @override
  int get selectedRowCount => 1;
}
