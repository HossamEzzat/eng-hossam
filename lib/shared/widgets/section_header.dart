import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/theme/app_colors.dart';

/// Eyebrow + headline + subtitle section header.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.headline,
    this.eyebrow,
    this.subtitle,
    this.centered = false,
    this.animate = true,
    this.maxWidth = 720,
    this.crossAxisAlignment,
  });

  final String headline;
  final String? eyebrow;
  final String? subtitle;
  final bool centered;
  final bool animate;
  final double maxWidth;
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final align =
        crossAxisAlignment ??
        (centered ? CrossAxisAlignment.center : CrossAxisAlignment.start);
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eyebrow != null && eyebrow!.isNotEmpty) ...[
            Text(
              eyebrow!.toUpperCase(),
              textAlign: textAlign,
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            headline,
            textAlign: textAlign,
            style: context.textTheme.headlineLarge?.copyWith(
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              subtitle!,
              textAlign: textAlign,
              style: context.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: context.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (centered) {
      content = Center(child: content);
    }

    if (!animate) return content;

    return content
        .animate()
        .fadeIn(duration: AppConstants.animNormal, curve: Curves.easeOut)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
        );
  }
}
