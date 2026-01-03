import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Deep Space
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color primaryBlue = Color(0xFF1B263B);
  static const Color primaryLight = Color(0xFF415A77);
  
  // Secondary Colors - Cream/Warm
  static const Color secondaryCream = Color(0xFFFFF8E1);
  static const Color creamLight = Color(0xFFFFFDE7);
  
  // Accent Colors - Gold (Premium feel)
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFE8D5A3);
  static const Color accentGoldDark = Color(0xFFB8960C);
  
  // Cosmic Colors
  static const Color cosmicPurple = Color(0xFF667EEA);
  static const Color cosmicViolet = Color(0xFF764BA2);
  static const Color cosmicPink = Color(0xFFF093FB);
  static const Color cosmicBlue = Color(0xFF4FACFE);
  static const Color cosmicTeal = Color(0xFF00F2FE);
  
  // Gradient Presets
  static const List<Color> sunriseGradient = [Color(0xFFFF6B6B), Color(0xFFFF8E53)];
  static const List<Color> oceanGradient = [Color(0xFF4ECDC4), Color(0xFF556270)];
  static const List<Color> purpleGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const List<Color> pinkGradient = [Color(0xFFF093FB), Color(0xFFF5576C)];
  static const List<Color> goldGradient = [Color(0xFFD4AF37), Color(0xFFE8D5A3)];
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0D1120);
  static const Color backgroundDarkAlt = Color(0xFF1A1F3C);
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E2E);
  static const Color cardDarkAlt = Color(0xFF2D3A4A);
  
  // Status Colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  // Zodiac Colors
  static const Map<String, Color> zodiacColors = {
    'Aries': Color(0xFFE53935),
    'Taurus': Color(0xFF43A047),
    'Gemini': Color(0xFFFDD835),
    'Cancer': Color(0xFF90CAF9),
    'Leo': Color(0xFFFF9800),
    'Virgo': Color(0xFF8D6E63),
    'Libra': Color(0xFFEC407A),
    'Scorpio': Color(0xFF7B1FA2),
    'Sagittarius': Color(0xFF5C6BC0),
    'Capricorn': Color(0xFF455A64),
    'Aquarius': Color(0xFF00ACC1),
    'Pisces': Color(0xFF26A69A),
  };

  // Planet Colors
  static const Map<String, Color> planetColors = {
    'Sun': Color(0xFFFF9800),
    'Moon': Color(0xFFE0E0E0),
    'Mars': Color(0xFFF44336),
    'Mercury': Color(0xFF4CAF50),
    'Jupiter': Color(0xFFFFEB3B),
    'Venus': Color(0xFFE91E63),
    'Saturn': Color(0xFF607D8B),
    'Rahu': Color(0xFF3F51B5),
    'Ketu': Color(0xFF795548),
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.light,
      primaryColor: primaryNavy,
      colorScheme: ColorScheme.light(
        primary: primaryNavy,
        secondary: accentGold,
        surface: backgroundLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: primaryNavy,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: creamLight,
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryNavy,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.3),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: BorderSide(color: accentGold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentGold.withOpacity(0.1),
        selectedColor: accentGold,
        labelStyle: TextStyle(color: primaryNavy),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryNavy,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
      primaryColor: primaryLight,
      colorScheme: ColorScheme.dark(
        primary: primaryLight,
        secondary: accentGold,
        surface: backgroundDark,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: primaryNavy,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDarkAlt,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryNavy,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGold,
          side: BorderSide(color: accentGold, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentGold.withOpacity(0.15),
        selectedColor: accentGold,
        labelStyle: TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryNavy,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
      ),
    );
  }

  // Utility gradients
  static BoxDecoration get cosmicBackground => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0D1B2A),
        Color(0xFF1B263B),
        Color(0xFF415A77),
      ],
    ),
  );

  static BoxDecoration get goldAccentCard => BoxDecoration(
    gradient: LinearGradient(
      colors: goldGradient,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: accentGold.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  );
}
