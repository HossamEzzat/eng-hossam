import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/repositories/session_repository.dart';
import 'package:lumina/data/services/session_store.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final sessionStoreProvider = ChangeNotifierProvider<SessionStore>((ref) {
  return SessionStore.instance;
});

/// students, apps, academies, awards, avgRating (public marketing counts)
final statsProvider = Provider<(int, int, int, int, double)>((ref) {
  final store = ref.watch(sessionStoreProvider);
  return (
    store.displaySocialProofRegistered,
    10,
    AppConstants.academies.length,
    AppConstants.awards.length,
    store.averageRating,
  );
});
