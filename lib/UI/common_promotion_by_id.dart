import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/UI/login_purchase_subscription.dart';
import 'package:hit_me_up/UI/offer_detail_page.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/promotion_list_data.dart';
import 'package:page_transition/page_transition.dart';

class CommonPromotionByIdList extends StatefulWidget {
  final String id,url,distance;

  const CommonPromotionByIdList(
      {super.key,
        required this.id,
        required this.url,
        required this.distance,});

  @override
  State<CommonPromotionByIdList> createState() =>
      _CommonPromotionByIdListState();
}

class _CommonPromotionByIdListState extends State<CommonPromotionByIdList> {
  List<PromotionListData> _offerList = [];
  int bannerCount=0;
  int trialActive = 0;
  int trialExpired = 0;
  String subText = '1 Year Subscription';
  String trialText = '3 Days Trial';
  int subActive = 0;
  int subExpired = 0;
  String pinVerified = '0';
  String orderId = '';
  bool isTrialClicked = false;

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getPromotionList();
  }

  Future navigationHomePage(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (
          context,) => OfferDetailPage(requestType: widget.url.contains('notification')?'2':'1',businessId: _offerList[index].business_id.toString(),promotionId: _offerList[index].promotion_id.toString(),
          name: _offerList[index].business_detail['name'],title: _offerList[index].title,
          address: "${_offerList[index].business_detail['country']['name']}, ${_offerList[index].business_detail['state']['name']}, ${_offerList[index].business_detail['city']}, ${_offerList[index].business_detail['address']}, ${_offerList[index].business_detail['pincode']}",description: _offerList[index].description,
          distance: widget.distance.isEmpty ? '' : widget.distance.toString() ,email: _offerList[index].business_detail['email'],mobile: _offerList[index].business_detail['mobile'], webUrl : _offerList[index].business_detail['website_url'], lat : _offerList[index].business_detail['latitude'].toString(), lng : _offerList[index].business_detail['longitude'].toString(),),),
    );
    if(result== true){
      showLoader(context);
      getPromotionList();
    }
  }

  void getPromotionList() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    String url = '$baseUrl/${widget.url}/${widget.id}/${user[kId].toString()}';
    var result = await callApi('GET', null, url);
    if (result[kDataCode] == 200) {
      var rest = result['data'] as List;
      _offerList = rest
          .map<PromotionListData>((json) => PromotionListData.fromJson(json))
          .toList();
      checkSubscription();
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  void checkSubscription() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      'user_id': user[kId].toString(),
    };
    const url = '$baseUrl/check-subscriptions';
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      trialActive = result[kData][kTrial][kActive];
      if (trialActive == 1) {
        isTrialClicked = false;
        trialExpired = result[kData][kTrial][kExpired];
        if (trialExpired == 0) {
          trialText =
          '${result[kData][kTrial][kPackageName]} expired on ${result[kData][kTrial][kExpiredDate]}';
        } else {
          isTrialClicked = true;
          trialText = 'Trial Expired';
        }
      } else {
        if(trialExpired==0){
          isTrialClicked = true;
        }else{
          isTrialClicked = false;
          trialText = 'Trial Expired';
        }
      }

      subActive = result[kData][kSubscription][kActive];

      if (subActive == 1) {
        isTrialClicked = false;
        trialText = 'Trial Expired';
        subExpired = result[kData][kSubscription][kExpired];
        pinVerified = result[kData][kSubscription][kPinVerified].toString();
        orderId = result[kData][kSubscription][kOrderId].toString();
        if (subExpired == 0) {
          subText =
          '${result[kData][kSubscription][kPackageName]} expired on ${result[kData][kSubscription][kExpiredDate]}';
        } else {
          subText = '1 Year Subscription';
        }
      } else {
        subText = '1 Year Subscription';
      }
      setState(() {});
    } else {
      hideLoader(context);
      showToast(context, result[kDataMessage]);
    }
  }

  void callPurchaseView() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPurchaseSubscription(
              userId: user[kId].toString(),
              subText: subText,
              isTrialClicked: isTrialClicked,
              trialText: trialText,
            ),),);
  }


  Future navigationLoginScreen() async {
    await Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: LoginPinPage(
              orderId: orderId,
            ),),);
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
                          const Expanded(
                              child: Padding(
                                  padding: EdgeInsets.only(top: 35, right: 50),
                                  child: Text(
                                    'Promotions',
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
                          height: .1,
                          alignment: Alignment.topLeft,
                          color: Colors.white,
                          margin:
                          const EdgeInsets.only(left: 0.0, top: 10, right: 0.0),
                        ),
                      ),
                      Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(_offerList.length, (index) {
                              return Center(
                                child: InkWell(
                                  onTap: (){
                                    if(trialActive == 1 && trialExpired==0){
                                      navigationHomePage(index);
                                    }else if(subActive == 1 && subExpired==0){
                                      if(pinVerified == '0') {
                                        navigationLoginScreen();
                                      }else{
                                        navigationHomePage(index);
                                      }
                                    }else{
                                      callPurchaseView();
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
                                          child: Text(
                                            _offerList[index].title,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontSize: 13, color: Colors.white,),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),),
                    ],
                  ),
                ],
              ),),
        ],
      ),
    );
  }
}
