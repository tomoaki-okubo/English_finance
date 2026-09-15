import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF0F62FE); // ITプロフェッショナルブルー
  static const _secondaryColor = Color(0xFF00D2FF); // ネオンシアン
  static const _backgroundColorLight = Color(0xFFF8F9FA);
  static const _surfaceColorLight = Color(0xFFFFFFFF);

  static const _backgroundColorDark = Color(0xFF0D1117); // GitHub Dark風
  static const _surfaceColorDark = Color(0xFF161B22);

  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColorLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _backgroundColorLight,
      textTheme: GoogleFonts.interTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColorDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _backgroundColorDark,
      textTheme: GoogleFonts.interTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF30363D)),
        ),
      ),
    );
  }
}
