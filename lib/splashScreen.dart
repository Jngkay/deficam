import 'dart:async';
import 'package:flutter/material.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    super.initState();
    //After 5 seconds the screen will redirect to the Dashboard
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => dashboardScreen())));
  }

  // This builds the front end design of the Splashscreen
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 180,
          ),
          Container(
            width: 310,
            child: Image.asset('assets/logo/logowname.png'),
          ),
          Container(
            height: 200,
          ),
          Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Color(0xff2D9D33), size: 70)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GROW WITH EASE',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'healthy trees guarantee',
                style: TextStyle(
                  color: Color(0xff2F272A),
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
