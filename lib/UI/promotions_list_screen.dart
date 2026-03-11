import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/UI/offer_detail_page.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/promotion_list_data.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:hit_me_up/providers/auth_provider.dart';
import 'package:hit_me_up/UI/common_promotion_by_id.dart';
import 'package:hit_me_up/UI/login_screen.dart';

class PromotionListScreen extends StatefulWidget {
  final String id;
  final dynamic data, subData, searchType;

  const PromotionListScreen({
    super.key,
    required this.id,
    required this.searchType,
    required this.data,
    required this.subData,
  });

  @override
  State<PromotionListScreen> createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  List<PromotionListData> _offerList = [];
  int bannerCount = 0;
  String _radioType = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int trialActive = 0;
  int trialExpired = 0;
  String subText = '1 Year Subscription';
  String trialText = '3 Days Trial';
  int subActive = 0;
  int subExpired = 0;
  String pinVerified = '0';
  String orderId = '';
  bool isTrialClicked = false;
  List<dynamic> stateList = [];
  List<dynamic> categoryList = [];
  List<dynamic> subCategoryList = [];
  Map stateData = {};
  Map categoryData = {};
  Map subCategoryData = {};
  String _stateId = '', _categoryId = '';
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  late Position position;
  String noPromotionsAvailable = '';
  bool isGuest = false;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    isGuest = authProvider.isGuest;

    final searchType = widget.searchType as Map<String, dynamic>;
    if (searchType[kSearchType] == 'NA') {
      _radioType = 'Manual Search';
    } else if (searchType[kSearchType] != 'NA') {
      _radioType = searchType[kSearchType] == 'GPS'
          ? 'Location Search'
          : 'Manual Search';

      if (searchType['type'] == 2) {
        if ((searchType['zip_code'] as String).isNotEmpty) {
          _zipCodeController.text = searchType['zip_code'] as String;
        }
      } else if (searchType['type'] == 1) {
        if ((searchType['state'] as String).isNotEmpty &&
            (searchType['city'] as String).isNotEmpty) {
          _stateId = searchType['state'] as String;
          _cityController.text = searchType['city'] as String;
        }
      }
    }
    //getCategories();
    if (widget.data != null) {
      categoryList = widget.data as List<dynamic>;
    }
    if (widget.subData != null) {
      subCategoryList = widget.subData as List<dynamic>;
    }
    requestLocationPermission();
    showLoader(context);
    getPromotionList(searchType[kSearchType] as String, '', true);
    callMark(false);
  }

  callMark(bool isCall) {
    getCurrentLocation(isCall);
  }

  getCurrentLocation(bool isCall) async {
    // Check permission status
    await Permission.locationWhenInUse.request();

    final bool agb = await Geolocator.isLocationServiceEnabled();
    if (agb) {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      if (isCall) {
        getPromotionList('Location Search', '', false);
      }
    } else {
      if (!mounted) return;
      if (isCall) {
        hideLoader(context);
      }
      Timer(const Duration(seconds: 3), () {
        showToast(context, "Please enable your location to view offer's");
      });
    }
  }

  void requestLocationPermission() async {
    if (await Permission.location.isRestricted) {
      await [
        Permission.location,
      ].request();
    } else if (await Permission.speech.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void getPromotionList(String type, String stateId, bool isFirstTime) async {
    final searchType = widget.searchType as Map<String, dynamic>;
    Map<String, dynamic>? param;

    if (searchType[kSearchType] == 'NA' && isFirstTime) {
      param = {
        //"user_id": user[kId].toString(),
        'category_id': widget.id,
      };
    } /*else if (_radioType== "Location Search") {
      param = {
        "user_id": user[kId].toString(),
        "category_id": widget.id,
        "latitude": widget.searchType["lat"] ?? position.latitude.toString(),
        "longitude": widget.searchType["long"]??position.longitude.toString(),
      };
    } else {
      param = {
        "user_id": user[kId].toString(),
        "category_id": _categoryId,
        "pincode": _zipCodeController.text.trim().toString(),
        "state_id": _stateId,
        "address": _addressController.text.trim().toString(),
        "city": _cityController.text.trim().toString(),
      };
    }*/
    else if (_radioType == 'Location Search') {
      param = {
        //"user_id": user[kId].toString(),
        'category_id': _categoryId.isNotEmpty ? _categoryId : widget.id,
        'latitude': (searchType['lat'] as String?) ?? position.latitude.toString(),
        'longitude': (searchType['long'] as String?) ?? position.longitude.toString(),
        //"latitude": "36.8431034",
        //"longitude": "-76.0722054",
      };
      //showToast(context, "Search by category "+_categoryId);
    } else if (_radioType == 'Manual Search') {
      if (_stateId.isNotEmpty &&
          _cityController.text.isNotEmpty &&
          _zipCodeController.text.isEmpty) {
        param = {
          //"user_id": user[kId].toString(),
          'category_id': _categoryId.isNotEmpty ? _categoryId : widget.id,
          'state_id': _stateId,
          'city': _cityController.text.trim(),
        };
        //showToast(context, 'Search by State & City');
      } else if (_zipCodeController.text.isNotEmpty) {
        param = {
          //"user_id": user[kId].toString(),
          'category_id': _categoryId.isNotEmpty ? _categoryId : widget.id,
          'pincode': _zipCodeController.text.trim(),
        };
        // showToast(context, 'Search by Zip code');
      }
      /*else if(_zipCodeController.text.isNotEmpty || widget.searchType['zip_code'].isNotEmpty){
        param = {
          "user_id": user[kId].toString(),
          "category_id": _categoryId.isNotEmpty?_categoryId:widget.id,
          "pincode": _zipCodeController.text.isNotEmpty?_zipCodeController.text.trim():widget.searchType['zip_code'],
        };
        // showToast(context, 'Search by Zip code');
      }*/

      /*else{
        //showToast(context, 'Search by category '+_categoryId);
        param = {
          "user_id": user[kId].toString(),
          "category_id": _categoryId.isNotEmpty?_categoryId:widget.id,
        };
      }*/
    }
    const url = '$baseUrl/promotions-list';
    final result = await callApi('POST', param, url);
    if (!mounted) return;
    if (result[kDataCode] == 200) {
      final List<dynamic> rest = result['data'] as List<dynamic>;
      _offerList = rest
          .map<PromotionListData>(
            (json) => PromotionListData.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      noPromotionsAvailable = 'No Business available around you.';
      setState(() {});
      if (isFirstTime) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isGuest) {
          setState(() {});
          getStateListData();
        } else {
          checkSubscription();
        }
      } else {
        setState(() {});
        hideLoader(context);
      }
    } else {
      hideLoader(context);
      showToast(context, result[kDataMessage] as String);
    }
  }

  void getSubCategoryData(String id) async {
    String url = '$baseUrl/categories-list/$id';
    final result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      subCategoryList = result['data'] as List<dynamic>;
      if (subCategoryList.isNotEmpty) {
        subCategoryData = subCategoryList[0];
      }
      setState(() {});
    } else {
      showToast(context, result[kDataMessage] as String);
    }
  }

  void checkSubscription() async {
    final dynamic rawUser = await getSharedPreference(kDataLoginUser);
    final user = rawUser as Map<String, dynamic>;
    final param = {
      'user_id': user[kId].toString(),
    };
    const url = '$baseUrl/check-subscriptions';
    final result = await callApi('POST', param, url);
    if (!mounted) return;

    if (result[kDataCode] == 200) {
      final appData = result[kData] as Map<String, dynamic>;
      final trialData = appData[kTrial] as Map<String, dynamic>;
      final subData = appData[kSubscription] as Map<String, dynamic>;
      trialActive = trialData[kActive] as int;
      trialExpired = trialData[kExpired] as int;
      if (trialActive == 1) {
        isTrialClicked = false;

        if (trialExpired == 0) {
          trialText =
              '${trialData[kPackageName]} expired on ${trialData[kExpiredDate]}';
        } else {
          isTrialClicked = true;
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

      subActive = subData[kActive] as int;

      if (subActive == 1) {
        isTrialClicked = false;
        trialText = 'Trial Expired';
        subExpired = subData[kExpired] as int;
        pinVerified = subData[kPinVerified].toString();
        orderId = subData[kOrderId].toString();
        if (subExpired == 0) {
          subText =
              '${subData[kPackageName]} expired on ${subData[kExpiredDate]}';
        } else {
          subText = '1 Year Subscription';
        }
      } else {
        subText = '1 Year Subscription';
      }
      getStateListData();
    } else {
      hideLoader(context);
      showToast(context, result[kDataMessage] as String);
    }
  }

  void getStateListData() async {
    String url = '';
    if (!isGuest) {
      final dynamic rawUser = await getSharedPreference(kDataLoginUser);
      final user = rawUser as Map<String, dynamic>;
      final country = user['country'] as Map<String, dynamic>;
      url = '$baseUrl/states-list/${country['id']}';
    } else {
      const int countryId = 231;
      url = '$baseUrl/states-list/$countryId';
    }

    final result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      stateList = result['data'] as List<dynamic>;
      if (stateList.isNotEmpty) {
        if (_stateId.isNotEmpty) {
          final int index = stateList.indexWhere(
            (data) => (data as Map<String, dynamic>)['id'].toString() == _stateId,
          );
          stateData = stateList[index] as Map<String, dynamic>;
        } else {
          stateData = stateList[1] as Map<String, dynamic>;
          _stateId = (stateData['id']).toString();
        }
        setState(() {});
      }
      setState(() {});
    } else {
      showToast(context, result[kDataMessage] as String);
    }
  }

  /*void getStateListData() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    final url = "$baseUrl/states-list/${user["country"]["id"]}";
    var result = await callApi("GET", null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      stateList = result["data"] as List;
      if (stateList.isNotEmpty) {
        stateData = stateList[1];
        _stateId = stateData["id"];
      }
      setState(() {});
    } else {
      showToast(context, result[kDataMessage]);
    }
  }*/

  void callPurchaseView() async {
    await getSharedPreference(kDataLoginUser);
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AppDrawer(isNotification: false),
      ),
    );
  }

  Future navigationLoginScreen() async {
    await Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: LoginPinPage(
          orderId: orderId,
        ),
      ),
    );
  }

  Future navigationPromotionPage(id, index) async {
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: CommonPromotionByIdList(
          id: id.toString(),
          url: 'promotions-list-by-id',
          distance: _offerList[index].distance == null
              ? ''
              : _offerList[index].distance.toString(),
        ),
      ),
    );
  }

  Future<void> navigationPromotionDetail(int index) async {
    final st = widget.searchType as Map<String, dynamic>;
    String type = '';
    if (st[kSearchType] == 'NA') {
      type = '1';
    } else if (_radioType == 'Location Search') {
      type = '0';
    } else {
      type = '1';
    }
    final offer = _offerList[index];
    final bd = offer.businessDetail as Map<String, dynamic>;
    final country = bd['country'] as Map<String, dynamic>;
    final state = bd['state'] as Map<String, dynamic>;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailPage(
          requestType: type,
          businessId: offer.businessId?.toString() ?? '',
          promotionId: offer.promotionId?.toString() ?? '',
          name: bd['name'] as String? ?? '',
          title: offer.title,
          address:
              '${country['name'] ?? ''}, ${state['name'] ?? ''}, ${bd['city'] ?? ''}, ${bd['address'] ?? ''}, ${bd['pincode'] ?? ''}',
          description: offer.description,
          distance: offer.distance?.toString() ?? '',
          email: bd['email'] as String? ?? '',
          mobile: bd['mobile'] as String? ?? '',
          webUrl: bd['website_url'] as String? ?? '',
          lat: bd['latitude'] as String? ?? '',
          lng: bd['longitude'] as String? ?? '',
        ),
      ),
    );
    if (!mounted) return;
    if (result == true) {
      showLoader(context);
      if (_radioType.isEmpty) {
        getPromotionList('NA', '', false);
      } else if (_radioType == 'Manual Search') {
        getPromotionList('Manual Search', '', false);
      } else {
        getPromotionList('Location Search', '', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: _radioType == 'Manual Search',
      endDrawer: SizedBox(
        width: 210,
        child: Drawer(
          elevation: 10,
          child: Container(
            color: buttonParrotColor,
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: Column(
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Text(
                                  'Filter Discounts',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(0.0, 4.0),
                                        blurRadius: 4.0,
                                        color: Colors.white54,
                                      ),
                                    ],
                                  ),
                                ),
                                /*   Container(
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  alignment: Alignment.centerLeft,
                                  width: 220,
                                  height: 45,
                                  padding:
                                      const EdgeInsets.only(top: 0, left: 10, right: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: greyBorder, width: 0.0),
                                      color: greyFilled,
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(25))),
                                  child: DropdownButtonFormField<dynamic>(
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    decoration:
                                        const InputDecoration.collapsed(hintText: ''),
                                    value: stateData != null
                                        ? stateData["name"]
                                        : null,
                                    hint: const Text("Select State"),
                                    isExpanded: true,
                                    items: stateList
                                        .toSet()
                                        .toList()
                                        .map((label) => DropdownMenuItem(
                                              child: Text(
                                                label["name"],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400),
                                                maxLines: 1,
                                                overflow: TextOverflow.clip,
                                              ),
                                              value: label["name"],
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      int index = stateList
                                          .indexWhere((data) => data["name"] == value);
                                      stateData=stateList[index];
                                      _stateId = stateList[index]["id"].toString();
                                      setState(() {});
                                    },
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
                                            color: greyBorder, width: 0.0),
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0),
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
                                    controller: _addressController,
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.streetAddress,
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 10),
                                      hintText: 'Address',
                                      hintStyle: const TextStyle(color: Colors.black),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0),
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
                                    controller: _zipCodeController,
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
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
                                            color: greyBorder, width: 0.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                            color: greyBorder, width: 0.0),
                                      ),
                                      border: const OutlineInputBorder(),
                                      fillColor: greyFilled,
                                      filled: true,
                                    ),
                                  ),
                                ),*/
                                _radioType == 'Manual Search'
                                    ? Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            height: 45,
                                            padding: const EdgeInsets.only(
                                              top: 0,
                                              left: 10,
                                              right: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: greyBorder,
                                                width: 0.0,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(25),
                                              ),
                                            ),
                                            child: DropdownButtonFormField<
                                                dynamic>(
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                              ),
                                              decoration: const InputDecoration
                                                  .collapsed(hintText: ''),
                                              initialValue: stateData['name'],
                                              hint: const Text('Select State'),
                                              isExpanded: true,
                                              items: stateList
                                                  .toSet()
                                                  .toList()
                                                  .map(
                                                    (label) {
                                                      final item = label as Map<String, dynamic>;
                                                      return DropdownMenuItem<String>(
                                                        value: item['name'] as String?,
                                                        child: Text(
                                                          item['name'] as String? ?? '',
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow.clip,
                                                        ),
                                                      );
                                                    },
                                                  )
                                                  .toList(),
                                              onChanged: (value) {
                                                final int index =
                                                    stateList.indexWhere(
                                                  (data) =>
                                                      (data as Map<String, dynamic>)['name'] == value,
                                                );
                                                stateData = stateList[index] as Map<String, dynamic>;
                                                _stateId = (stateList[index] as Map<String, dynamic>)['id']
                                                    .toString();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          /*Container(
                                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                                      alignment: Alignment.centerLeft,
                                      width: 220,
                                      height: 45,
                                      padding:
                                      const EdgeInsets.only(top: 0, left: 10, right: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(color: greyBorder, width: 0.0),
                                          color: greyFilled,
                                          borderRadius:
                                          const BorderRadius.all(Radius.circular(25))),
                                      child: DropdownButtonFormField<dynamic>(
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        decoration:
                                        const InputDecoration.collapsed(hintText: ''),
                                        value: categoryData != null ? categoryData["category_name"] : null,
                                        hint: const Text("Select State"),
                                        isExpanded: true,
                                        items: categoryList
                                            .toSet()
                                            .toList()
                                            .map((label) => DropdownMenuItem(
                                          child: Text(
                                            label["category_name"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          value: label["category_name"],
                                        ))
                                            .toList(),
                                        onChanged: (value) {
                                          int index = categoryList.indexWhere(
                                                  (data) => data["category_name"] == value);
                                          categoryData=categoryList[index];
                                          _categoryId = categoryList[index]["id"];
                                          showLoader(context);
                                          getSubCategoryData(_categoryId);
                                        },
                                      ),
                                    ),*/
                                          Container(
                                            color: Colors.transparent,
                                            margin: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                            ),
                                            alignment: Alignment.center,
                                            width: 220,
                                            height: 45,
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: TextFormField(
                                              controller: _cityController,
                                              textAlign: TextAlign.left,
                                              keyboardType:
                                                  TextInputType.streetAddress,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                              onFieldSubmitted: (input) {
                                                if (_stateId.isNotEmpty &&
                                                    _cityController
                                                        .text.isNotEmpty) {
                                                  showLoader(context);
                                                  updateCategories(
                                                    type: 'city',
                                                  );
                                                } else {
                                                  showToast(
                                                    context,
                                                    'Please select state and city both',
                                                  );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                hintText: 'City',
                                                hintStyle: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25.0,
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: greyBorder,
                                                    width: 0.0,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25.0,
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: greyBorder,
                                                    width: 0.0,
                                                  ),
                                                ),
                                                border:
                                                    const OutlineInputBorder(),
                                                fillColor: Colors.white,
                                                filled: true,
                                              ),
                                            ),
                                          ),
                                          const Text('OR'),
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 15,
                                              bottom: 15,
                                            ),
                                            alignment: Alignment.center,
                                            width: 220,
                                            height: 45,
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: TextFormField(
                                              controller: _zipCodeController,
                                              textAlign: TextAlign.left,
                                              keyboardType:
                                                  TextInputType.streetAddress,
                                              //keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                              onFieldSubmitted: (input) {
                                                if (_zipCodeController
                                                    .text.isNotEmpty) {
                                                  showLoader(context);
                                                  updateCategories(type: 'zip');
                                                } else {
                                                  showToast(
                                                    context,
                                                    'Please select state and city both',
                                                  );
                                                }
                                              },
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                hintText: 'Zipcode',
                                                hintStyle: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25.0,
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: greyBorder,
                                                    width: 0.0,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    25.0,
                                                  ),
                                                  borderSide: const BorderSide(
                                                    color: greyBorder,
                                                    width: 0.0,
                                                  ),
                                                ),
                                                border:
                                                    const OutlineInputBorder(),
                                                fillColor: Colors.white,
                                                filled: true,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              height: .3,
                                              alignment: Alignment.topLeft,
                                              color: Colors.white,
                                              margin: const EdgeInsets.only(
                                                left: 0.0,
                                                top: 10,
                                                right: 0.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 15,
                                    bottom: 15,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  width: 220,
                                  height: 45,
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    left: 10,
                                    right: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: greyBorder,
                                      width: 0.0,
                                    ),
                                    color: greyFilled,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  child: DropdownButtonFormField<dynamic>(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                    initialValue: categoryData['category_name'],
                                    hint: const Text('Select category'),
                                    isExpanded: true,
                                    items: categoryList
                                        .toSet()
                                        .toList()
                                        .map(
                                          (label) {
                                            final item = label as Map<String, dynamic>;
                                            return DropdownMenuItem<String>(
                                              value: item['category_name'] as String?,
                                              child: Text(
                                                item['category_name'] as String? ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      final int index = categoryList.indexWhere(
                                        (data) =>
                                            (data as Map<String, dynamic>)['category_name'] == value,
                                      );
                                      categoryData = categoryList[index] as Map<String, dynamic>;
                                      _categoryId =
                                          (categoryList[index] as Map<String, dynamic>)['id'].toString();
                                      addSubcategories(index);
                                    },
                                  ),
                                ),
                                /* Container(
                                  margin: const EdgeInsets.only(top: 15, bottom: 15),
                                  alignment: Alignment.centerLeft,
                                  width: 220,
                                  height: 45,
                                  padding:
                                      const EdgeInsets.only(top: 0, left: 10, right: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: greyBorder, width: 0.0),
                                      color: greyFilled,
                                      borderRadius:
                                          const BorderRadius.all(Radius.circular(25))),
                                  child: DropdownButtonFormField<dynamic>(
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 14),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    decoration:
                                        const InputDecoration.collapsed(hintText: ''),
                                    value: subCategoryData != null
                                        ? subCategoryData["category_name"]
                                        : null,
                                    hint: const Text("Select Sub-Category"),
                                    isExpanded: true,
                                    items: subCategoryList
                                        .toSet()
                                        .toList()
                                        .map((label) => DropdownMenuItem(
                                              child: Text(
                                                label["category_name"],
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              value: label["category_name"],
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      int index = subCategoryList.indexWhere(
                                          (data) => data["category_name"] == value);
                                      subCategoryData= subCategoryList[index];
                                      _categoryId = subCategoryList[index]["id"].toString();
                                      setState(() {});
                                    },
                                  ),
                                ),*/
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 15,
                                    bottom: 15,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  width: 220,
                                  height: 45,
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    left: 10,
                                    right: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: greyBorder,
                                      width: 0.0,
                                    ),
                                    color: greyFilled,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  child: DropdownButtonFormField<dynamic>(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    decoration: const InputDecoration.collapsed(
                                      hintText: '',
                                    ),
                                    initialValue:
                                        subCategoryData['category_name'],
                                    hint: const Text('Select Sub-Category'),
                                    isExpanded: true,
                                    items: subCategoryList
                                        .toSet()
                                        .toList()
                                        .map(
                                          (label) {
                                            final item = label as Map<String, dynamic>;
                                            return DropdownMenuItem<String>(
                                              value: item['category_name'] as String?,
                                              child: Text(
                                                item['category_name'] as String? ?? 'NA',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      final int index = subCategoryList.indexWhere(
                                        (data) =>
                                            (data as Map<String, dynamic>)['category_name'] == value,
                                      );
                                      subCategoryData = subCategoryList[index] as Map<String, dynamic>;
                                      _categoryId = (subCategoryList[index] as Map<String, dynamic>)['id']
                                          .toString();
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                    bottom: 25,
                                    top: 20,
                                  ),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (categoryData.isEmpty ||
                                            subCategoryData.isEmpty) {
                                          if (_stateId.isEmpty ||
                                              _cityController.text.isEmpty) {
                                            showToast(
                                              context,
                                              'Please select state and enter city or zip code',
                                            );
                                          } else {
                                            showToast(
                                              context,
                                              'Please select category and sub category',
                                            );
                                          }
                                        } else {
                                          if (isValid()) {
                                            if (_scaffoldKey.currentState!
                                                .isEndDrawerOpen) {
                                              Navigator.pop(context);
                                            }
                                            showLoader(context);
                                            getPromotionList(
                                              'Manual Search',
                                              _stateId,
                                              false,
                                            );
                                          } else {
                                            showToast(
                                              context,
                                              'Please enter complete details',
                                            );
                                          }
                                        }

                                        /*if(_radioType == "Location Search"){
                                          if(_categoryId.isNotEmpty){
                                            //showLoader(context);
                                            //getPromotionList("Location Search",_categoryId,false);
                                            showToast(context, "Search by category "+_categoryId);
                                          }else{
                                            showToast(context, "Please select Category");
                                          }
                                        }
                                        else if(_radioType == "Manual Search"){
                                          if(_stateId.isNotEmpty && _cityController.text.isNotEmpty){
                                            showToast(context, 'Search by State & City');
                                          }
                                          else if(_zipCodeController.text.isNotEmpty){
                                            showToast(context, 'Search by Zip code');
                                          }
                                          else if(_categoryId.isNotEmpty){
                                            showToast(context, 'Search by category '+_categoryId);
                                          }
                                          else{
                                            showToast(context, 'Please enter parameters');
                                          }
                                        }*/
                                      },
                                      child: Container(
                                        height: 45,
                                        width: 150,
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Apply',
                                          style: TextStyle(
                                            color: buttonParrotColor,
                                            fontSize: 15,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
              ],
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/discount_bg.png',
                  fit: BoxFit.fill,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 15,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 35, left: 10),
                            child: IconButton(
                              iconSize: 35,
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 70,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 35,
                            ),
                            child: Text(
                              'Business',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 15,
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 35, right: 10),
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Visibility(
                                  //visible: _radioType == "Manual Search",
                                  child: InkWell(
                                    onTap: () {
                                      if (_scaffoldKey
                                          .currentState!.isEndDrawerOpen) {
                                        Navigator.pop(context);
                                      } else {
                                        _scaffoldKey.currentState!
                                            .openEndDrawer();
                                        // if(){
                                        //   int index = stateList
                                        //       .indexWhere((data) => data["id"] == stateData['id']);
                                        // }
                                        setState(() {});
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/filter_icon.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        height: .1,
                        alignment: Alignment.topLeft,
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                          left: 0.0,
                          top: 10,
                          right: 0.0,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(top: 10, left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _radioType = 'Location Search';
                              stateData = {};
                              categoryData = {};
                              subCategoryData = {};
                              _cityController.clear();
                              _addressController.clear();
                              _zipCodeController.clear();
                              setState(() {});
                              //if(position.latitude.toString().isEmpty){
                              showLoader(context);
                              callMark(true);
                              /*}else{
                              showLoader(context);
                              getPromotionList("Location Search","",false);
                            }*/
                            },
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // ignore: deprecated_member_use
                                  Radio(
                                    activeColor: Colors.white,
                                    value: 'Location Search',
                                    // ignore: deprecated_member_use
                                    groupValue: _radioType,
                                    // ignore: deprecated_member_use
                                    onChanged: (value) async {
                                      _radioType = 'Location Search';
                                      _categoryId = '';
                                      stateData = {};
                                      categoryData = {};
                                      subCategoryData = {};
                                      _cityController.clear();
                                      _addressController.clear();
                                      _zipCodeController.clear();
                                      setState(() {});
                                      /*if(position.latitude.toString().isEmpty){
                                      showLoader(context);
                                      callMark(true);
                                    }else{*/

                                      showLoader(context);
                                      callMark(true);
                                      //getPromotionList("Location Search","",false);
                                      //}
                                    },
                                  ),
                                  Text(
                                    'GPS Search',
                                    style: TextStyle(
                                      color: _radioType == 'Manual Search'
                                          ? Colors.white70
                                          : Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _radioType = 'Manual Search';
                              if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                                Navigator.pop(context);
                              } else {
                                _scaffoldKey.currentState!.openEndDrawer();
                                setState(() {});
                              }
                            },
                            child: Theme(
                              data: ThemeData(
                                unselectedWidgetColor: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ignore: deprecated_member_use
                                  Radio(
                                    activeColor: Colors.white,
                                    value: 'Manual Search',
                                    // ignore: deprecated_member_use
                                    groupValue: _radioType,
                                    // ignore: deprecated_member_use
                                    onChanged: (value) {
                                      _radioType = value.toString();
                                      _categoryId = '';
                                      if (_scaffoldKey
                                          .currentState!.isEndDrawerOpen) {
                                        Navigator.pop(context);
                                      } else {
                                        _scaffoldKey.currentState!
                                            .openEndDrawer();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Text(
                                      'Manual Search',
                                      style: TextStyle(
                                        color: _radioType == 'Manual Search'
                                            ? Colors.white
                                            : Colors.white70,
                                        fontSize: 14,
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
                    _offerList.isNotEmpty
                        ? Expanded(
                            child: Center(
                              child: GridView.count(
                                crossAxisCount: 3,
                                children:
                                    List.generate(_offerList.length, (index) {
                                  return Center(
                                    child: InkWell(
                                      onTap: () {
                                        if (isGuest) {
                                          navigateLogin();
                                        } else {
                                          if (trialActive == 1 &&
                                              trialExpired == 0) {
                                            //navigationPromotionDetail(index);
                                            navigationPromotionPage(
                                              _offerList[index].businessId,
                                              index,
                                            );
                                          } else if (subActive == 1 &&
                                              subExpired == 0) {
                                            if (pinVerified == '0') {
                                              navigationLoginScreen();
                                            } else {
                                              navigationPromotionPage(
                                                _offerList[index].businessId,
                                                index,
                                              );
                                              //navigationPromotionDetail(index);
                                            }
                                          } else {
                                            callPurchaseView();
                                          }
                                        }
                                      },
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Center(
                                              child: Image.asset(
                                                'assets/polygon.png',
                                                fit: BoxFit.fill,
                                                width: 100,
                                                height: 100,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(9.0),
                                                child: Text(
                                                  (_offerList[index].businessDetail as Map<String, dynamic>)['name'] as String? ?? '',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Center(
                              child: Text(
                                noPromotionsAvailable,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(0.0, 4.0),
                                      blurRadius: 4.0,
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isValid() {
    bool parameterValid = false;
    if (_radioType == 'Location Search' && _categoryId.isNotEmpty) {
      parameterValid = true;
    } else if (_radioType == 'Manual Search') {
      if (_stateId.isNotEmpty &&
          _cityController.text.isNotEmpty &&
          _categoryId.isNotEmpty) {
        parameterValid = true;
      } else if (_zipCodeController.text.isNotEmpty && _categoryId.isNotEmpty) {
        parameterValid = true;
      }
    }
    return parameterValid;
  }

  void addSubcategories(int index) {
    if (subCategoryData.isNotEmpty) {
      setState(() {
        subCategoryData = {};
      });
    }
    if (subCategoryList.isNotEmpty) {
      setState(() {
        subCategoryList.clear();
      });
    }
    final subCat = categoryList[index] as Map<String, dynamic>;
    final data = subCat['children'] as List<dynamic>;
    subCategoryList.addAll(data);
    setState(() {});
  }

  Future<void> updateCategories({required String type}) async {
    Map<String, dynamic>? param;
    if (type == 'city') {
      param = {
        kState: _stateId,
        kCity: _cityController.text.trim(),
      };
    } else if (type == 'zip') {
      param = {
        'pincode': _zipCodeController.text.trim(),
      };
    }
    const url = '$baseUrl/categories-list';
    final result = await callApi('POST', param, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      final List<dynamic> rest = result['data'] as List<dynamic>;
      setState(() {
        categoryList
          ..clear()
          ..addAll(rest);
      });
    } else {
      showToast(context, result[kDataMessage] as String);
    }
  }

  void navigateLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

/*Future<void> getCategories() async {
    var param;
    //print('Lat & Lng - '+param.toString());
    const url = "$baseUrl/categories-list";
    var result= await callApi("POST", param , url);
    //hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
        var rest = result["data"] as List;
        //categoryList = rest.map<CategoryListData>((json) => CategoryListData.fromJson(json)).toList();
        categoryList = rest;

      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }*/
}
