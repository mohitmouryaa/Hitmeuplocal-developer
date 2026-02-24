// Migrated from flutter_inapp_purchase → in_app_purchase (official Flutter plugin)
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseTeting extends StatefulWidget {
  const PurchaseTeting({super.key});

  @override
  State<PurchaseTeting> createState() => _InAppState();
}

class _InAppState extends State<PurchaseTeting> {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final List<String> _productLists =
      Platform.isAndroid ? ['montly30', 'year12'] : ['month30', 'year12'];

  List<ProductDetails> _items = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _initIAP();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initIAP() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!mounted) return;
    setState(() => _isAvailable = available);
    if (!available) return;
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_productLists.toSet());
    if (!mounted) return;
    if (response.notFoundIDs.isNotEmpty) {}
    setState(() {
      _items = response.productDetails;
      _purchases = [];
    });
  }

  Future<void> _getPurchases() async {
    // Triggers purchase restoration; results arrive via purchaseStream
    await InAppPurchase.instance.restorePurchases();
  }

  List<Widget> _renderInApps() {
    return _items
        .map(
          (item) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    '${item.title} — ${item.price}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                // FlatButton(
                //   color: Colors.orange,
                //   onPressed: () {
                //     print("---------- Buy Item Button Pressed");
                //     this._requestPurchase(item);
                //   },
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         child: Container(
                //           height: 48.0,
                //           alignment: Alignment(-1.0, 0.0),
                //           child: Text('Buy Item'),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> _renderPurchases() {
    return _purchases
        .map(
          (item) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    '${item.productID} (${item.status.name})',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width - 20;
    final double buttonWidth = (screenWidth / 3) - 20;

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                'Store available: $_isAvailable',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: buttonWidth,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _getProducts,
                      child: const Text('Get Items'),
                    ),
                  ),
                  SizedBox(
                    width: buttonWidth,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _getPurchases,
                      child: const Text('Restore'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(children: _renderInApps()),
              Column(children: _renderPurchases()),
            ],
          ),
        ],
      ),
    );
  }
}
