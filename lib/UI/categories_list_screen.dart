import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/sub_category_list_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/category_list_data.dart';

class CategoriesListScreen extends StatefulWidget {
  final void Function() drawerCall;
  final void Function(dynamic) openViewCall;
  final dynamic data;

  const CategoriesListScreen(
      {super.key,
      required this.drawerCall,
      required this.openViewCall,
      required this.data,
      });

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  List<CategoryListData> _categoryList = [];
  List<dynamic> rest = [];
  String noPromotionsAvailable = '';

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getCategoryData();
  }

  @override
  void didUpdateWidget(covariant CategoriesListScreen oldWidget) {
    setState(() {
      _categoryList.clear();
      noPromotionsAvailable = '';
    });
    showLoader(context);
    getCategoryData();
    super.didUpdateWidget(oldWidget);
  }

  /*void getCategoryData() async {
    const url = "$baseUrl/categories-list/";
    var result= await callApi("GET", null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
         rest = result["data"] as List;
        _categoryList = rest.map<CategoryListData>((json) => CategoryListData.fromJson(json)).toList();
      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }*/

  void getCategoryData() async {
    final data = widget.data as Map<String, dynamic>;
    final String searchType = data['search_type'] as String;
    Map<String, dynamic>? param;

    if (searchType == 'Manual') {
      final int manualType = data['type'] as int;
      if (manualType == 1) {
        final String state = data['state'] as String;
        final String city = data['city'] as String;
        param = {
          'state': state,
          'city': city,
        };
      } else {
        final String zipCode = data['zip_code'] as String;
        param = {
          'pincode': zipCode,
        };
      }
    } else if (searchType == 'GPS') {
      final String lat = data['lat'] as String;
      final String lng = data['long'] as String;
      param = {
        'latitude': lat,
        'longitude': lng,
      };
    }

    const url = '$baseUrl/categories-list';
    final result = await callApi('POST', param, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
        rest = result['data'] as List<dynamic>;
        _categoryList = rest
            .map<CategoryListData>(
              (json) => CategoryListData.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        noPromotionsAvailable = 'No Promotions available around you.';
      });
    } else {
      showToast(context, result[kDataMessage] as String);
    }
  }

  Future navigationSubCategoryPage(String id, String title) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SubCategoriesListScreen(
                id: id,
                title: title,
                searchType: widget.data,
                data: rest,
              ),
          ),
    );
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/category_bg.png',
                  fit: BoxFit.fill,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 35, right: 45),
                              child: Text(
                                'Categories',
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
                        ),
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
                    _categoryList.isNotEmpty
                        ? Expanded(
                            child: Center(
                              child: GridView.count(
                                crossAxisCount: 3,
                                children: List.generate(_categoryList.length,
                                    (index) {
                                  return InkWell(
                                    onTap: () {
                                      navigationSubCategoryPage(
                                          '${_categoryList[index].id}',
                                          _categoryList[index].categoryName,);
                                    },
                                    child: Center(
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
                                              child: Text(
                                                _categoryList[index]
                                                    .categoryName,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
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
}
