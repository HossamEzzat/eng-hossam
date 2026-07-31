import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class WhyProgrammingSection extends StatelessWidget {
  const WhyProgrammingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wide = Responsive.isWide(context);
    final columns = wide ? 2 : 1;
    final cards = [
      (
        Icons.rocket_launch_rounded,
        l10n.whyCard1Title,
        l10n.whyCard1Body,
        AppColors.primary,
      ),
      (
        Icons.child_care_rounded,
        l10n.whyCard2Title,
        l10n.whyCard2Body,
        AppColors.secondary,
      ),
      (
        Icons.public_rounded,
        l10n.whyCard3Title,
        l10n.whyCard3Body,
        AppColors.accent,
      ),
      (
        Icons.flag_rounded,
        l10n.whyCard4Title,
        l10n.whyCard4Body,
        AppColors.primarySoft,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bg,
            AppColors.surface.withValues(alpha: 0.6),
            AppColors.bg,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: 88,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              children: [
                SectionHeader(
                  centered: true,
                  eyebrow: l10n.navWhyProgramming,
                  headline: l10n.whyProgrammingTitle,
                  subtitle: l10n.whyProgrammingSubtitle,
                ),
                const SizedBox(height: 48),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = 20.0;
                    final cardWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - gap) / 2;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (var i = 0; i < cards.length; i++)
                          SizedBox(
                            width: cardWidth,
                            child: FadeInView(
                              delay: Duration(milliseconds: 80 * i),
                              child: _WhyCard(
                                icon: cards[i].$1,
                                title: cards[i].$2,
                                body: cards[i].$3,
                                accent: cards[i].$4,
                                index: i,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhyCard extends StatefulWidget {
  const _WhyCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
    required this.index,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;
  final int index;

  @override
  State<_WhyCard> createState() => _WhyCardState();
}

class _WhyCardState extends State<_WhyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        child: GlassCard(
          glow: _hovered,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      widget.accent.withValues(alpha: 0.22),
                      widget.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 26),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.body,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.75,
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (60 * widget.index).ms, duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}
