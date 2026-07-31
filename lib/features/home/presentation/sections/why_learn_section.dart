import 'package:flutter/material.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class WhyLearnSection extends StatelessWidget {
  const WhyLearnSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wide = Responsive.isWide(context);
    final desktop = Responsive.isDesktop(context);
    final columns = desktop ? 4 : (wide ? 2 : 1);
    final features = [
      (Icons.business_center_rounded, l10n.featureIndustry),
      (Icons.phone_iphone_rounded, l10n.featureProduction),
      (Icons.handyman_rounded, l10n.featurePractical),
      (Icons.explore_rounded, l10n.featureCareer),
      (Icons.folder_special_rounded, l10n.featureProjects),
      (Icons.forum_rounded, l10n.featureInteractive),
      (Icons.workspace_premium_rounded, l10n.featureCertificate),
      (Icons.favorite_rounded, l10n.featureFriendly),
    ];

    return Padding(
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
                eyebrow: l10n.brandName,
                headline: l10n.whyLearnTitle,
                subtitle: l10n.whyLearnSubtitle,
              ),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = 16.0;
                  final width = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - gap * (columns - 1)) / columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var i = 0; i < features.length; i++)
                        SizedBox(
                          width: width,
                          child: FadeInView(
                            delay: Duration(milliseconds: 50 * i),
                            child: _FeatureCard(
                              icon: features[i].$1,
                              title: features[i].$2,
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
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.index,
  });

  final IconData icon;
  final String title;
  final int index;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accents = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.primarySoft,
    ];
    final accent = accents[widget.index % accents.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: GlassCard(
          glow: _hovered,
          padding: const EdgeInsets.all(22),
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      accent.withValues(alpha: 0.65),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
