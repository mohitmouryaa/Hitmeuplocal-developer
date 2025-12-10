import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/login_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/providers/auth_provider.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import 'UI/purchase_testing.dart';
import 'UI/subscription_plan_list.dart';

late AndroidNotificationChannel channel;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',// title// description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  //runApp(const MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hit Me Up',
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        primaryColorDark: Colors.green,
        primaryColorLight: Colors.blueAccent,
        fontFamily: 'VarelaRound',
      ),
        routes: {

          '/message': (context) => const AppDrawer(isNotification: true),
        },
      home: MySplashPage(),
      //home: const MySplashPage(),
    );
  }
}

class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  State<MySplashPage> createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  late FirebaseMessaging messaging;
  var test;

  @override
  void initState() {
    super.initState();
    firebaseInit();
    startTime();
  }

  Future<void> firebaseInit() async {
    messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  void dispose() {
    test.cancel();
    super.dispose();
  }

  startTime() async {
    var _duration = const Duration(seconds: 4);
    test = Timer(_duration, _checkLogin);
  }

  Future<void> _checkLogin() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    bool check = false;
    if (user != null) {
      check = user[kName] != null ? true : false;
    }
    if (check) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.login();
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      if (initialMessage != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AppDrawer(isNotification: true),
            ));
      }else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AppDrawer(isNotification: false),
            ));
      }
    } else {
      messaging.getToken().then((value) {
        print(value);
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
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
                  'assets/splash_bg.png',
                  fit: BoxFit.fill,
                ),
              )
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: SizedBox(
                  height: 300,
                  child: Center(
                    child: Image.asset(
                      "assets/logo.png", height: 200,
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
                  "Your Source For Local Discounts",
                  style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 4.0),
                          blurRadius: 4.0,
                          color: Colors.black45,
                        ),
                      ],
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 25),
                alignment: Alignment.center,
                child: const Text(
                  "Celebrating Small Business",
                  style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 4.0),
                          blurRadius: 4.0,
                          color: Colors.black45,
                        ),
                      ],
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 5),
                alignment: Alignment.center,
                child: const Text(
                  "Everyday",
                  style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 4.0),
                          blurRadius: 4.0,
                          color: Colors.black45,
                        ),
                      ],
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 25),
                alignment: Alignment.center,
                child: const Text(
                  "Shop Local / Buy Local",
                  style: TextStyle(
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(0.0, 4.0),
                          blurRadius: 4.0,
                          color: Colors.black45,
                        ),
                      ],
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.normal),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
