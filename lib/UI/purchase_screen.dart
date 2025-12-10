import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/become_partner.dart';
import 'package:hit_me_up/UI/registration_screen.dart';
import 'package:hit_me_up/UI/subscription_plan_list.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class PurchaseSubscription extends StatefulWidget {
  final Function drawerCall;
  final String subText,trialText;
  final bool isTrialClicked;
  const PurchaseSubscription({Key? key,required this.drawerCall,required this.subText,required this.trialText
    ,required this.isTrialClicked}) : super(key: key);

  @override
  State<PurchaseSubscription> createState() => _PurchaseSubscriptionState();
}

class _PurchaseSubscriptionState extends State<PurchaseSubscription> {

  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isGuest = authProvider.isGuest;
  }

  Future navigationRegisterPage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future navigationHomePage() async {
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: const AppDrawer(isNotification: false)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(flex: 55,child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/trial_bg.png',fit: BoxFit.fill,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 35,left: 10),
                          child: InkWell(
                            onTap: (){
                               widget.drawerCall();
                            },
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),),
                      const Expanded(child: Padding(
                          padding: EdgeInsets.only(top: 35,right: 50),
                          child: Text(
                            'Purchase',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold,shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0.0, 4.0),
                                blurRadius: 4.0,
                                color: Colors.black45,
                              ),
                            ]),
                          )))
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: .2,
                      alignment: Alignment.topLeft,
                      color: Colors.white,
                      margin: const EdgeInsets.only(left: 0.0, top: 10, right: 0.0),
                    ),
                  ),
                  Expanded(child: Center(
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
                              _loginRequired("Please login to get Free Trial");
                            }else{
                              if(widget.isTrialClicked){
                                showLoader(context);
                                apiTrialPurchase();
                              }else{
                                if(widget.trialText.contains("expired on")){
                                  showMessage(kAlert, widget.trialText, context);
                                }else{
                                  showMessage(kAlert, "Your trial period has been expired", context);
                                }
                              }
                            }
                          },
                          child: Container(
                            height: 50,
                            width: widget.trialText.contains("expired on")?270:260,
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            alignment: Alignment.center,
                            child: Text(
                              widget.trialText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: buttonColor, fontSize: 16,fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
                ],
              )
            ],
          )),
          Expanded(flex: 45,child:  Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/subscription_bg.png',fit: BoxFit.fill,),
              Center(
                child: Card(
                  color: Colors.white,
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if(isGuest){
                        _loginRequired("Please login to buy subscription");
                      }else{
                        navigationSubscriptionPage();
                      }

               /*       if(widget.subText.contains("expired on")) {
                        showMessage(kAlert, "Your current plan is active.", context);
                      }else{
                        navigationSubscriptionPage();
                      }*/
                    },
                    child:
                    Container(
                      height: 50,
                      width: widget.subText.contains("expires on")?300:200,
                      padding: const EdgeInsets.only(top: 5, bottom: 5,left: 7,right: 7),
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          widget.subText,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              color: buttonParrotColor, fontSize: widget.subText.contains("expires on")?13:16,fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  Future navigationSubscriptionPage() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: SubscriptionPlanList(userId: user[kId].toString(),)));
  }

  void apiTrialPurchase() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      "sub_id": "0",
      "user_id": user[kId].toString(),
      "type": "0",
    };
    const url = "$baseUrl/buy-subscriptions";
    var result = await callApi("POST", param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context, kTrialPeriodStart);
      Timer(const Duration(seconds: 1), () {
        navigationHomePage();
      });

      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AppDrawer(isNotification: false)));
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  void _loginRequired(String message) {
    showToast(context, message);
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });

  }
}
