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
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => dashboardScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF88BF3B),
              Color(0xFF178F3E),
            ]),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Image.asset(
              'assets/icons/clouds1.png',
            ),
            Image.asset('assets/icons/clouds2.png'),
          ]),
          Container(
            height: 90,
          ),
          Container(
            width: 210,
            height: 210,
            child: Image.asset('assets/logo/logo.png'),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Deficam',
                style: GoogleFonts.roboto(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    color: Color.fromARGB(255, 37, 37, 37),
                    textStyle: TextStyle(decoration: TextDecoration.none)),
              ),
            ],
          ),
          Container(
            height: 80,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Image.asset('assets/icons/clouds3.png'),
            Image.asset('assets/icons/clouds4.png'),
          ]),
          Container(
            height: 80,
          ),
          Center(
              child: LoadingAnimationWidget.prograssiveDots(
                  color: Colors.white, size: 70)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GROW WITH EASE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'healthy trees guarantees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
