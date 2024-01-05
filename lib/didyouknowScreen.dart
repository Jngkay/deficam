import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:deficam/dashboardScreen.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';

class infoScreen extends StatefulWidget {
  const infoScreen({super.key});

  @override
  State<infoScreen> createState() => _infoScreenState();
}

class _infoScreenState extends State<infoScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool showTutorial = true;
  CarouselController carouselController = CarouselController();

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
                          "Info",
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
                          Column(
                            children: [
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        showTutorial = true;
                                      });
                                    },
                                    icon: Image.asset(
                                      'assets/icons/tutorial_icon.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    label: Text(
                                      'Tutorial',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor:
                                          Color.fromARGB(255, 0, 0, 0),
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        showTutorial = false;
                                      });
                                    },
                                    icon: Image.asset(
                                      'assets/icons/trivia_icon.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    label: Text(
                                      'Trivia',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor:
                                          Color.fromARGB(255, 0, 0, 0),
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Visibility(
                                visible: showTutorial,
                                child: Column(
                                  children: [
                                    // Tutorial content
                                    // Add your tutorial widgets here

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.arrow_back_ios),
                                          onPressed: () {
                                            carouselController.previousPage();
                                          },
                                        ),
                                        Text(
                                          'Welcome to the Tutorial!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: () {
                                            carouselController.nextPage();
                                          },
                                        ),
                                      ],
                                    ),
                                    CarouselSlider(
                                      items: [
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/tutorial/dashboard.jpg"),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/tutorial/report.jpg"),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/tutorial/report.jpg"),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                      ],
                                      options: CarouselOptions(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.60,
                                        enlargeCenterPage: true,
                                        autoPlay: true,
                                        aspectRatio: 16 / 9,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enableInfiniteScroll: true,
                                        autoPlayAnimationDuration:
                                            Duration(milliseconds: 800),
                                        viewportFraction: 0.8,
                                      ),
                                      carouselController: carouselController,
                                    ),
                                    // Add more tutorial content here
                                  ],
                                ),
                                replacement: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.arrow_back_ios),
                                          onPressed: () {
                                            carouselController.previousPage();
                                          },
                                        ),
                                        Text(
                                          'Trivia 101',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          color: Colors.white,
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: () {
                                            carouselController.nextPage();
                                          },
                                        ),
                                      ],
                                    ),
                                    CarouselSlider(
                                      items: [
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/trivia/trivia1.png"),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/trivia/trivia2.png"),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/trivia/trivia3.png"),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ],
                                      options: CarouselOptions(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.60,
                                        enlargeCenterPage: true,
                                        autoPlay: true,
                                        aspectRatio: 16 / 9,
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enableInfiniteScroll: true,
                                        autoPlayAnimationDuration:
                                            Duration(milliseconds: 800),
                                        viewportFraction: 0.8,
                                      ),
                                      carouselController: carouselController,
                                    ),
                                  ],
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


/* 

 Column(
                  children: [
                    Container(
                      child: OnBoardingSlider(
                        headerBackgroundColor: Colors.white,
                        finishButtonText: 'Explore',
                        finishButtonStyle: FinishButtonStyle(
                          backgroundColor: Colors.black,
                        ),
                        skipTextButton: Text('Skip'),
                        background: [
                          Image.asset('assets/splash.jpg'),
                          Image.asset('assets/splash.jpg'),
                          Image.asset('assets/splash.jpg'),
                          Image.asset('assets/splash.jpg'),
                        ],
                        totalPage: 4,
                        speed: 1.8,
                        pageBodies: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                ),
                                Text('Description 1')
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                ),
                                Text('Description 2')
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                ),
                                Text('Description 3')
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 200,
                                ),
                                Text('Description 4')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),








------------------------------------------------
return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => dashboardScreen()));
          },
          child: Image.asset('assets/logo/logo.png'),
        ),
        title: Text(
          'Info',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF88BF3B),
                  Color(0xFF178F3E),
                ]),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          
    );

*/
