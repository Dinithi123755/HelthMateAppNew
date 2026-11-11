import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF087F71);
  static const ink = Color(0xFF19342F);
  static const muted = Color(0xFF5D726D);
  static const background = Color(0xFFF3F7F5);
  static const line = Color(0xFFDCE7E2);
  static const steps = Color(0xFF087F71);
  static const calories = Color(0xFFBD5035);
  static const water = Color(0xFF326DC3);
  static Color metric(BuildContext context, Color color) {
    if (Theme.of(context).brightness != Brightness.dark) return color;
    if (color == steps) return const Color(0xFF74D9C7);
    if (color == calories) return const Color(0xFFFFAA8F);
    return const Color(0xFF91BBFF);
  }
}

ThemeData appTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? const Color(0xFF192D29) : Colors.white;
  final ink = dark ? const Color(0xFFE5F1EC) : AppColors.ink;
  final muted = dark ? const Color(0xFFA8BFB6) : AppColors.muted;
  final line = dark ? const Color(0xFF365048) : AppColors.line;
  final primary = dark ? const Color(0xFF74D9C7) : AppColors.primary;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ).copyWith(
        primary: primary,
        onPrimary: dark ? const Color(0xFF00382F) : Colors.white,
        surface: surface,
        onSurface: ink,
        onSurfaceVariant: muted,
        outlineVariant: line,
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    scaffoldBackgroundColor: dark
        ? const Color(0xFF101E1B)
        : AppColors.background,
    textTheme: base.textTheme.copyWith(
      headlineSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -.4,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        height: 1.45,
        color: ink,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: surface,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 68,
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIconColor: primary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        textStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: surface,
        minimumSize: const Size(48, 48),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: dark ? const Color(0xFF294E44) : const Color(0xFFD9EEE8),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? primary : muted,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: TextStyle(fontFamily: 'Roboto', color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
