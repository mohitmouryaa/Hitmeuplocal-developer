import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hit_me_up/UI/common_promotion_by_id.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:page_transition/page_transition.dart';

class BusinessOwnerRegister extends StatefulWidget {
  final Function drawerCall;
  const BusinessOwnerRegister({Key? key,required this.drawerCall}) : super(key: key);

  @override
  State<BusinessOwnerRegister> createState() => _BusinessOwnerRegisterState();
}

class _BusinessOwnerRegisterState extends State<BusinessOwnerRegister> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _id="";
  Map childString={};
  List<dynamic> responseList=[];

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getBusinessList();
  }

  void getBusinessList() async {
    String url = "$baseUrl/business-list";
    var result = await callApi("GET", null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      responseList= result["data"] as List;
      if(responseList.isNotEmpty) {
        childString = responseList[0];
        _addressController.text=childString["address"];
        _id=childString["id"].toString();
        _phoneController.text=childString["mobile"];
      }
      setState(() {});
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  Future navigationPromotionPage() async {
    Navigator.push(
      context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: CommonPromotionByIdList(id: _id,url: "promotions-list-by-id",distance: "",))
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          leading: InkWell(
            onTap: () {
              widget.drawerCall();
            },
            child: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 35,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'Business Owner',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 210,
                child: Center(
                  child: Image.asset(
                    "assets/owner_image.png", height: 200,
                    fit: BoxFit.fitWidth,
                    // color: Colors.orangeAccent,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.centerLeft,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0, left: 10,right: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: greyBorder, width: 0.0),
                  color: greyFilled,
                  borderRadius: const BorderRadius.all(Radius.circular(25))),
              child: DropdownButtonFormField<dynamic>(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: const InputDecoration.collapsed(hintText: ''),
                value: childString!=null?childString["name"]:childString,
                hint: const Text("Select Owner"),
                isExpanded: true,
                items: responseList
                    .toSet()
                    .toList()
                    .map((label) => DropdownMenuItem(
                  child: Text(
                    label["name"],
                    style: const TextStyle(fontWeight: FontWeight.w400),
                    maxLines: null,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: label["name"],
                ))
                    .toList(),
                onChanged: (value) {
                  int index = responseList.indexWhere(
                          (data) => data["name"] == value);
                   _addressController.text=responseList[index]["address"];
                   _phoneController.text=responseList[index]["mobile"];
                  _id=responseList[index]["id"].toString();
                  setState(() {});
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 15),
              alignment: Alignment.center,
              width: 220,
              height: 45,
              padding: const EdgeInsets.only(top: 0),
              child: TextFormField(
                enabled: false,
                controller: _addressController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.text,
                maxLines: 1,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Address',
                  hintStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
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
                enabled: false,
                controller: _phoneController,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.number,
                maxLines: 1,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  hintText: 'Phone',
                  hintStyle: const TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: greyBorder, width: 0.0),
                  ),
                  border: const OutlineInputBorder(),
                  fillColor: greyFilled,
                  filled: true,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 25),
              child: Card(
                color: buttonParrotColor,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: InkWell(
                  onTap: () {
                    navigationPromotionPage();
                  },
                  child: Container(
                    height: 40,
                    width: 200,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Padding(padding: const EdgeInsets.only(left: 15,right: 10),child: SizedBox(
                          height: 10,
                          child: Center(
                            child: Image.asset(
                              "assets/discount_icon.png",
                              fit: BoxFit.fitWidth,
                              // color: Colors.orangeAccent,
                            ),
                          ),
                        ),),
                        const Text(
                          "Discount Offered",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            /*Container(
              padding: const EdgeInsets.only(bottom: 25),
              child: Card(
                color: buttonColor,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    height: 45,
                    width: 150,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    alignment: Alignment.center,
                    child: const Text(
                      "Redeem",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
