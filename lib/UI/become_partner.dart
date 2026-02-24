import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';

class BecomePartner extends StatefulWidget {

  const BecomePartner({super.key});


  @override
  State<BecomePartner> createState() => _BecomePartnerState();
}

class _BecomePartnerState extends State<BecomePartner> {

  Future navigationPage() async {
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppDrawer()),
    );*/
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Become Partner',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,),
      persistentFooterButtons: [
        Center(
          child: Card(
            color: buttonColor,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: GestureDetector(
              onTap: () {
                navigationPage();
              },
              child: Container(
                height: 45,
                width: 150,
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                alignment: Alignment.center,
                child: const Text(
                  'Email Us',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16,fontWeight: FontWeight.w500,),
                ),
              ),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
         child: Column(
           children: [
             Container(
               padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
               alignment: Alignment.center,
               child: const Text(
                 'It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts. It is a long established fact that a Your Source For Local Discounts.nnIt is a long established fact that a Your Source For Local Discounts English.',
                 style: TextStyle(
                     color: Colors.black, fontSize: 17,fontStyle: FontStyle.normal,),
               ),
             ),
             Container(
               padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
               alignment: Alignment.center,
               child: const Text(
                 'It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts. It is a long established fact that a Your Source For Local Discounts.nnIt is a long established fact that a Your Source For Local Discounts English.',
                 style: TextStyle(
                     color: Colors.black, fontSize: 17,fontStyle: FontStyle.normal,),
               ),
             ),
           ],
         ),
      ),
    );
  }
}
