import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/floating_blobs.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: FadeInView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF0E7490),
                            Color(0xFF164E63),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Opacity(
                      opacity: 0.45,
                      child: FloatingBlobs(),
                    ),
                  ),
                  const Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: ParticleField(count: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 56 : 28,
                      vertical: wide ? 64 : 48,
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.brandName,
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1),
                        const SizedBox(height: 16),
                        Text(
                          l10n.finalCtaTitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 500.ms)
                            .slideY(begin: 0.12),
                        const SizedBox(height: 18),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Text(
                            l10n.finalCtaBody,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.7,
                            ),
                          ),
                        ).animate().fadeIn(delay: 140.ms, duration: 500.ms),
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stackButtons = constraints.maxWidth < 420;
                            final buttons = [
                              GradientButton(
                                label: l10n.ctaReserveNow,
                                icon: Icons.event_seat_rounded,
                                variant: GradientButtonVariant.accent,
                                height: 56,
                                expand: stackButtons,
                                onPressed: () => context.go('/register'),
                              ),
                              GradientButton(
                                label: l10n.navSessions,
                                variant: GradientButtonVariant.secondary,
                                icon: Icons.calendar_month_outlined,
                                height: 56,
                                expand: stackButtons,
                                onPressed: () => context.go('/session'),
                              ),
                            ];
                            if (stackButtons) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  buttons[0],
                                  const SizedBox(height: 12),
                                  buttons[1],
                                ],
                              );
                            }
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: buttons,
                            );
                          },
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 450.ms)
                            .slideY(begin: 0.1),
                      ],
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
