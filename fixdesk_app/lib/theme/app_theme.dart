import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E48D1);

  static const Color pendingColor = Color(0xFFF59E0B);

  static const Color progressColor = Color(0xFF3B82F6);

  static const Color doneColor = Color(0xFF22C55E);

  static const Color urgentHigh = Color(0xFFF8D7DA);

  static const Color urgentMedium = Color(0xFFFCE8C3);

  static const Color urgentLow = Color(0xFFD1F3E0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
    ),

    scaffoldBackgroundColor: const Color(0xfff3f4f6),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
