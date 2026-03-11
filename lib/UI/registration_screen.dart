import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hit_me_up/UI/select_state.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/country_list_data.dart';
import 'package:hit_me_up/model/phone_code_list_data.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _referenceController = TextEditingController();
  late String _countryId='', _stateId='',_phoneCodeId='',_phoneCode='';
  late List<CountryListData> countryData = [];
  late List<PhoneCodeListData> countryCodeData = [];



  @override
  void initState() {
    super.initState();
    showLoader(context);
    getCountry();
    _countryController.text = 'Country';
    _stateController.text = 'State';
    _phoneCode = '+Code';
  }




  void _awaitReturnValueFromSelectedState() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectState(
            countryId: _countryId,
          ),
        ),);
    if (result != null) {
      setState(() {
        String jsonData = result;
        _stateId = jsonData.split('@')[0];
        _stateController.text = jsonData.split('@')[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'Registration',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            iconSize: 35,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
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
                    'assets/logo.png', height: 200,
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
                  hintText: 'First Name',
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
                controller: _lastNameController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Last Name',
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
              decoration: BoxDecoration(
                  border: Border.all(color: greyBorder, width: 0.0),
                  color: greyFilled,
                  borderRadius: const BorderRadius.all(Radius.circular(25)),),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Phone code commented on UI (but functionality still working)
                  /*Expanded(
                    flex:25,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5,top: 0),
                        child: GestureDetector(
                          //onTap: _awaitSelectedPhoneCode,
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              Text(_phoneCode),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Container(width: 1,height: 30, color: Colors.black),
                              ),
                              *//*const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              )*//*
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  Expanded(
                    flex: 65,
                    child: TextFormField(
                      controller: _phoneController,
                      textAlign: TextAlign.left,
                      //keyboardType: TextInputType.number,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: 'Phone (Optional)',
                        hintStyle: const TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                        ),
                        border: const OutlineInputBorder(),
                        fillColor: greyFilled,
                        filled: true,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 25),
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
            GestureDetector(
              //onTap: _awaitReturnValueFromSelectedCountry,
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                alignment: Alignment.centerLeft,
                width: 220,
                height: 45,
                padding: const EdgeInsets.only(top: 0, left: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: greyBorder, width: 0.0),
                    color: greyFilled,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),),
                child: Text(
                  _countryController.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                if(_countryId.isNotEmpty){
                  _awaitReturnValueFromSelectedState();
                }else{
                  showToast(context, kEmptySelectCountryError);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15),
                alignment: Alignment.centerLeft,
                width: 220,
                height: 45,
                padding: const EdgeInsets.only(top: 0, left: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: greyBorder, width: 0.0),
                    color: greyFilled,
                    borderRadius: const BorderRadius.all(Radius.circular(25)),),
                child: Text(
                  _stateController.text,
                  style: const TextStyle(fontSize: 16),
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
                controller: _cityController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'City',
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
            // Container(
            //   margin: const EdgeInsets.only(top: 15, bottom: 15),
            //   alignment: Alignment.center,
            //   width: 220,
            //   height: 45,
            //   padding: const EdgeInsets.only(top: 0),
            //   child: TextFormField(
            //     controller: _addressController,
            //     textAlign: TextAlign.left,
            //     keyboardType: TextInputType.streetAddress,
            //     decoration: InputDecoration(
            //       contentPadding: const EdgeInsets.only(left: 10),
            //       hintText: 'Address (Optional)',
            //       hintStyle: const TextStyle(color: Colors.black),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(25.0),
            //         borderSide: const BorderSide(color: greyBorder, width: 0.0),
            //       ),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(25.0),
            //         borderSide: const BorderSide(color: greyBorder, width: 0.0),
            //       ),
            //       border: const OutlineInputBorder(),
            //       fillColor: greyFilled,
            //       filled: true,
            //     ),
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 85,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _pinCodeController,
                textAlign: TextAlign.left,
                maxLines: 1,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                //keyboardType: TextInputType.number,
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'ZipCode',
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
              margin: const EdgeInsets.only(top: 5, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 85,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _referenceController,
                textAlign: TextAlign.left,
                maxLines: 1,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Reference Number',
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
              margin: const EdgeInsets.only(top: 15, bottom: 25),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _passwordController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Password',
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
              margin: const EdgeInsets.only(top: 15, bottom: 25),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                controller: _confirmController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Confirm Password',
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
              padding: const EdgeInsets.only(bottom: 25),
              child: InkWell(
                onTap: () {
                  if (_nameController.text.isEmpty) {
                    showToast(context, kEmptyNameError);
                  } else if (_lastNameController.text.isEmpty) {
                    showToast(context, kEmptyNameError);
                  }
                  // else if (_phoneController.text.isEmpty) {
                  //   showToast(context, kEmptyNumberError);
                  // }
                  else if (_phoneController.text.isNotEmpty && _phoneController.text.length < 9 || _phoneController.text.length>11) {
                    showToast(context, kValidNumberError);
                  }else if (_phoneCodeId.isEmpty) {
                    showToast(context, kPhoneCodeError);
                  }else if (_emailController.text.isEmpty) {
                    showToast(context, kEmptyEmailError);
                  } else if (!isEmail(_emailController.text)) {
                    showToast(context, kValidEmailError);
                  }else if (_countryId.isEmpty) {
                    showToast(context, kEmptyCountryError);
                  } else if (_stateId.isEmpty) {
                    showToast(context, kEmptyStateError);
                  } else if (_cityController.text.isEmpty) {
                    showToast(context, kEmptyCityError);
                  }
                  // else if (_addressController.text.isEmpty) {
                  //   showToast(context, kEmptyAddressError);
                  // }
                  else if (_pinCodeController.text.isEmpty) {
                    showToast(context, kEmptyPinError);
                  }else if (_pinCodeController.text.length<5) {
                    showToast(context, kValidPinError);
                  } else if (_passwordController.text.isEmpty) {
                    showToast(context, kEmptyPasswordError);
                  } else if (_confirmController.text.isEmpty) {
                    showToast(context, kEmptyConfirmPasswordError);
                  } else if (_passwordController.text !=
                      _confirmController.text) {
                    showToast(context, kMatchPasswordError);
                  } else if(_passwordController.text.length < 6 || _confirmController.text.length < 6){
                    showToast(context, kPasswordLength);
                  } else {
                    showLoader(context);
                    apiRegisterUser(context);
                  }
                },
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
                      'Register',
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

  Future<void> showMessagePopUp(
      String title,
      String message,
      ) async {
    final res=await showDialog(
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
                      fontWeight: FontWeight.w700,),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
            title: Text(
              title,
              style: const TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),
            ),
            content: Text(
              message,
              style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700,),
            ),
          );
        },);
    if (!mounted) return;
    if(res!=null){
      Navigator.pop(context);
    }
  }

  void apiRegisterUser(BuildContext context) async {
    if(_phoneController.text.isEmpty){
      _phoneCode = '';
    }
    var param = {
      'name': '${_nameController.text.toString().trim()} ${_lastNameController.text.toString().trim()}',
      'email': _emailController.text.toString().trim(),
      'mobile': _phoneController.text.toString().trim(),
      'address': _addressController.text.toString().trim(),
      'password': _passwordController.text.toString().trim(),
      'phonecode': _phoneCode,
      'country_id': _countryId,
      'state_id': _stateId,
      'city': _cityController.text.toString().trim(),
      'pincode': _pinCodeController.text.toString().trim(),
      'reference_code': _referenceController.text.toString().trim(),
    };
    const url = '$baseUrl/signup';
    var result = await callApi('POST', param, url);
    if (!context.mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      await showMessagePopUp(kAlert,result[kDataMessage]);
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  void getCountry() async {
    int countryCodeId = 0;
    const url = '$baseUrl/countries-list';
    var result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      final data = result['data'] as Map<String, dynamic>;
      setState(() {
        var restCountries = data['countries'] as List;
        var restPhoneCodes = data['phonecodesList'] as List;

        countryData = restCountries.map<CountryListData>((json) => CountryListData.fromJson(json)).toList();
        countryCodeData = restPhoneCodes.map<PhoneCodeListData>((json) => PhoneCodeListData.fromJson(json)).toList();

        for(int i = 0 ; i < countryCodeData.length ; i++){
          if(countryCodeData[i].phonecode == '1'){
            countryCodeId = i;
          }
        }

        _countryId = countryData[0].id.toString();
        _countryController.text = countryData[0].name;
        _stateId = '';
        _stateController.text = 'Click To Select State';

        _phoneCodeId = countryCodeData[countryCodeId].id.toString();
        _phoneCode = '+${countryCodeData[countryCodeId].phonecode}';
        setState(() {

        });
      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

}
