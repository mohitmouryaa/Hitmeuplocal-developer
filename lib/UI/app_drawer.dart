import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hit_me_up/UI/about_us_screen.dart';
import 'package:hit_me_up/UI/business_owner_register.dart';
import 'package:hit_me_up/UI/categories_list_screen.dart';
import 'package:hit_me_up/UI/contact_us_screen.dart';
import 'package:hit_me_up/UI/home_screen.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/UI/login_screen.dart';
import 'package:hit_me_up/UI/my_offer_list_screen.dart';
import 'package:hit_me_up/UI/ngo_registration.dart';
import 'package:hit_me_up/UI/notification_list.dart';
import 'package:hit_me_up/UI/owner_registration.dart';
import 'package:hit_me_up/UI/purchase_screen.dart';
import 'package:hit_me_up/UI/settings_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_purchase_subscription.dart';

class AppDrawer extends StatefulWidget {
  final bool isNotification;

  const AppDrawer({Key? key,required this.isNotification}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Widget widgetForBody = widget.isNotification?NotificationListScreen(drawerCall: drawerCall):HomeScreenPage(
    drawerCall: drawerCall,
    openViewCall: openViewCall,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isHome = true;

  // int intSubActive=0;
  // int intTrial=0;

  int trialActive = 0;
  int trialExpired = 0;
  String trialText = "3 Days Trial";
  bool isTrialClicked = false;

  int subActive = 0;
  int subExpired = 0;
  String subText = "1 Year Subscription";
  String pinVerified = "0";
  String orderId = "";
  late FirebaseMessaging messaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  bool isGuest = false;

  @override
  void initState() {

    super.initState();
    //checkSub();
    //showLoader(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isGuest = authProvider.isGuest;

    checkSubscription();
    firebaseInit();
  }

  Future<void> firebaseInit() async {
    messaging = FirebaseMessaging.instance;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title// description
      importance: Importance.high,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: 'launch_background',
              ),
            ));
        _onNotificationReceived(notification.body.toString());
      }else if(notification != null && apple != null){
        _onNotificationReceived(notification.body.toString());
      }
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');


      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      widgetForBody = NotificationListScreen(drawerCall: drawerCall);
      setState(() {});
    });
  }

  Future<void> _onNotificationReceived(String msg) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification!'),
        content: const Text("You received a new notification!"),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: roundedButton(" Cancel "),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: roundedButton(" View "),
              ),
            ],
          )
        ],
      ),
    );
    if (result == true) {
      navigationHomePage();
    }
  }

  Future navigationHomePage() async {
    widgetForBody = NotificationListScreen(drawerCall: drawerCall);
    setState(() {});
  }

   checkSubscription() async {
     final authProvider = Provider.of<AuthProvider>(context, listen: false);
     if (authProvider.isGuest) {
       //callPurchaseView();
       callHomeView();
     } else{
       showLoader(context);
       String deviceTimeZone = await getTimeZone();
       print('Device Time Zone: $deviceTimeZone');
       dynamic user = await getSharedPreference(kDataLoginUser);
       var param = {
         "user_id": user[kId].toString(),
         "user_timezone": deviceTimeZone,
         // "device_type": Platform.isAndroid?'2':'1',
       };
       const url = "$baseUrl/check-subscriptions";
       var result = await callApi("POST", param, url);
       // hideLoader(context);
       if(mounted) {
         hideLoader(context);
       }
       if (result[kDataCode] == 200) {
         trialActive = result[kData][kTrial][kActive];
         trialExpired = result[kData][kTrial][kExpired];
         subActive = result[kData][kSubscription][kActive];
         if (trialActive == 1) {
           isTrialClicked = false;
           if (trialExpired == 0) {
             trialText =
             "${result[kData][kTrial][kPackageName]} expired on ${result[kData][kTrial][kExpiredDate]}";
           } else {
             isTrialClicked = false;
             trialText = "Trial Expired";
           }
         } else {
           if(trialExpired==0){
             isTrialClicked = true;
           }else{
             isTrialClicked = false;
             trialText = "Trial Expired";
           }
         }

         if (subActive == 1) {
           isTrialClicked = false;
           trialText = "Trial Expired ${result[kData][kTrial][kExpiredDate]}";
           subExpired = result[kData][kSubscription][kExpired];
           pinVerified = result[kData][kSubscription][kPinVerified].toString();
           orderId = result[kData][kSubscription][kOrderId].toString();
           if (subExpired == 0) {
             subText =
             "${result[kData][kSubscription][kPackageName]} expires on ${result[kData][kSubscription][kExpiredDate]}";
           } else {
             subText = "1 Year Subscription";
           }
         } else {
           subText = "1 Year Subscription";
           //Future.delayed(const Duration(microseconds: 1000),() => navigationPurchasePage(user[kId].toString(),false));
         }

         if (trialActive == 0 && subActive == 0) {
           callPurchaseView();
         } else if (subActive == 1) {
           if(pinVerified == "0") {
             navigationLoginScreen(orderId);
           }
         }
       } else {
         showToast(context, result!=null?result[kDataMessage]:"Server Error");
       }
       if (mounted) {
         setState(() {});
       }
     }
  }

  Future navigationPurchasePage(String userId, bool isTrial) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPurchaseSubscription(userId: userId,trialText: trialText,subText: subText,isTrialClicked: isTrialClicked,)));
  }


  Future navigationLoginScreen(String orderId) async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPinPage(
              orderId: orderId,
            )));
  }

  void callPurchaseView(){
    widgetForBody = PurchaseSubscription(
      drawerCall: drawerCall,
      isTrialClicked: isTrialClicked,
      subText: subText,
      trialText: trialText,
    );
  }

  void callHomeView(){
    widgetForBody = HomeScreenPage(
      drawerCall: drawerCall,
      openViewCall: openViewCall,
    );
  }

  Future<void> _onLogoutPressed() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert!'),
        content: const Text('Are you sure want to Logout?'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: roundedButton(" NO "),
              ),
              GestureDetector(
                onTap: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  authProvider.logout();
                  Navigator.pop(context, true);
                },
                child: roundedButton(" YES "),
              ),
            ],
          )
        ],
      ),
    );
    if (result == true) {
      removeSharedPreference(context);
    }
  }

  void _onLoginPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  void drawerCall() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.pop(context);
    } else {
      _scaffoldKey.currentState!.openDrawer();
      setState(() {});
    }
  }

  Future<void> openViewCall(var data) async {
    switch (data[kScreen]) {
      case kSubCategory:
        isHome = false;
        widgetForBody = CategoriesListScreen(
          drawerCall: drawerCall,
          openViewCall: openViewCall,
          data: data,
        );
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          body: widgetForBody,
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF).withOpacity(0.7),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.3, 0),
                          ),
                          leading: SizedBox(
                            height: 20,
                            width: 20,
                            child: Image.asset(
                              'assets/home_icon.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = true;
                            widgetForBody = HomeScreenPage(
                              drawerCall: drawerCall,
                              openViewCall: openViewCall,
                            );
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Purchase',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.3, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              height: 27,
                              width: 18,
                              child: Image.asset(
                                'assets/purchase_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            isHome = false;
                            Navigator.pop(context);
                            if(trialActive == 1 && trialExpired==0){
                              callPurchaseView();
                            }else if(subActive == 1 && subExpired==0){
                              if(pinVerified == "0") {
                                navigationLoginScreen(orderId);
                              }else{
                                callPurchaseView();
                              }
                            }else{
                              callPurchaseView();
                            }
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'My Offer\'s',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.3, 0),
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 3),
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            isHome = false;
                            Navigator.pop(context);
                            if(trialActive == 1 && trialExpired==0){
                              widgetForBody = MyOfferListScreen(drawerCall: drawerCall,);
                            }else if(subActive == 1 && subExpired==0){
                              if(pinVerified == "0") {
                                navigationLoginScreen(orderId);
                              }else{
                                widgetForBody = MyOfferListScreen(drawerCall: drawerCall,);
                              }
                            }else{
                              callPurchaseView();
                            }
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Discounts',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.2, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Image.asset(
                                'assets/discount_menu_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            isHome = false;
                            Navigator.pop(context);
                            if(trialActive == 1 && trialExpired==0){
                              isHome = true;
                              widgetForBody = HomeScreenPage(
                                drawerCall: drawerCall,
                                openViewCall: openViewCall,
                              );
                            }else if(subActive == 1 && subExpired==0){
                              if(pinVerified == "0") {
                                navigationLoginScreen(orderId);
                              }else{
                                isHome = true;
                                widgetForBody = HomeScreenPage(
                                  drawerCall: drawerCall,
                                  openViewCall: openViewCall,
                                );
                              }
                            }else{
                              callPurchaseView();
                            }
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.2, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: SizedBox(
                              height: 15,
                              width: 20,
                              child: Image.asset(
                                'assets/menu_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            var data={
                              kSearchType:"NA",
                            };
                            widgetForBody = CategoriesListScreen(
                              drawerCall: drawerCall,
                              openViewCall: openViewCall,
                              data: data,
                            );
                            setState(() {});
                          },
                        ),
                        Container(
                          height: 0.5,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          color: Colors.black,
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        if (!isGuest)ListTile(
                          title: const Align(
                            child: Text(
                              "Notification's",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.2, 0),
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 7),
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody =
                                NotificationListScreen(drawerCall: drawerCall);
                            setState(() {});
                          },
                        ),
                        //Hidden as per client suggested
                        /*ListTile(
                          title: const Align(
                            child: Text(
                              'Business Owner',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.2, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: SizedBox(
                              height: 23,
                              width: 20,
                              child: Image.asset(
                                'assets/business_owner_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody =
                                BusinessOwnerRegister(drawerCall: drawerCall);
                            setState(() {});
                          },
                        ),*/
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Business Owner Registration',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.2, 0),
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 7),
                            child: Icon(
                              Icons.article,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody = OwnerRegisterPage(
                              drawerCall: drawerCall,
                              title: "",
                              url: "",
                            );
                            setState(() {});
                          },
                        ),
                        Container(
                          height: 0.5,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          color: Colors.black,
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'Fundraising Registration',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.1, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: SizedBox(
                              height: 20,
                              width: 22,
                              child: Image.asset(
                                'assets/fundraising_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody = NGORegisterPage(
                              drawerCall: drawerCall,
                              url: "",
                              title: "",
                            );
                            setState(() {});
                          },
                        ),
                        /*ListTile(
                          title: const Align(
                            child: Text(
                              'Fundraising Registration',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.1, 0),
                          ),
                          leading: const Icon(
                            Icons.description,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody = NGORegisterPage(
                              drawerCall: drawerCall,
                              url: "",
                              title: "",
                            );
                            setState(() {});
                          },
                        ),*/
                        Container(
                          height: 0.5,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          color: Colors.black,
                          margin:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                        ),
                        ListTile(
                          title: const Align(
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment(-1.0, 0),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Image.asset(
                                'assets/about_icon.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody = AboutUsScreen(
                              drawerCall: drawerCall,
                            );
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: const Align(
                            alignment: Alignment(-1.0, 0),
                            child: Text(
                              'Contact Us',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Icon(
                              Icons.call,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            isHome = false;
                            widgetForBody =
                                ContactUsPage(drawerCall: drawerCall);
                            setState(() {});
                          },
                        ),
                        ListTile(
                          title: Align(
                            alignment: const Alignment(-1.0, 0),
                            child: Text(
                              isGuest ? 'Login' : 'Settings',
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          leading: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (isGuest) {
                              _onLoginPressed();
                            } else {
                              //_onLogoutPressed();
                              //Navigator.pop(context);
                              isHome = false;
                              widgetForBody =
                                  SettingsScreen(drawerCall: drawerCall);
                              setState(() {});
                            }
                          },
                        ),
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 5, right: 5),
                            child: Text(
                              'Version 1.0',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (isHome) {
            return true;
          } else {

            isHome = true;
            onBackPress(context, drawerCall, openViewCall);
            return false;
          }
        });
  }

   checkSub()  {
     showLoader(context);
    Future.delayed(const Duration(milliseconds: 500), () async {

      checkSubscription();

    });
  }

}
