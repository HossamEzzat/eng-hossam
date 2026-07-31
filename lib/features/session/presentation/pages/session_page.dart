import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class SessionPage extends ConsumerWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);
    final sessions = store.sessions.isNotEmpty
        ? store.sessions
        : SessionCatalog.upcoming;
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return SiteShell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: 48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInView(
                  child: SectionHeader(
                    eyebrow: l10n.navCourse,
                    headline: l10n.coursePageTitle,
                    subtitle: l10n.courseAudience,
                  ),
                ),
                const SizedBox(height: 40),
                FadeInView(
                  delay: 60.ms,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _TicketCard(
                      session: sessions.first,
                      index: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                const FadeInView(child: _WhoFor()),
                const SizedBox(height: 64),
                const FadeInView(child: _Agenda()),
                const SizedBox(height: 64),
                const FadeInView(child: _Practicals()),
                const SizedBox(height: 64),
                const FadeInView(child: _SessionCta()),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatefulWidget {
  const _TicketCard({required this.session, required this.index});

  final OpeningSession session;
  final int index;

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final s = widget.session;
    final lowSeats = s.remainingSeats <= 10;
    final pad = Responsive.value(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        child: GlassCard(
          glow: _hovered || lowSeats,
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Text(
                      s.cityLabel(isAr),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    l10n.registrationOpen,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                s.title(isAr),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.academy(isAr),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(Icons.schedule_outlined, s.timeLabel(isAr)),
              const SizedBox(height: 10),
              _InfoRow(Icons.place_outlined, s.address(isAr)),
              const SizedBox(height: 10),
              _InfoRow(Icons.groups_outlined, s.audience(isAr)),
              const SizedBox(height: 10),
              _InfoRow(
                Icons.event_seat_outlined,
                '${s.remainingSeats} ${l10n.seatsRemaining} · ${s.totalSeats}',
                emphasize: lowSeats,
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: l10n.reserveSeat,
                expand: true,
                icon: Icons.how_to_reg_rounded,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (80 * widget.index).ms, duration: 500.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text, {this.emphasize = false});

  final IconData icon;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: emphasize ? AppColors.accent : AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: emphasize ? AppColors.accent : AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

class _WhoFor extends StatelessWidget {
  const _WhoFor();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.school_outlined, l10n.gradeFirst, l10n.courseAudience),
      (Icons.auto_stories_outlined, l10n.gradeSecond, l10n.courseLaptop),
      (Icons.family_restroom_outlined, l10n.navFaq, l10n.courseFree),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: l10n.navCourse,
          headline: l10n.courseAudience,
          subtitle: l10n.courseLaptop,
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final multi = constraints.maxWidth >= 800;
            final cards = [
              for (var i = 0; i < items.length; i++)
                _AudienceCard(
                  icon: items[i].$1,
                  title: items[i].$2,
                  body: items[i].$3,
                  index: i,
                ),
            ];
            if (multi) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  cards[i],
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.index,
  });

  final IconData icon;
  final String title;
  final String body;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textSoft,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (70 * index).ms, duration: 450.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final agenda = [
      l10n.content1,
      l10n.content2,
      l10n.content3,
      l10n.content4,
      l10n.content5,
      l10n.content6,
      l10n.content7,
      l10n.content8,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: l10n.navCourse,
          headline: l10n.contentTitle,
          subtitle: l10n.contentSubtitle,
        ),
        const SizedBox(height: 28),
        ...List.generate(agenda.length, (i) {
          final title = agenda[i];
          return Padding(
            padding: EdgeInsets.only(
              bottom: i == agenda.length - 1 ? 0 : 14,
            ),
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Text(
                      '${i + 1}'.padLeft(2, '0'),
                      style: context.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (60 * i).ms, duration: 450.ms)
                .slideX(begin: -0.04, curve: Curves.easeOutCubic),
          );
        }),
      ],
    );
  }
}

class _Practicals extends StatelessWidget {
  const _Practicals();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.confirmation_number_outlined, l10n.courseFree),
      (Icons.laptop_mac_outlined, l10n.courseLaptop),
      (Icons.workspace_premium_outlined, l10n.featureCertificate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          eyebrow: l10n.navCourse,
          headline: l10n.coursePageTitle,
          subtitle: l10n.sessionsSubtitle,
        ),
        const SizedBox(height: 24),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.secondary.withValues(alpha: 0.12),
                    ),
                    child: Icon(e.$1, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      e.$2,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionCta extends StatelessWidget {
  const _SessionCta();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassCard(
      glow: true,
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              GradientButton(
                label: l10n.ctaReserveNow,
                icon: Icons.event_available_rounded,
                onPressed: () => context.go('/register'),
              ),
              GradientButton(
                label: l10n.navFaq,
                variant: GradientButtonVariant.secondary,
                icon: Icons.help_outline_rounded,
                onPressed: () => context.go('/faq'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
