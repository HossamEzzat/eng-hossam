import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminExportsPage extends ConsumerWidget {
  const AdminExportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);
    final filtered = ref.watch(filteredStudentsProvider);
    final export = ref.watch(adminExportServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Exports',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Download CSV, Excel, or printable PDF attendance sheets.',
          style: TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 24),
        _section(
          context,
          title: 'Students',
          children: [
            _btn('All students (CSV)', () {
              export.downloadCsv(
                'students_all.csv',
                export.studentsCsv(store.registrations),
              );
              adminSnack(context, 'CSV downloaded');
            }),
            _btn('Filtered students (CSV)', () {
              export.downloadCsv(
                'students_filtered.csv',
                export.studentsCsv(filtered),
              );
              adminSnack(context, 'CSV downloaded');
            }),
            _btn('All students (Excel)', () {
              export.downloadExcel(
                'students_all.xlsx',
                export.studentsExcel(store.registrations),
              );
              adminSnack(context, 'Excel downloaded');
            }),
            _btn('Attendance list (CSV)', () {
              final list = store.registrations
                  .where((r) => r.attendanceConfirmed)
                  .toList();
              export.downloadCsv(
                'attendance_list.csv',
                export.studentsCsv(list),
              );
            }),
            _btn('Certificate list (CSV)', () {
              final list = store.registrations
                  .where((r) => r.certificateIssued)
                  .toList();
              export.downloadCsv(
                'certificates.csv',
                export.studentsCsv(list),
              );
            }),
          ],
        ),
        _section(
          context,
          title: 'Reviews',
          children: [
            _btn('All reviews (CSV)', () {
              export.downloadCsv(
                'reviews.csv',
                export.reviewsCsv(store.reviews),
              );
            }),
          ],
        ),
        _section(
          context,
          title: 'Attendance sheets (PDF)',
          children: [
            for (final s in store.sessions)
              _btn('${s.titleEn} sheet', () async {
                final students = store.registrations
                    .where((r) => r.sessionId == s.id)
                    .toList();
                final bytes = await export.attendanceSheetPdf(
                  sessionTitle: s.titleEn,
                  students: students,
                );
                export.downloadPdf(
                  'attendance_${s.id}.pdf',
                  bytes,
                );
                if (context.mounted) {
                  adminSnack(context, 'Attendance PDF ready');
                }
              }),
          ],
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onPressed) {
    return FilledButton.tonal(onPressed: onPressed, child: Text(label));
  }
}
