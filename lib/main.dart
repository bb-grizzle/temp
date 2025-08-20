import 'package:every_football/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 위치 권한 요청
  PermissionStatus status = await Permission.location.request();

  // 권한이 허용된 경우에만 위치 정보 가져오기
  Position? position;
  if (status.isGranted) {
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print('위치 정보를 가져올 수 없습니다: $e');
    }
  }

  runApp(MyApp(position: position));
}

class MyApp extends StatelessWidget {
  final Position? position;

  const MyApp({super.key, this.position});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff282828)),
      home: WebViewScreen(position: position),
    );
  }
}
