import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';

class StateCitySelection extends StatefulWidget {
  const StateCitySelection({Key? key}) : super(key: key);

  @override
  _StateCitySelectionState createState() => _StateCitySelectionState();
}

class _StateCitySelectionState extends State<StateCitySelection> {
  List<dynamic> stateList = [];
  Map stateData={};
  String _stateId="";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showLoader(context);
    getStateListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
                                    "Select your location",
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
                                        ]),
                                  )))
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
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        alignment: Alignment.centerLeft,
                        width: 220,
                        height: 45,
                        padding:
                        const EdgeInsets.only(top: 0, left: 10, right: 5),
                        decoration: BoxDecoration(
                            border: Border.all(color: greyBorder, width: 0.0),
                            color: Colors.transparent,
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
                        color: Colors.transparent,
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
                            fillColor: Colors.transparent,
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
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 25, top: 20),
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              //showLoader(context);
                            //  getPromotionList("Manual Search",_stateId,false);
                            },
                            child: Container(
                              height: 45,
                              width: 150,
                              padding:
                              const EdgeInsets.only(top: 5, bottom: 5),
                              alignment: Alignment.center,
                              child: const Text(
                                "Apply",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )),
        ],
      ),
    );;
  }

  void getStateListData() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    final url = "$baseUrl/states-list/${user["country"]["id"]}";
    var result = await callApi("GET", null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      stateList = result["data"] as List;
      if (stateList.isNotEmpty) {
        // stateData = stateList[1];
        // _stateId = stateData["id"];
      }
      WidgetsBinding.instance!.addPostFrameCallback(_onLayoutDone);
      setState(() {});
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  _onLayoutDone(_) {
    _scaffoldKey.currentState!.openEndDrawer();
  }
}
