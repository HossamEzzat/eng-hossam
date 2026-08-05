import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/shared/widgets/student_journey_progress.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:printing/printing.dart';

Future<void> showAdminStudentProfile(
  BuildContext context,
  Registration registration,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AdminStudentProfileSheet(registrationId: registration.id),
  );
}

class AdminStudentProfileSheet extends ConsumerWidget {
  const AdminStudentProfileSheet({super.key, required this.registrationId});

  final String registrationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);
    final r = store.registrations
        .where((e) => e.id == registrationId)
        .firstOrNull;
    if (r == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Text('Student not found'),
      );
    }
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              r.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
            ),
            Text(
              r.registrationId,
              style: const TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            _kv('Phone', r.mobile),
            _kv('Parent phone', r.parentPhone ?? '—'),
            _kv('School', r.schoolName),
            _kv('Grade', r.grade),
            _kv('City', r.city),
            _kv('Session', r.sessionLabel),
            _kv('Registered', fmt.format(r.createdAt)),
            _kv('Attendance', r.attendanceStatus),
            _kv(
              'Attendance date',
              r.attendanceDate != null ? fmt.format(r.attendanceDate!) : '—',
            ),
            _kv('Certificate', r.certificateStatus),
            _kv(
              'Issued at',
              r.certificateIssuedAt != null
                  ? fmt.format(r.certificateIssuedAt!)
                  : '—',
            ),
            _kv(
              'Downloaded at',
              r.certificateDownloadedAt != null
                  ? fmt.format(r.certificateDownloadedAt!)
                  : '—',
            ),
            _kv('Review', r.reviewStatus),
            if (r.rating != null) _kv('Rating', r.rating!.toStringAsFixed(1)),
            if (r.reviewComment != null && r.reviewComment!.isNotEmpty)
              _kv('Review content', r.reviewComment!),
            const SizedBox(height: 20),
            StudentJourneyProgress(registration: r, showActions: false),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(sessionRepositoryProvider)
                        .setAttendance(r.id, attended: true);
                    if (context.mounted) {
                      adminSnack(context, 'Marked attended');
                    }
                  },
                  child: const Text('Mark attended'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await ref
                        .read(sessionRepositoryProvider)
                        .setCertificateIssued(r.id, issued: true);
                    if (context.mounted) {
                      adminSnack(context, 'Certificate published');
                    }
                  },
                  child: const Text('Publish certificate'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await ref
                        .read(sessionRepositoryProvider)
                        .setCertificateIssued(r.id, issued: false);
                    if (context.mounted) {
                      adminSnack(context, 'Certificate unpublished');
                    }
                  },
                  child: const Text('Unpublish'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final bytes = await CertificatePdfService().build(r);
                    await Printing.layoutPdf(onLayout: (_) async => bytes);
                  },
                  child: const Text('Generate PDF'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
