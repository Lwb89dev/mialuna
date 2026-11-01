import 'package:flutter/material.dart';

/// Mialuna brand palette — a Mediterranean evening.
abstract final class MialunaColors {
  static const midnightNavy = Color(0xFF20243D);
  static const moonlightCream = Color(0xFFFFF3DF);
  static const twilightRose = Color(0xFFEFA1AC);
  static const mutedLavender = Color(0xFFA49BBE);
  static const warmOffWhite = Color(0xFFFBF8F5);
  static const darkCharcoal = Color(0xFF24222D);
}

abstract final class MialunaTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: MialunaColors.midnightNavy,
          brightness: Brightness.light,
          surface: MialunaColors.warmOffWhite,
        ).copyWith(
          primary: MialunaColors.midnightNavy,
          secondary: MialunaColors.twilightRose,
          tertiary: MialunaColors.mutedLavender,
          surface: MialunaColors.warmOffWhite,
        );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: MialunaColors.warmOffWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: MialunaColors.warmOffWhite,
        foregroundColor: MialunaColors.midnightNavy,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: MialunaColors.twilightRose,
          brightness: Brightness.dark,
          surface: MialunaColors.darkCharcoal,
        ).copyWith(
          primary: MialunaColors.moonlightCream,
          secondary: MialunaColors.twilightRose,
          tertiary: MialunaColors.mutedLavender,
          surface: MialunaColors.darkCharcoal,
        );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: MialunaColors.darkCharcoal,
      appBarTheme: const AppBarTheme(
        backgroundColor: MialunaColors.darkCharcoal,
        foregroundColor: MialunaColors.moonlightCream,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) => ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.outline,
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
