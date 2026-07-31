import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/home/presentation/widgets/session_countdown.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class UpcomingSessionsSection extends ConsumerWidget {
  const UpcomingSessionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);
    final sessions = store.sessions;
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            AppColors.bg,
            const Color(0xFF164E63).withValues(alpha: 0.35),
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
                  eyebrow: l10n.navSessions,
                  headline: l10n.sessionsTitle,
                  subtitle: l10n.sessionsSubtitle,
                ),
                const SizedBox(height: 48),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = 24.0;
                    final stack = constraints.maxWidth < 900;
                    final cols = stack
                        ? 1
                        : constraints.maxWidth < 1200
                            ? 2
                            : 3;
                    final cardWidth = stack
                        ? constraints.maxWidth
                        : (constraints.maxWidth - gap * (cols - 1)) / cols;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (var i = 0; i < sessions.length; i++)
                          SizedBox(
                            width: cardWidth,
                            child: FadeInView(
                              delay: Duration(milliseconds: 100 * i),
                              slideFrom: i.isEven
                                  ? FadeInDirection.left
                                  : FadeInDirection.right,
                              child: SessionTicketCard(session: sessions[i]),
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

class SessionTicketCard extends StatelessWidget {
  const SessionTicketCard({super.key, required this.session});

  final OpeningSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final open = session.remainingSeats > 0;
    final region = l10n.sessionRegionSuez;
    final branch = session.branch == SessionBranch.suez
        ? l10n.branchSuez
        : l10n.branchAlSalam;
    final foil = session.branch == SessionBranch.suez
        ? const [AppColors.primary, AppColors.secondary]
        : const [AppColors.secondary, AppColors.accent];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: foil.first.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.card, AppColors.surface],
                ),
                border: Border.all(
                  color: foil.first.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: foil,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: open
                                        ? AppColors.success
                                            .withValues(alpha: 0.14)
                                        : AppColors.error
                                            .withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: open
                                          ? AppColors.success
                                              .withValues(alpha: 0.4)
                                          : AppColors.error
                                              .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    open
                                        ? l10n.registrationOpen
                                        : l10n.adminPending,
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                      color: open
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Text(
                                  region,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: foil.first.withValues(alpha: 0.7),
                                  ),
                                ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              session.gradeLabel(isAr),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              branch,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: foil.first,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _TicketMeta(
                              icon: Icons.place_rounded,
                              label: '📍 ${session.venue(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.schedule_rounded,
                              label: '🕐 ${session.timeLabel(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.event_seat_rounded,
                              label:
                                  '${session.remainingSeats} ${l10n.seatsRemaining} · ${session.totalSeats}',
                            ),
                            const SizedBox(height: 22),
                            CustomPaint(
                              painter: _TicketDashPainter(
                                color: AppColors.border.withValues(alpha: 0.9),
                              ),
                              size: const Size(double.infinity, 1),
                            ),
                            const SizedBox(height: 18),
                            SessionCountdown(
                              target: session.date,
                              compact: true,
                            ),
                            const SizedBox(height: 20),
                            GradientButton(
                              label: l10n.reserveSeat,
                              icon: Icons.confirmation_number_outlined,
                              expand: true,
                              onPressed: open
                                  ? () => context.go(
                                        '/register?session=${session.id}',
                                      )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (_) => Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bg,
                      border: Border.all(
                        color: foil.first.withValues(alpha: 0.25),
                      ),
                    ),
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

class _TicketMeta extends StatelessWidget {
  const _TicketMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: AppColors.textSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketDashPainter extends CustomPainter {
  _TicketDashPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 6.0;
    const gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketDashPainter oldDelegate) =>
      oldDelegate.color != color;
}
