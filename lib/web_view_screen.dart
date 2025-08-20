import 'package:every_football/data/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';

class WebViewScreen extends StatefulWidget {
  final Position? position;

  const WebViewScreen({super.key, this.position});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  double progress = 0;

  String get _webUrlWithLocation {
    if (widget.position != null) {
      final lat = widget.position!.latitude;
      final lng = widget.position!.longitude;
      return '$webUrl?lat=$lat&lng=$lng';
    }
    return webUrl;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: bgColor,
          child: Column(
            children: [
              Expanded(
                child: InAppWebView(
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: true,
                  ),
                  key: webViewKey,
                  initialUrlRequest: URLRequest(
                    url: WebUri(_webUrlWithLocation),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).padding.bottom, // 제스처 바 높이만큼
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
