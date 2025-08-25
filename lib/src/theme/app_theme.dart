import 'package:flutter/material.dart';

class AppTheme {
  // Paleta propuesta
  static const Color _primaryYellow = Color(0xFFFFD600); // Amarillo vibrante
  static const Color _secondaryOrange = Color(0xFFFF8F00); // Naranja cálido
  static const Color _tertiaryPink = Color(0xFFF06292); // Rosa suave
  static const Color _lightBackground = Color(0xFFFFFDE7); // Fondo pastel

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryYellow,
      onPrimary: Colors.black,
      secondary: _secondaryOrange,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      primaryContainer: Color(0xFFFFECB3), // Amarillo suave
      onPrimaryContainer: Colors.black,
      secondaryContainer: Color(0xFFFFE0B2), // Naranja suave
      onSecondaryContainer: Colors.black,

      // ✅ Reemplazo: antes usabas surfaceVariant (DEPRECATED)
      // Ahora definimos surfaceContainerHighest para roles de contenedor.
      surfaceContainerHighest: Color(0xFFFFF9C4),

      onSurfaceVariant: Colors.black87,
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      shadow: Colors.black26,
      scrim: Colors.black38,
      inverseSurface: Color(0xFF333333),
      onInverseSurface: Colors.white,
      inversePrimary: _primaryYellow,
      surfaceTint: _primaryYellow,
      tertiary: _tertiaryPink,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF8BBD0),
      onTertiaryContainer: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryYellow,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryYellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _tertiaryPink,
          side: const BorderSide(color: _tertiaryPink),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _secondaryOrange),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: Colors.black),
        backgroundColor: _primaryYellow.withValues(alpha: 0.8),
        selectedColor: _secondaryOrange,
        secondarySelectedColor: _tertiaryPink,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),

      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: _lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _secondaryOrange),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _tertiaryPink, width: 2),
        ),
        filled: true,
        fillColor: _lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _secondaryOrange,
        contentTextStyle: TextStyle(color: Colors.white),
        actionTextColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: _primaryYellow,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(color: Colors.black54),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
