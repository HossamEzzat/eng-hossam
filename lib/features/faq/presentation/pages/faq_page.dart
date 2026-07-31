import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/core/utils/url_helpers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;
    final items = [
      (l10n.faqQ1, l10n.faqA1),
      (l10n.faqQ2, l10n.faqA2),
      (l10n.faqQ3, l10n.faqA3),
      (l10n.faqQ4, l10n.faqA4),
      (l10n.faqQ5, l10n.faqA5),
      (l10n.faqQ6, l10n.faqA6),
      (l10n.faqQ7, l10n.faqA7),
    ];

    return SiteShell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: 48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInView(
                  child: SectionHeader(
                    eyebrow: l10n.navFaq,
                    headline: l10n.faqTitle,
                    subtitle: l10n.contactSubtitle,
                    centered: true,
                  ),
                ),
                const SizedBox(height: 36),
                ...List.generate(items.length, (i) {
                  final (q, a) = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeInView(
                      delay: (40 * i).ms,
                      child: _FaqTile(question: q, answer: a, index: i),
                    ),
                  );
                }),
                const SizedBox(height: 40),
                FadeInView(
                  child: GlassCard(
                    glow: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 36,
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.contactTitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.contactSubtitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSoft,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            GradientButton(
                              label: l10n.whatsapp,
                              icon: Icons.chat_rounded,
                              onPressed: () => UrlHelpers.launchWhatsApp(),
                            ),
                            GradientButton(
                              label: l10n.ctaReserveNow,
                              variant: GradientButtonVariant.secondary,
                              icon: Icons.event_available_rounded,
                              onPressed: () => context.go('/register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
    required this.index,
  });

  final String question;
  final String answer;
  final int index;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          initiallyExpanded: widget.index == 0,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSoft,
          title: Text(
            widget.question,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          children: [
            AnimatedOpacity(
              opacity: _expanded || widget.index == 0 ? 1 : 0.9,
              duration: AppConstants.animFast,
              child: Text(
                widget.answer,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: AppColors.textSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
