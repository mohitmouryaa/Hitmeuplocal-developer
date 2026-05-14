import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/UI/login_purchase_subscription.dart';
import 'package:hit_me_up/UI/offer_detail_page.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/promotion_list_data.dart';
import 'package:page_transition/page_transition.dart';

class CommonPromotionByIdList extends StatefulWidget {
  final String id, url, distance;

  const CommonPromotionByIdList({
    super.key,
    required this.id,
    required this.url,
    required this.distance,
  });

  @override
  State<CommonPromotionByIdList> createState() =>
      _CommonPromotionByIdListState();
}

class _CommonPromotionByIdListState extends State<CommonPromotionByIdList> {
  List<PromotionListData> _offerList = [];
  int bannerCount = 0;
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

  Future<void> navigationHomePage(int index) async {
    final offer = _offerList[index];
    final bd = offer.businessDetail as Map<String, dynamic>;
    final country = bd['country'] as Map<String, dynamic>;
    final state = bd['state'] as Map<String, dynamic>;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailPage(
          requestType: widget.url.contains('notification') ? '2' : '1',
          businessId: offer.businessId?.toString() ?? '',
          promotionId: offer.promotionId?.toString() ?? '',
          name: bd['name'] as String? ?? '',
          title: offer.title,
          address:
              '${country['name'] ?? ''}, ${state['name'] ?? ''}, ${bd['city'] ?? ''}, ${bd['address'] ?? ''}, ${bd['pincode'] ?? ''}',
          description: offer.description,
          distance: widget.distance.isEmpty ? '' : widget.distance.toString(),
          email: bd['email'] as String? ?? '',
          mobile: bd['mobile'] as String? ?? '',
          webUrl: bd['website_url'] as String? ?? '',
          lat: (bd['latitude'] ?? '').toString(),
          lng: (bd['longitude'] ?? '').toString(),
        ),
      ),
    );
    if (result == true) {
      if (!mounted) return;
      showLoader(context);
      getPromotionList();
    }
  }

  void getPromotionList() async {
    final dynamic rawUser = await getSharedPreference(kDataLoginUser);
    final user = rawUser as Map<String, dynamic>;
    final String url = '$baseUrl/${widget.url}/${widget.id}/${user[kId]}';
    final result = await callApi('GET', null, url);
    if (!mounted) return;
    if (result[kDataCode] == 200) {
      final rest = result['data'] as List;
      _offerList = rest
          .map<PromotionListData>((json) => PromotionListData.fromJson(json))
          .toList();
      checkSubscription();
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
    hideLoader(context);
    if (result[kDataCode] == 200) {
      final appData = result[kData] as Map<String, dynamic>;
      final trial = appData[kTrial] as Map<String, dynamic>;
      final subscription = appData[kSubscription] as Map<String, dynamic>;
      trialActive = trial[kActive] as int;
      if (trialActive == 1) {
        isTrialClicked = false;
        trialExpired = trial[kExpired] as int;
        if (trialExpired == 0) {
          trialText =
              '${trial[kPackageName]} expired on ${trial[kExpiredDate]}';
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

      subActive = subscription[kActive] as int;

      if (subActive == 1) {
        isTrialClicked = false;
        trialText = 'Trial Expired';
        subExpired = subscription[kExpired] as int;
        pinVerified = subscription[kPinVerified].toString();
        orderId = subscription[kOrderId].toString();
        if (subExpired == 0) {
          subText =
              '${subscription[kPackageName]} expired on ${subscription[kExpiredDate]}';
        } else {
          subText = '1 Year Subscription';
        }
      } else {
        subText = '1 Year Subscription';
      }
      setState(() {});
    } else {
      hideLoader(context);
      showToast(context, result[kDataMessage] as String);
    }
  }

  void callPurchaseView() async {
    final dynamic rawUser = await getSharedPreference(kDataLoginUser);
    final user = rawUser as Map<String, dynamic>;
    if (!mounted) return;
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: LoginPurchaseSubscription(
          userId: user[kId].toString(),
          subText: subText,
          isTrialClicked: isTrialClicked,
          trialText: trialText,
        ),
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
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
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
                                ],
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
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(_offerList.length, (index) {
                          return Center(
                            child: InkWell(
                              onTap: () {
                                if (trialActive == 1 && trialExpired == 0) {
                                  navigationHomePage(index);
                                } else if (subActive == 1 && subExpired == 0) {
                                  if (pinVerified == '0') {
                                    navigationLoginScreen();
                                  } else {
                                    navigationHomePage(index);
                                  }
                                } else {
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
                                          fontSize: 13,
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
