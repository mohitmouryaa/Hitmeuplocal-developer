import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hit_me_up/paypal/paypal_services.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;
  final String name,amount;

  const PaypalPayment({Key? key,required this.onFinish,required this.name,required this.amount}) : super(key: key);



  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl="";
  late String executeUrl;
  late String accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic,dynamic> defaultCurrency = {"symbol": "USD ", "decimalDigits": 2, "symbolBeforeTheNumber": true, "currency": "USD"};

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL= 'cancel.example.com';


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        accessToken = (await services.getAccessToken())!;
        // accessToken = "A21AAILimpEjxvKnw477kcx8B1RHcgHC7uPkrsdZg-vvQ1cE9Blpc345md2aC1nyX5sZAXSZugGox3KGvmO1rk1dmzY_ExAyg";

        final transactions = getOrderParams();
        final res = await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"].toString();
            executeUrl = res["executeUrl"].toString();
          });
        }
      } catch (e) {
        print('exception: '+e.toString());
      }
    });
  }

  // item name, price and quantity
  // String itemName = 'iPhone X';
  // String itemPrice = '1.99';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": widget.name,
        "quantity": quantity,
        "price": widget.amount,
        "currency": defaultCurrency["currency"]
      }
    ];


    // checkout invoice details
    String totalAmount = widget.amount;
    String subTotalAmount = widget.amount;
    String shippingCost = '0';
    int shippingDiscountCost = 0;

    Map<String, dynamic> temp = {
      "intent": "sale",

      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount":
              ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE",
          },
          "item_list": {
            "items": items,
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": returnURL,
        "cancel_url": cancelURL
      }
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          //backgroundColor: Theme.of(context).backgroundColor,
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: GestureDetector(
            child: const Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: Text(""),
        // WebView(
        //   initialUrl: checkoutUrl,
        //   javascriptMode: JavascriptMode.unrestricted,
        //   navigationDelegate: (NavigationRequest request) {
        //     if (request.url.contains(returnURL)) {
        //       final uri = Uri.parse(request.url);
        //       final payerID = uri.queryParameters['PayerID'];
        //       if (payerID != null) {
        //         services
        //             .executePayment(executeUrl, payerID, accessToken)
        //             .then((id) {
        //           widget.onFinish(id);
        //           Navigator.pop(context,true);
        //         });
        //       } else {
        //         Navigator.pop(context,true);
        //       }
        //       Navigator.pop(context,true);
        //     }
        //     if (request.url.contains(cancelURL)) {
        //       Navigator.pop(context,true);
        //     }
        //     return NavigationDecision.navigate;
        //   },
        // ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context,true);
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}