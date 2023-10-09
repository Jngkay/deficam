//This is the working history screen
import 'dart:io';
import 'package:deficam/dashboardScreen.dart';
import 'package:deficam/dbHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dbHelper.dart';
import 'package:intl/intl.dart';

class historyPage extends StatefulWidget {
  const historyPage({super.key});

  @override
  State<historyPage> createState() => _historyPageState();
}

class _historyPageState extends State<historyPage> {
  late Future<List<Map<String, dynamic>>> _data;

  String formatDate(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    DateFormat formatter = DateFormat('MMM d, yyyy');
    return formatter.format(parsedDate);
  }

  String formatTime(String inputTime) {
    DateTime parsedTime = DateTime.parse(inputTime);
    String formatter = DateFormat.jm().format(parsedTime);
    return formatter;
  }

  String formatPercentage(double inputpercentage) {
    String percentage = (inputpercentage * 100).toStringAsFixed(1) + '%';
    return percentage;
  }

  @override
  void initState() {
    super.initState();
    _data = DBHelper.getAllRows();
  }

  @override
  Widget build(BuildContext context) {
    @override
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
    return /*Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  String formattedDate = formatDate('${item['captureTime']}');
                  String formattedTime = formatTime('${item['captureTime']}');
                  String imagePath = '${item['imagePath']}';
                  return ListTile(
                    leading: Image.file(
                      File(imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text('Prediction: ${item['prediction']}'),
                    subtitle: Text('Confidence: ${item['confidence']}'),
                    trailing: //Text('Date $formattedDate'
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                          Text('$formattedDate'),
                          Text('$formattedTime'),
                        ]),
                  );
                },
              ),
            );
          }
        },
      ),
    );

*/
        Scaffold(
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
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {}, child: Text('Sorts'))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                child: Container(
                                  height: 650,
                                  child:
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _data,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center(
                                            child: Text('No data available.'));
                                      } else {
                                        return Container(
                                          child: ListView.builder(
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              var item = snapshot.data![index];
                                              String formattedDate = formatDate(
                                                  '${item['captureTime']}');
                                              String formattedTime = formatTime(
                                                  '${item['captureTime']}');
                                              String imagePath =
                                                  '${item['imagePath']}';

                                              double confidence =
                                                  item['confidence'];

                                              String formattedPercentage =
                                                  NumberFormat.percentPattern(
                                                          'en_US')
                                                      .format(confidence);

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8,
                                                    right: 8,
                                                    bottom: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Border radius
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromARGB(
                                                                255,
                                                                137,
                                                                136,
                                                                136)
                                                            .withOpacity(
                                                                0.3), // Shadow color
                                                        spreadRadius:
                                                            2, // Spread radius
                                                        blurRadius:
                                                            5, // Blur radius
                                                        offset: Offset(1,
                                                            2), // Offset in x and y direction
                                                      ),
                                                    ],
                                                  ),
                                                  child: ListTile(
                                                    leading: Image.file(
                                                      File(imagePath),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    title: Text(
                                                      'Prediction: ${item['prediction']}',
                                                      style: GoogleFonts.roboto(
                                                          color: Colors.black,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                      'Confidence: $formattedPercentage',
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    trailing: //Text('Date $formattedDate'
                                                        Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                          Text(
                                                            '$formattedDate',
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                          Text(
                                                            '$formattedTime',
                                                            style: GoogleFonts.roboto(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
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
        ],
      ),
    );
  }
}


  /*@override
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
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
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _data,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text('No data available.'));
                                    } else {
                                      return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          var item = snapshot.data![index];
                                          return ListTile(
                                            title: Text(
                                                'Prediction: ${item['prediction']}'),
                                            subtitle: Text(
                                                'Confidence: ${item['confidence']}'),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
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
        ],
      ),
    );
  }
  */