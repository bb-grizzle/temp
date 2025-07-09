import 'package:every_football/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Every Football',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WebViewScreen(),
    );
  }
}
