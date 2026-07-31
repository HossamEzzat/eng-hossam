import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'dart:math' as math;
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Column(
        children: [
          const _AboutHero(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 48 : 24,
              vertical: 56,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxContentWidth,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BioSection(),
                    SizedBox(height: 72),
                    _CompaniesSection(),
                    SizedBox(height: 72),
                    _AcademiesSection(),
                    SizedBox(height: 72),
                    _AwardsSection(),
                    SizedBox(height: 72),
                    _PhilosophySection(),
                    SizedBox(height: 72),
                    _AboutCta(),
                    SizedBox(height: 40),
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

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.heroGradientDark),
      child: _AboutHeroBody(),
    );
  }
}

class _AboutHeroBody extends StatelessWidget {
  const _AboutHeroBody();

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: wide ? 64 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: wide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 5, child: _HeroPhoto()),
                    SizedBox(width: 56),
                    Expanded(flex: 6, child: _HeroCopy()),
                  ],
                )
              : const Column(
                  children: [
                    _HeroPhoto(),
                    SizedBox(height: 36),
                    _HeroCopy(),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 48;
        final size =
            280.0.clamp(160.0, math.max(160.0, maxW - 8)).toDouble();
        return Center(
          child: SizedBox(
            width: size,
            height: size + 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size * 1.05,
                  height: size * 1.05,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.secondary.withValues(alpha: 0.14),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: size * 0.92,
                  height: size + 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 44,
                        offset: const Offset(0, 22),
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
              ],
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 650.ms)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutCubic);
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final roles = [
      l10n.brandRole,
      l10n.featureIndustry,
      l10n.featureInteractive,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.navAbout,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w700,
          ),
        )
            .animate()
            .fadeIn(duration: 450.ms)
            .slideY(begin: 0.12, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        Text(
          l10n.brandName,
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: AppColors.text,
          ),
        )
            .animate()
            .fadeIn(delay: 60.ms, duration: 500.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),
        const SizedBox(height: 6),
        Text(
          isAr
              ? AppConstants.instructorFullNameAr
              : AppConstants.instructorFullNameEn,
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 80.ms, duration: 500.ms),
        const SizedBox(height: 10),
        Text(
          l10n.brandRole,
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.textSoft,
            height: 1.45,
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < roles.length; i++)
              _RoleChip(label: roles[i])
                  .animate()
                  .fadeIn(delay: (140 + i * 50).ms, duration: 400.ms)
                  .slideY(begin: 0.15, curve: Curves.easeOutCubic),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          l10n.aboutPageIntro,
          style: context.textTheme.bodyLarge?.copyWith(
            height: 1.75,
            color: AppColors.text,
          ),
        ).animate().fadeIn(delay: 280.ms, duration: 500.ms),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withValues(alpha: 0.18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  const _BioSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: SectionHeader(
          eyebrow: l10n.aboutTitle,
          headline: l10n.aboutPageTitle,
          subtitle: l10n.aboutSubtitle,
          animate: false,
        ),
      ),
    );
  }
}

class _CompaniesSection extends StatelessWidget {
  const _CompaniesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: l10n.companiesTitle,
            headline: l10n.companiesTitle,
            subtitle: l10n.aboutSubtitle,
          ),
          const SizedBox(height: 28),
          ...List.generate(AppConstants.companies.length, (i) {
            final (name, role, detail) = AppConstants.companies[i];
            final isLast = i == AppConstants.companies.length - 1;
            return _TimelineItem(
              company: name,
              role: role,
              detail: detail,
              isLast: isLast,
              index: i,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.company,
    required this.role,
    required this.detail,
    required this.isLast,
    required this.index,
  });

  final String company;
  final String role;
  final String detail;
  final bool isLast;
  final int index;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.primary.withValues(alpha: 0.22),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: GlassCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.textSoft,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (80 * index).ms, duration: 450.ms)
                  .slideX(begin: -0.04, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademiesSection extends StatelessWidget {
  const _AcademiesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: l10n.academiesTitle,
            headline: l10n.academiesTitle,
            subtitle: '${l10n.brandName} · ${l10n.aboutSubtitle}',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < AppConstants.academies.length; i++)
                GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 14,
                  child: Text(
                    AppConstants.academies[i],
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (40 * i).ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.94, 0.94),
                      curve: Curves.easeOutCubic,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AwardsSection extends StatelessWidget {
  const _AwardsSection();

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return FadeInView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            eyebrow: l10n.awardsTitle,
            headline: l10n.awardsTitle,
            subtitle: l10n.aboutSubtitle,
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.awards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 3 : (Responsive.isMobile(context) ? 1 : 2),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: wide ? 1.35 : 1.55,
            ),
            itemBuilder: (context, i) {
              final (emoji, title, subtitle) = AppConstants.awards[i];
              return _AwardCard(
                emoji: emoji,
                title: title,
                subtitle: subtitle,
                index: i,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AwardCard extends StatefulWidget {
  const _AwardCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.index,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final int index;

  @override
  State<_AwardCard> createState() => _AwardCardState();
}

class _AwardCardState extends State<_AwardCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1,
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        child: GlassCard(
          glow: _hovered,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (70 * widget.index).ms, duration: 500.ms)
        .slideY(begin: 0.12, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutCubic);
  }
}

class _PhilosophySection extends StatelessWidget {
  const _PhilosophySection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        glow: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              eyebrow: l10n.philosophyTitle,
              headline: l10n.philosophyTitle,
              animate: false,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.philosophyBody,
              style: context.textTheme.bodyLarge?.copyWith(
                height: 1.8,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCta extends StatelessWidget {
  const _AboutCta();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          children: [
            Text(
              l10n.finalCtaTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.finalCtaBody,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                height: 1.65,
                color: AppColors.textSoft,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: l10n.ctaReserveNow,
              icon: Icons.event_available_rounded,
              onPressed: () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}
