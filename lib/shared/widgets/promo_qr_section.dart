import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/theme/app_colors.dart';

/// Promo poster with a scannable QR that opens the live site.
class PromoQrSection extends StatelessWidget {
  const PromoQrSection({super.key, this.compact = false});

  /// Smaller padding when embedded inside another page (e.g. Contact).
  final bool compact;

  static const assetPath = 'assets/branding/eng-hossam-promo-qr.png';

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: compact ? 24 : 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? 420 : AppConstants.maxContentWidth,
          ),
          child: FadeInView(
            child: GlassCard(
              glow: true,
              padding: EdgeInsets.all(compact ? 20 : 28),
              child: Column(
                children: [
                  Text(
                    isAr ? 'امسح واحجز مكانك' : 'Scan & reserve your seat',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr
                        ? 'وجّه كاميرا الموبايل على الكود عشان تفتح صفحة التسجيل.'
                        : 'Point your phone camera at the code to open registration.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: compact ? 280 : 360,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.card,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.qr_code_2_rounded,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 16),
                  SelectableText(
                    'https://hossamezzat.github.io/eng-hossam/',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
