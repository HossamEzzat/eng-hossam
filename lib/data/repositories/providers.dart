import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/repositories/session_repository.dart';
import 'package:lumina/data/services/session_store.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final sessionStoreProvider = ChangeNotifierProvider<SessionStore>((ref) {
  final store = SessionStore.instance;
  // Refresh from Firestore so admin (and cache) stay cross-device.
  if (AppConstants.useFirebase) {
    Future.microtask(() async {
      await ref.read(sessionRepositoryProvider).syncFromRemote();
    });
  }
  return store;
});

/// Explicit refresh for admin Students page / pull-to-refresh.
final remoteSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  if (!AppConstants.useFirebase) return;
  await ref.read(sessionRepositoryProvider).syncFromRemote();
});

/// students, apps, academies, awards, avgRating — real counts only.
final statsProvider = Provider<(int, int, int, int, double)>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return (
    store.registeredCount,
    AppConstants.companies.length,
    AppConstants.academies.length,
    AppConstants.awards.length,
    store.averageRating,
  );
});
