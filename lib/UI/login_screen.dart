import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/forgot_password.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/UI/login_purchase_subscription.dart';
import 'package:hit_me_up/UI/registration_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:hit_me_up/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int trialActive = 0;
  int trialExpired = 0;
  String subText = '1 Year Subscription';
  String trialText = '3 Days Trial';
  int subActive = 0;
  int subExpired = 0;
  String pinVerified = '0';
  String orderId = '';
  bool isTrialClicked = false;
  late FirebaseMessaging messaging;
  String _token='';
  late FToast fToast;

  @override
  void initState() {
    super.initState();
      fToast = FToast();
      fToast.init(context);
      messaging = FirebaseMessaging.instance;
      messaging.getToken().then((value) {
        _token = value.toString();
      }).catchError((e) {
        // FCM token unavailable on simulators / devices without APNs support
      });

  }

  Future navigationRegisterPage() async {
    await Navigator.push(
      context,
      PageTransition(
          type: PageTransitionType.rightToLeft, child: const RegisterPage(),),
    );
  }

  Future navigationForgotPasswordPage() async {
    await Navigator.push(
      context,
      PageTransition(
          type: PageTransitionType.rightToLeft, child: const ForgotPasswordPage(),),
    );
  }

  Future navigationPurchasePage(String userId, bool isTrial) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPurchaseSubscription(userId: userId,trialText: trialText,subText: subText,isTrialClicked: isTrialClicked,),),);
  }

  Future navigationHomePage() async {
    await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    await Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const AppDrawer(isNotification: false),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10), // Adjust padding as needed
          child: Text(
            'Login',
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
              ],
            ),
          ),
        ),
        backgroundColor: appBarGreen, // Change to your desired color
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
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                // const Padding(
                //     padding: EdgeInsets.only(top: 40),
                //     child: Text(
                //       'Login',
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           shadows: <Shadow>[
                //             Shadow(
                //               offset: Offset(0.0, 4.0),
                //               blurRadius: 4.0,
                //               color: Colors.black45,
                //             ),
                //           ]),
                //     )),
                // Align(
                //   alignment: Alignment.topLeft,
                //   child: Container(
                //     height: .2,
                //     alignment: Alignment.topLeft,
                //     color: Colors.white,
                //     margin:
                //         const EdgeInsets.only(left: 0.0, top: 15, right: 0.0),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 230,
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png', height: 230,
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
                          color: Colors.black, fontWeight: FontWeight.bold,),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),),
                      fillColor: editField,
                      filled: true,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15, bottom: 25),
                  alignment: Alignment.center,
                  width: 250,
                  height: 45,
                  padding: const EdgeInsets.only(top: 0),
                  child: TextFormField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10),
                      hintText: 'Password*',
                      hintStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold,),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),),
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
                      } else if (!isEmail(_emailController.text)) {
                        showToast(context, kValidEmailError);
                      } else if (_passwordController.text.isEmpty) {
                        showToast(context, kEmptyPasswordError);
                      } else {
                        showLoader(context);
                        apiLoginUser(context);
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
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(30, 10, 40, 10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text('OR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0.0, 4.0),
                            blurRadius: 4.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),),
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      navigationHomePage();
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
                          'Skip',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    navigationRegisterPage();
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30, 20, 40, 10),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text('New user? Create an account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(0.0, 4.0),
                              blurRadius: 4.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    navigationForgotPasswordPage();
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30, 0, 40, 40),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text('Forgot password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(0.0, 4.0),
                              blurRadius: 4.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future navigationLoginScreen(String orderId) async {
    await Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPinPage(
              orderId: orderId,
            ),),);
  }

  /*"sub_active":1(Subscribed),"showTrial":0(Trial version expired)*/
  void apiLoginUser(BuildContext context) async {
    var param = {
      'login_type': '1',
      'email': _emailController.text.toString().trim(),
      'password': _passwordController.text.toString().trim(),
      'device_token': _token.isNotEmpty?_token:'NoDeviceTokenFound',
     // "device_token": 'example',
      'device_type': Platform.isAndroid?'android':'ios',
    };
    const url = '$baseUrl/login';
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context, result[kDataMessage]);
      setSharedPreference(kDataLoginUser, result[kData]);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.login();
      trialActive = result[kData][kSubscription][kTrial][kActive];
      if (trialActive == 1) {
        isTrialClicked = false;
        trialExpired = result[kData][kSubscription][kTrial][kExpired];
        if (trialExpired == 0) {
          trialText = '${result[kData][kSubscription][kTrial][kPackageName]} expired on ${result[kData][kSubscription][kTrial][kExpiredDate]}';
        } else {
          isTrialClicked = true;
          trialText = 'Trial Expired';
        }
      } else {
        if(trialExpired==0){
          isTrialClicked = true;
        }else{
          isTrialClicked = false;
          trialText = 'Trial Expired';
        }
      }
      subActive = result[kData][kSubscription][kSubscription][kActive];
      if (subActive == 1) {
        subExpired = result[kData][kSubscription][kSubscription][kExpired];
        pinVerified = result[kData][kSubscription][kSubscription][kPinVerified].toString();
        orderId = result[kData][kSubscription][kSubscription][kOrderId].toString();
        if (subExpired == 0) {
          subText =
          '${result[kData][kSubscription][kSubscription][kPackageName]} expired on ${result[kData][kSubscription][kSubscription][kExpiredDate]}';
        } else {
          subText = '1 Year Subscription';
        }
      } else {
        subText = '1 Year Subscription';
      }

      if(trialActive == 1 && trialExpired==0){
        await navigationHomePage();
      }else if(subActive == 1 && subExpired==0){
        if(pinVerified == '0') {
          await navigationLoginScreen(orderId);
        }else{
          await navigationHomePage();
        }
      }else{
        /*navigationPurchasePage(result[kData][kId].toString(),
            result[kData][kSubscription][kShowTrial] == 1);*/
        await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AppDrawer(isNotification: false),
            ),);
      }
    } else {
      //showToast(context, result[kDataMessage]);
      fToast.showToast(
        child: showCustomToast(context, result[kDataMessage]),
        toastDuration: const Duration(seconds: 5),
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
