import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/admin_models.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/auth/admin_auth_controller.dart';
import 'package:lumina/features/admin/auth/admin_auth_repository.dart';
import 'package:lumina/features/admin/auth/firebase_admin_auth_repository.dart';
import 'package:lumina/features/admin/auth/local_dev_admin_auth_repository.dart';
import 'package:lumina/features/admin/data/admin_export_service.dart';
import 'package:lumina/features/admin/data/notification_outbox.dart';

/// Swap this provider to change auth backend without touching UI.
final adminAuthRepositoryProvider = Provider<LoginRepository>((ref) {
  if (AppConstants.useFirebase) {
    return FirebaseAdminAuthRepository();
  }
  return LocalDevAdminAuthRepository();
});

final adminAuthProvider = ChangeNotifierProvider<AuthService>((ref) {
  final service = AuthService(ref.watch(adminAuthRepositoryProvider));
  service.restore();
  return service;
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
