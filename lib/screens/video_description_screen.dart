import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class VideoDescription extends StatefulWidget {
  final String url;

  const VideoDescription({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoDescription> createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends State<VideoDescription> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Force landscape while on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.errorCode} ${error.description}');
          },
          onPageFinished: (url) => debugPrint('Loaded: $url'),
        ),
      )
      // ..setMediaPlaybackRequiresUserGesture(false)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // Restore portrait on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _resetOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<bool> _onWillPop() async {
    await _resetOrientation();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // NEW API
              WebViewWidget(controller: _controller),

              Positioned(
                top: 20,
                left: app_language_rtl.$ ? null : 10,
                right: app_language_rtl.$ ? 10 : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    color: MyTheme.medium_grey_50,
                    child: IconButton(
                      icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.white),
                      onPressed: () async {
                        await _resetOrientation();
                        if (mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
