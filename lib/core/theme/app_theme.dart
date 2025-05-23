import 'package:flutter/material.dart';

/// Theme configuration for the app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Brand Colors
  static const Color primaryColor = Color(0xFF3E63E4); // Blue
  static const Color secondaryColor = Color(0xFFFFAE00); // Gold accent
  static const Color accentColor = Color(0xFF00B2FF); // Light blue for accents
  
  // Background colors
  static const Color scaffoldBackgroundColor = Color(0xFF121212); // Dark background
  static const Color cardColor = Color(0xFF1E1E1E); // Slightly lighter dark
  static const Color surfaceColor = Color(0xFF252525); // Surface components
  
  // Text Colors
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White
  static const Color secondaryTextColor = Color(0xFFB0B0B0); // Light grey
  static const Color disabledTextColor = Color(0xFF757575); // Darker grey
  
  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color infoColor = accentColor; // Use accent blue

  // Gradient colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF2845C3)],
  );
  
  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFF0095D5)],
  );
  
  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFFFFC846)],
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardColor: cardColor,
    canvasColor: surfaceColor,
    dividerColor: Colors.white12,
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primaryTextColor),
      bodyMedium: TextStyle(color: primaryTextColor),
      bodySmall: TextStyle(color: secondaryTextColor),
      labelLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
    ),
    
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, 
        backgroundColor: primaryColor,
        minimumSize: const Size(88, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(88, 48),
        side: BorderSide(color: primaryColor.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    
    // Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
      hintStyle: const TextStyle(color: disabledTextColor),
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: cardColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryTextColor),
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    
    // Bottom Navigation Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Tab Bar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: secondaryTextColor,
      indicatorColor: primaryColor,
    ),
    
    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: primaryColor.withOpacity(0.3),
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.2),
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: secondaryTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade700;
      }),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      disabledColor: surfaceColor.withOpacity(0.5),
      selectedColor: primaryColor,
      secondarySelectedColor: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: const TextStyle(color: primaryTextColor),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      circularTrackColor: surfaceColor,
      linearTrackColor: surfaceColor,
    ),
  );
} 