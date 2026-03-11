import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/promotions_list_screen.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/category_list_data.dart';

class SubCategoriesListScreen extends StatefulWidget {
  final String id,title;
  final dynamic data,searchType;

  const SubCategoriesListScreen(
      {super.key,
        required this.id,required this.title,required this.searchType,required this.data,});

  @override
  State<SubCategoriesListScreen> createState() =>
      _SubCategoriesListScreenState();
}

class _SubCategoriesListScreenState extends State<SubCategoriesListScreen> {
  List<CategoryListData> _categoryList = [];
  dynamic rest;
  String noPromotionsAvailable = '';

  @override
  void initState() {
    super.initState();
    //showLoader(context);
    //getSubCategoryData();
    getSubCategoryList();
  }

  void getSubCategoryData() async {
    String url = '$baseUrl/categories-list/${widget.id}';
    var result= await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      final restList = result['data'] as List<dynamic>;
      rest = restList;
      _categoryList = restList
          .map<CategoryListData>((json) => CategoryListData.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {});
      if(_categoryList.isEmpty) {
        if (!mounted) return;
        await navigationPromotionEmpty(widget.id);
      }
    } else {
      showToast(context, result[kDataMessage] as String);
    }
  }

  Future navigationPromotionEmpty(String id) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PromotionListScreen(id: id,searchType: widget.searchType,data: widget.data,subData: rest,)),
    );
  }

  Future navigationPromotionPage(String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PromotionListScreen(id: id,searchType: widget.searchType,data: widget.data,subData: rest,)),
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
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 35, left: 10),
                            child: IconButton(
                              iconSize: 35,
                              icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(top: 35, right: 50),
                                  child: Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
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
                          margin:
                          const EdgeInsets.only(left: 0.0, top: 10, right: 0.0),
                        ),
                      ),
                      _categoryList.isNotEmpty?Expanded(
                          child: Center(
                              child: GridView.count(
                                crossAxisCount: 3,
                                children: List.generate(_categoryList.length, (index) {
                                  return Center(
                                    child: InkWell(
                                      onTap: (){
                                        navigationPromotionPage(_categoryList[index].id.toString());
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
                                              child: Text(
                                                _categoryList[index].categoryName,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                    fontSize: 12, color: Colors.white,),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),),):Expanded(
                        child: Center(
                          child: Text(
                            noPromotionsAvailable,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold,shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0.0, 4.0),
                                blurRadius: 4.0,
                                color: Colors.black45,
                              ),
                            ],),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),),
        ],
      ),
    );
  }

  void getSubCategoryList() {
    final listData = widget.data as List<dynamic>;
    // int index = listData.indexWhere((data) => data['id'] == widget.id);
    //int index = listData.indexWhere((listData) => listData['id'] == widget.id);
    //int index = 0;
    int index = listData.indexWhere((item) => (item as Map<String, dynamic>)['id'] == int.parse(widget.id));
    final data = listData[index] as Map<String, dynamic>;
    final rest = data['children'] as List<dynamic>;
    _categoryList = rest.map<CategoryListData>((json) => CategoryListData.fromJson(json)).toList();
    noPromotionsAvailable = 'No Business available around you.';
    setState(() {

    });

    if(_categoryList.isEmpty){
      showLoader(context);
      getSubCategoryData();
    }
    /*else{
      rest = data;
    }*/
    setState(() {

    });
  }
}
