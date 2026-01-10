import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Color Palette
  static const Color frenchBlue = Color(0xFF274690); // Primary
  static const Color apricot = Color(0xFFFFB74D); // Secondary FFB74D
  static const Color aliceBlue = Color(0xFFE8EEF2); // Background
  static const Color alabasterGrey = Color(
    0xFFDBDBDB,
  ); // Borders/Surface Variant
  static const Color evergreen = Color(0xFF00241B); // Dark Accent/SnackBar

  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // Semantic Aliases
  static const Color primary = frenchBlue;
  static const Color secondary = apricot;
  static const Color background = aliceBlue;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        background: background,
        tertiary: evergreen, // Useful for specialized accents
      ),
      textTheme: GoogleFonts.latoTextTheme(),
      scaffoldBackgroundColor: background,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // For iOS
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: Colors.white,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: evergreen, // Updated to Evergreen
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: alabasterGrey,
          ), // Use Alabaster for borders
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: alabasterGrey,
          ), // Use Alabaster for borders
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error),
        ),
      ),
    );
  }
}
