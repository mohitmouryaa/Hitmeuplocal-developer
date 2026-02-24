import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function drawerCall;
  const SettingsScreen({super.key,required this.drawerCall});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: InkWell(
            onTap: () {
              widget.drawerCall();
            },
            child: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 35,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'Settings',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout , color: Colors.white , size: 25,),
              label: const Text('Logout' ,style: TextStyle(color: Colors.white , fontSize: 20),),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onDeleteAccount,
              icon: const Icon(Icons.delete, color: buttonColor),
              label: const Text(
                'Delete Account',
                style: TextStyle(color: buttonColor),
              ),
            ),
            //const SizedBox(height: -5,),
            const Text('(Delete account will permanently delete your account)' ,style: TextStyle(color: Colors.grey , fontSize: 10),),
            // ElevatedButton.icon(
            //   onPressed: onDeleteAccount,
            //   icon: const Icon(Icons.delete),
            //   label: const Text('Delete Account'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.red,
            //     minimumSize: const Size(double.infinity, 50),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> onLogout() async {
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
                child: roundedButton(' NO '),
              ),
              GestureDetector(
                onTap: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  authProvider.logout();
                  Navigator.pop(context, true);
                },
                child: roundedButton(' YES '),
              ),
            ],
          ),
        ],
      ),
    );
    if (result == true) {
      removeSharedPreference(context);
    }
  }


  Future<void> onDeleteAccount() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert!'),
        content: const Text('Are you sure want to delete your account permanently?'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: roundedButton(' NO '),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: roundedButton(' YES '),
              ),
            ],
          ),
        ],
      ),
    );
    if (result == true) {
      bool autoRenewal = await checkSubscription();
      if(autoRenewal){
        // Show another alert: subscription not cancelled
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Subscription Active'),
            content: const Text(
              'You have an active subscription. Please cancel your renewal from your Apple Subscriptions before deleting your account.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: roundedButton(' Cancel '),
              ),
              TextButton(
                onPressed: () async {
                  const url = 'https://apps.apple.com/account/subscriptions';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                  Navigator.pop(context);
                },
                child: roundedButton(' Proceed '),
              ),
            ],
          ),
        );
      }else{
        await deleteUserAccount();
      }
    }
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    //print("userName"+userData["name"].toString());
    //String name = userData["name"];

    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        setState(() {
          userName = userMap['name'] ?? 'Guest';
        });
      } catch (e) {
        // handle JSON parse error
        setState(() {
          userName = 'Guest';
        });
      }
    } else {
      setState(() {
        userName = 'Guest';
      });
    }
  }

  Future<bool> checkSubscription() async {
    showLoader(context);
    bool autoRenewal = false;
      String deviceTimeZone = await getTimeZone();
      dynamic user = await getSharedPreference(kDataLoginUser);
      var param = {
        'user_id': user[kId].toString(),
        'user_timezone': deviceTimeZone,
        // "device_type": Platform.isAndroid?'2':'1',
      };
      const url = '$baseUrl/check-subscriptions';
      var result = await callApi('POST', param, url);
      // hideLoader(context);
      if(mounted) {
        hideLoader(context);
      }
      if (result[kDataCode] == 200) {
        if(result[kData][kSubscription][kActive] == 1 && result[kData][kSubscription][kRecurring] == 1){
          autoRenewal = true;
        }
      } else {
        showToast(context, result[kDataMessage]);
      }
    if(mounted) {
      setState(() {});
    }
      return autoRenewal;
  }

  Future<void> deleteUserAccount() async {
    showLoader(context);
    dynamic user = await getSharedPreference(kDataLoginUser);
    String user_id =  user[kId].toString();
    final url = '$baseUrl/delete-user/$user_id';
    var result = await callApi('GET', null, url);
    // hideLoader(context);
    if(mounted) {
      hideLoader(context);
    }
    if (result[kDataCode] == 200) {
      showToast(context, result[kData][kDataMessage]);
      showToast(context, result[kDataMessage]);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.logout();
      removeSharedPreference(context);
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

}
