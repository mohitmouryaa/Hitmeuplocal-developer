import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NGORegisterPage extends StatefulWidget {
  final void Function() drawerCall;
  final String url;
  final String title;

  const NGORegisterPage({
    super.key,
    required this.drawerCall,
    required this.url,
    required this.title,
  });

  @override
  State<NGORegisterPage> createState() => _NGORegisterPageState();
}

class _NGORegisterPageState extends State<NGORegisterPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // To manage loading spinner
  bool _hasError = false;
  String _errorMessage = '';

  String get _initialUrl {
    if (widget.url.isNotEmpty) {
      return widget.url;
    }
    final String baseHost = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$baseHost/signup?role_id=4';
  }

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onHttpError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage =
                  'Server error (${error.response?.statusCode ?? 0}).';
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              if (error.isForMainFrame == true) {
                _hasError = true;
                _errorMessage = error.description;
              }
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_initialUrl)); // Load the initial URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title.isNotEmpty ? widget.title : 'Fundraising Registration',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black),
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

          if (_hasError)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load the registration page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                          _errorMessage = '';
                        });
                        _controller.loadRequest(Uri.parse(_initialUrl));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),

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
