import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors (Warm, inviting food theme)
  static const Color primary = Color(0xFFFF5722); // Warm Coral Orange
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primaryLight = Color(0xFFFFCCBC);
  static const Color primaryContainerLight = Color(0xFFFFF0EB);
  static const Color primaryContainerDark = Color(0xFF3E2218);

  static const Color secondary = Color(0xFFFFA000); // Warm Amber
  static const Color secondaryContainerLight = Color(0xFFFFF8E1);
  static const Color secondaryContainerDark = Color(0xFF362B10);

  // Light theme surfaces & text
  static const Color backgroundLight = Color(0xFFFBF9F6); // Soft Warm Ivory
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardColorLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E2022);
  static const Color textSecondaryLight = Color(0xFF686D76);
  static const Color textMutedLight = Color(0xFF9BA4B5);
  static const Color dividerColorLight = Color(0xFFEEEEEE);
  static const Color cardBorderLight = Color(0xFFEFEFEF);

  // Dark theme surfaces & text
  static const Color backgroundDark = Color(0xFF121418);
  static const Color surfaceDark = Color(0xFF1D2128);
  static const Color cardColorDark = Color(0xFF1D2128);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFFA0A6B2);
  static const Color textMutedDark = Color(0xFF6B7280);
  static const Color dividerColorDark = Color(0xFF2C323D);
  static const Color cardBorderDark = Color(0xFF2C323D);

  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFE53935);

  // Backwards compatibility shortcuts (defaulting to light values)
  static const Color primaryContainer = primaryContainerLight;
  static const Color secondaryContainer = secondaryContainerLight;
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color cardColor = cardColorLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textMuted = textMutedLight;
  static const Color dividerColor = dividerColorLight;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerLight,
        onPrimaryContainer: primaryDark,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainerLight,
        onSecondaryContainer: Color(0xFFE65100),
        error: accentRed,
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimaryLight,
        surfaceContainerHighest: Color(0xFFF2EFEB),
        outline: Color(0xFFE0E0E0),
        outlineVariant: dividerColorLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: cardColorLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withAlpha(80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.center,
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryContainerLight,
        disabledColor: const Color(0xFFF5F5F5),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimaryLight,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: primaryDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColorLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFFF7043),
        onPrimary: Colors.black,
        primaryContainer: primaryContainerDark,
        onPrimaryContainer: Color(0xFFFFCCBC),
        secondary: secondary,
        onSecondary: Colors.black,
        secondaryContainer: secondaryContainerDark,
        onSecondaryContainer: Color(0xFFFFE082),
        error: accentRed,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: Color(0xFF262B34),
        outline: Color(0xFF3F4756),
        outlineVariant: dividerColorDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: cardColorDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          backgroundColor: const Color(0xFFFF6434),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.center,
          foregroundColor: const Color(0xFFFF8A65),
          side: const BorderSide(color: Color(0xFFFF7043), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryContainerDark,
        disabledColor: const Color(0xFF262B34),
        side: const BorderSide(color: Color(0xFF39404E), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimaryDark,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFAB91),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColorDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
