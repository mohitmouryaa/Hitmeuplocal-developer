import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';

class ContactUsPage extends StatefulWidget {
  final void Function() drawerCall;
  const ContactUsPage({super.key,required this.drawerCall});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

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
            'Contact Us',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 210,
                child: Center(
                  child: Image.asset(
                    'assets/contact_us_bg.png', height: 200,
                    fit: BoxFit.fitWidth,
                    // color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _nameController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Name',
                  hintStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _phoneController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Phone',
                  hintStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _emailController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
                  filled: true,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _commentController,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                maxLines: 6,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10,top: 15),
                  hintText: 'Leave us a message.',
                  hintStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
                  filled: true,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 25),
              child: Card(
                color: buttonColor,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: InkWell(
                  onTap: () {
                    if(_nameController.text.isEmpty){
                      showToast(context, kEmptyNameError);
                    }else if(_phoneController.text.isEmpty){
                      showToast(context, kEmptyNumberError);
                    }else if(_phoneController.text.length<9 || _phoneController.text.length>10){
                      showToast(context, kValidNumberError);
                    }else if(_emailController.text.isEmpty){
                      showToast(context, kEmptyEmailError);
                    }else if (!isEmail(_emailController.text)) {
                      showToast(context, kValidEmailError);
                    }else if(_commentController.text.isEmpty){
                      showToast(context, kEmptyCommentError);
                    }else{
                      //showLoader(context);
                      showLoader(context);
                      apiContactUs(context);
                    }
                  },
                  child: Container(
                    height: 45,
                    width: 150,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    alignment: Alignment.center,
                    child: const Text(
                      'Send',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   void apiContactUs(BuildContext context) async {
    var param = {
      'name': _nameController.text.toString().trim(),
      'email': _emailController.text.toString().trim(),
      'mobile': _phoneController.text.toString().trim(),
      'comment': _commentController.text.toString().trim(),
    };
    const url = '$baseUrl/contact-us';
    var result = await callApi('POST', param, url);
    if (!context.mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context, result[kDataMessage].toString());
      setState(() {
        _nameController.text = '';
        _phoneController.text = '';
        _emailController.text = '';
        _commentController.text = '';
      });
    } else {
      showToast(context, result[kDataMessage].toString());
    }
  }
}
