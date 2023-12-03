import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class reportsPage extends StatefulWidget {
  const reportsPage({super.key});

  @override
  State<reportsPage> createState() => _reportsPageState();
}

class _reportsPageState extends State<reportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
          child: Container(
        color: Colors.blueGrey,
        height: 400,
        width: 400,
        child: _LineChart(),
      )),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
        swapAnimationDuration: const Duration(milliseconds: 250), sampleData1);
  }
}

LineChartData get sampleData1 => LineChartData(
    gridData: gridData,
    titlesData: titlesData,
    borderData: borderData,
    lineBarsData: lineBarsData,
    minX: 0,
    maxX: 14,
    minY: 0,
    maxY: 4);

List<LineChartBarData> get lineBarsData => [lineChartBarData1];
FlTitlesData get titlesData => FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: bottomTitles),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: leftTitles(),
      ),
    );

Widget leftTitlesWidget(double value, TitleMeta meta) {
  const style = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  String text;
  switch (value.toInt()) {
    case 1:
      text = '1m';
      break;
    case 2:
      text = '2m';
      break;
    case 3:
      text = '3m';
      break;
    case 4:
      text = '4m';
      break;
    default:
      return Container();
  }
  return Text(
    text,
    style: style,
    textAlign: TextAlign.center,
  );
}

SideTitles leftTitles() => SideTitles(
      getTitlesWidget: leftTitlesWidget,
      showTitles: true,
      interval: 1,
      reservedSize: 40,
    );

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  Widget text;
  switch (value.toInt()) {
    case 1:
      text = const Text(
        '2020',
        style: style,
      );
      break;
    case 2:
      text = const Text(
        '2021',
        style: style,
      );
      break;
    case 3:
      text = const Text(
        '2022',
        style: style,
      );
      break;
    case 4:
      text = const Text(
        '2023',
        style: style,
      );
      break;
    default:
      text = const Text('');
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 10,
    child: text,
  );
}

SideTitles get bottomTitles => SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: 1,
      getTitlesWidget: bottomTitleWidgets,
    );

FlGridData get gridData => FlGridData(show: false);

FlBorderData get borderData => FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.grey, width: 4),
        left: BorderSide(
          color: Colors.grey,
        ),
        right: BorderSide(color: Colors.transparent),
        top: BorderSide(color: Colors.transparent),
      ),
    );

LineChartBarData get lineChartBarData1 {
  Future<List<FlSpot>> fetchDataFromFirestore() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('imageClassificationData')
        .get();

    List<FlSpot> spots = [];

    snapshot.docs.forEach((doc) {
      double prediction = doc['prediction'];
      Timestamp capturedTime = doc['capturedTime'];
      // Convert capturedTime to month index (assuming capturedTime is a timestamp)
      int month = capturedTime.toDate().month;

      spots.add(FlSpot(month.toDouble(), prediction));
    });

    return spots;
  }

  List<FlSpot> fetchedSpots = fetchDataFromFirestore();

  return LineChartBarData(
    isCurved: true,
    color: Colors.purple,
    barWidth: 6,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: fetchedSpots,
  );
}
