
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hit_me_up/UI/about_us_screen.dart';
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
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'package:hit_me_up/providers/auth_provider.dart';
import 'package:hit_me_up/UI/login_purchase_subscription.dart';

class AppDrawer extends StatefulWidget {
  final bool isNotification;

  const AppDrawer({super.key,required this.isNotification});

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
  String trialText = '3 Days Trial';
  bool isTrialClicked = false;

  int subActive = 0;
  int subExpired = 0;
  String subText = '1 Year Subscription';
  String pinVerified = '0';
  String orderId = '';
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
            ),);
        _onNotificationReceived(notification.body.toString());
      }else if(notification != null && apple != null){
        _onNotificationReceived(notification.body.toString());
      }
      if (message.notification != null) {
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
        content: const Text('You received a new notification!'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: roundedButton(' Cancel '),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: roundedButton(' View '),
              ),
            ],
          ),
        ],
      ),
    );
    if (result == true) {
      await navigationHomePage();
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
       final String deviceTimeZone = await getTimeZone();
       final dynamic rawUser = await getSharedPreference(kDataLoginUser);
       final user = rawUser as Map<String, dynamic>;
       final param = {
         'user_id': user[kId].toString(),
         'user_timezone': deviceTimeZone,
       };
       const url = '$baseUrl/check-subscriptions';
       final result = await callApi('POST', param, url);
       if (mounted) {
         hideLoader(context);
       }
       if (!mounted) return;
       if (result[kDataCode] == 200) {
         final appData = result[kData] as Map<String, dynamic>;
         final trialData = appData[kTrial] as Map<String, dynamic>;
         final subData = appData[kSubscription] as Map<String, dynamic>;
         trialActive = trialData[kActive] as int;
         trialExpired = trialData[kExpired] as int;
         subActive = subData[kActive] as int;
         if (trialActive == 1) {
           isTrialClicked = false;
           if (trialExpired == 0) {
             trialText =
             '${trialData[kPackageName]} expired on ${trialData[kExpiredDate]}';
           } else {
             isTrialClicked = false;
             trialText = 'Trial Expired';
           }
         } else {
           if (trialExpired == 0) {
             isTrialClicked = true;
           } else {
             isTrialClicked = false;
             trialText = 'Trial Expired';
           }
         }

         if (subActive == 1) {
           isTrialClicked = false;
           trialText = 'Trial Expired ${trialData[kExpiredDate]}';
           subExpired = subData[kExpired] as int;
           pinVerified = subData[kPinVerified].toString();
           orderId = subData[kOrderId].toString();
           if (subExpired == 0) {
             subText =
             '${subData[kPackageName]} expires on ${subData[kExpiredDate]}';
           } else {
             subText = '1 Year Subscription';
           }
         } else {
           subText = '1 Year Subscription';
         }

         if (trialActive == 0 && subActive == 0) {
           callPurchaseView();
         } else if (subActive == 1) {
           if (pinVerified == '0') {
             await navigationLoginScreen(orderId);
           }
         }
       } else {
         showToast(context, result[kDataMessage] as String);
       }
       if (mounted) {
         setState(() {});
       }
     }
  }

  Future navigationPurchasePage(String userId, bool isTrial) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPurchaseSubscription(userId: userId,trialText: trialText,subText: subText,isTrialClicked: isTrialClicked,),),);
  }


  Future navigationLoginScreen(String orderId) async {
    await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPinPage(
              orderId: orderId,
            ),),);
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


  void _onLoginPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Future<void> openViewCall(dynamic data) async {
    final screenData = data as Map<String, dynamic>;
    switch (screenData[kScreen]) {
      case kSubCategory:
        isHome = false;
        widgetForBody = CategoriesListScreen(
          drawerCall: drawerCall,
          openViewCall: openViewCall,
          data: screenData,
        );
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: isHome,
        onPopInvokedWithResult: (bool didPop, _) {
          if (!didPop) {
            isHome = true;
            onBackPress(context, drawerCall, openViewCall);
          }
        },
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
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.7),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Align(
                            alignment: Alignment(-1.3, 0),
                            child: Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                            alignment: Alignment(-1.3, 0),
                            child: Text(
                              'Purchase',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              if(pinVerified == '0') {
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
                            alignment: Alignment(-1.3, 0),
                            child: Text(
                              'My Offer\'s',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              if(pinVerified == '0') {
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
                            alignment: Alignment(-1.2, 0),
                            child: Text(
                              'Discounts',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              if(pinVerified == '0') {
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
                            alignment: Alignment(-1.2, 0),
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              kSearchType:'NA',
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
                            alignment: Alignment(-1.2, 0),
                            child: Text(
                              "Notification's",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                            alignment: Alignment(-1.2, 0),
                            child: Text(
                              'Business Owner Registration',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              title: '',
                              url: '',
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
                            alignment: Alignment(-1.1, 0),
                            child: Text(
                              'Fundraising Registration',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                              url: '',
                              title: '',
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
                            alignment: Alignment(-1.0, 0),
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

   checkSub()  {
     showLoader(context);
    Future.delayed(const Duration(milliseconds: 500), () async {

      checkSubscription();

    });
  }

}
