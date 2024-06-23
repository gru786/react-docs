import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController _controller;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _checkInternetConnection();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://react.dev/'));
  }

  void _checkInternetConnection() async {
    final listener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          // The internet is now connected
          setState(() {
            _hasInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          // The internet is now disconnected
          setState(() {
            _hasInternet = false;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff23272f),
      body: SafeArea(
        child: _hasInternet
            ? Column(
                children: [
                  Expanded(
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                  ),
                  Container(
                    color: const Color(0xff23272f),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.grey[100],
                          ),
                          onPressed: () async {
                            if (await _controller.canGoBack()) {
                              await _controller.goBack();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.home,
                            color: Colors.grey[100],
                          ),
                          onPressed: () {
                            _controller
                                .loadRequest(Uri.parse('https://react.dev/'));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  'No internet connection',
                  style: TextStyle(color: Colors.grey[100]),
                ),
              ),
      ),
    );
  }
}
