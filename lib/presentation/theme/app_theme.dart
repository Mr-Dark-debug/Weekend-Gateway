import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neo-brutalist Design Colors
  static const Color primaryBackground = Colors.white;
  static const Color primaryForeground = Colors.black;
  static const Color primaryAccent = Color(0xFFFF0000); // Bold Red
  static const Color secondaryAccent = Color(0xFFFFFF00); // Bold Yellow
  
  // Border styles
  static const double borderWidth = 3.0;
  static const double buttonBorderWidth = 3.0;
  
  // Get theme data
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryAccent,
        onPrimary: primaryBackground,
        primaryContainer: primaryBackground,
        onPrimaryContainer: primaryForeground,
        secondary: secondaryAccent,
        onSecondary: primaryForeground,
        secondaryContainer: secondaryAccent,
        onSecondaryContainer: primaryForeground,
        error: Colors.red,
        onError: primaryBackground,
        errorContainer: Colors.red.shade100,
        onErrorContainer: Colors.red.shade900,
        background: primaryBackground,
        onBackground: primaryForeground,
        surface: primaryBackground,
        onSurface: primaryForeground,
        surfaceVariant: Colors.grey.shade100,
        onSurfaceVariant: primaryForeground,
        outline: primaryForeground,
        outlineVariant: Colors.grey.shade700,
        shadow: primaryForeground,
        scrim: Colors.black.withOpacity(0.3),
        inverseSurface: primaryForeground,
        onInverseSurface: primaryBackground,
        inversePrimary: primaryAccent,
      ),
      
      // Typography with monospace font
      textTheme: GoogleFonts.robotoMonoTextTheme().copyWith(
        displayLarge: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: primaryForeground,
        ),
        displayMedium: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: primaryForeground,
        ),
        displaySmall: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: primaryForeground,
        ),
        headlineMedium: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: primaryForeground,
        ),
        headlineSmall: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: primaryForeground,
        ),
        titleLarge: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: primaryForeground,
        ),
        bodyLarge: GoogleFonts.robotoMono(
          fontSize: 16,
          color: primaryForeground,
        ),
        bodyMedium: GoogleFonts.robotoMono(
          fontSize: 14,
          color: primaryForeground,
        ),
        bodySmall: GoogleFonts.robotoMono(
          fontSize: 12,
          color: primaryForeground,
        ),
        labelLarge: GoogleFonts.robotoMono(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: primaryForeground,
        ),
      ),
      
      // Apply neo-brutalist styling to various components
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: primaryForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: primaryForeground,
        ),
      ),
      
      // No rounded corners for buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: primaryBackground,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(
              color: primaryForeground,
              width: buttonBorderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Text buttons (secondary actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryForeground,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryForeground,
          side: const BorderSide(
            color: primaryForeground,
            width: buttonBorderWidth,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 16,
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Input decoration (for TextFields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(
            color: primaryForeground,
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(
            color: primaryForeground,
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: primaryAccent,
            width: borderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Colors.red,
            width: borderWidth,
          ),
        ),
        labelStyle: TextStyle(
          fontFamily: 'RobotoMono',
          color: Colors.grey.shade700,
        ),
        hintStyle: TextStyle(
          fontFamily: 'RobotoMono',
          color: Colors.grey.shade500,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: primaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            color: primaryForeground,
            width: borderWidth,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryAccent;
          }
          return null;
        }),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: const BorderSide(
          color: primaryForeground,
          width: 2,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryBackground,
        selectedItemColor: primaryAccent,
        unselectedItemColor: primaryForeground,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
        ),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: primaryForeground,
        thickness: 2,
        space: 24,
      ),
      
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: primaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(
            color: primaryForeground,
            width: borderWidth,
          ),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: primaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: primaryForeground,
            width: borderWidth,
          ),
        ),
      ),
    );
  }
} 