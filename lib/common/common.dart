import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ******Color Code********//

const greyColor = Color(0xffaeaeae);
const greyColor2 = Color(0xffE8E8E8);
const greyCol = Color(0xffede9e9);
const greyBorder = Color(0xffD3DBE1);
const greyFilled = Color(0xffF7F7F9);

const buttonColor = Color(0xFF1B9CEA);
const buttonParrotColor = Color(0xFF4bb905);
const buttonParrot1Color = Color(0xFF4bb905);
const appBarGreen = Color(0xFF3DB133);
const editField = Color(0xFFEEF4FE);

const kDataCode = 'status_code';
const kDataMessage = 'message';
const kData = 'data';
const kName = 'name';
const kAlert = 'Alert!';
const kSubscription = 'subscription';
const kSubActive = 'sub_active';
const kShowTrial = 'showTrial';
const kDataLoginUser = 'user_data';
const kId = 'id';
const kTitle = 'title';
const kSearchType = 'search_type';
const kType = 'type';
const kState = 'state';
const kCity = 'city';
const kZipCode = 'zip_code';
const kScreen = 'screen';
const kSubCategory = 'subCategory';
const kHome = 'home';
const kTrial = 'trial';
const kActive = 'active';
const kExpired = 'expired';
const kRecurring = 'recurring_payment';
const kPackageName = 'package_name';
const kExpiredDate = 'expiry_date';
const kPinVerified = 'pin_verified';
const kOrderId = 'order_id';
const kEmptyEmailError = 'Please enter your Email.';
const kEmptyRegisterPinError = 'Please enter your Pin.';
const kEmptyCommentError = 'Please enter your comment.';
const kEmptyAddressError = 'Please enter your Address.';
const kEmptyCityError = 'Please enter your city.';
const kEmptyPinError = 'Please enter your Zip-Code.';
const kValidPinError = 'Please enter valid Zip-Code.';
const kEmptyCountryError = 'Please select Country';
const kEmptySelectCountryError = 'Please select Country First.';
const kEmptyStateError = 'Please select State';
const kEmptyNumberError = 'Please enter your Phone Number.';
const kValidNumberError = 'Please enter valid Phone Number.';
const kPhoneCodeError = 'Please enter Phone Code.';
const kEmptyNameError = 'Please enter your Name.';
const kEmptyLastNameError = 'Please enter your Last Name.';
const kEmptyOrganizationNameError = 'Please enter Organization Name.';
const kValidEmailError = 'Please enter valid Email.';
const kEmptyPasswordError = 'Please enter Password.';
const kEmptyConfirmPasswordError = 'Please enter Confirm Password.';
const kMatchPasswordError = 'Your password does not match.';
const kPasswordLength = 'Password length should be at least 6 digits';
const kTrialPeriodStart = 'Your 3 days trial period started successfully.';
const kCurrencySymbol = '\$';

const appThemeColor = '#1154AE';

// Plain HTTP is blocked by Android's network security policy and iOS ATS in production.
// const baseUrl = 'https://dev.01s.in/hitmeup/public/api';
const baseUrl = 'http://104.131.164.62/api';

Widget noDataFound(String text) {
  return Center(
    heightFactor: 10,
    child: Text(
      text == 'Please wait while processing...' ? '' : text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
  );
}

void onBackPress(
  BuildContext context,
  Function drawerCall,
  Function openViewCall,
) {
  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => const AppDrawer(
        isNotification: false,
      ),
    ),
  );
}

/*void showMessagePopUp(
  String title,
  String message,
  BuildContext mContext,
) {
  showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[50],
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'OK',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 400), () {
                  Navigator.pop(context, true);
                });
              },
            ),
          ],
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: const TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        );
      });
}*/

void showMessage(
  String title,
  String message,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[50],
        actions: <Widget>[
          ElevatedButton(
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    },
  );
}

void showMessageAnimation(
  String title,
  String message,
  BuildContext context,
) {
  showGeneralDialog(
    barrierLabel: 'Barrier',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 700),
    context: context,
    pageBuilder: (_, __, ___) {
      return AlertDialog(
        backgroundColor: Colors.grey[50],
        actions: const <Widget>[
          // FlatButton(
          //   child: Text(
          //     'OK',
          //     style: TextStyle(
          //         color: Colors.black,
          //         fontSize: 15,
          //         fontWeight: FontWeight.w700),
          //   ),
          //   onPressed: () {
          //     Navigator.of(context).pop();
          //   },
          // ),
        ],
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position:
            Tween(begin: const Offset(0, 1), end: Offset.zero).animate(anim),
        child: child,
      );
    },
  );
}

void showSuccessMessage(String message, BuildContext context) {
  // Scaffold.of(context).showSnackBar(SnackBar(
  //   content: Text(
  //     message,
  //     style: TextStyle(
  //         color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
  //   ),
  //   backgroundColor: Colors.green,
  // ));
}

Future<String> getTimeZone() async {
  try {
    String timeZone = await FlutterTimezone.getLocalTimezone();
    if (timeZone.isEmpty) {
      return 'Timezone not detected or returned empty.';
    }
    return timeZone;
  } catch (e) {
    return 'Error fetching timezone: $e';
  }
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(em);
}

void setSharedPreference(String key, dynamic value) async {
  var str = convert.json.encode(value);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, str);
}

Future<dynamic> getSharedPreference(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString(key) != null) {
    dynamic obj = convert.jsonDecode(prefs.getString(key) ?? '');
    return obj;
  }
}

void removePreference(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

Widget roundedButton(String buttonLabel) {
  var loginBtn = Container(
    padding: const EdgeInsets.all(5.0),
    alignment: FractionalOffset.center,
    child: Text(
      buttonLabel,
      style: const TextStyle(
        color: buttonColor,
        fontSize: 18.0,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
  return loginBtn;
}

void removeSharedPreference(BuildContext context) async {
  dynamic user = await getSharedPreference(kDataLoginUser);
  if (user != null) {
    removePreference(kDataLoginUser);
  }
  await Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
  );
}

void hideLoader(BuildContext context) {
  Navigator.pop(context);
}

void showToast(BuildContext context, String msg) {
  Fluttertoast.showToast(
    msg: msg,
    //toastLength: Toast.LENGTH_SHORT,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
  );
  // Toast.show(msg, context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
}

Widget showCustomToast(BuildContext context, String msg) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.black54,
    ),
    child: Text(
      msg,
      style: const TextStyle(fontSize: 16.0, color: Colors.white),
    ),
  );
  return toast;
}

void showLoader(BuildContext context) {
  SchedulerBinding.instance.addPostFrameCallback(
    (_) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AbsorbPointer(
          absorbing: true,
          child: SizedBox(
            height: 20,
            width: 20,
            child: Image.asset(
              'assets/loader.gif',
              height: 20,
              width: 20,
              fit: BoxFit.scaleDown,
            ),
          ),
        );
      },
    ),
  );
}
