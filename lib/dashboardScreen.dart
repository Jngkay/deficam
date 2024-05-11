import 'dart:io';
import 'package:camera/camera.dart';
import 'package:deficam/backupClassify.dart';
import 'package:deficam/cameraclassify.dart';
import 'package:deficam/camscreen.dart';
import 'package:deficam/classifyScreen.dart';
import 'package:deficam/didyouknowScreen.dart';
import 'package:deficam/historyScreen.dart';
import 'package:deficam/historyScreenPage.dart';
import 'package:deficam/main.dart';
import 'package:deficam/reportsSample.dart';
import 'package:deficam/reportsScreen.dart';
import 'package:deficam/reportsTrial.dart';
import 'package:deficam/trial2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:deficam/cnnclassify.dart';
import 'cnnclassify_working.dart';

class dashboardScreen extends StatefulWidget {
  const dashboardScreen({super.key});

  @override
  State<dashboardScreen> createState() => _dashboardScreenState();
}

class _dashboardScreenState extends State<dashboardScreen> {
  @override
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    //On will pop for confirmation if the user want to close the application
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,

        //Builds the dashboard board front end design
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
                          "Dashboard",
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset('assets/icons/clouds1.png'),
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          //Capture and Reports
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                )),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                Home())); //this is for the manual and gallery pick classify

                                    //     Navigator.pushReplacement(
                                    // context,
                                    // MaterialPageRoute(
                                    //     builder: (_) => Home())); //This is for the realtime classify
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2E9D33),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Color.fromARGB(255, 81, 81, 81),
                                          blurRadius: 5,
                                          offset:
                                              Offset(2, 2), // Shadow position
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                    ),
                                    width: 165,
                                    height: 165,
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 35, 22, 0),
                                              width: 60.0,
                                              child: Image.asset(
                                                  'assets/icons/classify_icon.png'),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Capture',
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Image.asset(
                                                'assets/icons/cloudsBox.png'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                )),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => LineChartSample()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDAAF5B),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Color.fromARGB(255, 81, 81, 81),
                                          blurRadius: 5,
                                          offset:
                                              Offset(2, 2), // Shadow position
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                    ),
                                    width: 165,
                                    height: 165,
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 35, 22, 0),
                                              width: 60.0,
                                              child: Image.asset(
                                                  'assets/icons/reports_icon.png'),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Reports',
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Image.asset(
                                                'assets/icons/cloudsBox.png'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                )),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => historyPage()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF84AD82),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Color.fromARGB(255, 81, 81, 81),
                                          blurRadius: 5,
                                          offset:
                                              Offset(2, 2), // Shadow position
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                    ),
                                    width: 165,
                                    height: 165,
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 35, 22, 0),
                                              width: 60.0,
                                              child: Image.asset(
                                                  'assets/icons/history_icon.png'),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'History',
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Image.asset(
                                                'assets/icons/cloudsBox.png'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                )),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => infoScreen()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD4C023),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Color.fromARGB(255, 81, 81, 81),
                                          blurRadius: 5,
                                          offset:
                                              Offset(2, 2), // Shadow position
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                    ),
                                    width: 165,
                                    height: 165,
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  20, 35, 22, 0),
                                              width: 60.0,
                                              child: Image.asset(
                                                  'assets/icons/info_icon.png'),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'Info',
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Image.asset(
                                                'assets/icons/cloudsBox.png'),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 80,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                'assets/icons/clouds4.png',
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
}
