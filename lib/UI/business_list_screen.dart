import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/promotion_list_data.dart';

class BusinessListScreen extends StatefulWidget {

  const BusinessListScreen(
      {super.key,});

  @override
  State<BusinessListScreen> createState() =>
      _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  List<PromotionListData> _offerList = [];
  var rest;

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getBusinessListData();
    //getSubCategoryData();
    //getSubCategoryList();
  }


  Future<void> getBusinessListData() async {
    await getSharedPreference(kDataLoginUser);
    const url = '$baseUrl/promotions-list';
   var param = {
     // "user_id": user[kId].toString(),
      'user_id': '5',
      'category_id': '4',
    };
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      var rest = result['data'] as List;
      _offerList = rest
          .map<PromotionListData>((json) => PromotionListData.fromJson(json))
          .toList();
    } else {
      hideLoader(context);
      showToast(context, result[kDataMessage]);
    }
    setState(() {

    });
  }

/*
  Future navigationPromotionEmpty(String id) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PromotionListScreen(id: id,searchType: widget.searchType,data: widget.data,subData: rest,)),
    );
  }
*/

/*  Future navigationPromotionPage(String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PromotionListScreen(id: id,searchType: widget.searchType,data: widget.data,subData: rest,)),
    );
  }*/

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
                          const Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(top: 35, right: 50),
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
                      Expanded(
                          child: Center(
                              child: GridView.count(
                                crossAxisCount: 3,
                                children: List.generate(_offerList.length, (index) {
                                  return Center(
                                    child: InkWell(
                                      onTap: (){
                                        //navigationPromotionPage(_categoryList[index].id.toString());
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
                                                  _offerList[index].business_detail['name'],
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
                              ),),),
                    ],
                  ),
                ],
              ),),
        ],
      ),
    );
  }

}
