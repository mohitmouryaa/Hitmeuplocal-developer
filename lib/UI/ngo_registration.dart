
import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NGORegisterPage extends StatefulWidget {
  final Function drawerCall;
  final url,title;

  const NGORegisterPage({super.key, required this.drawerCall,required this.url,required this.title});

  @override
  State<NGORegisterPage> createState() => _NGORegisterPageState();
}

class _NGORegisterPageState extends State<NGORegisterPage> {

  late final WebViewController _controller;
  bool _isLoading = true; // To manage loading spinner

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController
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
            // Handle any errors that occur
          },
        ),
      )
      ..loadRequest(Uri.parse('https://dev.01s.in/hitmeup/public/signup?role_id=4')); // Load the initial URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Fundraising Registration',
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
    );
  }
}
