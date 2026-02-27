import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  await Supabase.initialize(
    url: 'https://zokyojxouidgentyjonr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpva3lvanhvdWlkZ2VudHlqb25yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTI0NzksImV4cCI6MjA4NzY4ODQ3OX0.talylYsvoL3VRGH3Wltl7RaXnU9dRn-3zD6MCcchoP0',
  );
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