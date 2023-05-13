import 'package:deficam/dashboardScreen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadImagesAndPredictions();
  }

  Future<void> _loadImagesAndPredictions() async {
    final appDir = await getApplicationDocumentsDirectory();
    final files = await appDir.list().toList();
    final imageFiles = files
        .where((file) => file.path.endsWith('.jpg'))
        .map((file) => File(file.path))
        .toList();

    final predictionFiles =
        files.where((file) => file.path.endsWith('.txt')).toList();
    final predictionTexts = await Future.wait(
      predictionFiles.map((file) async => await File(file.path).readAsString()),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Storage'),
      ),
      body: _imageFiles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(child: Text('Timestamp')),
                    TableCell(child: Text('Image')),
                    TableCell(child: Text('Prediction')),
                  ],
                ),
                ...List.generate(
                  _imageFiles.length,
                  (index) => TableRow(
                    children: [
                      TableCell(child: Text(_timestamps[index])),
                      TableCell(
                          child: Image.file(
                        _imageFiles[index],
                        width: 80,
                        height: 80,
                      )),
                      TableCell(child: Text(_predictionTexts[index])),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/*

  @override
  void initState() {
    super.initState();
    setState(() {
      _items = _generateItems();
    });
  }

  List<Item> _generateItems() {
    return List.generate(10, (int index) {
      return Item(
        id: index + 1,
        time: index + 100,
        ndclassify: 'Nitrogen',
        ndfoliar: 'FOLIARTAL N30',
        isSelected: false,
      );
    });
  }

  void updateSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: const Text('Date'),
        numeric: false,
      ),
      DataColumn(
          label: const Text('Time'),
          numeric: false,
          tooltip: 'Time of the item added',
          onSort: (int columnIndex, bool ascending) {
            if (ascending) {
              _items.sort((item1, item2) => item1.time.compareTo(item2.time));
            } else {
              _items.sort((item1, item2) => item2.time.compareTo(item1.time));
            }
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          }),
      DataColumn(
          label: Text('Nutrient Deficiency Classification'),
          numeric: false,
          tooltip: 'Nutrient Deficiency Classification of the item',
          onSort: (int columnIndex, bool ascending) {
            if (ascending) {
              _items.sort((item1, item2) =>
                  item1.ndclassify.compareTo(item2.ndclassify));
            } else {
              _items.sort((item1, item2) =>
                  item2.ndclassify.compareTo(item1.ndclassify));
            }
            setState(() {
              _sortColumnIndex = columnIndex;
              _sortAscending = ascending;
            });
          }),
      DataColumn(
        label: const Text('Foliar Fertilizer Recommendation'),
        numeric: false,
        tooltip: 'Foliar Fertilizer',
      ),
    ];
  }

  DataRow _createRow(Item item) {
    return DataRow(
      key: ValueKey(item.id),
      selected: item.isSelected,
      onSelectChanged: (bool? isSelected) {
        if (isSelected != null) {
          item.isSelected = isSelected;
          setState(() {});
        }
      },
      color: MaterialStateColor.resolveWith((Set<MaterialState> states) =>
          states.contains(MaterialState.selected)
              ? Color.fromARGB(255, 235, 235, 235)
              : Color.fromARGB(100, 215, 217, 219)),
      cells: [
        DataCell(
          Text(item.id.toString()),
        ),
        DataCell(
          Text(item.time.toString()),
        ),
        DataCell(
          Text(item.ndclassify),
        ),
        DataCell(
          Text(item.ndfoliar),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext) {
                                    return dashboardScreen();
                                  }));
                                },
                              ),
                            ),
                          ],
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
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     elevation: 0,
    //     leading: GestureDetector(
    //       onTap: () {
    //         Navigator.pushReplacement(
    //             context, MaterialPageRoute(builder: (_) => dashboardScreen()));
    //       },
    //       child: Image.asset('assets/logo/logo.png'),
    //     ),
    //     title: Text(
    //       'History',
    //       style: TextStyle(
    //         color: Colors.black,
    //         fontSize: 30,
    //       ),
    //     ),
    //     centerTitle: true,
    //     backgroundColor: Colors.white,
    //   ),
    //   body: Container(
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //           begin: Alignment.topCenter,
    //           end: Alignment.bottomCenter,
    //           colors: [
    //             Color(0xFF88BF3B),
    //             Color(0xFF178F3E),
    //           ]),
    //       borderRadius: BorderRadius.only(
    //           topLeft: Radius.circular(25), topRight: Radius.circular(25)),
    //     ),
    //     child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           Center(
    //             child: Container(
    //               width: 400,
    //               child: SingleChildScrollView(
    //                 child: DataTable(
    //                   sortColumnIndex: _sortColumnIndex,
    //                   sortAscending: _sortAscending,
    //                   columnSpacing: 0,
    //                   dividerThickness: 1,
    //                   onSelectAll: (bool? isSelected) {
    //                     if (isSelected != null) {
    //                       _items.forEach((item) {
    //                         item.isSelected = isSelected;
    //                       });

    //                       setState(() {});
    //                     }
    //                   },
    //                   decoration:
    //                       BoxDecoration(color: Colors.white, boxShadow: [
    //                     BoxShadow(
    //                       color: Color.fromARGB(255, 81, 81, 81),
    //                       blurRadius: 5,
    //                       offset: Offset(2, 2), // Shadow position
    //                     ),
    //                   ]),
    //                   dataRowColor: MaterialStateColor.resolveWith(
    //                       (Set<MaterialState> states) =>
    //                           states.contains(MaterialState.selected)
    //                               ? Color.fromARGB(255, 137, 137, 137)
    //                               : Color(0xFFF5F5F5)),
    //                   dataRowHeight: 50,
    //                   dataTextStyle: const TextStyle(
    //                       fontStyle: FontStyle.italic, color: Colors.black),
    //                   headingRowColor: MaterialStateColor.resolveWith(
    //                       (states) => Color(0xFFEDAD3D)),
    //                   headingRowHeight: 60,
    //                   headingTextStyle: const TextStyle(
    //                       fontWeight: FontWeight.bold, color: Colors.black),
    //                   horizontalMargin: 10,
    //                   showBottomBorder: true,
    //                   showCheckboxColumn: true,
    //                   columns: _createColumns(),
    //                   rows: _items.map((item) => _createRow(item)).toList(),
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ]),
    //   ),
    // );
  }
}
*/
