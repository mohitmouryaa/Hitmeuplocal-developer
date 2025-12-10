import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/subscription_plan_list_model.dart';
import 'package:hit_me_up/paypal/paypal_payment.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dio/dio.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPlanList extends StatefulWidget {
  final String userId;

  const SubscriptionPlanList({Key? key, required this.userId}) : super(key: key);

  @override
  _SubscriptionPlanListState createState() => _SubscriptionPlanListState();
}

class _SubscriptionPlanListState extends State<SubscriptionPlanList> {

  // InApp Purchase variables
  late StreamSubscription? _purchaseUpdatedSubscription;
  late StreamSubscription? _purchaseErrorSubscription;
  late StreamSubscription? _conectionSubscription;
  //final List<String> _productLists = Platform.isAndroid ? ['monthly30', 'year12'] : ['month30', 'year12'/*,'weekly07'*/];
  final List<String> _productLists = [];
  //static final MethodChannel _channel = const MethodChannel('flutter_inapp');
  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
  List<bool> _purchaseStatus = [];
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //final List<SubscriptionPlanListData> _searchResult = [];
  final List<IAPItem> _searchResult = [];
  List<SubscriptionPlanListData> subscriptionListData = [];
  TextEditingController controller = TextEditingController();

   /*List<PaymentItem> _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '1.00',
      status: PaymentItemStatus.final_price,
    )
  ];*/

   // final _paymentItems = <PaymentItem> [];

  // Get json result and convert it to model. Then add

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformVersion = (await FlutterInappPurchase.instance.platformVersion)!;
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }
    //WidgetsFlutterBinding.ensureInitialized();

    // prepare
    var result = await FlutterInappPurchase.instance.initialize().then((value) => getInAppSubscriptions());
    //await Future.delayed(Duration(seconds: 1));
    //getInAppSubscriptions();
    //_getPurchases();
    //getAvailablePurchases();
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAll();
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
          print('connected: $connected');
        });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          print('purchase-updated: $productItem');
          var purchaseResponse = productItem;
          String? receipt = purchaseResponse?.transactionReceipt;
          //print('Product Item - '+receipt.toString());
          //validatePurchase(productItem!);
          _handlePurchaseUpdate(productItem);

        });

    //FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('purchase-error: $purchaseError');
      hideLoader(context);
    });
  }

  void getSubscriptionData() async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    String user_id =  user[kId].toString();
    //const url = "$baseUrl/subscriptions-list";
    final url = "$baseUrl/subscriptions-list/$user_id";
    var result = await callApi("GET", null, url);
    //hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
        var rest = result["data"] as List;
        subscriptionListData = rest
            .map<SubscriptionPlanListData>((json) => SubscriptionPlanListData.fromJson(json))
            .toList();
        for(int i = 0; i < subscriptionListData.length ; i++){
          //Add unique product id to productsList
          //if(subscriptionListData[i].subscriptionId != "year12"){
            _productLists.add(subscriptionListData[i].subscriptionId);
          //}

        }
        // _productLists.add("weekly7");
        //_productLists.add("month1");
        initPlatformState();
      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  @override
  void initState() {
    super.initState();
    //initConnection();
    //initPlatformState();
    //getInAppSubscriptions();
    showLoader(context);
    getSubscriptionData();
    //_paymentItems.add(PaymentItem(amount: '5.00', label: 'Plan 1' , status: PaymentItemStatus.final_price));

  }

  @override
  void dispose() {
    _conectionSubscription?.cancel();  // Cancel connection updates
    _purchaseUpdatedSubscription?.cancel();  // Cancel purchase updates
    _purchaseErrorSubscription?.cancel();  // Cancel purchase error listener

    FlutterInappPurchase.instance.finalize();
    super.dispose();
  }

  Future getInAppSubscriptions() async {
    List<IAPItem> items =
    await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    hideLoader(context);
    for (var item in items) {
      // ignore: avoid_print
      print(item.toString());
      _items.add(item);
      await updatePlanStatus();
    }

    setState(() {
        for (var productDetail in _items) {
          _searchResult.add(productDetail);
        }

      _items = items;
      _purchases = [];
    });
  }

  // void requestPurchase(IAPItem item) {
  //  if(Platform.isAndroid){
  //    if(isPlanActive()){
  //      showToast(context, "Another plan is active currently");
  //    }else{
  //      FlutterInappPurchase.instance
  //          .requestPurchase(item.productId.toString())
  //          .then((value) => {print(value)});
  //    }
  //  }else{
  //    setState(() {
  //      isLoading = true;
  //    });
  //    FlutterInappPurchase.instance
  //        .requestPurchase(item.productId.toString())
  //        .then((value) => {print(value)});
  //  }
  // }

  // void requestPurchase(IAPItem item) {
  //   // Display loading indicator while fetching products
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   // Fetch available subscriptions from the store
  //   FlutterInappPurchase.instance.getSubscriptions([item.productId!]).then((products) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //
  //     if (products.isEmpty) {
  //       // Show message if the subscription is not available
  //       showToast(context, "Subscription not available.");
  //     } else {
  //       // Check for active subscription plan on Android (if applicable)
  //       if (Platform.isAndroid && isPlanActive()) {
  //         showToast(context, "Another plan is active currently.");
  //         return;
  //       }
  //
  //       // Proceed to request purchase
  //       FlutterInappPurchase.instance.requestPurchase(item.productId!).then((value) {
  //         print("Purchase successful: $value");
  //         // Handle post-purchase logic here
  //       }).catchError((error) {
  //         // Handle errors during the purchase process
  //         print("Error during purchase: $error");
  //         showToast(context, "Purchase failed. Please try again.");
  //       });
  //     }
  //   }).catchError((error) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     // Handle errors while fetching subscriptions
  //     // print("Error fetching products: $error");
  //     // showToast(context, "Error fetching subscription. Please try again.");
  //     print("Error fetching products: ${error.toString()}");
  //     print("Stack trace: ${error.stackTrace}");
  //     showToast(context, "Error fetching subscription. Please try again.");
  //   });
  // }

  // void requestPurchase(IAPItem item) {
  //   FlutterInappPurchase.instance
  //       .requestPurchase(item.productId!)
  //       .then((value) {
  //     print("Purchase successful: $value");
  //     // Handle post-purchase logic here, such as unlocking content
  //   }).catchError((error) {
  //     print("Error during purchase: ${error.toString()}");
  //     print("Error type: ${error.runtimeType}");
  //
  //     // If more error details are available, log them
  //     if (error is PlatformException) {
  //       print("PlatformException: ${error.message}");
  //     }
  //
  //     // Show user-friendly message in case of error
  //     showToast(context, "Purchase failed. Please try again.");
  //   });
  // }

  //Current using
  // void requestPurchase(IAPItem item) {
  //   try {
  //     // Display loading indicator while fetching products
  //     setState(() {
  //       isLoading = true;
  //     });
  //
  //     print("Starting purchase process for product ID: ${item.productId}");
  //
  //     // Fetch available subscriptions from the store
  //     FlutterInappPurchase.instance.getSubscriptions([item.productId!]).then((products) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //       if (products.isEmpty) {
  //         // Show message if the subscription is not available
  //         print("No products found.");
  //         showToast(context, "Subscription not available.");
  //       } else {
  //         print("Products found: $products");
  //
  //         // Check if another plan is active (if needed)
  //         // Remove or modify this check based on your business logic
  //         // if (Platform.isAndroid && isPlanActive()) {
  //         //   showToast(context, "Another plan is active currently.");
  //         //   return;
  //         // }
  //
  //         // Proceed to request purchase
  //         try {
  //           print("Requesting purchase for product ID: ${item.productId!}");
  //
  //           FlutterInappPurchase.instance.requestPurchase(item.productId!).then((value) {
  //             print("Purchase successful: $value");
  //             // Handle post-purchase logic here
  //             // e.g., validate purchase, unlock content, etc.
  //           }).catchError((error) {
  //             // Handle errors during the purchase process
  //             print("Error during purchase: ${error.toString()}");
  //             print("Error type: ${error.runtimeType}");
  //             showToast(context, "Purchase failed. Please try again.");
  //           });
  //         } catch (e) {
  //           // Catch exceptions during the purchase process
  //           print("Caught exception in requestPurchase: ${e.toString()}");
  //           showToast(context, "An error occurred while requesting the purchase.");
  //         }
  //       }
  //     }).catchError((error) {
  //       // Handle errors while fetching subscriptions
  //       setState(() {
  //         isLoading = false;
  //       });
  //       print("Error fetching products: ${error.toString()}");
  //       print("Error type: ${error.runtimeType}");
  //       print("Stack trace: ${error is Error ? error.stackTrace : 'No stack trace available'}");
  //       showToast(context, "Error fetching subscription. Please try again.");
  //     });
  //   } catch (e, s) {
  //     // Catch any errors that might not be caught in the async code
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print("Caught error: ${e.toString()}");
  //     print("Stack trace: $s");
  //     showToast(context, "An unexpected error occurred.");
  //   }
  // }

  void requestPurchase(IAPItem item) {
    // Ensure the item and productId are not null before proceeding
    showLoader(context);
    if (item == null || item.productId == null || item.productId!.isEmpty) {
      showToast(context, "Invalid product. Please try again.");
      hideLoader(context);
      return;
    }

    try {
      // Display loading indicator while fetching products
      setState(() {
        isLoading = true;
      });

      print("Starting purchase process for product ID: ${item.productId}");

      // Fetch available subscriptions from the store
      FlutterInappPurchase.instance.getSubscriptions([item.productId!]).then((products) {
        setState(() {
          isLoading = false;
        });

        if (products.isEmpty) {
          // Show message if the subscription is not available
          print("No products found.");
          showToast(context, "Subscription not available.");
          hideLoader(context);
        } else {
          print("Products found: $products");

          // Proceed to request purchase
          try {
            print("Requesting purchase for product ID: ${item.productId!}");

            FlutterInappPurchase.instance.requestPurchase(item.productId!).then((purchaseResult) {
              print("Purchase successful: $purchaseResult");

              // Handle post-purchase logic here (e.g., validate purchase, unlock content, etc.)
              // You can also check the `purchaseResult` for further details, e.g.:
              if (purchaseResult != null && purchaseResult.transactionId != null) {
                print("Transaction ID: ${purchaseResult.transactionId}");
                // Proceed with unlocking content or validating the purchase
              } else {
                print("Purchase result invalid or incomplete.");
                showToast(context, "Purchase incomplete. Please try again.");
                hideLoader(context);
              }

            }).catchError((error) {
              // Handle errors during the purchase process
              print("Error during purchase: ${error.toString()}");
              print("Error type: ${error.runtimeType}");

              // Check if error message contains "User canceled"
              if (error.toString().toLowerCase().contains("user canceled")) {
                print("User canceled the purchase.");
              } else {
                showToast(context, "Purchase failed. Please try again.");
              }

              //showToast(context, "Purchase failed. Please try again.");
              hideLoader(context);
            });

          } catch (e) {
            // Catch exceptions during the purchase process
            print("Caught exception in requestPurchase: ${e.toString()}");
            showToast(context, "An error occurred while requesting the purchase.");
            hideLoader(context);
          }
        }
      }).catchError((error) {
        // Handle errors while fetching subscriptions
        setState(() {
          isLoading = false;
        });
        print("Error fetching products: ${error.toString()}");
        print("Error type: ${error.runtimeType}");
        showToast(context, "Error fetching subscription. Please try again.");
        hideLoader(context);
      });

    } catch (e, s) {
      // Catch any errors that might not be caught in the async code
      setState(() {
        isLoading = false;
      });
      print("Caught error: ${e.toString()}");
      print("Stack trace: $s");
      showToast(context, "An unexpected error occurred.");
      hideLoader(context);
    }
  }




  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      for (var productDetail in _items) {
          _searchResult.add(productDetail);
      }
      setState(() {});
      return;
    }
    for (var productDetail in _items) {
      if (productDetail.title!.toUpperCase().contains(text.toUpperCase())) {
        _searchResult.add(productDetail);
      }
    }

    /*for (var IAPItem in _items) {
      if (IAPItem.title!.toUpperCase().contains(text.toUpperCase())) {
        _searchResult.add(IAPItem);
      }
    }*/

    setState(() {});


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [buttonColor, buttonParrotColor],
                      begin: FractionalOffset(0.5, 0.5),
                      end: FractionalOffset(0.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Your Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  elevation: 0.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.search),
                    title: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                          hintText: 'Search', border: InputBorder.none),
                      onChanged: onSearchTextChanged,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        controller.clear();
                        onSearchTextChanged('');
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _items.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                  itemCount: _searchResult.length,
                  //itemCount: _items.length,
                  itemBuilder: (context, i) {
                    return Card(
                      child: Row(
                        children: [
                          Expanded(flex: 70,child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(
                                      //_items[i].title.toString(),
                                      _searchResult[i].title.toString(),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Container(padding: const EdgeInsets.only(
                                    //     right: 0, top: 5, bottom: 5),
                                    //     child: Text(
                                    //       // "\$${_items[i].price.toString().isNotEmpty?_items[i].price.toString():"0"} valid upto ${_items[i].subscriptionPeriodAndroid.toString().isNotEmpty?_items[i].subscriptionPeriodAndroid.toString():""} ${_items[i].currency.toString().isNotEmpty?_items[i].currency.toString():""}",
                                    //       //_items[i].description.toString(),
                                    //       //_searchResult[i].description.toString(),
                                    //       "Description - Access exclusive local discounts & offers " +
                                    //           (_searchResult[i].productId == "year12" ? "for a year" : "for a month"),
                                    //       style: TextStyle(
                                    //           fontSize: 16,
                                    //           color: Colors.grey.shade500),
                                    //       maxLines: 4,
                                    //     )),
                                    ReadMoreText(
                                      "When users subscribe to Hit Me Up Local, they gain full access to exclusive discounts and special offers from participating local businesses. The subscription unlocks savings that are only available through the app. Renewing the subscription ensures continuous access to these members-only deals, helping users save money while supporting their favorite local spots. Subscriptions are auto-renewable and can be managed or canceled anytime via Apple ID settings.",
                                      trimLines: 3,
                                      colorClickableText: Colors.blue,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'More',
                                      trimExpandedText: 'Less',
                                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                                      moreStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        height: 1.8,
                                      ),
                                      lessStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        height: 1.8,
                                      ),
                                    ),
                                    Container(padding: const EdgeInsets.only(
                                        right: 0, top: 5, bottom: 5),
                                        child: Text(
                                          // "\$${_items[i].price.toString().isNotEmpty?_items[i].price.toString():"0"} valid upto ${_items[i].subscriptionPeriodAndroid.toString().isNotEmpty?_items[i].subscriptionPeriodAndroid.toString():""} ${_items[i].currency.toString().isNotEmpty?_items[i].currency.toString():""}",
                                          //_items[i].description.toString(),
                                          "Price - "+_searchResult[i].price.toString() + " "+_searchResult[i].currency.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade500),
                                          maxLines: 4,
                                        )),
                                    Container(padding: const EdgeInsets.only(
                                        right: 0, top: 5, bottom: 5),
                                        child: Text(
                                          // "\$${_items[i].price.toString().isNotEmpty?_items[i].price.toString():"0"} valid upto ${_items[i].subscriptionPeriodAndroid.toString().isNotEmpty?_items[i].subscriptionPeriodAndroid.toString():""} ${_items[i].currency.toString().isNotEmpty?_items[i].currency.toString():""}",
                                          //_items[i].description.toString(),
                                            "Auto-renewable: Automatically renews unless canceled at least 24 hours before the end of the current period.",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade500),
                                          maxLines: 4,
                                        )),
                                  ],
                                ),
                              )
                            ],
                          )),
                          Expanded(flex: 30,child: Center(
                            child: InkWell(
                              onTap: () {
                                /*  showLoader(context);
                            apiPackagePurchase(_searchResult[i].id.toString(),i,_searchResult);*/
                                /*if(_purchaseStatus[i] == true){
                                  showToast(context, "Plan already active");
                                }else{
                                  //showToast(context, "Start Purchase");
                                  requestPurchase(_items[i]);
                                }*/

                                if(_searchResult[i].isPlanActive == true){
                                  showToast(context, "Plan already active");
                                }
                                else if(isAnyPlanActive(_searchResult)){
                                  showToast(context, "Other Plan already active");
                                }
                                else{
                                  requestPurchase(_searchResult[i]);
                                  // testApi();
                                }
                              },
                              child: Card(
                                color: buttonParrotColor,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Container(
                                  height: 33,
                                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                                  alignment: Alignment.center,
                                  child:  /*Text(_purchaseStatus!=null?_purchaseStatus[i]==true?'Active':'Buy':'Buy',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),*/
                                  /*Text(getPurchaseStatus(i),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),*/
                                  Text(_searchResult[i].isPlanActive==true?'Active':'Buy',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ))
                        ],
                      ),
                    );
                  },
                )
                    : Container(),
                /*ListView.builder(
              itemCount: subscriptionListData.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Row(
                    children: [
                      Expanded(flex: 70,child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  subscriptionListData[index].name.isNotEmpty?subscriptionListData[index].name:"N/A",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(padding: const EdgeInsets.only(
                                    right: 0, top: 5, bottom: 5),
                                    child: Text(
                                      "\$${subscriptionListData[index].price.toString().isNotEmpty?subscriptionListData[index].price.toString():"0"} valid upto ${subscriptionListData[index].validity.toString().isNotEmpty?subscriptionListData[index].validity.toString():""} ${subscriptionListData[index].validity_unit.isNotEmpty?subscriptionListData[index].validity_unit:""}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade500),
                                      maxLines: 4,
                                    )),
                              ],
                            ),
                          )
                        ],
                      )),
                      Expanded(flex: 30,child: Center(
                        child: InkWell(
                          onTap: () {
                            //showLoader(context);
                            //apiPackagePurchase(subscriptionListData[index].id.toString(),index,subscriptionListData);

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  PaymentsScreen(packId: subscriptionListData[index].id.toString(),position: index, packList :subscriptionListData)),
                            );
                          },
                          child: Card(
                            color: buttonParrotColor,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Container(
                              height: 33,
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              alignment: Alignment.center,
                              child: const Text(
                                "Buy",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                );
              },
            ),*/
              ),
              /*GooglePayButton(
            paymentConfigurationAsset: 'google_pay.json',
            height: 50,
            width: 200,
            paymentItems: _paymentItems,
            style: GooglePayButtonStyle.black,
            type: GooglePayButtonType.pay,
            margin: const EdgeInsets.only(top: 15.0),
            onPaymentResult: (data){
              print(data);
            },
            loadingIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
          ),*/
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 10, right: 10, top: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black), // Default text color
                    children: [
                      const TextSpan(text: "Note: By subscribing, you agree to our "),
                      TextSpan(
                        text: "Terms of Use",
                        style: const TextStyle(
                          color: Colors.blue, // Blue color for clickable text
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'; // Your Terms of Use URL
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          color: Colors.blue, // Blue color for clickable text
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url = 'http://104.131.164.62/privacy-policy'; // Your Privacy Policy URL
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
              ),
            ],
          ),
          isLoading? CircularProgressIndicator() : Container(),
        ],
      ),
    );
  }

  void onGooglePayResult(paymentResult) {
    // Send the resulting Google Pay token to your server / PSP
  }



  Future navigationLoginScreen(String orderId) async {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: LoginPinPage( orderId: orderId,)));
  }

  void apiPackagePurchase(String subId,int index,List<SubscriptionPlanListData> _searchResult) async {
    var param = {
      "sub_id": subId,
      "user_id": widget.userId,
      "type": "1",
    };
    const url = "$baseUrl/buy-subscriptions";
    var result = await callApi("POST", param, url);
    if (result[kDataCode] == 200) {
      callPaymentView(index,_searchResult,result[kData][kOrderId].toString());
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  Future<void> callPaymentView(int index,List<SubscriptionPlanListData> _searchResult,String orderId) async {
   final result=await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalPayment(
          name: _searchResult[index].name.toString(),
          amount: _searchResult[index].price.toString(),
          onFinish: (number) async {
            apiPaymentConfirm(orderId,number.toString());
          },
        ),
      ),
    );
   if(result==null){
     hideLoader(context);
   }
  }

  Future<void> showMessagePopUp(
      String title,
      String message,String orderId
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
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
            title: Text(
              title,
              style: const TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text(
              message,
              style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          );
        });
    if(res!=null){
      navigationLoginScreen(orderId);
    }
  }

  void apiPaymentConfirm(String subId,String paymentId) async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      "order_id": subId,
      "payment_id": paymentId,
      "user_id": user[kId].toString(),
    };
    const url = "$baseUrl/pay-subscriptions";
    var result = await callApi("POST", param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      showMessagePopUp(kAlert, result[kDataMessage],subId);
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  Future _getPurchases() async {
    List<PurchasedItem>? items =
    await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items!) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      //this._items = [];
      this._purchases = items;
    });
  }

  /*Future<List<PurchasedItem>?> getAvailablePurchases() async {
    if (Platform.isIOS) {
      dynamic result = await _channel.invokeMethod('getAvailableItems');
      print('Available plan - '+result.toString());

      //return extractPurchased(json.encode(result));
    }
    throw PlatformException(
        code: Platform.operatingSystem, message: "platform not supported");
  }*/

  validatePurchase(PurchasedItem productItem) async {
    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      "user_id": user[kId].toString(),
      "type": '1',
      "sub_id": productItem.productId,
      "payment_id": '',
      "token": productItem.transactionReceipt,
      "product_id": productItem.transactionId,
    };
    const url = "$baseUrl/validatePurchase";
    var result = await callApi("POST", param, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      //showMessagePopUp(kAlert, result[kDataMessage],subId);
      // If status is true from server side acknowledge this to app Store for IOS
      //FlutterInappPurchase.instance.finishTransaction(productItem);
      //_callProStatusChangedListeners();
      try {
        await FlutterInappPurchase.instance.finishTransaction(productItem);
        print("Transaction finished successfully: ${productItem.transactionId}");
      } catch (error) {
        print("Failed to finish transaction: $error");
      }
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  /*void _callProStatusChangedListeners() {
    _proStatusChangedListeners.forEach((Function callback) {
      callback();
    });
  }*/


  void _handlePurchaseUpdate(PurchasedItem? productItem) async {

    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(productItem);
    } else {
      await _handlePurchaseUpdateIOS(productItem);
    }

  }

  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem? purchasedItem) async {
    _verifyAndFinishTransaction(purchasedItem!);
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem? purchasedItem) async {
    if (purchasedItem != null && purchasedItem.transactionStateIOS != null) {
      switch (purchasedItem.transactionStateIOS) {
        case TransactionState.deferred:
        // Edit: This was a bug that was pointed out here : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
        // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
          break;
        case TransactionState.failed:
        //_callErrorListeners("Transaction Failed");
        print("Transaction failed or cancelled by user");
          hideLoader(context);
          FlutterInappPurchase.instance.finishTransaction(purchasedItem);
          break;
        case TransactionState.purchased:
          //showLoader(context);
          await _verifyAndFinishTransaction(purchasedItem);
          break;
        case TransactionState.purchasing:
          break;
        case TransactionState.restored:
          FlutterInappPurchase.instance.finishTransaction(purchasedItem);
          break;
        default:
      }
    } else {
      // Handle the case where purchasedItem is null.
      print('Error: purchasedItem or transactionStateIOS is null.');
      // Add error handling logic here (e.g., show an error message to the user).
    }
  }

  _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    //FlutterInappPurchase.instance.finishTransactionIOS(purchasedItem.toString());

    dynamic user = await getSharedPreference(kDataLoginUser);
    var param = {
      "user_id": user[kId].toString(),
      "type": '1',
      //1 for IOS and 2 for Android
      "device_type": Platform.isAndroid?'2':'1',
      "sub_id": purchasedItem.productId.toString(),
      "payment_id": purchasedItem.transactionId.toString(),
      "token": Platform.isAndroid ? purchasedItem.purchaseToken.toString() : purchasedItem.transactionReceipt.toString() ,
    };
    print(param);
    const url = "$baseUrl/pay-subscriptions";
    //var result = await callApi("POST", param, url);
    Dio dio = Dio();
    try {
      var response = await dio.post(
        url,
        data: param,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      // Check if response.data is a valid map and log the type
      print("Response type: ${response.data.runtimeType}");
      var result = response.data;
      hideLoader(context);
      print("result - ${result}");
      //if (result[kDataCode] == 200) {
      if (result['status_code'] == 200){
        //showMessagePopUp(kAlert, result[kDataMessage],subId);
        if(result['result'] == true){
          // If status is true from server side acknowledge this to app Store for IOS
          //FlutterInappPurchase.instance.finishTransaction(purchasedItem);
          try {
            await FlutterInappPurchase.instance.finishTransaction(purchasedItem);
            print("Transaction finished successfully: ${purchasedItem.transactionId}");
          } catch (error) {
            print("Failed to finish transaction: $error");
          }
          //_callProStatusChangedListeners();
          showToast(context, "Subscription active Successfully");

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AppDrawer(isNotification: false),
              ));
        }
        else{
          showToast(context, result[kDataMessage]);
          hideLoader(context);
        }

      } else {
        showToast(context, result[kDataMessage]);
        //developer.log('--- API Failed ---' , error: result[kDataCode]);
        //print("--- API Failed --- error"+result[kDataCode]);
      }
    } catch (error) {
      // Handle the error
      hideLoader(context);
      print(error.toString());
    }
  }

  testApi() async {
    dynamic user = await getSharedPreference(kDataLoginUser);

    var param = {
      "user_id": user[kId].toString(),
      "type": "1",
      //1 for IOS and 2 for Android
      "device_type": '1',
      "sub_id": "monthly30",
      "payment_id": "2000000359585341",
      "token": "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"
    };
    //print(param);
    const url = "https://dev.01s.in/hitmeup/public/api/pay-subscriptions";
    // var result = await callApi("POST", param, url);
    //
    // if (result[kDataCode] == 200) {
    //   showToast(context , "API Success");
    //   //showMessagePopUp(kAlert, result[kDataMessage],subId);
    //   if(result['result'] == true){
    //     showToast(context , "Result = True");
    //
    //   }
    //
    // }
    Dio dio = Dio();
    try {
      var response = await dio.post(
          url,
          data: param,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Handle the response
      print(response.data);
    } catch (error) {
      // Handle the error
      print(error.toString());
    }
  }

  String getPurchaseStatus(int index) {
    String purchaseStatus = 'Buy';
    /*if(_items[index].productId == subscriptionListData[index].subscriptionId)
      {
        if(subscriptionListData[index].subscriptionId == true){
          purchaseStatus = "Purchased";
        }
      }
    return purchaseStatus;*/

    for(int i = 0; i < subscriptionListData.length ; i++){
      if(_items[index].productId == subscriptionListData[i].subscriptionId)
      {
        if(subscriptionListData[i].planActive == true){
            //_purchaseStatus.insert(i,true);
              _purchaseStatus.add(true);
              return "Active";
        }
        else{
          //_purchaseStatus.insert(i,false);
            _purchaseStatus.add(false);
        }
      }
    }
    return 'Buy';
  }


   bool isPlanActive() {
    bool isActive = false;
    /*for(int i = 0; i< _purchaseStatus.length;i++){
      if(_purchaseStatus[i] == true){
        //return true;
        isActive = true;
      }
    }
    return isActive;*/

     for(int i = 0; i< _items.length;i++){
      if(_items[i].isPlanActive == true){
        //return true;
        isActive = true;
      }
    }
    return isActive;

  }

   updatePlanStatus() async {
    for(int j = 0; j < _items.length ; j++){
      for(int i = 0; i < subscriptionListData.length ; i++){
        if(_items[j].productId == subscriptionListData[i].subscriptionId)
        {
          if(subscriptionListData[i].planActive == true){
            _items[j].isPlanActive = true;
            //showToast(context, "isPlanActive = true");
          }
          else{
            _items[j].isPlanActive = false;
            //showToast(context, "isPlanActive = False");
          }
        }
      }
    }
  }

  bool isAnyPlanActive(List<IAPItem> searchResult) {
    for(int i = 0 ; i< searchResult.length ; i ++){
      if(searchResult[i].isPlanActive == true){
        return true;
      }
    }
    return false;
  }


}
