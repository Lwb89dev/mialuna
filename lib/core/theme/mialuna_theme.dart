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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
      color: scheme.brightness == Brightness.dark
          ? Color.alphaBlend(
              scheme.onSurface.withValues(alpha: 0.035),
              scheme.surface,
            )
          : scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surface,
      selectedColor: scheme.primary.withValues(alpha: 0.08),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.45),
      thickness: 0.5,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: scheme.surface,
      elevation: 0,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.outline,
      showUnselectedLabels: false,
      showSelectedLabels: false,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
