import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/shared/widgets/animated_counter.dart';
import 'package:lumina/shared/widgets/floating_blobs.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = math.max(
      Responsive.isMobile(context) ? 560.0 : 680.0,
      context.screenHeight - AppConstants.navHeight,
    );
    final wide = Responsive.isWide(context);
    final stats = ref.watch(statsProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradientDark),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.4, -0.6),
                    radius: 1.1,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: FloatingBlobs()),
          const Positioned.fill(child: ParticleField(count: 28)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 48 : 24,
              vertical: wide ? 56 : 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    wide
                        ? const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 6, child: _HeroCopy()),
                              SizedBox(width: 48),
                              Expanded(flex: 5, child: _HeroPhoto()),
                            ],
                          )
                        : const Column(
                            children: [
                              _HeroCopy(),
                              SizedBox(height: 40),
                              _HeroPhoto(),
                            ],
                          ),
                    const SizedBox(height: 48),
                    _LiveStatsRow(
                      students: stats.$1,
                      apps: stats.$2,
                      academies: stats.$3,
                      awards: stats.$4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.brandName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.displaySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            height: 1.15,
            fontSize: Responsive.value(
              context,
              mobile: 28,
              tablet: 34,
              desktop: 40,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.18, curve: Curves.easeOutCubic),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppColors.accent.withValues(alpha: 0.14),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            l10n.brandRole,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 60.ms, duration: 450.ms)
            .slideX(begin: -0.04, curve: Curves.easeOutCubic),
        const SizedBox(height: 20),
        Text(
          l10n.heroHeadline,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppColors.text,
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 600.ms)
            .slideY(begin: 0.14, curve: Curves.easeOutCubic),
        const SizedBox(height: 18),
        Text(
          l10n.heroSubtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            height: 1.75,
            color: AppColors.textSoft,
          ),
        ).animate().fadeIn(delay: 160.ms, duration: 550.ms),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final stack = constraints.maxWidth < 420;
            final buttons = [
              GradientButton(
                label: l10n.ctaReserveNow,
                icon: Icons.event_seat_rounded,
                expand: stack,
                onPressed: () => context.go('/register'),
              ),
              GradientButton(
                label: l10n.ctaLearnMore,
                variant: GradientButtonVariant.secondary,
                icon: Icons.arrow_forward_rounded,
                expand: stack,
                onPressed: () => context.go('/session'),
              ),
            ];
            if (stack) {
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
              children: buttons,
            );
          },
        )
            .animate()
            .fadeIn(delay: 220.ms, duration: 500.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),
      ],
    );
  }
}

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 48;
        final size = (Responsive.isMobile(context) ? 280.0 : 340.0)
            .clamp(180.0, math.max(180.0, maxW - 16))
            .toDouble();

        return Center(
          child: SizedBox(
            width: size,
            height: size + 48,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size * 0.95,
                  height: size * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.secondary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Container(
                  width: size * 0.88,
                  height: size,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.accent,
                        AppColors.primarySoft,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.32),
                        blurRadius: 48,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/instructor.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 8,
                  right: 8,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    borderRadius: 16,
                    glow: true,
                    child: Column(
                      children: [
                        Text(
                          l10n.brandName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.brandRole,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: 140.ms, duration: 700.ms)
        .scale(
          begin: const Offset(0.94, 0.94),
          curve: Curves.easeOutCubic,
        );
  }
}

class _LiveStatsRow extends StatelessWidget {
  const _LiveStatsRow({
    required this.students,
    required this.apps,
    required this.academies,
    required this.awards,
  });

  final int students;
  final int apps;
  final int academies;
  final int awards;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (students.clamp(0, 9999), l10n.statStudents),
      (apps, l10n.statApps),
      (academies, l10n.statAcademies),
      (awards.clamp(5, 99), l10n.statAwards),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      borderRadius: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 640;
          if (narrow) {
            return Wrap(
              spacing: 12,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  SizedBox(
                    width: ((constraints.maxWidth - 12) / 2).clamp(120.0, 280.0),
                    child: AnimatedCounter(
                      value: items[i].$1,
                      label: items[i].$2,
                      suffix: '+',
                      valueStyle: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: AppColors.border.withValues(alpha: 0.8),
                  ),
                Expanded(
                  child: AnimatedCounter(
                    value: items[i].$1,
                    label: items[i].$2,
                    suffix: '+',
                    valueStyle: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    )
        .animate()
        .fadeIn(delay: 280.ms, duration: 600.ms)
        .slideY(begin: 0.12, curve: Curves.easeOutCubic);
  }
}
