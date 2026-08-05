import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Promo QR — loads the static web image first (reliable on GitHub Pages),
/// then the Flutter asset, then a generated QR as last resort.
class PromoQrSection extends StatelessWidget {
  const PromoQrSection({super.key, this.compact = false});

  final bool compact;

  static const assetPath = 'assets/branding/eng-hossam-promo-qr.png';
  static const siteUrl = 'https://hossamezzat.github.io/eng-hossam/';

  /// Prefer the file copied from `web/promo/` into the deployed site root.
  static String get webImageUrl {
    final base = Uri.base;
    final path = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(path: '${path}promo/promo-qr.png').toString();
  }

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final maxImg = compact ? 280.0 : 360.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: compact ? 24 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: compact ? 440 : AppConstants.maxContentWidth,
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
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxImg),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _QrImage(maxSize: maxImg),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.97, 0.97),
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 16),
                SelectableText(
                  siteUrl,
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
    );
  }
}

class _QrImage extends StatelessWidget {
  const _QrImage({required this.maxSize});

  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      PromoQrSection.webImageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFF0F172A),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) => Image.asset(
        PromoQrSection.assetPath,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => ColoredBox(
          color: Colors.white,
          child: Center(
            child: QrImageView(
              data: PromoQrSection.siteUrl,
              version: QrVersions.auto,
              size: maxSize * 0.78,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
