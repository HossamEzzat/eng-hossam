import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/session_repository.dart';
import 'package:lumina/data/services/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore.instance;
    store.registrations.clear();
    store.reviews.clear();
    store.syncOfficialFromCatalog();
    await store.hydrate(force: true);
  });

  test('Firebase flags: data on, auth off until Console ready', () {
    expect(AppConstants.useFirebase, isTrue);
    expect(AppConstants.useFirebaseAuth, isFalse);
  });

  test('local register path still works when repository has no Firestore',
      () async {
    final repo = SessionRepository(forceLocal: true);
    expect(repo.store.registrations, isEmpty);

    final entry = await repo.register(
      fullName: 'Test Student',
      mobile: '01011112222',
      schoolName: 'Test School',
      grade: 'الصف الأول الثانوي',
    );
    expect(entry.registrationId, startsWith('REG-2026-'));
    expect(SessionStore.instance.registrations.length, 1);
  });

  test('Registration.toMap includes fields required by Firestore rules', () {
    final r = Registration(
      id: 'abc',
      registrationId: 'REG-2026-ABCD',
      fullName: 'علي',
      mobile: '01012345678',
      schoolName: 'مدرسة',
      grade: 'الصف الأول الثانوي',
      sessionId: 'ses_glc_opening',
      sessionLabel: 'جلسة',
      createdAt: DateTime(2026, 8, 4),
      createdBy: 'public',
    );
    final map = r.toMap();
    for (final key in [
      'registrationId',
      'fullName',
      'mobile',
      'schoolName',
      'grade',
      'sessionId',
      'createdAt',
      'createdBy',
    ]) {
      expect(map.containsKey(key), isTrue, reason: 'missing $key');
    }
    expect(map['createdBy'], 'public');
  });
}
