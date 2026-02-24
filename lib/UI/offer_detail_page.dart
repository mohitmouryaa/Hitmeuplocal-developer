import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hit_me_up/UI/become_partner.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';




class OfferDetailPage extends StatefulWidget {
  final String requestType,promotionId,businessId, title,description,distance,name,email,mobile,webUrl,address,lat , lng;

  const OfferDetailPage({
    super.key,
    required this.requestType,
    required this.promotionId,
    required this.businessId,
    required this.title,
    required this.description,
    required this.distance,
    required this.name,
    required this.email,
    required this.mobile,
    required this.webUrl,
    required this.address,
    required this.lat,
    required this.lng,

  });

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  late FToast fToast;



  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  Future navigationHomePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BecomePartner()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            iconSize: 35,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Offer Detail',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0.0, 4.0),
                    blurRadius: 4.0,
                    color: Colors.black45,
                  ),
                ],),
          ),
          backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: const LinearGradient(
                      colors: [buttonColor, buttonParrotColor],
                      begin: FractionalOffset(0.5, 0.5),
                      end: FractionalOffset(0.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10,),
                    Text(
                      widget.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,),
                      textAlign: TextAlign.center,
                      // overflow: TextOverflow.ellipsis,
                      // maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white30, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0), // Border radius
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 2.0,
                          ),
                        ),
                        onPressed: () {
                          showLoader(context);
                          apiRedeemUser();
                        },
                        child: const Text(
                          'Redeem',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Stack(
              //   children: [
              //     Container(
              //       height: 180,
              //       decoration: const BoxDecoration(
              //         borderRadius: BorderRadius.all(Radius.circular(25)),
              //         gradient: LinearGradient(
              //             colors: [buttonColor, buttonParrotColor],
              //             begin: FractionalOffset(0.5, 0.5),
              //             end: FractionalOffset(0.0, 0.0),
              //             stops: [0.0, 1.0],
              //             tileMode: TileMode.clamp
              //         ),
              //       ),
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Row(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisAlignment: MainAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Flexible(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 mainAxisAlignment: MainAxisAlignment.start,
              //                 mainAxisSize: MainAxisSize.max,
              //                 children: [
              //                   Container(
              //                     height: 40,
              //                     alignment: Alignment.topLeft,
              //                     child: Container(
              //                         padding: const EdgeInsets.only(left: 10, top: 20),
              //                         child: Text(
              //                           widget.title,
              //                           style: const TextStyle(
              //                               fontSize: 15,
              //                               fontWeight: FontWeight.w600,
              //                               color: Colors.white),
              //                           textAlign: TextAlign.center,
              //                           overflow: TextOverflow.ellipsis,
              //                         )),
              //                   ),
              //                   Container(
              //                     padding: const EdgeInsets.only(left: 10, top: 5),
              //                     child: Text(
              //                       widget.description,
              //                       style: const TextStyle(
              //                           fontSize: 13,
              //                           fontWeight: FontWeight.w600,
              //                           color: Colors.white),
              //                       textAlign: TextAlign.start,
              //
              //                     ),
              //                   )
              //                 ],
              //               ),
              //             )
              //           ],
              //         ),
              //         Align(
              //           alignment: Alignment.bottomRight,
              //           child: Padding(
              //             padding: const EdgeInsets.only(
              //                 top: 45, bottom: 5, right: 15),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.end,
              //               mainAxisAlignment: MainAxisAlignment.end,
              //               mainAxisSize: MainAxisSize.min,
              //               children: <Widget>[
              //                 SizedBox(
              //                   height: 40,
              //                   width: 100,
              //                   child: InkWell(
              //                     onTap: (){
              //                       showLoader(context);
              //                       apiRedeemUser();
              //                     },
              //                     child: Card(
              //                       color: Colors.white30,
              //                       elevation: 10,
              //                       shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(25.0),
              //                       ),
              //                       child: Container(
              //                         height: 40,
              //                         padding: const EdgeInsets.only(
              //                             top: 5, bottom: 5),
              //                         alignment: Alignment.center,
              //                         child: const Text(
              //                           "Redeem",
              //                           style: TextStyle(
              //                               color: Colors.white,
              //                               fontSize: 16,
              //                               fontWeight: FontWeight.bold),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         )
              //       ],
              //     )
              //   ],
              // ),
            ),
            const Align(
              alignment: Alignment.topLeft ,
              child: Padding(
                padding: EdgeInsets.only(left: 20, top: 10, right: 0.0),
                child: Text(
                  'Business Detail',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                elevation: 15,
                color: Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              height: 45,
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 20, top: 20),
                              child: Text(
                                widget.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),),
                          InkWell(
                            onTap: () => {sendMail()},
                            child: Container(
                              padding: const EdgeInsets.only(left: 20, top: 25),
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => {launch('tel:+1${widget.mobile}')},
                            child: Container(
                              padding: const EdgeInsets.only(left: 20, top: 25),
                              child: Text(
                                widget.mobile,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          widget.webUrl.isNotEmpty ? Container(
                            padding: const EdgeInsets.only(left: 20, top: 25),
                            child: InkWell(
                            //onTap: () => launch('https://www.google.com/?client=safari'),
                              //onTap: () => {sendEmail()},
                              //onTap: () => launchUrl(Uri.parse((widget.webUrl).replaceAll("www.", "https://"))),
                              //onTap: () => launchUrl(Uri.parse('https://'+widget.webUrl)),
                              onTap: () => launchUrl(Uri.parse(getUrl(widget.webUrl))),
                              child: Text(widget.webUrl,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,),
                                textAlign: TextAlign.start,
                              ),
                                //onTap: () => launch(widget.webUrl),
                            ),
                          ) : Container(),
                          InkWell(
                            onTap: () => {navigateToMaps(widget.lat,widget.lng)},
                            child: Container(
                              padding: const EdgeInsets.only(left: 20, top: 25),
                              child:  Text(
                                widget.address,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 5, right: 15 , left: 20,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.only(
                                    top: 5, bottom: 5,),
                                alignment: Alignment.bottomLeft,
                                child: Text(getMiles(),
                                  //widget.distance.isNotEmpty && widget.distance != "0"?"${widget.distance.substring(0,3)} Miles Away":"",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,),
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
    );
  }

  Future<void> showMessagePopUp(
      String title,
      String message,
      ) async {
    final res=await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[50],
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
            title: Text(
              title,
              style: const TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,),
            ),
            content: Text(
              message,
              style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700,),
            ),
          );
        },);
    if(res!=null){
      Navigator.pop(context, true);
    }
  }

  void apiRedeemUser() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      'user_id': user[kId].toString(),
      'promotion_id': widget.promotionId,
      'business_id': widget.businessId,
      'request_from': widget.requestType,
    };
    const url = '$baseUrl/avail-offer';
    var result = await callApi('POST', param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      await showMessagePopUp(kAlert, result[kDataMessage]);
    } else {
      //showToast(context, result[kDataMessage]);
      /*fToast.showToast(
        child: showCustomToast(context, result[kDataMessage]),
        toastDuration: Duration(seconds: 5),
        gravity: ToastGravity.CENTER,
      );*/
      await showMessagePopUp(kAlert, result[kDataMessage]);
    }
  }

  String getMiles() {
    String miles = '';
    if(widget.distance.isNotEmpty && widget.distance != '0'){
      var distance = double.parse(widget.distance);
      var dis = (distance * 0.621371);
      miles = '${dis.toString().substring(0,4)} Miles away';
    }
    return miles;
  }

  sendMail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: widget.email,
      //query: 'subject=App Feedback&body=App Version 3.23', //add subject and body here
    );

    var url = params;
    await launchUrl(url);
  }

  navigateToMaps(String lat , String lng) async {
    await MapsLauncher.launchCoordinates(double.parse(lat), double.parse(lng));
      /*if(Platform.isAndroid){
        uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
      }else{
        //Uri.parse("https://maps.apple.com/?q=$lat,$lat&mode=d");
        Uri.parse("https://maps.apple.com/?q=$lat,$lng'");

      }
      //var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");

      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        throw 'Could not launch ${uri.toString()}';
      }*/
  }

  String getUrl(String url) {
    // Remove the trailing slash if it exists
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    // Add "https://" if "http://" is not provided
    if (!RegExp(r'^(?:f|ht)tps?://', caseSensitive: false).hasMatch(url)) {
      url = 'https://${url.replaceFirst('www.', '')}';
    }
    return url;
  }
}
