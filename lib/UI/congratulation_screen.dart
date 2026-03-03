import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/app_drawer.dart';

class CongratulationScreen extends StatefulWidget {
  const CongratulationScreen({super.key});

  @override
  State<CongratulationScreen> createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<CongratulationScreen> {
  var test;

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  void dispose() {
    test.cancel();
    super.dispose();
  }

  startTime() async {
    var duration = const Duration(seconds: 4);
    test = Timer(duration, navigationPage);
  }

  Future navigationPage() async {
    if (!mounted) return;
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const AppDrawer(isNotification: false)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    height: 300,
                    child: Center(
                      child: Image.asset(
                        'assets/congratulation.gif', height: 300,
                        fit: BoxFit.fitWidth,
                        // color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  alignment: Alignment.center,
                  child: const Text(
                    'Thanks for purchasing our package',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  alignment: Alignment.center,
                  child: const Text(
                    'and',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  alignment: Alignment.center,
                  child: const Text(
                    //"Your package is valid upto",
                    'Your package is Activated',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
