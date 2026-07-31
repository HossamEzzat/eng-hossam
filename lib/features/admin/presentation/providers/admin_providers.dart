import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/data/models/admin_models.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/data/admin_auth_service.dart';
import 'package:lumina/features/admin/data/admin_export_service.dart';
import 'package:lumina/features/admin/data/notification_outbox.dart';

final adminAuthProvider =
    ChangeNotifierProvider<AdminAuthService>((ref) {
  final auth = AdminAuthService();
  auth.restore();
  return auth;
});

final studentFiltersProvider =
    StateProvider<StudentFilters>((ref) => const StudentFilters());

final selectedStudentIdsProvider =
    StateProvider<Set<String>>((ref) => <String>{});

final adminStatsProvider = Provider<AdminDashboardStats>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return store.computeStats();
});

final filteredStudentsProvider = Provider<List<Registration>>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final filters = ref.watch(studentFiltersProvider);
  return store.filterStudents(filters);
});

final notificationDispatcherProvider =
    Provider<NotificationDispatcher>((ref) => NoOpNotificationDispatcher());

final adminExportServiceProvider =
    Provider<AdminExportService>((ref) => AdminExportService());
