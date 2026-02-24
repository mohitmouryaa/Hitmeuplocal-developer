import 'package:flutter/material.dart';

class AboutUsScreen extends StatefulWidget {
  final Function drawerCall;
  const AboutUsScreen({super.key,required this.drawerCall});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title: const Text(
            'About Us',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              alignment: Alignment.center,
              child: const Text(
                'It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts. It is a long established fact that a Your Source For Local Discounts.nnIt is a long established fact that a Your Source For Local Discounts English.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontStyle: FontStyle.normal,),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
              alignment: Alignment.center,
              child: const Text(
                'It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts.It is a long established fact that a Your Source For Local Discounts. It is a long established fact that a Your Source For Local Discounts.nnIt is a long established fact that a Your Source For Local Discounts English.',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontStyle: FontStyle.normal,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
