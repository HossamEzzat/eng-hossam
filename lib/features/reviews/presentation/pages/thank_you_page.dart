import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/celebration_overlay.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Full-screen celebration after the student completes their journey review.
class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SiteShell(
      showFooter: false,
      child: CelebrationOverlay(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: GlassCard(
                glow: true,
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 56))
                        .animate()
                        .scale(duration: 700.ms, curve: Curves.elasticOut)
                        .then()
                        .shimmer(duration: 1200.ms),
                    const SizedBox(height: 20),
                    Text(
                      l10n.thankYouCongrats,
                      textAlign: TextAlign.center,
                      style: context.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.thankYouJourneyDone,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.thankYouBodyFull,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        height: 1.85,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        GradientButton(
                          label: '📅 ${l10n.upcomingSessionsCta}',
                          icon: Icons.event_available_outlined,
                          onPressed: () => context.go('/session'),
                        ),
                        GradientButton(
                          label: '🏠 ${l10n.backHome}',
                          icon: Icons.home_outlined,
                          variant: GradientButtonVariant.secondary,
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.06),
            ),
          ),
        ),
      ),
    );
  }
}
