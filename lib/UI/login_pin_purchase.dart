import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/congratulation_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';

class LoginPinPage extends StatefulWidget {
  final String orderId;
  const LoginPinPage({Key? key,required this.orderId}) : super(key: key);

  @override
  State<LoginPinPage> createState() => _LoginPinPageState();
}

class _LoginPinPageState extends State<LoginPinPage> {
  final _pinController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/splash_bg.png',
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
                      'Verify Your Account',
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
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    height: 230,
                    child: Center(
                      child: Image.asset(
                        "assets/unlock_discounts.png", height: 230,
                        fit: BoxFit.fitWidth,
                        // color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 15),
                  alignment: Alignment.center,
                  width: 250,
                  height: 45,
                  padding: const EdgeInsets.only(top: 0),
                  child: TextFormField(
                    controller: _pinController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      //hintText: 'Pin #',
                      hintText: 'Check mail for pin.',
                      hintStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      fillColor: editField,
                      filled: true,
                    ),
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      if (_pinController.text.isEmpty) {
                        showToast(context, kEmptyRegisterPinError);
                      }  else {
                        showLoader(context);
                        apiRegisterUsingPin(context);
                      }
                    },
                    child: Card(
                      color: buttonParrotColor,
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Container(
                        height: 45,
                        width: 150,
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        alignment: Alignment.center,
                        child: const Text(
                          "Subscribe",
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
  Future navigationHomePage() async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const CongratulationScreen()));
  }

  /*"sub_active":1(Subscribed),"showTrial":0(Trial version expired)*/
  void apiRegisterUsingPin(BuildContext context) async {
    var param = {
      "order_id": widget.orderId,
      "pin": _pinController.text.toString().trim(),
    };

    const url = "$baseUrl/payment-pin-verification";
    var result = await callApi("POST", param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      /*showToast(context, result[kDataMessage]);*/
      navigationHomePage();
    } else {
      showToast(context, result[kDataMessage]);
    }
  }
}
