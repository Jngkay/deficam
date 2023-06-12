import 'package:deficam/dashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
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
List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    // Retrieve data from Firebase Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('DeficamClassification')
        .get();

    // Map to count the number of data entries for each prediction
    Map<String, int> predictionCount = {
      'Healthy': 0,
      'Nitrogen': 0,
      'Potassium': 0,
    };

    // Parse and organize the data
    snapshot.docs.forEach((doc) {
      String prediction = doc.get('predictionText').trim();
      // Filter based on the uploaded month

      if (prediction == 'Healthy') {
        predictionCount['Healthy'] = (predictionCount['Healthy'] ?? 0) + 1;
      } else if (prediction == 'Nitrogen') {
        predictionCount['Nitrogen'] = (predictionCount['Nitrogen'] ?? 0) + 1;
      } else if (prediction == 'Potassium') {
        predictionCount['Potassium'] = (predictionCount['Potassium'] ?? 0) + 1;
      }
    });

    List<ChartData> chartData = [];

    // Convert the prediction count map into ChartData objects
    predictionCount.forEach((prediction, count) {
      chartData.add(ChartData(prediction, count));
    });

    setState(() {
      _chartData = chartData;
    });

    print('Healthy count: ${predictionCount['Healthy']}');
    print('Nitrogen count: ${predictionCount['Nitrogen']}');
    print('Potassium count: ${predictionCount['Potassium']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      body: Center(
        child: _chartData.isEmpty
            ? CircularProgressIndicator() // Display a loading indicator while fetching data
            : SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  interval: 1,
                  minimum: 0,
                  maximum: 10,
                ),
                series: <ChartSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: _chartData,
                    xValueMapper: (ChartData data, _) => data.prediction,
                    yValueMapper: (ChartData data, _) => data.count,
                  ),
                ],
              ),
      ),
    );
  }
}

class ChartData {
  final String prediction;
  final int count;

  ChartData(this.prediction, this.count);
}
 
*/