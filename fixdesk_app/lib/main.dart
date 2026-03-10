import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'login/login_page.dart';
import 'service/api_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initSupabase();
  runApp(FixDeskApp());
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