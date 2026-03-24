import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:hit_me_up/UI/app_drawer.dart';
import 'package:hit_me_up/UI/login_pin_purchase.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/subscription_plan_list_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wraps [ProductDetails] with server-side subscription status so the UI
/// can show 'Active' vs 'Buy' without mutating the immutable [ProductDetails].
class _IAPProduct {
  final ProductDetails details;
  bool isPlanActive;

  _IAPProduct(this.details, {this.isPlanActive = false});

  String? get productId => details.id;
  String get title => details.title;
  String get price => details.price;
  String get currency => details.currencyCode;
}

class SubscriptionPlanList extends StatefulWidget {
  final String userId;

  const SubscriptionPlanList({super.key, required this.userId});

  @override
  _SubscriptionPlanListState createState() => _SubscriptionPlanListState();
}

class _SubscriptionPlanListState extends State<SubscriptionPlanList> {
  // InApp Purchase variables
  StreamSubscription<List<PurchaseDetails>>? _purchaseUpdatedSubscription;
  final List<String> _productLists = [];
  List<_IAPProduct> _items = [];
  final List<bool> _purchaseStatus = [];
  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<_IAPProduct> _searchResult = [];
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
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      if (mounted) hideLoader(context);
      return;
    }
    if (!mounted) return;

    // Single stream handles both purchase updates and errors.
    _purchaseUpdatedSubscription = InAppPurchase.instance.purchaseStream.listen(
      (purchases) {
        for (final purchase in purchases) {
          if (mounted) setState(() => isLoading = false);
          if (purchase.status == PurchaseStatus.error ||
              purchase.status == PurchaseStatus.canceled) {
            if (!mounted) return;
            hideLoader(context);
            if (purchase.status == PurchaseStatus.error) {
              showToast(context, 'Purchase failed. Please try again.');
            }
            // Always complete the transaction to clear it from the store queue.
            InAppPurchase.instance.completePurchase(purchase);
          } else {
            _handlePurchaseUpdate(purchase);
          }
        }
      },
      onError: (dynamic error) {
        if (mounted) setState(() => isLoading = false);
        if (mounted) hideLoader(context);
      },
    );
    await getInAppSubscriptions();
  }

  void getSubscriptionData() async {
    final dynamic rawUser = await getSharedPreference(kDataLoginUser);
    final user = rawUser as Map<String, dynamic>;
    final String userId = user[kId].toString();
    final url = '$baseUrl/subscriptions-list/$userId';
    final result = await callApi('GET', null, url);
    if (!mounted) return;
    if (result[kDataCode] == 200) {
      setState(() {
        var rest = result['data'] as List;
        subscriptionListData = rest
            .map<SubscriptionPlanListData>(
              (json) => SubscriptionPlanListData.fromJson(json),
            )
            .toList();
        for (int i = 0; i < subscriptionListData.length; i++) {
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
      showToast(context, result[kDataMessage] as String);
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
    _purchaseUpdatedSubscription?.cancel();
    super.dispose();
  }

  Future<void> getInAppSubscriptions() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_productLists.toSet());
    if (response.notFoundIDs.isNotEmpty) {}
    final items = response.productDetails.map(_IAPProduct.new).toList();
    await updatePlanStatus(items);
    if (!mounted) return;
    hideLoader(context);
    setState(() {
      _items = items;
      _searchResult
        ..clear()
        ..addAll(items);
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

  void requestPurchase(_IAPProduct item) {
    if (item.productId == null || item.productId!.isEmpty) {
      showToast(context, 'Invalid product. Please try again.');
      return;
    }
    debugPrint('Initiating purchase for ${item.productId}');
    showLoader(context);
    setState(() => isLoading = true);

    // Build platform-specific purchase params.
    // Android Play Billing v5+ requires an offer token for subscriptions;
    // GooglePlayProductDetails.offerToken provides it automatically.
    final PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      final googleDetails = item.details as GooglePlayProductDetails;
      debugPrint('Debugging Android Purchase Params:');
      debugPrint('Product ID: ${googleDetails.id}');
      debugPrint('Offer Token: ${googleDetails.offerToken}');
      
      if (googleDetails.offerToken?.isEmpty ?? true) {
        debugPrint('WARNING: Offer token is empty. Purchase may fail.');
      }

      purchaseParam = GooglePlayPurchaseParam(
        productDetails: item.details,
        offerToken: googleDetails.offerToken,
      );
    } else {
      purchaseParam = PurchaseParam(productDetails: item.details);
    }

    InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam)
        .then((success) {
      debugPrint('Purchase request initiated. Success: $success');
      if (!success) {
        if (!mounted) return;
        setState(() => isLoading = false);
        showToast(
          context,
          'Purchase could not be initiated. Please try again.',
        );
        hideLoader(context);
      }
      // Actual purchase result arrives via purchaseStream (_purchaseUpdatedSubscription)
    }).catchError((dynamic error) {
      debugPrint('Purchase request failed with error: $error');
      if (!mounted) return null;
      setState(() => isLoading = false);
      if (error.toString().toLowerCase().contains('cancel')) {
      } else {
        showToast(context, 'Purchase failed. Please try again.');
      }
      hideLoader(context);
    });
  }

  Future<void> onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      for (var productDetail in _items) {
        _searchResult.add(productDetail);
      }
      setState(() {});
      return;
    }
    for (var productDetail in _items) {
      if (productDetail.title.toUpperCase().contains(text.toUpperCase())) {
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
                    tileMode: TileMode.clamp,
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
                        fontStyle: FontStyle.normal,
                      ),
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
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
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
                                Expanded(
                                  flex: 70,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              //_items[i].title.toString(),
                                              _searchResult[i].title.toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
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
                                              'When users subscribe to Hit Me Up Local, they gain full access to exclusive discounts and special offers from participating local businesses. The subscription unlocks savings that are only available through the app. Renewing the subscription ensures continuous access to these members-only deals, helping users save money while supporting their favorite local spots. Subscriptions are auto-renewable and can be managed or canceled anytime via Apple ID settings.',
                                              trimLines: 3,
                                              colorClickableText: Colors.blue,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: 'More',
                                              trimExpandedText: 'Less',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade500,
                                              ),
                                              moreStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                                height: 1.8,
                                              ),
                                              lessStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                                height: 1.8,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                right: 0,
                                                top: 5,
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                // "\$${_items[i].price.toString().isNotEmpty?_items[i].price.toString():"0"} valid upto ${_items[i].subscriptionPeriodAndroid.toString().isNotEmpty?_items[i].subscriptionPeriodAndroid.toString():""} ${_items[i].currency.toString().isNotEmpty?_items[i].currency.toString():""}",
                                                //_items[i].description.toString(),
                                                'Price - ${_searchResult[i].price} ${_searchResult[i].currency}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade500,
                                                ),
                                                maxLines: 4,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                right: 0,
                                                top: 5,
                                                bottom: 5,
                                              ),
                                              child: Text(
                                                // "\$${_items[i].price.toString().isNotEmpty?_items[i].price.toString():"0"} valid upto ${_items[i].subscriptionPeriodAndroid.toString().isNotEmpty?_items[i].subscriptionPeriodAndroid.toString():""} ${_items[i].currency.toString().isNotEmpty?_items[i].currency.toString():""}",
                                                //_items[i].description.toString(),
                                                'Auto-renewable: Automatically renews unless canceled at least 24 hours before the end of the current period.',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade500,
                                                ),
                                                maxLines: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 30,
                                  child: Center(
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

                                        if (_searchResult[i].isPlanActive ==
                                            true) {
                                          showToast(
                                            context,
                                            'Plan already active',
                                          );
                                        } else if (isAnyPlanActive(
                                          _searchResult,
                                        )) {
                                          showToast(
                                            context,
                                            'Other Plan already active',
                                          );
                                        } else {
                                          requestPurchase(_searchResult[i]);
                                          // testApi();
                                        }
                                      },
                                      child: Card(
                                        color: buttonParrotColor,
                                        elevation: 10,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        child: Container(
                                          height: 33,
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                          ),
                                          alignment: Alignment.center,
                                          child: /*Text(_purchaseStatus!=null?_purchaseStatus[i]==true?'Active':'Buy':'Buy',
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
                                              Text(
                                            _searchResult[i].isPlanActive ==
                                                    true
                                                ? 'Active'
                                                : 'Buy',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
                                      "\$${subscriptionListData[index].price.toString().isNotEmpty?subscriptionListData[index].price.toString():"0"} valid upto ${subscriptionListData[index].validity.toString().isNotEmpty?subscriptionListData[index].validity.toString():""} ${subscriptionListData[index].validityUnit.isNotEmpty?subscriptionListData[index].validityUnit:""}",
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
            },
            loadingIndicator: const Center(
                            child: CircularProgressIndicator(),
                          ),
          ),*/
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40,
                  left: 10,
                  right: 10,
                  top: 20,
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                    ), // Default text color
                    children: [
                      const TextSpan(
                        text: 'Note: By subscribing, you agree to our ',
                      ),
                      TextSpan(
                        text: 'Terms of Use',
                        style: const TextStyle(
                          color: Colors.blue, // Blue color for clickable text
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url =
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'; // Your Terms of Use URL
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.blue, // Blue color for clickable text
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url =
                                'http://104.131.164.62/privacy-policy'; // Your Privacy Policy URL
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          isLoading ? const CircularProgressIndicator() : Container(),
        ],
      ),
    );
  }

  void onGooglePayResult(dynamic paymentResult) {
    // Send the resulting Google Pay token to your server / PSP
  }

  Future navigationLoginScreen(String orderId) async {
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

  /*Future<List<PurchasedItem>?> getAvailablePurchases() async {
    if (Platform.isIOS) {
      dynamic result = await _channel.invokeMethod('getAvailableItems');
      print('Available plan - '+result.toString());

      //return extractPurchased(json.encode(result));
    }
    throw PlatformException(
        code: Platform.operatingSystem, message: "platform not supported");
  }*/

  /*void _callProStatusChangedListeners() {
    _proStatusChangedListeners.forEach((Function callback) {
      callback();
    });
  }*/

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchaseDetails) async {
    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(purchaseDetails);
    } else {
      await _handlePurchaseUpdateIOS(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseUpdateAndroid(
    PurchaseDetails purchaseDetails,
  ) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        // Deferred payment (e.g., carrier billing); do nothing until it resolves.
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _verifyAndFinishTransaction(purchaseDetails);
        break;
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        // Already handled in the stream listener.
        break;
    }
  }

  Future<void> _handlePurchaseUpdateIOS(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        // Transaction deferred or still in progress; no action needed
        break;
      case PurchaseStatus.error:
      case PurchaseStatus.canceled:
        hideLoader(context);
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.purchased:
        await _verifyAndFinishTransaction(purchaseDetails);
        break;
      case PurchaseStatus.restored:
        // Re-validate restored purchases with the server so subscription
        // status is updated for the current user/device.
        await _verifyAndFinishTransaction(purchaseDetails);
        break;
    }
  }

  Future<void> _verifyAndFinishTransaction(
    PurchaseDetails purchaseDetails,
  ) async {
    final dynamic rawUser = await getSharedPreference(kDataLoginUser);
    if (!mounted) return;
    final user = rawUser as Map<String, dynamic>;
    final param = {
      'user_id': user[kId].toString(),
      'type': '1',
      'device_type': Platform.isAndroid ? '2' : '1',
      'sub_id': purchaseDetails.productID,
      'payment_id': purchaseDetails.purchaseID ?? '',
      // serverVerificationData holds the purchase token (Android) or receipt (iOS).
      'token': purchaseDetails.verificationData.serverVerificationData,
    };
    const url = '$baseUrl/pay-subscriptions';

    debugPrint('Verify Transaction URL: $url');
    debugPrint('Verify Transaction Params: $param');

    final result = await callApi('POST', param, url);

    debugPrint('Verify Transaction Result: $result');

    if (!mounted) return;
    hideLoader(context);

    // Always complete the purchase to remove the transaction from the store queue,
    // even if server validation fails. This prevents stuck/replayed transactions.
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
        debugPrint('Purchase completed (acknowledged) with store.');
      } catch (error) {
        debugPrint('Error completing purchase: $error');
      }
    }

    if (!mounted) return;

    // Robust check for success
    final isStatusCodeSuccess = result[kDataCode] == 200;
    // Check if result is true, 'true', 1, or if code is 200 and result is missing/null (implies success)
    final dynamic resVal = result['result'];
    final isResultTruthy = resVal == true || resVal == 'true' || resVal == 1;
    
    // If strict compliance with API is needed:
    // Some APIs return 200 but result: false for business logic failures.
    // However, if we just Bought it, we usually want to let them in or show the error.
    
    if (isStatusCodeSuccess && (isResultTruthy || resVal == null)) {
      showToast(context, 'Subscription activated successfully.');
      if (!mounted) return;
      // Use pushAndRemoveUntil to clear the stack and ensure we land on the Home Screen cleanly
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AppDrawer(isNotification: false),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      showToast(
        context,
        result[kDataMessage]?.toString() ?? 'Subscription activation failed. Please contact support.',
      );
    }
  }

  String getPurchaseStatus(int index) {
    /*if(_items[index].productId == subscriptionListData[index].subscriptionId)
      {
        if(subscriptionListData[index].subscriptionId == true){
          purchaseStatus = "Purchased";
        }
      }
    return purchaseStatus;*/

    for (int i = 0; i < subscriptionListData.length; i++) {
      if (_items[index].productId == subscriptionListData[i].subscriptionId) {
        if (subscriptionListData[i].planActive == true) {
          //_purchaseStatus.insert(i,true);
          _purchaseStatus.add(true);
          return 'Active';
        } else {
          //_purchaseStatus.insert(i,false);
          _purchaseStatus.add(false);
        }
      }
    }
    return 'Buy';
  }

  bool isPlanActive() {
    return _items.any((item) => item.isPlanActive);
  }

  Future<void> updatePlanStatus([List<_IAPProduct>? items]) async {
    final targets = items ?? _items;
    for (final iapProduct in targets) {
      for (final sub in subscriptionListData) {
        if (iapProduct.productId == sub.subscriptionId) {
          iapProduct.isPlanActive = sub.planActive;
        }
      }
    }
  }

  bool isAnyPlanActive(List<_IAPProduct> searchResult) {
    return searchResult.any((item) => item.isPlanActive);
  }
}
