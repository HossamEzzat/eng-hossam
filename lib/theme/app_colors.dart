import 'package:flutter/material.dart';

/// Dark-only premium palette — Eng. Hossam sessions platform.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFF0B1120);
  static const Color surface = Color(0xFF111827);
  static const Color card = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);

  static const Color primary = Color(0xFF3B82F6);
  static const Color primarySoft = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color text = Color(0xFFFFFFFF);
  static const Color textSoft = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  // Compatibility aliases used across existing widgets
  static const Color primaryLight = primarySoft;
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  static const Color info = primary;

  static const Color darkBg = bg;
  static const Color darkSurface = surface;
  static const Color darkSurfaceElevated = card;
  static const Color darkBorder = border;
  static const Color darkText = text;
  static const Color darkTextSecondary = textSoft;
  static const Color darkTextMuted = textMuted;

  static const Color lightBg = bg;
  static const Color lightSurface = surface;
  static const Color lightSurfaceElevated = card;
  static const Color lightBorder = border;
  static const Color lightText = text;
  static const Color lightTextSecondary = textSoft;
  static const Color lightTextMuted = textMuted;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    colors: [Color(0xFF0B1120), Color(0xFF0F172A), Color(0xFF0E7490)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = heroGradientDark;

  static const LinearGradient glassDark = LinearGradient(
    colors: [Color(0x991E293B), Color(0x66111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassLight = glassDark;
}
