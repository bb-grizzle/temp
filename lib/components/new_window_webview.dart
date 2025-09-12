import 'package:every_football/data/const.dart';
import 'package:every_football/components/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class NewWindowWebView extends StatefulWidget {
  final String url;

  const NewWindowWebView({super.key, required this.url});

  @override
  State<NewWindowWebView> createState() => _NewWindowWebViewState();
}

class _NewWindowWebViewState extends State<NewWindowWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // AppHeader 사용
                AppHeader(),
                // WebView 영역
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        initialSettings: _webViewSettings,
                        key: webViewKey,
                        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async =>
                                NavigationActionPolicy.ALLOW,
                        onLoadStart: (controller, url) {
                          setState(() {
                            isLoading = true;
                          });
                        },
                        onLoadStop: (controller, url) async {
                          setState(() {
                            isLoading = false;
                          });

                          // 뒤로가기/앞으로가기 버튼 상태 업데이트
                          final canBack = await controller.canGoBack();
                          final canForward = await controller.canGoForward();
                          setState(() {
                            canGoBack = canBack;
                            canGoForward = canForward;
                          });
                        },
                        onCreateWindow: (controller, createWindowAction) async {
                          // 새창에서 또 다른 새창을 열 때는 현재 창에서 열기
                          await controller.loadUrl(
                            urlRequest: URLRequest(
                              url: createWindowAction.request.url,
                            ),
                          );
                          return true;
                        },
                      ),
                      if (isLoading)
                        Container(
                          color: bgColor,
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
          // 좌측 하단 뒤로가기 버튼
          Positioned(
            left: 32,
            bottom: 64,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderGray, width: 1),
              ),
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: bgColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
