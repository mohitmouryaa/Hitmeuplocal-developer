import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/subscription_plan_list.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'package:hit_me_up/providers/auth_provider.dart';
import 'package:hit_me_up/UI/login_screen.dart';

class LoginPurchaseSubscription extends StatefulWidget {
  final String userId;
  final String subText, trialText;
  final bool isTrialClicked;

  const LoginPurchaseSubscription(
      {super.key,
      required this.userId,
      required this.subText,
      required this.trialText,
      required this.isTrialClicked,});

  @override
  State<LoginPurchaseSubscription> createState() =>
      _LoginPurchaseSubscriptionState();
}

class _LoginPurchaseSubscriptionState extends State<LoginPurchaseSubscription> {

  bool isGuest = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isGuest = authProvider.isGuest;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 55,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/trial_bg.png',
                      fit: BoxFit.fill,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 45, bottom: 10),
                          child: const Center(
                              child: Text(
                            'Purchase',
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
                                ],),
                          ),),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            height: .2,
                            alignment: Alignment.topLeft,
                            color: Colors.white,
                            margin: const EdgeInsets.only(
                                left: 0.0, top: 10, right: 0.0,),
                          ),
                        ),
                        Expanded(
                            child: Center(
                          child: Card(
                            color: Colors.white,
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                if(isGuest){
                                  _loginRequired();
                                }else {
                                  if (widget.isTrialClicked) {
                                    showLoader(context);
                                    apiTrialPurchase();
                                  } else {
                                    if (widget.trialText.contains('expired on')) {
                                      showMessage(
                                          kAlert, widget.trialText, context,);
                                    } else {
                                      showMessage(
                                          kAlert,
                                          'Your trial period has been expired',
                                          context,);
                                    }
                                  }
                                  // widget.openViewCall("home");
                                }
                              },
                              child: Container(
                                height: 40,
                                width: widget.trialText.contains('expired on')
                                    ? 270
                                    : 200,
                                padding: const EdgeInsets.only(top: 5, bottom: 5),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.trialText,
                                  style: const TextStyle(
                                      color: buttonColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,),
                                ),
                              ),
                            ),
                          ),
                        ),),
                      ],
                    ),
                  ],
                ),),
            Expanded(
                flex: 45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/subscription_bg.png',
                      fit: BoxFit.fill,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if(isGuest){
                            _loginRequired();
                          }else{
                            if (widget.subText.contains('expired on')) {
                              showMessage(
                                  kAlert, 'Your current plan is Active.', context,);
                            } else {
                              navigationSubscriptionPage(widget.userId);
                            }
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Container(
                            height: 40,
                            width: 200,
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            alignment: Alignment.center,
                            child: const Text(
                              '1 Year Subscription',
                              style: TextStyle(
                                  color: buttonParrotColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),),
          ],
        ),
      ),
    );
  }

  Future navigationHomePage() async {
    await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    await Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const AppDrawer(isNotification: false),),);
  }

  void _loginRequired() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future navigationSubscriptionPage(String userId) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: SubscriptionPlanList(
              userId: userId,
            ),),);
  }

  void apiTrialPurchase() async {
    var param = {
      'sub_id': '0',
      'user_id': widget.userId,
      'type': '0',
    };
    //const url = "$baseUrl/buy-subscriptions";
    const url = '$baseUrl/pay-subscriptions';
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context, kTrialPeriodStart);
      await navigationHomePage();
    } else {
      showToast(context, result[kDataMessage]);
    }
  }
}
