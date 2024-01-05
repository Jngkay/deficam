//This is the working reports screen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class LineChartSample extends StatefulWidget {
  @override
  _LineChartSampleState createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<FlSpot> dataPoints = [];
  String selectedPrediction = 'nitrogen'; // Default prediction type
  String chartTitle = 'Nutrient Deficiency in Nitrogen';

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }

  void updateData(String predictionType) {
    setState(() {
      selectedPrediction = predictionType;
      chartTitle =
          'Nutrient Deficiency in ${predictionType[0].toUpperCase()}${predictionType.substring(1)}';
    });
    fetchDataFromFirestore(); // Update data based on the selected prediction type
  }

  Future<void> fetchDataFromFirestore() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('imageClassificationData');

    QuerySnapshot querySnapshot = await collection.orderBy('captureTime').get();

    int count = 0;
    int currentMonth = -1;

    List<FlSpot> newDataPoints = [];

    setState(() {
      newDataPoints = querySnapshot.docs.map((doc) {
        String timestampString = doc['captureTime'];
        String prediction = doc['prediction'];
        DateTime timestamp = DateTime.parse(timestampString);

        double x = timestamp.month.toDouble();

        if (currentMonth != x) {
          currentMonth = x.toInt();
          count = 0;
        }

        if (prediction.toLowerCase() == selectedPrediction) {
          count++;
        }

        double y = count.toDouble();

        return FlSpot(x, y);
      }).toList();

      dataPoints = newDataPoints;
    });
  }

  Widget monthTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = 'Jan';
        break;
      case 2:
        text = 'Feb';
        break;
      case 3:
        text = 'Mar';
        break;
      case 4:
        text = 'Apr';
        break;
      case 5:
        text = 'May';
        break;
      case 6:
        text = 'Jun';
        break;
      case 7:
        text = 'Jul';
        break;
      case 8:
        text = 'Aug';
        break;
      case 9:
        text = 'Sept';
        break;
      case 10:
        text = 'Oct';
        break;
      case 11:
        text = 'Nov';
        break;
      case 12:
        text = 'Dec';
        break;
      default:
        text = '';
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(now);
    return formattedDate;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Confirm Close',
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),
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

  @override
  Widget build(BuildContext context) {
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
                          "Reports",
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
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chartTitle,
                                style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Report as of ${getCurrentDate()}',
                                style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.60,
                            width: MediaQuery.of(context).size.width * 0.90,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, right: 20),
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                      drawHorizontalLine: true,
                                      drawVerticalLine: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: monthTitleWidgets,
                                    )),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                  ),
                                  minX: 1,
                                  maxX: 12,
                                  minY: 0,
                                  maxY: 20,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: dataPoints,
                                      isCurved: false,
                                      color: selectedPrediction == 'healthy'
                                          ? Color(0xff4C241B)
                                          : selectedPrediction == 'nitrogen'
                                              ? Color(0xffEF5241)
                                              : Color(0xffBB521F),
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xffEF5241),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () => updateData('nitrogen'),
                                child: Text(
                                  'Nitrogen',
                                  style: GoogleFonts.roboto(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xff4C241B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () => updateData('healthy'),
                                child: Text(
                                  'Healthy',
                                  style: GoogleFonts.roboto(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xffBB521F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () => updateData('potassium'),
                                child: Text(
                                  'Potassium',
                                  style: GoogleFonts.roboto(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600),
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
      ),
    );
  }
}
