import 'package:flutter/material.dart';

class ThemeConfig {
  // App Colors (default)
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);

  // Retro mode colors (warm amber / vintage TV)
  static const Color retroBackground = Color(0xFF1A1510);
  static const Color retroSurface = Color(0xFF2D2218);
  static const Color retroPrimary = Color(0xFFFFB300);
  static const Color retroSecondary = Color(0xFFFFF8E1);
  static const Color retroTextPrimary = Color(0xFFFFF8E1);
  static const Color retroTextSecondary = Color(0xFFBCAAA4);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Dark Theme (Recommended for IPTV)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary),
        displayMedium: TextStyle(color: textPrimary),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
    );
  }

  /// Retro mode theme - warm amber/gold on dark brown, applied to all pages.
  static ThemeData get retroTheme {
    const colorScheme = ColorScheme.dark(
      primary: retroPrimary,
      onPrimary: Color(0xFF1A1510),
      secondary: retroSecondary,
      onSecondary: Color(0xFF1A1510),
      surface: retroSurface,
      onSurface: retroTextPrimary,
      error: Color(0xFFCF6679),
      onError: Color(0xFF1A1510),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: retroBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: retroBackground,
        foregroundColor: retroTextPrimary,
        titleTextStyle: TextStyle(
          color: retroTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: retroSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: retroTextPrimary),
        displayMedium: TextStyle(color: retroTextPrimary),
        headlineMedium: TextStyle(color: retroTextPrimary),
        titleLarge: TextStyle(color: retroTextPrimary),
        titleMedium: TextStyle(color: retroTextPrimary),
        bodyLarge: TextStyle(color: retroTextPrimary),
        bodyMedium: TextStyle(color: retroTextSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: retroPrimary,
          foregroundColor: retroBackground,
        ),
      ),
    );
  }
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}
