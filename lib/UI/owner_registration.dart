
import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OwnerRegisterPage extends StatefulWidget {
  final Function drawerCall;
  final url,title;

  const OwnerRegisterPage({super.key,required this.drawerCall,required this.url,required this.title});

  @override
  State<OwnerRegisterPage> createState() => _OwnerRegisterPageState();
}

class _OwnerRegisterPageState extends State<OwnerRegisterPage> {

  late final WebViewController _controller;
  bool _isLoading = true; // For loading spinner

  @override
  void initState() {
    super.initState();
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
          },
        ),
      )
      ..loadRequest(Uri.parse('https://dev.01s.in/hitmeup/public/signup?role_id=2')); // Load the URL passed from the widget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Owner Registration',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
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
        ),
      body: Stack(
        children: [
          // WebView content
          WebViewWidget(controller: _controller),

          // Loading spinner when the page is loading
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: buttonParrotColor,
              ),
            ),
        ],
      ),
        // body: Stack(
        //   children: [
        //     const Center(
        //       child: CircularProgressIndicator(
        //         color: buttonParrotColor,
        //       ),
        //     ),
        //     Column(
        //       children: const [
        //         Expanded(
        //             child: WebView(
        //                 javascriptMode: JavascriptMode.unrestricted,
        //                 initialUrl: "https://dev.01s.in/hitmeup/public/signup?role_id=2"))
        //                 // initialUrl: "https://www.hitmeuplocal.com/business-features/"))
        //
        //       ],
        //     )
        //   ],
        // )
    );
  }
}
