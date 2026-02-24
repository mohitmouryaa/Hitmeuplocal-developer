
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';

class FundraisingRequestForm extends StatefulWidget {

  const FundraisingRequestForm({super.key,});

  @override
  State<FundraisingRequestForm> createState() => _FundraisingRequestFormState();
}

class _FundraisingRequestFormState extends State<FundraisingRequestForm> {
  final _nameController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commentController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 35,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'Fundraising Request',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
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
                  maxLines: 1,
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
                  controller: _organizationNameController,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    hintText: 'Name of Organization',
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
                  maxLines: 1,
                  controller: _addressController,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    hintText: 'Address',
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
                  maxLines: 1,
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
                  maxLines: 1,
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
                    hintText: 'Comments',
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
              InkWell(
                onTap: (){
                  if(_nameController.text.isEmpty){
                    showToast(context, kEmptyNameError);
                  }else if(_organizationNameController.text.isEmpty){
                    showToast(context, kEmptyOrganizationNameError);
                  }else if(_addressController.text.isEmpty){
                    showToast(context, kEmptyAddressError);
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
                    showLoader(context);
                    apiFundRequest(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Card(
                    color: buttonColor,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Container(
                      height: 45,
                      width: 150,
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      alignment: Alignment.center,
                      child: const Text(
                        'Ok',
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
      ),
    );
  }

  void apiFundRequest(BuildContext context) async {
    var param = {
      'name': _nameController.text.toString().trim(),
      'org_name': _organizationNameController.text.toString().trim(),
      'email': _emailController.text.toString().trim(),
      'mobile': _phoneController.text.toString().trim(),
      'address': _addressController.text.toString().trim(),
      'comment': _commentController.text.toString().trim(),
    };
    const url = '$baseUrl/fund-rasing-request';
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showToast(context,result[kDataMessage],);
      _nameController.clear();
       _organizationNameController.clear();
       _addressController.clear();
       _phoneController.clear();
       _emailController.clear();
       _commentController.clear();
    } else {
      showToast(context, result[kDataMessage]);
    }
  }
}
