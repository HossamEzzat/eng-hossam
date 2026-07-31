import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/data/models/admin_models.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/data/notification_outbox.dart';
import 'package:lumina/features/admin/presentation/pages/admin_student_profile_sheet.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminStudentsPage extends ConsumerStatefulWidget {
  const AdminStudentsPage({super.key});

  @override
  ConsumerState<AdminStudentsPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends ConsumerState<AdminStudentsPage> {
  final _search = TextEditingController();
  int _rowsPerPage = 25;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(sessionStoreProvider);
    final students = ref.watch(filteredStudentsProvider);
    final selected = ref.watch(selectedStudentIdsProvider);
    final filters = ref.watch(studentFiltersProvider);
    final grades = store.registrations.map((r) => r.grade).toSet().toList();
    final schools = store.registrations.map((r) => r.schoolName).toSet().toList();

    final pad = MediaQuery.sizeOf(context).width < 600 ? 12.0 : 24.0;
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Students',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${students.length} matching · ${store.registrations.length} total',
            style: const TextStyle(color: AppColors.textSoft),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _search,
            decoration: const InputDecoration(
              hintText: 'Search by ID, name, mobile, or school…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) {
              ref.read(studentFiltersProvider.notifier).state =
                  filters.copyWith(query: v);
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterDropdown(
                label: 'Session',
                value: filters.sessionId,
                items: {
                  for (final s in store.sessions) s.id: s.titleEn,
                },
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(
                  sessionId: v,
                  clearSessionId: v == null,
                ),
              ),
              _FilterDropdown(
                label: 'Grade',
                value: filters.grade,
                items: {for (final g in grades) g: g},
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(grade: v, clearGrade: v == null),
              ),
              _FilterDropdown(
                label: 'City',
                value: filters.city,
                items: const {'suez': 'Suez'},
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(city: v, clearCity: v == null),
              ),
              _FilterDropdown(
                label: 'School',
                value: filters.school,
                items: {for (final s in schools) s: s},
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(school: v, clearSchool: v == null),
              ),
              _FilterDropdown(
                label: 'Attendance',
                value: filters.attendanceStatus,
                items: const {
                  'attended': 'Attended',
                  'pending': 'Pending',
                },
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(
                  attendanceStatus: v,
                  clearAttendance: v == null,
                ),
              ),
              _FilterDropdown(
                label: 'Certificate',
                value: filters.certificateStatus,
                items: const {
                  'issued': 'Issued',
                  'downloaded': 'Downloaded',
                  'not_issued': 'Not issued',
                },
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(
                  certificateStatus: v,
                  clearCertificate: v == null,
                ),
              ),
              _FilterDropdown(
                label: 'Review',
                value: filters.reviewStatus,
                items: const {
                  'submitted': 'Submitted',
                  'pending': 'Pending',
                },
                onChanged: (v) => ref.read(studentFiltersProvider.notifier).state =
                    filters.copyWith(
                  reviewStatus: v,
                  clearReview: v == null,
                ),
              ),
              if (filters.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    _search.clear();
                    ref.read(studentFiltersProvider.notifier).state =
                        const StudentFilters();
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: 12),
            _BulkBar(
              count: selected.length,
              onAttend: () {
                store.bulkSetAttendance(selected.toList(), attended: true);
                adminSnack(context, 'Marked ${selected.length} as attended');
                ref.read(selectedStudentIdsProvider.notifier).state = {};
              },
              onIssueCerts: () {
                store.bulkSetCertificateIssued(selected.toList(), issued: true);
                ref.read(notificationDispatcherProvider).enqueue(
                      NotificationRequest(
                        kind: NotificationKind.certificateReady,
                        studentIds: selected.toList(),
                      ),
                    );
                adminSnack(context, 'Certificates issued');
                ref.read(selectedStudentIdsProvider.notifier).state = {};
              },
              onNotify: () {
                ref.read(notificationDispatcherProvider).enqueue(
                      NotificationRequest(
                        kind: NotificationKind.sessionReminder,
                        studentIds: selected.toList(),
                      ),
                    );
                adminSnack(context, 'Notification queued (not sent yet)');
              },
              onExport: () {
                final list =
                    students.where((s) => selected.contains(s.id)).toList();
                final csv = ref.read(adminExportServiceProvider).studentsCsv(list);
                ref.read(adminExportServiceProvider).downloadCsv(
                      'students_selected.csv',
                      csv,
                    );
              },
              onDelete: () async {
                final ok = await adminConfirm(
                  context,
                  title: 'Delete registrations?',
                  message: 'Delete ${selected.length} students permanently?',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (!ok) return;
                store.deleteRegistrations(selected.toList());
                ref.read(selectedStudentIdsProvider.notifier).state = {};
                if (context.mounted) {
                  adminSnack(context, 'Deleted');
                }
              },
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'No students match your filters',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final minTableWidth = 1100.0;
                      return SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: math.max(
                                constraints.maxWidth,
                                minTableWidth,
                              ),
                            ),
                            child: PaginatedDataTable(
                              header: const Text('Registrations'),
                              rowsPerPage: _rowsPerPage,
                              availableRowsPerPage: const [10, 25, 50],
                              onRowsPerPageChanged: (v) {
                                if (v != null) {
                                  setState(() => _rowsPerPage = v);
                                }
                              },
                              columns: const [
                                DataColumn(label: Text('')),
                                DataColumn(label: Text('Reg ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Mobile')),
                                DataColumn(label: Text('School')),
                                DataColumn(label: Text('Grade')),
                                DataColumn(label: Text('City')),
                                DataColumn(label: Text('Session')),
                                DataColumn(label: Text('Registered')),
                                DataColumn(label: Text('Attendance')),
                                DataColumn(label: Text('Certificate')),
                                DataColumn(label: Text('Review')),
                                DataColumn(label: Text('Actions')),
                              ],
                              source: _StudentsSource(
                                students: students,
                                selected: selected,
                                onToggle: (id, value) {
                                  final next = {...selected};
                                  if (value) {
                                    next.add(id);
                                  } else {
                                    next.remove(id);
                                  }
                                  ref
                                      .read(selectedStudentIdsProvider.notifier)
                                      .state = next;
                                },
                                onOpen: (r) =>
                                    showAdminStudentProfile(context, r),
                                onAttend: (r) {
                                  store.setAttendance(r.id, attended: true);
                                  adminSnack(context, 'Attendance saved');
                                },
                                onIssue: (r) {
                                  store.setCertificateIssued(r.id, issued: true);
                                  adminSnack(context, 'Certificate issued');
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 200),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All')),
          for (final e in items.entries)
            DropdownMenuItem(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _BulkBar extends StatelessWidget {
  const _BulkBar({
    required this.count,
    required this.onAttend,
    required this.onIssueCerts,
    required this.onNotify,
    required this.onExport,
    required this.onDelete,
  });

  final int count;
  final VoidCallback onAttend;
  final VoidCallback onIssueCerts;
  final VoidCallback onNotify;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$count selected',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          FilledButton.tonal(
            onPressed: onAttend,
            child: const Text('Mark attended'),
          ),
          FilledButton.tonal(
            onPressed: onIssueCerts,
            child: const Text('Issue certificates'),
          ),
          FilledButton.tonal(
            onPressed: onNotify,
            child: const Text('Queue notifications'),
          ),
          FilledButton.tonal(
            onPressed: onExport,
            child: const Text('Export selected'),
          ),
          TextButton(
            onPressed: onDelete,
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StudentsSource extends DataTableSource {
  _StudentsSource({
    required this.students,
    required this.selected,
    required this.onToggle,
    required this.onOpen,
    required this.onAttend,
    required this.onIssue,
  });

  final List<Registration> students;
  final Set<String> selected;
  final void Function(String id, bool value) onToggle;
  final void Function(Registration r) onOpen;
  final void Function(Registration r) onAttend;
  final void Function(Registration r) onIssue;

  final _fmt = DateFormat('yyyy-MM-dd');

  @override
  DataRow? getRow(int index) {
    if (index >= students.length) return null;
    final r = students[index];
    return DataRow(
      selected: selected.contains(r.id),
      onSelectChanged: (_) => onOpen(r),
      cells: [
        DataCell(
          Checkbox(
            value: selected.contains(r.id),
            onChanged: (v) => onToggle(r.id, v ?? false),
          ),
        ),
        DataCell(Text(r.registrationId, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.fullName, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.mobile, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.schoolName, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.grade, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.city, overflow: TextOverflow.ellipsis)),
        DataCell(Text(r.sessionLabel, overflow: TextOverflow.ellipsis)),
        DataCell(Text(_fmt.format(r.createdAt))),
        DataCell(_StatusChip(r.attendanceStatus)),
        DataCell(_StatusChip(r.certificateStatus)),
        DataCell(_StatusChip(r.reviewStatus)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Mark attended',
                onPressed: () => onAttend(r),
                icon: const Icon(Icons.how_to_reg_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Issue certificate',
                onPressed: () => onIssue(r),
                icon: const Icon(Icons.workspace_premium_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Open profile',
                onPressed: () => onOpen(r),
                icon: const Icon(Icons.open_in_new, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => students.length;

  @override
  int get selectedRowCount => selected.length;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    final color = switch (value) {
      'attended' || 'issued' || 'downloaded' || 'submitted' => AppColors.success,
      'pending' || 'not_issued' => AppColors.accent,
      _ => AppColors.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
