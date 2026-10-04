import 'package:flutter/material.dart';

/// Meezan-style brand palette (original approximation — not official assets).
class MColors {
  static const Color green = Color(0xFF00543D);
  static const Color greenDark = Color(0xFF003D2C);
  static const Color greenDeep = Color(0xFF012B1F);
  static const Color greenBright = Color(0xFF2E8B63);
  static const Color gold = Color(0xFFC6A45C);
  static const Color goldDeep = Color(0xFFB98F45);
  static const Color goldSoft = Color(0xFFEFE4CB);
  static const Color bg = Color(0xFFF4F6F3);
  static const Color ink = Color(0xFF17251D);
  static const Color subtle = Color(0xFF6B7A70);
  static const Color danger = Color(0xFFC0392B);
  static const Color darkBg = Color(0xFF0D1411);
  static const Color darkCard = Color(0xFF15201A);
  static const Color darkField = Color(0xFF1B2A22);
  static const Color darkLine = Color(0xFF2A3B31);
}

ThemeData buildTheme({required bool dark}) {
  final ColorScheme scheme = dark
      ? const ColorScheme.dark(
          primary: MColors.greenBright,
          onPrimary: Colors.white,
          secondary: MColors.gold,
          onSecondary: MColors.ink,
          surface: MColors.darkCard,
          onSurface: Colors.white,
          error: Color(0xFFE57373),
          onError: Colors.white,
        )
      : const ColorScheme.light(
          primary: MColors.green,
          onPrimary: Colors.white,
          secondary: MColors.goldDeep,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: MColors.ink,
          error: MColors.danger,
          onError: Colors.white,
        );

  final Color fieldFill = dark ? MColors.darkField : Colors.white;
  final Color line = dark ? MColors.darkLine : const Color(0xFFE2E8E4);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? MColors.darkBg : MColors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: fieldFill,
      hintStyle: TextStyle(color: MColors.subtle.withOpacity(0.8)),
      labelStyle: const TextStyle(color: MColors.subtle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? MColors.darkCard : Colors.white,
      indicatorColor: scheme.primary.withOpacity(0.14),
      height: 68,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white70 : MColors.ink,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.primary);
        }
        return IconThemeData(color: MColors.subtle);
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: scheme.primary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? const Color(0xFF233129) : MColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    cardTheme: CardTheme(
      color: dark ? MColors.darkCard : Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: line),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? MColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
  );
}
