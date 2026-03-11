import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/promotion_list_data.dart';

class MyOfferListScreen extends StatefulWidget {
  final void Function() drawerCall;

  const MyOfferListScreen({
    super.key,
    required this.drawerCall,
  });

  @override
  State<MyOfferListScreen> createState() => _MyOfferListScreenState();
}

class _MyOfferListScreenState extends State<MyOfferListScreen> {
  List<PromotionListData> _offerList = [];

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getOfferListData();
  }

  void getOfferListData() async {
    final rawUser = await getSharedPreference(kDataLoginUser);
    final user = rawUser as Map<String, dynamic>;
    final url = '$baseUrl/my-offers/${user[kId]}';
    final result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      final rest = result['data'] as List<dynamic>;
      _offerList = rest
          .map<PromotionListData>((json) => PromotionListData.fromJson(json as Map<String, dynamic>))
          .toList();
      setState(() {});
    } else {
      showToast(context, result[kDataMessage] as String);
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
                              "My Offer's",
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
                        height: .2,
                        alignment: Alignment.topLeft,
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                            left: 0.0, top: 10, right: 0.0,),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ListView.builder(
                          itemCount: _offerList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(15),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      gradient: LinearGradient(
                                        colors: [
                                          buttonColor,
                                          buttonParrotColor,
                                        ],
                                        begin: FractionalOffset(0.5, 0.5),
                                        end: FractionalOffset(0.0, 0.0),
                                        stops: [0.0, 1.0],
                                        tileMode: TileMode.clamp,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              top: 20,),
                                                      child: Text(
                                                        _offerList[index].title,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10, top: 5,),
                                                    child: Text(
                                                      _offerList[index]
                                                          .description,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  const Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          top: 10,
                                                          right: 0.0,),
                                                      child: Text(
                                                        'Business Detail',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18,
                                                          color: Colors.white,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 25, top: 5,),
                                                    child: Text(
                                                      (_offerList[index].businessDetail as Map<String, dynamic>)['name'] as String? ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 25, top: 5,),
                                                    child: Text(
                                                      (_offerList[index].businessDetail as Map<String, dynamic>)['mobile'] as String? ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 25, top: 5,),
                                                    child: Text(
                                                      (_offerList[index].businessDetail as Map<String, dynamic>)['email'] as String? ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 25, top: 5,),
                                                    child: Text(
                                                      () {
                                                        final bd = _offerList[index].businessDetail as Map<String, dynamic>;
                                                        final c = bd['country'] as Map<String, dynamic>;
                                                        final s = bd['state'] as Map<String, dynamic>;
                                                        return '${c['name'] ?? ''}, ${s['name'] ?? ''}, ${bd['city'] ?? ''}, ${bd['address'] ?? ''}, ${bd['pincode'] ?? ''}';
                                                      }(),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              bottom: 5,
                                              right: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 40,
                                                  width: 100,
                                                  child: Card(
                                                    color: Colors.white30,
                                                    elevation: 10,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25.0,),
                                                    ),
                                                    child: Container(
                                                      height: 40,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 5,
                                                        bottom: 5,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        _offerList[index]
                                                            .status,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                ],
                              ),
                            );
                          },
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
