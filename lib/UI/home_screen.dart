import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:hit_me_up/providers/auth_provider.dart';

class HomeScreenPage extends StatefulWidget {
  final Function drawerCall,openViewCall;

  const HomeScreenPage({super.key, required this.drawerCall, required this.openViewCall});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  List<dynamic> stateList = [];
  Map stateData={};
  String _stateId='';
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  late Position position;
  bool isGuest = false;
  @override
  void initState() {
    super.initState();
    //showLoader(context);
    //getStateListData(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isGuest = authProvider.isGuest;
    requestLocationPermission();
  }

  void requestLocationPermission() async {
    if (await Permission.location.isRestricted) {
      await [
        Permission.location,
      ].request();
    }else if (await Permission.speech.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  callMark() {

    getCurrentLocation();
  }

  getCurrentLocation() async {
    bool agb = await Geolocator.isLocationServiceEnabled();
    if (agb) {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      var data={
        kSearchType:'GPS',
        kScreen:kSubCategory,
        'lat':position.latitude.toString(),
        'long':position.longitude.toString(),
        //"lat":'27.7644005',
        //"long":'-82.3985596'
        // "lat":'36.8464723',
        // "long":'-76.045599'


      };
      hideLoader(context);
      widget.openViewCall(data);
        } else {
      hideLoader(context);
      Timer(const Duration(seconds: 3), () {
        showToast(context, "Please enable your location to view offer's");
      });
    }
  }

   getStateListData(BuildContext context) async {

    String url= '' ;
    if(!isGuest){
      dynamic user = await getSharedPreference(kDataLoginUser);
      //print("Country ID - "+user["country"]["id"].toString());
       url = "$baseUrl/states-list/${user["country"]["id"]}";
    }else{
      int countryId = 231;
      url =  '$baseUrl/states-list/$countryId';
    }

    var result = await callApi('GET', null, url);
    if (mounted) {
      hideLoader(context);
    }
    if (result[kDataCode] == 200) {
      stateList = result['data'] as List;
      if (stateList.isNotEmpty) {
         stateData = stateList[1];
         _stateId = stateData['id'].toString();
      }
    } else {
        showToast(context, result[kDataMessage]);
    }
    if (mounted) {
      setState(() {

      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              flex: 55,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/gps_search_bg.png',
                    fit: BoxFit.fill,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 35, left: 10),
                            child: InkWell(
                              onTap: () {
                                widget.drawerCall();
                              },
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(top: 35, right: 50),
                                  child: Text(
                                    'Discounts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          Shadow(
                                            offset: Offset(0.0, 4.0),
                                            blurRadius: 4.0,
                                            color: Colors.black45,
                                          ),
                                        ],),
                                  ),),),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: .2,
                          alignment: Alignment.topLeft,
                          color: Colors.white,
                          margin: const EdgeInsets.only(
                              left: 0.0, top: 10, right: 0.0,),
                        ),
                      ),
                      Expanded(
                          child: InkWell(
                            onTap: (){
                              showLoader(context);
                              Timer(const Duration(seconds: 2), () {
                                callMark();
                               });
                            },
                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                            SizedBox(
                                height: 100,
                                width: 80,
                                child: Image.asset(
                                  'assets/gps_search_icon.png',
                                  fit: BoxFit.fill,
                                ),),
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'GPS Search',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,),
                              ),
                            ),
                        ],
                      ),
                          ),),
                    ],
                  ),
                ],
              ),),
          Expanded(
              flex: 45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/manual_search_bg.png',
                    fit: BoxFit.fill,
                  ),
                  InkWell(
                    onTap: () async {
                /*      var data={
                        kSearchType:"Manual",
                        kScreen:kSubCategory
                      };
                      widget.openViewCall(data);*/
                      showLoader(context);
                      await getStateListData(context);
                      _showBottomSheet(context);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            'assets/manual_search_icon.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Manual Search',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),),
        ],
      ),
    );
  }

  _showBottomSheet(
      BuildContext context,) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateModel) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.001),
                  child: GestureDetector(
                    onTap: () {},
                    child: Wrap(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                          ),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(flex: 3, child: Container()),
                                    const Expanded(
                                        flex: 8,
                                        child: Text(
                                          'Update List',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,),
                                        ),),
                                    Expanded(
                                        flex: 2,
                                        child: IconButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.black,
                                          ),
                                        ),),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  alignment: Alignment.centerLeft,
                                  width: 220,
                                  height: 45,
                                  padding:
                                  const EdgeInsets.only(top: 0, left: 10, right: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: greyBorder, width: 0.0),
                                      color: Colors.transparent,
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(25)),),
                                  child: DropdownButtonFormField<dynamic>(
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14,),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    decoration:
                                    const InputDecoration.collapsed(hintText: ''),
                                    value: stateData['name'],
                                    hint: const Text('Select State'),
                                    isExpanded: true,
                                    items: stateList
                                        .toSet()
                                        .toList()
                                        .map((label) => DropdownMenuItem(
                                      value: label['name'],
                                      child: Text(
                                        label['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),)
                                        .toList(),
                                    onChanged: (value) {
                                      int index = stateList
                                          .indexWhere((data) => data['name'] == value);
                                      stateData=stateList[index];
                                      _stateId = stateList[index]['id'].toString();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Container(
                                  color: Colors.transparent,
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  alignment: Alignment.center,
                                  width: 220,
                                  height: 45,
                                  padding: const EdgeInsets.only(top: 0),
                                  child: TextFormField(
                                    controller: _cityController,
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.streetAddress,
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 10),
                                      hintText: 'City',
                                      hintStyle: const TextStyle(color: Colors.black),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0,),
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0,),
                                      ),
                                      border: const OutlineInputBorder(),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const Text('OR'),
                                Container(
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  alignment: Alignment.center,
                                  width: 220,
                                  height: 45,
                                  padding: const EdgeInsets.only(top: 0),
                                  child: TextFormField(
                                    controller: _zipCodeController,
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.text,
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.digitsOnly,
                                    // ],
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 10),
                                      hintText: 'Zipcode',
                                      hintStyle: const TextStyle(color: Colors.black),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0,),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0,),
                                      ),
                                      border: const OutlineInputBorder(),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 25, top: 20),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        /*if(_stateId.isNotEmpty && _cityController.text.isNotEmpty && _zipCodeController.text.isNotEmpty){
                                          searchValue = _zipCodeController.text;
                                        }else if(_stateId.isNotEmpty && _cityController.text.isNotEmpty && _zipCodeController.text.isEmpty){
                                          searchValue = _cityController.text;
                                        }else if(_stateId.isNotEmpty && _cityController.text.isEmpty && _zipCodeController.text.isEmpty){
                                          searchValue = _stateId;
                                        }else{
                                          showToast(context, "Please enter city");
                                        }*/
                                        /*var data={
                                          kSearchType:"Manual",
                                          kScreen:kSubCategory,

                                        };*/
                                        var data;
                                        //type = 1 for State and city wise search
                                        //type = 2 for search with zip code
                                        if(_stateId.isNotEmpty && _cityController.text.isNotEmpty){
                                          data={
                                            kSearchType:'Manual',
                                            kScreen:kSubCategory,
                                            kType: 1,
                                            kState: _stateId,
                                            kCity: _cityController.text.toString().trim(),
                                          };
                                          widget.openViewCall(data);
                                          Navigator.of(context).pop();
                                        }
                                        else if (_zipCodeController.text.isNotEmpty){
                                          data={
                                            kSearchType:'Manual',
                                            kScreen:kSubCategory,
                                            kType: 2,
                                            kZipCode: _zipCodeController.text.toString().trim(),
                                          };
                                          widget.openViewCall(data);
                                          Navigator.of(context).pop();
                                        }
                                        else{
                                          showToast(context, 'Please enter City or Zip Code');
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 150,
                                        padding:
                                        const EdgeInsets.only(top: 5, bottom: 5),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.bold,),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },);
      },
    ).whenComplete(() {});
  }
}
