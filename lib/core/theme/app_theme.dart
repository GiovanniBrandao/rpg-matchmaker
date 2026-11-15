// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Cores do Modo Escuro (Taverna)
  static const Color backgroundDark = Color(0xFF14100E);
  static const Color surfaceDark = Color(0xFF221A15);
  static const Color cardDark = Color(0xFF2D221C);

  // Cores do Modo Claro (Pergaminho e Madeira)
  static const Color backgroundLight = Color(0xFFF4ECD8); // Pergaminho claro
  static const Color surfaceLight = Color(0xFFE8DCC4); // Painel pergaminho
  static const Color cardLight = Color(0xFFDFD0B5); // Card pergaminho escuro
  static const Color textDark = Color(0xFF2A1E17); // Tinta/Madeira escura
  static const Color subtextDark = Color(0xFF5A483C); // Texto secundário

  // Cores de Destaque (Taverna)
  static const Color goldPrimary = Color(0xFFE5A93B); // Ouro / Âmbar
  static const Color copperSecondary = Color(
    0xFF874B01,
  ); // Madeira nobre / Bronze
  static const Color errorRed = Color(0xFFB33A3A);

  // Aliases de compatibilidade para telas que referenciam as constantes antigas
  static const Color primaryColor = copperSecondary;
  static const Color primaryBright = Color(0xFFD97706);
  static const Color secondaryColor = Color(0xFFFFD700);
  static const Color backgroundColor = Color.fromARGB(255, 247, 161, 31);
  static const Color surfaceColor = Color.fromARGB(255, 208, 114, 6);
  static const Color cardColor = cardDark;
  static const Color darkBackground = backgroundDark;
  static const Color darkSurface = surfaceDark;
  static const Color darkSurfaceElevated = cardDark;
  static const Color lightBackground = backgroundLight;
  static const Color lightSurface = surfaceLight;
  static const Color errorColor = errorRed;

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
    },
  );

  // ================= TEMA CLARO (PERGAMINHO DE TAVERNA) =================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      pageTransitionsTheme: _pageTransitions,

      colorScheme: const ColorScheme.light(
        primary: copperSecondary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD4B896),
        onPrimaryContainer: textDark,
        secondary: goldPrimary,
        onSecondary: textDark,
        secondaryContainer: Color(0xFFE2CBAB),
        onSecondaryContainer: textDark,
        surface: surfaceLight,
        onSurface: textDark,
        onSurfaceVariant: subtextDark,
        surfaceContainerHighest: cardLight,
        error: errorRed,
        onError: Colors.white,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: copperSecondary,
        selectionColor: goldPrimary.withValues(alpha: 0.4),
        selectionHandleColor: copperSecondary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: copperSecondary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: 1.2,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 1.5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: subtextDark, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: copperSecondary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: copperSecondary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: copperSecondary.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: copperSecondary, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: copperSecondary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cardLight,
        selectedColor: goldPrimary,
        disabledColor: surfaceLight,
        checkmarkColor: textDark,
        labelStyle: const TextStyle(color: textDark, fontSize: 13),
        secondaryLabelStyle: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        side: const BorderSide(color: copperSecondary, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: goldPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: copperSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(color: subtextDark, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: textDark);
          }
          return const IconThemeData(color: subtextDark);
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return copperSecondary;
          return subtextDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return goldPrimary;
          return cardLight;
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================= TEMA ESCURO (MADEIRA NEGRA E COURO) =================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      pageTransitionsTheme: _pageTransitions,

      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        onPrimary: Color(0xFF1A1000),
        primaryContainer: Color(0xFF5A3200),
        onPrimaryContainer: Color(0xFFFFDEA8),
        secondary: copperSecondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF4B3800),
        onSecondaryContainer: Color(0xFFFFE082),
        surface: surfaceDark,
        onSurface: Color(0xFFF5E6C8),
        onSurfaceVariant: Color(0xFFC5B598),
        surfaceContainerHighest: cardDark,
        error: errorRed,
        onError: Colors.white,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: goldPrimary,
        selectionColor: goldPrimary.withValues(alpha: 0.3),
        selectionHandleColor: goldPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: goldPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF5E6C8),
          letterSpacing: 1.2,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white10),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: Color(0xFFC5B598), fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: goldPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: copperSecondary, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: copperSecondary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: const Color(0xFF1A1000),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: goldPrimary,
        disabledColor: surfaceDark,
        checkmarkColor: const Color(0xFF1A1000),
        labelStyle: const TextStyle(color: Color(0xFFF5E6C8), fontSize: 13),
        secondaryLabelStyle: const TextStyle(
          color: Color(0xFF1A1000),
          fontWeight: FontWeight.bold,
        ),
        side: const BorderSide(color: copperSecondary, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: goldPrimary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: goldPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            );
          }
          return const TextStyle(color: Color(0xFFC5B598), fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF1A1000));
          }
          return const IconThemeData(color: Color(0xFFC5B598));
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return goldPrimary;
          return const Color(0xFFC5B598);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return copperSecondary;
          return cardDark;
        }),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
