// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de Cores Principais (Identidade Visual Taverna / RPG)
  static const Color primaryColor = Color.fromARGB(255, 135, 75, 1); // Âmbar escuro / Couro
  static const Color primaryBright = Color(0xFFD97706); // Âmbar vibrante p/ contraste no escuro
  static const Color secondaryColor = Color(0xFFFFD700); // Ouro
  static const Color backgroundColor = Color.fromARGB(255, 247, 161, 31); // Laranja Taverna
  static const Color surfaceColor = Color.fromARGB(255, 208, 114, 6);
  static const Color cardColor = Color(0xFF2A2A32);
  static const Color darkBackground = Color.fromARGB(255, 24, 22, 19);
  static const Color darkSurface = Color(0xFF282520);
  static const Color darkSurfaceElevated = Color(0xFF343029);
  static const Color lightBackground = Color(0xFFFFF8EE); // Pergaminho claro (IHC: contraste WCAG)
  static const Color lightSurface = Color(0xFFF6E7CE);
  static const Color errorColor = Color.fromARGB(239, 215, 5, 5);

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDEA8),
      onPrimaryContainer: Color(0xFF2B1700),
      secondary: Color(0xFFB45309),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFECB3),
      onSecondaryContainer: Color(0xFF332200),
      surface: lightSurface,
      onSurface: Color(0xFF221B12),
      surfaceContainerHighest: Color(0xFFEAD4B0),
      onSurfaceVariant: Color(0xFF5C4A32),
      error: errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: scheme,
      pageTransitionsTheme: _pageTransitions,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8C29D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8C29D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF5C4A32), fontWeight: FontWeight.w500),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3E2C3),
        selectedColor: secondaryColor,
        checkmarkColor: const Color(0xFF2B1700),
        labelStyle: const TextStyle(color: Color(0xFF2B1700), fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF2B1700), fontWeight: FontWeight.bold),
        side: const BorderSide(color: Color(0xFFD8C29D)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFF6E7CE),
        indicatorColor: primaryColor.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? primaryColor : const Color(0xFF5C4A32),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: primaryBright,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF5A3200),
      onPrimaryContainer: Color(0xFFFFDEA8),
      secondary: secondaryColor,
      onSecondary: Color(0xFF261900),
      secondaryContainer: Color(0xFF4B3800),
      onSecondaryContainer: Color(0xFFFFE082),
      surface: darkSurface,
      onSurface: Color(0xFFF5EFE6),
      surfaceContainerHighest: darkSurfaceElevated,
      onSurfaceVariant: Color(0xFFD0C4B2),
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: scheme,
      pageTransitionsTheme: _pageTransitions,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF231D16),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFFD0C4B2)),
        floatingLabelStyle: const TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBright,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        selectedColor: secondaryColor,
        checkmarkColor: const Color(0xFF261900),
        labelStyle: const TextStyle(color: Color(0xFFF5EFE6), fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF261900), fontWeight: FontWeight.bold),
        side: const BorderSide(color: Colors.white12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF211E1A),
        indicatorColor: primaryBright.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? secondaryColor : const Color(0xFFD0C4B2),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
