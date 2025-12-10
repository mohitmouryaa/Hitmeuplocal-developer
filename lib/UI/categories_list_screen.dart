import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/sub_category_list_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/category_list_data.dart';

class CategoriesListScreen extends StatefulWidget {
  final Function drawerCall,openViewCall;
  final dynamic data;

  const CategoriesListScreen({Key? key,required this.drawerCall,required this.openViewCall,required this.data}) : super(key: key);

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  List<CategoryListData> _categoryList = [];
  var rest;
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
    String searchType = widget.data['search_type']; //GPS type - "GPS" and Search by State and city - "Manual"
    var param;

    if(searchType == "Manual"){
      int  manualType = widget.data['type'];
      if(manualType == 1){
        String state = widget.data['state'];
        String city = widget.data['city'];

        param = {
          'state' : state,
          'city' : city,
        };
      }
      else{
        String zipCode = widget.data['zip_code'];
        param = {
          //'zipCode' : zipCode,
          'pincode' : zipCode,
        };
      }
    }
    else if(searchType == "GPS"){
      String lat = widget.data['lat'];
      String lng = widget.data['long'];
      param = {
        'latitude' : lat,
        'longitude' : lng,
      };
    }
    else{

    }

    print('Parameters - '+param.toString());
    const url = "$baseUrl/categories-list";
    var result= await callApi("POST", param , url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
         rest = result["data"] as List;
        _categoryList = rest.map<CategoryListData>((json) => CategoryListData.fromJson(json)).toList();
         noPromotionsAvailable = 'No Promotions available around you.';
      });

    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  Future navigationSubCategoryPage(String id,String title) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubCategoriesListScreen(id: id,title: title,searchType: widget.data,data: rest,)),
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
          Expanded(child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/category_bg.png',fit: BoxFit.fill,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 35,left: 10),
                        child: InkWell(
                          onTap: (){
                            widget.drawerCall();
                          },
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),),
                      const Expanded(child: Center(
                        child: Padding(
                            padding: EdgeInsets.only(top: 35,right: 45),
                            child: Text(
                              'Categories',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold,shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 4.0),
                                  blurRadius: 4.0,
                                  color: Colors.black45,
                                ),
                              ]),
                            )),
                      )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      height: .2,
                      alignment: Alignment.topLeft,
                      color: Colors.white,
                      margin: const EdgeInsets.only(left: 0.0, top: 10, right: 0.0),
                    ),
                  ),
                  _categoryList.isNotEmpty?Expanded(child: Center(
                    child:  GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(_categoryList.length, (index) {
                          return InkWell(
                            onTap: (){
                              navigationSubCategoryPage(_categoryList[index].id.toString(),_categoryList[index].category_name);
                            },
                            child: Center(
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(
                                      child: Image.asset('assets/polygon.png',fit: BoxFit.fill,width: 100,height: 100,),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(
                                      child: Text(
                                        _categoryList[index].category_name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  ))):Expanded(
                    child: Center(
                      child: Text(
                        noPromotionsAvailable,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold,shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0.0, 4.0),
                            blurRadius: 4.0,
                            color: Colors.black45,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
        ],
      ),
    );
  }
}
