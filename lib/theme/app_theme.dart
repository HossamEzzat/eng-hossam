import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Dark theme only.
  static ThemeData get dark => _build();

  static ThemeData _build() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primary.withValues(alpha: 0.22),
      onPrimaryContainer: AppColors.primarySoft,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.withValues(alpha: 0.2),
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accent.withValues(alpha: 0.2),
      onTertiaryContainer: AppColors.accentLight,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerHighest: AppColors.card,
      onSurfaceVariant: AppColors.textSoft,
      outline: AppColors.border,
      outlineVariant: AppColors.border.withValues(alpha: 0.6),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.text,
      onInverseSurface: AppColors.bg,
      inversePrimary: AppColors.primarySoft,
    );

    // Default Arabic-first stack; English pages override via locale typography helper.
    final textTheme = AppTypography.arabic();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border.withValues(alpha: 0.5),
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.card,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.text),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class AppTypography {
  AppTypography._();

  static TextTheme arabic() {
    final display = GoogleFonts.cairo;
    final body = GoogleFonts.ibmPlexSansArabic;
    return _build(display, body);
  }

  static TextTheme english() {
    final display = GoogleFonts.manrope;
    final body = GoogleFonts.inter;
    return _build(display, body);
  }

  static TextTheme forLocale(Locale locale) {
    return locale.languageCode == 'ar' ? arabic() : english();
  }

  static TextTheme _build(
    TextStyle Function({
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
      double? letterSpacing,
      Color? color,
    }) display,
    TextStyle Function({
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
      double? letterSpacing,
      Color? color,
    }) body,
  ) {
    const primary = AppColors.text;
    const secondary = AppColors.textSoft;

    return TextTheme(
      displayLarge: display(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: primary,
      ),
      displayMedium: display(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: primary,
      ),
      displaySmall: display(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primary,
      ),
      headlineLarge: display(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: primary,
      ),
      headlineMedium: display(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: primary,
      ),
      headlineSmall: display(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.45,
        color: primary,
      ),
      titleLarge: display(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.45,
        color: primary,
      ),
      titleMedium: display(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: primary,
      ),
      titleSmall: display(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: primary,
      ),
      bodyLarge: body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.75,
        color: secondary,
      ),
      bodyMedium: body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: secondary,
      ),
      bodySmall: body(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: secondary,
      ),
      labelLarge: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: primary,
      ),
      labelMedium: body(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: primary,
      ),
      labelSmall: body(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: secondary,
      ),
    );
  }
}
