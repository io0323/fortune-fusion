import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFF0B1026);
  static const surface = Color(0xFF161B33);
  static const primary = Color(0xFFC9A961);
  static const secondary = Color(0xFF6B7AA8);
  static const onBackground = Color(0xFFE8DCC8);
  static const onSurface = Color(0xFFD4C9B0);
  static const onPrimary = Color(0xFF0B1026);
  static const surfaceVariant = Color(0xFF1E2440);
  static const outline = Color(0xFF4A5270);

  static const wood = Color(0xFF5B8C5A);
  static const fire = Color(0xFFC25450);
  static const earth = Color(0xFFC9A961);
  static const metal = Color(0xFFD4D4D4);
  static const water = Color(0xFF4A6FA5);
}

abstract final class AppTheme {
  static TextTheme _buildTextTheme(Color baseColor) => TextTheme(
        displayLarge: GoogleFonts.notoSerifJp(
            fontSize: 57, color: baseColor, fontWeight: FontWeight.w400),
        displayMedium: GoogleFonts.notoSerifJp(
            fontSize: 45, color: baseColor, fontWeight: FontWeight.w400),
        displaySmall: GoogleFonts.notoSerifJp(
            fontSize: 36, color: baseColor, fontWeight: FontWeight.w400),
        headlineLarge: GoogleFonts.notoSerifJp(
            fontSize: 32, color: baseColor, fontWeight: FontWeight.w400),
        headlineMedium: GoogleFonts.notoSerifJp(
            fontSize: 28, color: baseColor, fontWeight: FontWeight.w400),
        headlineSmall: GoogleFonts.notoSerifJp(
            fontSize: 24, color: baseColor, fontWeight: FontWeight.w400),
        titleLarge: GoogleFonts.notoSerifJp(
            fontSize: 22, color: baseColor, fontWeight: FontWeight.w500),
        titleMedium: GoogleFonts.notoSansJp(
            fontSize: 16, color: baseColor, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.notoSansJp(
            fontSize: 14, color: baseColor, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.notoSansJp(fontSize: 16, color: baseColor),
        bodyMedium: GoogleFonts.notoSansJp(fontSize: 14, color: baseColor),
        bodySmall: GoogleFonts.notoSansJp(fontSize: 12, color: baseColor),
        labelLarge: GoogleFonts.notoSansJp(
            fontSize: 14, color: baseColor, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.notoSansJp(
            fontSize: 12, color: baseColor, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.notoSansJp(
            fontSize: 11, color: baseColor, fontWeight: FontWeight.w500),
      );

  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: Color(0xFFCF6679),
      onError: Color(0xFF370B1E),
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: Color(0xFFBFB9A8),
      outline: AppColors.outline,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(AppColors.onBackground),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Color(0x33C9A961),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x33C9A961), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x55C9A961)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x55C9A961)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        labelStyle: const TextStyle(color: AppColors.secondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x33C9A961),
        thickness: 1,
      ),
    );
  }

  static ThemeData get light {
    const lightPrimary = Color(0xFF8B6914);
    const lightBg = Color(0xFFF5F0E8);
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Colors.white,
      secondary: Color(0xFF3D5080),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFFAF7F0),
      onSurface: Color(0xFF1C1B1F),
      surfaceContainerHighest: Color(0xFFEDE8D8),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF79747E),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: lightBg,
      textTheme: _buildTextTheme(const Color(0xFF1C1B1F)),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerifJp(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: lightPrimary,
        ),
        iconTheme: const IconThemeData(color: lightPrimary),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFFFAF7F0),
        indicatorColor: Color(0x338B6914),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEDE8D8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x558B6914)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x558B6914)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF3D5080)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
