
import 'package:flutter/material.dart';
import 'package:hit_me_up/UI/common_promotion_by_id.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/notification_list_data.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class NotificationListScreen extends StatefulWidget {
  final Function drawerCall;

  const NotificationListScreen({super.key, required this.drawerCall});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<NotificationListData> _notificationList = [];

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getNotificationListData();
  }

  void getNotificationListData() async {

    dynamic user = await getSharedPreference(kDataLoginUser);
    String url = '$baseUrl/notifications-list/${user[kId].toString()}';
    var result = await callApi('GET', null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      var rest = result['data'] as List;
      _notificationList = rest
          .map<NotificationListData>((json) => NotificationListData.fromJson(json))
          .toList();
      setState(() {});
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  Future navigationPromotionPage(String id) async {
    final result = await Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: CommonPromotionByIdList(id: id,url: 'promotion-list-by-notification',distance: '',),),
    );
    if(result==null){
      showLoader(context);
      getNotificationListData();
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
                      Padding(
                        padding: const EdgeInsets.only(top: 35, left: 10),
                        child: IconButton(
                          iconSize: 35,
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            widget.drawerCall();
                          },
                        ),
                      ),
                      const Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(top: 35, right: 50),
                              child: Text(
                                "Notification's",
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
                          child: ListView.builder(
                    itemCount: _notificationList.length,
                    itemBuilder: (context, index) {
                      DateTime tempDate = DateFormat('yyyy-MM-dd hh:mm:ss').parse(_notificationList[index].created_at);
                      return InkWell(
                        onTap: (){
                          navigationPromotionPage(_notificationList[index].id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: _notificationList[index].read=='1'?Colors.grey.shade400:Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Column(
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                          alignment: Alignment.topLeft,
                                          padding: const EdgeInsets.only(
                                              left: 10,),
                                          child: Text(
                                            _notificationList[index].title,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w600,
                                                color: Colors.black,),
                                            textAlign: TextAlign.start,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                      ),
                                      Container(
                                          alignment: Alignment.topRight,
                                          padding: const EdgeInsets.only(
                                              right: 10,top: 15,),
                                          child: Text(
                                            DateFormat('MMMM dd, yyyy hh:mma').format(tempDate),
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w600,
                                                color: Colors.black,),
                                            textAlign: TextAlign.start,
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
