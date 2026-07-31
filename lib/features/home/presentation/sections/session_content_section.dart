import 'package:flutter/material.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class SessionContentSection extends StatelessWidget {
  const SessionContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wide = Responsive.isWide(context);
    final steps = [
      ('01', l10n.content1, Icons.lightbulb_outline_rounded),
      ('02', l10n.content2, Icons.map_outlined),
      ('03', l10n.content3, Icons.tune_rounded),
      ('04', l10n.content4, Icons.flutter_dash),
      ('05', l10n.content5, Icons.apps_rounded),
      ('06', l10n.content6, Icons.construction_rounded),
      ('07', l10n.content7, Icons.explore_outlined),
      ('08', l10n.content8, Icons.chat_bubble_outline_rounded),
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
                eyebrow: l10n.navCourse,
                headline: l10n.contentTitle,
                subtitle: l10n.contentSubtitle,
              ),
              const SizedBox(height: 56),
              for (var i = 0; i < steps.length; i++)
                FadeInView(
                  delay: Duration(milliseconds: 60 * i),
                  child: _TimelineStep(
                    index: i,
                    total: steps.length,
                    number: steps[i].$1,
                    title: steps[i].$2,
                    icon: steps[i].$3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.index,
    required this.total,
    required this.number,
    required this.title,
    required this.icon,
  });

  final int index;
  final int total;
  final String number;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = index == total - 1;
    final accents = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
    ];
    final accent = accents[index % accents.length];
    final wide = Responsive.isWide(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: wide ? 72 : 56,
              child: Column(
                children: [
                  Container(
                    width: wide ? 56 : 44,
                    height: wide ? 56 : 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child:
                        Icon(icon, color: Colors.white, size: wide ? 24 : 20),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withValues(alpha: 0.55),
                              accents[(index + 1) % accents.length]
                                  .withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                child: GlassCard(
                  padding: EdgeInsets.all(wide ? 28 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.stepLabel} $number',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
