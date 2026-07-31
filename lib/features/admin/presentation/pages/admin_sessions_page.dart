import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:uuid/uuid.dart';

class AdminSessionsPage extends ConsumerWidget {
  const AdminSessionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              'Sessions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
            ),
            FilledButton.icon(
              onPressed: () => _editSession(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create session'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final s in store.sessions)
              _SessionCard(
                session: s,
                regs: store.registrations
                    .where((r) => r.sessionId == s.id)
                    .length,
                attended: store.registrations
                    .where((r) => r.sessionId == s.id && r.attendanceConfirmed)
                    .length,
                certs: store.registrations
                    .where((r) => r.sessionId == s.id && r.certificateIssued)
                    .length,
                reviews: store.registrations
                    .where((r) => r.sessionId == s.id && r.reviewSubmitted)
                    .length,
                onEdit: () => _editSession(context, ref, existing: s),
                onToggleReg: () {
                  store.setRegistrationOpen(
                    s.id,
                    open: !s.registrationOpen,
                  );
                  adminSnack(
                    context,
                    s.registrationOpen
                        ? 'Registration closed'
                        : 'Registration opened',
                  );
                },
                onMarkAllAttended: () async {
                  final ok = await adminConfirm(
                    context,
                    title: 'Mark all attended?',
                    message:
                        'Mark every student in “${s.titleEn}” as attended?',
                  );
                  if (!ok) return;
                  store.markSessionAttended(s.id);
                  if (context.mounted) {
                    adminSnack(context, 'Session attendance updated');
                  }
                },
                onDelete: () async {
                  final ok = await adminConfirm(
                    context,
                    title: 'Delete session?',
                    message:
                        'Only empty sessions can be deleted. Continue?',
                    destructive: true,
                    confirmLabel: 'Delete',
                  );
                  if (!ok) return;
                  final before = store.sessions.length;
                  store.deleteSession(s.id);
                  if (context.mounted) {
                    adminSnack(
                      context,
                      store.sessions.length < before
                          ? 'Session deleted'
                          : 'Cannot delete — students are registered',
                    );
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _editSession(
    BuildContext context,
    WidgetRef ref, {
    OpeningSession? existing,
  }) async {
    final titleAr = TextEditingController(text: existing?.titleAr ?? '');
    final titleEn = TextEditingController(
      text: existing?.titleEn ?? 'Programming Session',
    );
    final venueAr = TextEditingController(text: existing?.venueAr ?? '');
    final venueEn = TextEditingController(text: existing?.venueEn ?? '');
    final seats = TextEditingController(
      text: '${existing?.totalSeats ?? 40}',
    );
    var branch = existing?.branch ?? SessionBranch.suez;
    var gradeBand = existing?.gradeBand ?? SessionGradeBand.secondSecondary;
    var date = existing?.date ?? DateTime.now().add(const Duration(days: 7));
    final timeEn = TextEditingController(
      text: existing?.timeLabelEn ?? '1:00 PM – 3:00 PM',
    );
    final timeAr = TextEditingController(
      text: existing?.timeLabelAr ?? '١:٠٠ ظهرًا – ٣:٠٠ عصرًا',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(existing == null ? 'Create session' : 'Edit session'),
          content: SizedBox(
            width: math.min(420, MediaQuery.sizeOf(context).width - 48),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleEn,
                    decoration: const InputDecoration(labelText: 'Title (EN)'),
                  ),
                  TextField(
                    controller: titleAr,
                    decoration: const InputDecoration(labelText: 'Title (AR)'),
                  ),
                  TextField(
                    controller: venueEn,
                    decoration: const InputDecoration(labelText: 'Venue (EN)'),
                  ),
                  TextField(
                    controller: venueAr,
                    decoration: const InputDecoration(labelText: 'Venue (AR)'),
                  ),
                  TextField(
                    controller: timeEn,
                    decoration: const InputDecoration(labelText: 'Time (EN)'),
                  ),
                  TextField(
                    controller: timeAr,
                    decoration: const InputDecoration(labelText: 'Time (AR)'),
                  ),
                  TextField(
                    controller: seats,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Maximum seats'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SessionBranch>(
                    initialValue: branch,
                    items: const [
                      DropdownMenuItem(
                        value: SessionBranch.suez,
                        child: Text('Suez Branch'),
                      ),
                      DropdownMenuItem(
                        value: SessionBranch.alSalam,
                        child: Text('Al Salam Branch'),
                      ),
                    ],
                    onChanged: (v) => setLocal(() => branch = v ?? branch),
                    decoration: const InputDecoration(labelText: 'Branch'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<SessionGradeBand>(
                    initialValue: gradeBand,
                    items: const [
                      DropdownMenuItem(
                        value: SessionGradeBand.firstSecondary,
                        child: Text('First Secondary'),
                      ),
                      DropdownMenuItem(
                        value: SessionGradeBand.secondSecondary,
                        child: Text('Second Secondary'),
                      ),
                    ],
                    onChanged: (v) =>
                        setLocal(() => gradeBand = v ?? gradeBand),
                    decoration: const InputDecoration(labelText: 'Grade'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Date: ${DateFormat.yMMMd().format(date)}'),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setLocal(() => date = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              date.hour,
                              date.minute,
                            ));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final total = int.tryParse(seats.text) ?? 40;
    final remaining = existing == null
        ? total
        : (total - (existing.totalSeats - existing.remainingSeats))
            .clamp(0, total);
    final session = OpeningSession(
      id: existing?.id ?? 'ses_${const Uuid().v4().substring(0, 8)}',
      titleAr: titleAr.text.trim().isEmpty ? titleEn.text : titleAr.text,
      titleEn: titleEn.text.trim(),
      branch: branch,
      gradeBand: gradeBand,
      date: date,
      dateLabelAr: 'السويس',
      dateLabelEn: 'Suez',
      timeLabelAr: timeAr.text.trim(),
      timeLabelEn: timeEn.text.trim(),
      totalSeats: total,
      remainingSeats: remaining,
      venueAr: venueAr.text.isEmpty
          ? (branch == SessionBranch.suez ? 'فرع السويس' : 'فرع السلام')
          : venueAr.text,
      venueEn: venueEn.text.isEmpty
          ? (branch == SessionBranch.suez ? 'Suez Branch' : 'Al Salam Branch')
          : venueEn.text,
      registrationOpen: existing?.registrationOpen ?? true,
    );
    ref.read(sessionStoreProvider).upsertSession(session);
    if (context.mounted) adminSnack(context, 'Session saved');
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.regs,
    required this.attended,
    required this.certs,
    required this.reviews,
    required this.onEdit,
    required this.onToggleReg,
    required this.onMarkAllAttended,
    required this.onDelete,
  });

  final OpeningSession session;
  final int regs;
  final int attended;
  final int certs;
  final int reviews;
  final VoidCallback onEdit;
  final VoidCallback onToggleReg;
  final VoidCallback onMarkAllAttended;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final available = math.max(160.0, screenW - 48);
    final width = available < 420 ? available : math.min(360.0, available);

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.titleEn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${session.cityLabel(false)} · ${session.branchLabel(false)} · ${session.timeLabelEn}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSoft),
            ),
            Text(
              session.venueEn,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('Seats ${session.availableSeats}/${session.totalSeats}'),
                _chip(session.registrationOpen ? 'Open' : 'Closed'),
                _chip('$regs registered'),
                _chip('$attended attended'),
                _chip('$certs certificates'),
                _chip('$reviews reviews'),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                TextButton(
                  onPressed: onToggleReg,
                  child: Text(
                    session.registrationOpen ? 'Close reg.' : 'Open reg.',
                  ),
                ),
                TextButton(
                  onPressed: onMarkAllAttended,
                  child: const Text('Mark all attended'),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          t,
          style: const TextStyle(fontSize: 11, color: AppColors.textSoft),
        ),
      );
}
