import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lumina/theme/app_colors.dart';

/// Glassmorphism card with blur, border, and soft shadow (dark theme).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.onTap,
    this.glow = false,
    this.blurSigma = 16,
    this.margin,
    this.width,
    this.height,
    this.borderOpacity,
    this.backgroundOpacity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool glow;
  final double blurSigma;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? borderOpacity;
  final double? backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final fillOpacity = backgroundOpacity ?? 0.55;
    final edgeOpacity = borderOpacity ?? 0.28;

    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: AppColors.glassDark,
            color: AppColors.card.withValues(alpha: fillOpacity),
            border: Border.all(
              color: Colors.white.withValues(alpha: edgeOpacity * 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              if (glow)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final wrapped = margin != null
        ? Padding(padding: margin!, child: card)
        : card;

    if (onTap == null) return wrapped;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: wrapped,
      ),
    );
  }
}
