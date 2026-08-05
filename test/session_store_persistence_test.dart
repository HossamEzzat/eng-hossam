import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
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

  test('real registration persists across hydrate (no demo seeds)', () async {
    final store = SessionStore.instance;
    expect(store.registrations, isEmpty);

    store.register(
      fullName: 'أحمد محمد',
      mobile: '01000000001',
      schoolName: 'مدرسة السويس',
      grade: 'الصف الأول الثانوي',
    );
    await store.ensurePersisted();
    expect(store.registrations.length, 1);
    expect(store.registrations.single.sessionId, SessionCatalog.officialId);

    store.registrations.clear();
    await store.hydrate(force: true);

    expect(store.registrations.length, 1);
    expect(store.registrations.single.fullName, 'أحمد محمد');
    expect(store.registrations.single.mobile, '01000000001');
    // Must not invent the old demo seed students.
    expect(
      store.registrations.any((r) => r.id.startsWith('seed_')),
      isFalse,
    );
  });

  test('legacy session ids migrate to official opening', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'eng_hossam_registrations_v1',
      '''
[{
  "id":"old_1",
  "registrationId":"REG-2026-2001",
  "fullName":"سارة",
  "mobile":"01099999999",
  "schoolName":"مدرسة",
  "grade":"الصف الثاني الثانوي",
  "sessionId":"ses_old_multi",
  "sessionLabel":"جلسة قديمة",
  "createdAt":"2026-08-01T10:00:00.000",
  "city":"suez"
}]
''',
    );

    final store = SessionStore.instance;
    store.registrations.clear();
    await store.hydrate(force: true);

    expect(store.registrations.length, 1);
    expect(store.registrations.single.sessionId, SessionCatalog.officialId);
    expect(store.registrations.single.fullName, 'سارة');
  });

  test('adoptRegistration remaps non-official session ids', () {
    final store = SessionStore.instance;
    store.registrations.clear();
    store.adoptRegistration(
      Registration(
        id: 'x1',
        registrationId: 'REG-2026-3001',
        fullName: 'علي',
        mobile: '01022222222',
        schoolName: 'مدرسة',
        grade: 'الصف الأول الثانوي',
        sessionId: 'ses_legacy_a',
        sessionLabel: 'legacy',
        createdAt: DateTime(2026, 8, 2),
        city: 'suez',
      ),
    );
    expect(store.registrations.single.sessionId, SessionCatalog.officialId);
  });
}
