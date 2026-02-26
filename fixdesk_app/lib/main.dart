import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const FixDeskApp());
}

class FixDeskApp extends StatelessWidget {
  const FixDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}