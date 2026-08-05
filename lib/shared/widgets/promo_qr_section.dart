import 'package:flutter/material.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Always-visible QR block (drawn by Flutter — does not depend on network).
/// Also tries to show the branded promo poster when available.
class PromoQrSection extends StatelessWidget {
  const PromoQrSection({super.key, this.compact = false});

  final bool compact;

  static const siteUrl = 'https://hossamezzat.github.io/eng-hossam/';
  static const posterUrl =
      'https://hossamezzat.github.io/eng-hossam/promo/promo-qr.png';
  static const assetPath = 'assets/branding/eng-hossam-promo-qr.png';

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final qrSize = compact ? 200.0 : 240.0;
    final posterMax = compact ? 300.0 : 380.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: compact ? 20 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? 480 : AppConstants.maxContentWidth,
          ),
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
                // 1) Branded poster (network → asset). Hidden only if both fail.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: posterMax),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      posterUrl,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) => Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 2) Guaranteed scannable QR — always painted by Flutter.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: QrImageView(
                    data: siteUrl,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0B1120),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0B1120),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isAr ? 'أو افتح الرابط:' : 'Or open the link:',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  siteUrl,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
