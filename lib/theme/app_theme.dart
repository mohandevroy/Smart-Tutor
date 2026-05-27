import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color background = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFF6B7280);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: white,
      error: danger,
    ),

    fontFamily: 'Roboto',

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w900,
      ),
      titleMedium: TextStyle(
        color: textDark,
        fontWeight: FontWeight.w800,
      ),
      bodyMedium: TextStyle(
        color: textDark,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        color: textLight,
        height: 1.35,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      foregroundColor: textDark,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: border),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    ),

    // ✅ FIXED HERE (CardTheme → CardThemeData)
    cardTheme: const CardThemeData(
      color: white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: border),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
