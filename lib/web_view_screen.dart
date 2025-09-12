import 'package:every_football/data/const.dart';
import 'package:every_football/components/app_header.dart';
import 'package:every_football/components/new_window_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  Position? position;
  bool locationPermissionGranted = false;
  bool isLoading = true;
  bool isWebViewLoading = true;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermissionAndGetLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아왔을 때 WebView 상태 확인 및 복구
      _handleAppResumed();
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 갈 때 현재 URL 저장
      _saveCurrentUrl();
    }
  }

  void _saveCurrentUrl() async {
    if (webViewController != null) {
      try {
        final url = await webViewController!.getUrl();
        _currentUrl = url?.toString();
      } catch (e) {
        print('URL 저장 실패: $e');
      }
    }
  }

  void _handleAppResumed() async {
    if (webViewController != null) {
      try {
        // WebView가 여전히 유효한지 확인
        final currentUrl = await webViewController!.getUrl();
        if (currentUrl == null || currentUrl.toString().isEmpty) {
          // WebView가 비어있으면 다시 로드
          print('WebView 복구: URL 재로드');
          setState(() {
            isWebViewLoading = true;
          });
          await webViewController!.loadUrl(
            urlRequest: URLRequest(
              url: WebUri(_currentUrl ?? _webUrlWithLocation),
            ),
          );
        }
      } catch (e) {
        // WebView 오류 발생 시 재생성
        print('WebView 오류 감지, 재생성: $e');
        setState(() {
          // WebView를 강제로 재생성하기 위해 key 변경
          webViewKey = GlobalKey();
          isWebViewLoading = true;
        });
      }
    }
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

  InAppWebViewSettings get _webViewSettings {
    return InAppWebViewSettings(
      // 성능 최적화 설정
      transparentBackground: true,
      javaScriptEnabled: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      clearCache: false,
      cacheEnabled: true,
      // 로딩 최적화
      useOnLoadResource: false,
      useShouldOverrideUrlLoading: true,
      useOnDownloadStart: false,
      // 렌더링 최적화
      hardwareAcceleration: true,
      // window.open 최적화
      supportMultipleWindows: true,
      javaScriptCanOpenWindowsAutomatically: true,
      // 유저 에이전트 설정
      userAgent:
          "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
      // 추가 성능 설정
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    if (isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              AppHeader(),
              // 로딩 컨텐츠
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(mainGreen),
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
            ],
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
                child: Stack(
                  children: [
                    InAppWebView(
                      initialSettings: _webViewSettings,
                      key: webViewKey,
                      initialUrlRequest: URLRequest(
                        url: WebUri(_webUrlWithLocation),
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async =>
                              NavigationActionPolicy.ALLOW,
                      onLoadStart: (controller, url) {
                        // WebView 로딩 시작
                        setState(() {
                          isWebViewLoading = true;
                        });
                      },
                      onLoadStop: (controller, url) {
                        // WebView 로딩 완료
                        setState(() {
                          isWebViewLoading = false;
                        });
                        // 현재 URL 저장
                        _currentUrl = url?.toString();
                      },
                      onCreateWindow: (controller, createWindowAction) async {
                        // window.open 이벤트 처리 - 새 창을 새로운 WebView에서 열기
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewWindowWebView(
                              url:
                                  createWindowAction.request.url?.toString() ??
                                  '',
                            ),
                          ),
                        );
                        return true;
                      },
                    ),
                    // WebView 로딩 화면
                    if (isWebViewLoading)
                      Container(
                        color: bgColor,
                        child: Column(
                          children: [
                            // AppHeader 추가
                            AppHeader(),
                            // 로딩 컨텐츠
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        mainGreen,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      '로딩 중...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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
