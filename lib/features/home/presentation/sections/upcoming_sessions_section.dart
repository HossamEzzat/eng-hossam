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
    final session = store.sessions.isNotEmpty
        ? store.sessions.first
        : SessionCatalog.official;
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
                FadeInView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: SessionTicketCard(session: session),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium event-ticket card for the single official opening session.
class SessionTicketCard extends StatelessWidget {
  const SessionTicketCard({super.key, required this.session});

  final OpeningSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final open = session.remainingSeats > 0 && session.registrationOpen;
    const foil = [AppColors.primary, AppColors.secondary];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: foil.first.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF152238), AppColors.card, AppColors.surface],
                ),
                border: Border.all(
                  color: foil.first.withValues(alpha: 0.4),
                  width: 1.6,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 12,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: foil,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: open
                                        ? AppColors.success
                                            .withValues(alpha: 0.16)
                                        : AppColors.error
                                            .withValues(alpha: 0.12),
                                    border: Border.all(
                                      color: open
                                          ? AppColors.success
                                              .withValues(alpha: 0.45)
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
                                Text(
                                  isAr
                                      ? 'جلسة الافتتاح الرسمية'
                                      : 'Official Opening Session',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: foil.first.withValues(alpha: 0.85),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              session.title(isAr),
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.25,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${session.course(isAr)} · ${AppConstants.instructorNameAr}',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: foil.first,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _TicketMeta(
                              icon: Icons.location_city_rounded,
                              label: '📍 ${session.cityLabel(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.calendar_month_rounded,
                              label: '📅 ${session.dateLabel(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.school_rounded,
                              label: '🏫 ${session.academy(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.place_rounded,
                              label: '📌 ${session.address(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.schedule_rounded,
                              label: '🕕 ${session.timeLabel(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.person_rounded,
                              label:
                                  '👨‍🏫 ${isAr ? AppConstants.instructorNameAr : AppConstants.instructorNameEn}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.groups_rounded,
                              label: '🎯 ${session.audience(isAr)}',
                            ),
                            const SizedBox(height: 10),
                            _TicketMeta(
                              icon: Icons.event_seat_rounded,
                              label:
                                  '${session.remainingSeats} ${l10n.seatsRemaining}',
                            ),
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 22),
                            GradientButton(
                              label: l10n.reserveSeat,
                              icon: Icons.confirmation_number_outlined,
                              expand: true,
                              onPressed: open
                                  ? () => context.go('/register')
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
                  6,
                  (_) => Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bg,
                      border: Border.all(
                        color: foil.first.withValues(alpha: 0.28),
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
              fontWeight: FontWeight.w600,
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
