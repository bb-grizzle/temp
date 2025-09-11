import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      color: Color(0xFF2B2B2B),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/logo/logo-title.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
