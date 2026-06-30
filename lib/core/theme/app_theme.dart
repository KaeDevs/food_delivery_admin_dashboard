import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: kSeedColor,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFF1EB), // Soft warm orange accent
          onPrimaryContainer: kSeedColor,
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A), // Slate 900
          surfaceContainerHighest: const Color(0xFFF1F5F9), // Slate 100
          outlineVariant: const Color(0xFFE2E8F0), // Slate 200
          onSurfaceVariant: const Color(0xFF475569), // Slate 600
        );
    return _buildTheme(colorScheme, isDark: false);
  }

  static ThemeData get darkTheme {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.dark,
        ).copyWith(
          primary: kSeedColor,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFF2E1C15), // Deep warm orange container
          onPrimaryContainer: const Color(0xFFFFB38A),
          surface: const Color(0xFF121B2E), // Premium deep Navy Slate
          onSurface: Colors.white,
          surfaceContainerHighest: const Color(0xFF1E293B), // Slate 800
          outlineVariant: const Color(0xFF24324F), // Premium dark border
          onSurfaceVariant: const Color(0xFF94A3B8), // Slate 400
        );
    return _buildTheme(colorScheme, isDark: true);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, {required bool isDark}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),

      // AppBar theme
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card theme: elevation 0, outlined border, borderRadius 16
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: colorScheme.surface,
      ),

      // NavigationRail theme
      navigationRailTheme: NavigationRailThemeData(
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        backgroundColor: colorScheme.surface,
      ),

      // DataTable theme
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHighest,
        ),
        headingTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        dataTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 56,
      ),

      // FilledButton theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF16223F) : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 57,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
