import 'package:every_football/data/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  Position? position;
  bool locationPermissionGranted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetLocation();
  }

  Future<void> _checkLocationPermissionAndGetLocation() async {
    try {
      PermissionStatus status = await Permission.location.request();

      setState(() {
        locationPermissionGranted = status.isGranted;
      });

      // 권한이 허용된 경우에만 위치 정보 가져오기
      if (status.isGranted) {
        try {
          final currentPosition = await Geolocator.getCurrentPosition();

          setState(() {
            position = currentPosition;
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // 권한이 거부된 경우
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String get _webUrlWithLocation {
    if (locationPermissionGranted && position != null) {
      final lat = position!.latitude;
      final lng = position!.longitude;
      return '$webUrl?lat=$lat&lng=$lng';
    } else {
      return webUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  '위치 정보를 확인하고 있습니다...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
