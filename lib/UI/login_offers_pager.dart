import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/login_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:page_transition/page_transition.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class LoginOfferPage extends StatefulWidget {
  const LoginOfferPage({Key? key}) : super(key: key);

  @override
  State<LoginOfferPage> createState() => _LoginOfferPageState();
}

class _LoginOfferPageState extends State<LoginOfferPage> {
  final GlobalKey _containerKey = GlobalKey();
  final _controller = PageController();
  List<dynamic> offersList = [1, 2, 3];
  int pos = 0;
  final _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _autoScroll();
  }

  Future navigationPage() async {
    Navigator.push(
      context,
      PageTransition(
          type: PageTransitionType.rightToLeft, child: const LoginPage()),
    );
  }

  imageSlider(int index, BuildContext context) {
    if (index == offersList.length - 1) {
      pos = 0;
    } else {
      pos = index;
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, widget) {
        return Center(
          child: SizedBox(
            child: widget,
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
              child: SizedBox(
            height: 270,
            child: Center(
              child: Image.asset(
                "assets/polygon.png", height: 270,
                fit: BoxFit.fitWidth,
                // color: Colors.orangeAccent,
              ),
            ),
          )),
          const Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: Text(
                  "View an example of our amazing discounts!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 25,wordSpacing: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String pageNumber() {
    switch (pos) {
      case 0:
        return "contact_us_bg.png";
      case 1:
        return "owner_image.png";
      case 2:
        return "logo.png";
    }
    return "contact_us_bg.png";
  }

  void onPageChanged(int index) {
    setState(() {
      pos = index;
      _currentPageNotifier.value = index;
    });
  }

  _autoScroll() {
    Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (pos < offersList.length) {
        pos++;
        _controller.animateToPage(
          pos,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      } else {
        timer.cancel();
      }
    });
  }

  _buildCircleIndicator() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CirclePageIndicator(
          itemCount: offersList.length,
          currentPageNotifier: _currentPageNotifier,
          dotColor: Colors.white24,
          selectedDotColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/discount_bg.png',
                  fit: BoxFit.fill,
                ),
              )
            ],
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'Discounts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(0.0, 4.0),
                              blurRadius: 4.0,
                              color: Colors.black45,
                            ),
                          ]),
                    )),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: .2,
                    alignment: Alignment.topLeft,
                    color: Colors.white,
                    margin:
                        const EdgeInsets.only(left: 0.0, top: 15, right: 0.0),
                  ),
                ),
                Container(
                    key: _containerKey,
                    padding: const EdgeInsets.all(5),
                    height: 400,
                    child: Stack(
                      children: <Widget>[
                        PageView.builder(
                          controller: _controller,
                          onPageChanged: onPageChanged,
                          itemCount: offersList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return imageSlider(index, context);
                          },
                        ),
                      ],
                    )),
                _buildCircleIndicator(),
                Center(
                  child: InkWell(
                    onTap: () {
                      navigationPage();
                    },
                    child: Card(
                      margin: const EdgeInsets.only(top: 30),
                      color: buttonColor,
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Container(
                        height: 45,
                        width: 190,
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        alignment: Alignment.center,
                        child: const Text(
                          "Check'em Out",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
