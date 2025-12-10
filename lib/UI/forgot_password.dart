import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/registration_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';

import 'app_drawer.dart';
import 'login_pin_purchase.dart';
import 'login_purchase_subscription.dart';

class ForgotPasswordPage extends StatefulWidget {

  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future navigationRegisterPage() async {
    Navigator.push(
      context,
      PageTransition(
          type: PageTransitionType.rightToLeft, child: const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            iconSize: 35,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white
        //backgroundColor: appBarGreen,
      ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 230,
                    child: Center(
                      child: Image.asset(
                        "assets/logo.png", height: 230,
                        fit: BoxFit.fitWidth,
                        // color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25, bottom: 15),
                  alignment: Alignment.center,
                  width: 250,
                  height: 45,
                  padding: const EdgeInsets.only(top: 0),
                  child: TextFormField(
                    controller: _emailController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.emailAddress,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      hintText: 'Email*',
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
                      if (_emailController.text.isEmpty) {
                        showToast(context, kEmptyEmailError);
                      }else {
                        showLoader(context);
                        apiForgotPassword(context);
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
                          "Send reset email",
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

  void apiForgotPassword(BuildContext context) async {
    var param = {
      "email": _emailController.text,
    };
    print(param.toString());
    const url = "$baseUrl/sendForgetPasswordLink";
    var result = await callApi("POST", param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context, result[kDataMessage]);
    } else {
      showToast(context, result[kDataMessage]);
    }
  }
}