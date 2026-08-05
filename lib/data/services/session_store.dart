import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lumina/data/models/admin_models.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// In-memory session/registration store with local persistence.
///
/// On static GitHub Pages (Firebase off), data lives in the browser's
/// SharedPreferences / localStorage for **this origin + browser only**.
/// Registrations from other phones/browsers are never received here.
class SessionStore extends ChangeNotifier {
  SessionStore._() {
    syncOfficialFromCatalog();
  }

  static final SessionStore instance = SessionStore._();
  final _uuid = const Uuid();

  static const _regsKey = 'eng_hossam_registrations_v1';
  static const _reviewsKey = 'eng_hossam_reviews_v1';
  static const _sessionMetaKey = 'eng_hossam_session_meta_v1';

  /// Older / exploratory keys — read once for migration if present.
  static const _legacyRegKeys = [
    'eng_hossam_registrations',
    'lumina_registrations',
    'registrations',
    'session_registrations',
    'students',
  ];

  final List<OpeningSession> sessions =
      List<OpeningSession>.from(SessionCatalog.upcoming);
  final List<Registration> registrations = [];
  final List<Review> reviews = [];

  bool _hydrated = false;
  bool get isHydrated => _hydrated;
  Future<void>? _persistFuture;

  /// Wait until the latest localStorage write finishes (tests / cold start).
  Future<void> ensurePersisted() async {
    final pending = _persistFuture;
    if (pending != null) await pending;
  }

  /// Official GLC session from the in-memory list (catalog-seeded / date-locked).
  OpeningSession get officialSession {
    final i = sessions.indexWhere((s) => s.id == SessionCatalog.officialId);
    return i >= 0 ? sessions[i] : SessionCatalog.official;
  }

  /// Singleton store is shared across the app and Riverpod containers.
  /// Riverpod's ChangeNotifierProvider would otherwise permanently dispose it
  /// on tear-down (widget tests / hot restart), so dispose is a no-op.
  @override
  // ignore: must_call_super
  void dispose() {}

  /// Force official session schedule fields from [SessionCatalog] so a stale
  /// in-memory admin edit (or future persistence) cannot show the wrong date.
  void syncOfficialFromCatalog() {
    final catalog = SessionCatalog.official;
    final i = sessions.indexWhere((s) => s.id == SessionCatalog.officialId);
    if (i < 0) {
      sessions
        ..clear()
        ..add(catalog);
      return;
    }
    final current = sessions[i];
    final seatsTaken = current.totalSeats - current.remainingSeats;
    sessions[i] = catalog.copyWith(
      remainingSeats:
          (catalog.totalSeats - seatsTaken).clamp(0, catalog.totalSeats),
      registrationOpen: current.registrationOpen,
    );
  }

  /// Load persisted registrations/reviews (and migrate legacy keys / session IDs).
  /// Call once from [main] before [runApp]. Demo seed students are NOT loaded.
  Future<void> hydrate({bool force = false}) async {
    await ensurePersisted();
    if (_hydrated && !force) return;
    syncOfficialFromCatalog();
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = <Registration>[];

      final primary = prefs.getString(_regsKey);
      if (primary != null && primary.isNotEmpty) {
        loaded.addAll(_decodeRegistrations(primary));
      }

      // Migrate any leftover keys so existing browser data is not lost.
      for (final key in _legacyRegKeys) {
        final raw = prefs.getString(key);
        if (raw == null || raw.isEmpty) continue;
        for (final r in _decodeRegistrations(raw)) {
          if (!loaded.any((e) => e.id == r.id || e.registrationId == r.registrationId)) {
            loaded.add(r);
          }
        }
        await prefs.remove(key);
      }

      // Also scan for any other key that looks like a registration JSON list.
      for (final key in prefs.getKeys()) {
        if (key == _regsKey || _legacyRegKeys.contains(key)) continue;
        final lower = key.toLowerCase();
        if (!lower.contains('regist') && !lower.contains('student')) continue;
        final raw = prefs.getString(key);
        if (raw == null || raw.isEmpty || !raw.trimLeft().startsWith('[')) {
          continue;
        }
        for (final r in _decodeRegistrations(raw)) {
          if (!loaded.any((e) => e.id == r.id || e.registrationId == r.registrationId)) {
            loaded.add(r);
          }
        }
      }

      final migrated = loaded.map(_migrateRegistration).toList();
      migrated.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      registrations
        ..clear()
        ..addAll(migrated);

      final reviewsRaw = prefs.getString(_reviewsKey);
      if (reviewsRaw != null && reviewsRaw.isNotEmpty) {
        reviews
          ..clear()
          ..addAll(_decodeReviews(reviewsRaw));
      }

      final metaRaw = prefs.getString(_sessionMetaKey);
      if (metaRaw != null && metaRaw.isNotEmpty) {
        _applySessionMeta(metaRaw);
      }

      _recomputeOfficialSeats();
      await _persistAll();
    } catch (e, st) {
      debugPrint('SessionStore.hydrate failed: $e');
      debugPrint('$st');
    }
    _hydrated = true;
    notifyListeners();
  }

  /// Replace in-memory registrations (e.g. after a Firestore pull) and persist.
  void replaceRegistrations(List<Registration> list) {
    registrations
      ..clear()
      ..addAll(list.map(_migrateRegistration));
    registrations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _recomputeOfficialSeats();
    notifyListeners();
    _persistAll();
  }

  /// Replace in-memory reviews (e.g. after a Firestore pull) and persist.
  void replaceReviews(List<Review> list) {
    reviews
      ..clear()
      ..addAll(list);
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
    _persistAll();
  }

  /// Insert or update a review already saved in Firestore.
  void adoptReview(Review entry) {
    final i = reviews.indexWhere((r) => r.id == entry.id);
    if (i >= 0) {
      reviews[i] = entry;
    } else {
      reviews.insert(0, entry);
    }
    notifyListeners();
    _persistAll();
  }

  /// Public marketing counts — real registrations only (no inflated demos).
  int get displaySocialProofRegistered => registrations.length;
  int get displaySocialProofCertificates =>
      registrations.where((r) => r.certificateIssued).length;

  int get registeredCount => registrations.length;
  int get certificatesIssuedCount =>
      registrations.where((r) => r.certificateIssued).length;

  List<Review> get publicReviews =>
      reviews.where((r) => r.isPublic).toList(growable: false);

  double get averageRating {
    final list = publicReviews;
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (a, b) => a + b.rating) / list.length;
  }

  Registration register({
    required String fullName,
    required String mobile,
    String schoolName = '',
    String grade = '',
    String? sessionId,
  }) {
    // Always assign the single official opening session.
    final targetId = SessionCatalog.officialId;
    final session = sessions.firstWhere(
      (s) => s.id == targetId,
      orElse: () => SessionCatalog.official,
    );
    if (!session.registrationOpen) {
      throw StateError('التسجيل مغلق لهذه الجلسة.');
    }
    if (session.remainingSeats <= 0) {
      throw StateError('الجلسة دي امتلأت بالكامل.');
    }

    final existing = findByMobileOrId(mobile.trim());
    if (existing != null) return existing;

    final id = _uuid.v4();
    final regId =
        'REG-2026-${(1000 + registrations.length + 1).toString().padLeft(4, '0')}';
    final entry = Registration(
      id: id,
      registrationId: regId,
      fullName: fullName.trim(),
      mobile: mobile.trim(),
      schoolName: schoolName.trim(),
      grade: grade.trim(),
      sessionId: session.id,
      sessionLabel: session.displayLabel(true),
      createdAt: DateTime.now(),
      city: session.cityKey,
    );
    registrations.insert(0, entry);
    final i = sessions.indexWhere((s) => s.id == session.id);
    if (i >= 0) {
      sessions[i] =
          sessions[i].copyWith(remainingSeats: sessions[i].remainingSeats - 1);
    }
    notifyListeners();
    _persistAll();
    return entry;
  }

  /// Insert a registration already saved elsewhere (e.g. Firestore) into the
  /// local admin list without re-checking seats.
  void adoptRegistration(Registration entry) {
    final migrated = _migrateRegistration(entry);
    final existing = registrations.indexWhere(
      (r) => r.id == migrated.id || r.registrationId == migrated.registrationId,
    );
    if (existing >= 0) {
      registrations[existing] = migrated;
    } else {
      registrations.insert(0, migrated);
      final i = sessions.indexWhere((s) => s.id == migrated.sessionId);
      if (i >= 0 && sessions[i].remainingSeats > 0) {
        sessions[i] = sessions[i]
            .copyWith(remainingSeats: sessions[i].remainingSeats - 1);
      }
    }
    notifyListeners();
    _persistAll();
  }

  Registration? findByMobileOrId(String query) {
    final q = query.trim().toLowerCase().replaceAll(' ', '');
    if (q.isEmpty) return null;
    try {
      return registrations.firstWhere((r) {
        final mobile = r.mobile.replaceAll(' ', '').toLowerCase();
        return r.registrationId.toLowerCase() == q ||
            mobile == q ||
            r.fullName.toLowerCase() == query.trim().toLowerCase();
      });
    } catch (_) {
      return null;
    }
  }

  List<Registration> search(String query) {
    return StudentFilters(query: query).apply(registrations, sessions: sessions);
  }

  List<Registration> filterStudents(StudentFilters filters) =>
      filters.apply(registrations, sessions: sessions);

  void setAttendance(String id, {required bool attended}) {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i < 0) return;
    if (attended) {
      registrations[i] = registrations[i].copyWith(
        attendanceConfirmed: true,
        attendanceDate: DateTime.now(),
      );
    } else {
      registrations[i] = registrations[i].copyWith(
        attendanceConfirmed: false,
        clearAttendanceDate: true,
        certificateIssued: false,
        clearCertificateIssuedAt: true,
        certificateDownloaded: false,
        clearCertificateDownloadedAt: true,
      );
    }
    notifyListeners();
    _persistAll();
  }

  void bulkSetAttendance(List<String> ids, {required bool attended}) {
    for (final id in ids) {
      final i = registrations.indexWhere((r) => r.id == id);
      if (i < 0) continue;
      if (attended) {
        registrations[i] = registrations[i].copyWith(
          attendanceConfirmed: true,
          attendanceDate: DateTime.now(),
        );
      } else {
        registrations[i] = registrations[i].copyWith(
          attendanceConfirmed: false,
          clearAttendanceDate: true,
          certificateIssued: false,
          clearCertificateIssuedAt: true,
          certificateDownloaded: false,
          clearCertificateDownloadedAt: true,
        );
      }
    }
    notifyListeners();
    _persistAll();
  }

  void markSessionAttended(String sessionId) {
    final ids = registrations
        .where((r) => r.sessionId == sessionId)
        .map((r) => r.id)
        .toList();
    bulkSetAttendance(ids, attended: true);
  }

  void setCertificateIssued(String id, {required bool issued}) {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final r = registrations[i];
    if (issued && !r.attendanceConfirmed) return;
    if (issued) {
      registrations[i] = r.copyWith(
        certificateIssued: true,
        certificateIssuedAt: DateTime.now(),
      );
    } else {
      registrations[i] = r.copyWith(
        certificateIssued: false,
        clearCertificateIssuedAt: true,
        certificateDownloaded: false,
        clearCertificateDownloadedAt: true,
      );
    }
    notifyListeners();
    _persistAll();
  }

  void bulkSetCertificateIssued(List<String> ids, {required bool issued}) {
    for (final id in ids) {
      final i = registrations.indexWhere((r) => r.id == id);
      if (i < 0) continue;
      final r = registrations[i];
      if (issued && !r.attendanceConfirmed) continue;
      if (issued) {
        registrations[i] = r.copyWith(
          certificateIssued: true,
          certificateIssuedAt: DateTime.now(),
        );
      } else {
        registrations[i] = r.copyWith(
          certificateIssued: false,
          clearCertificateIssuedAt: true,
          certificateDownloaded: false,
          clearCertificateDownloadedAt: true,
        );
      }
    }
    notifyListeners();
    _persistAll();
  }

  /// Legacy: approved = attended + certificate issued.
  void approveCertificate(String id, {required bool approved}) {
    if (approved) {
      setAttendance(id, attended: true);
      setCertificateIssued(id, issued: true);
    } else {
      setAttendance(id, attended: false);
    }
  }

  void markCertificateDownloaded(String id) {
    final i = registrations.indexWhere((r) => r.id == id);
    if (i < 0) return;
    final r = registrations[i];
    if (!r.certificateIssued) return;
    registrations[i] = r.copyWith(
      certificateDownloaded: true,
      certificateDownloadedAt: DateTime.now(),
    );
    notifyListeners();
    _persistAll();
  }

  void markReviewSubmitted({
    String? registrationId,
    String? mobile,
    double? rating,
    String? comment,
    String? reviewId,
  }) {
    final i = registrations.indexWhere((r) {
      if (registrationId != null &&
          r.registrationId.toLowerCase() == registrationId.toLowerCase()) {
        return true;
      }
      if (mobile != null &&
          r.mobile.replaceAll(' ', '') == mobile.replaceAll(' ', '')) {
        return true;
      }
      return false;
    });
    if (i < 0) return;
    registrations[i] = registrations[i].copyWith(
      reviewSubmitted: true,
      reviewSubmittedAt: DateTime.now(),
      rating: rating,
      reviewComment: comment,
      reviewId: reviewId,
    );
    notifyListeners();
    _persistAll();
  }

  Review addReview({
    required double rating,
    required String comment,
    String suggestions = '',
    String? name,
    String? registrationId,
    String? mobile,
  }) {
    final student = _resolveStudent(
      registrationId: registrationId,
      mobile: mobile,
    );
    if (student == null) {
      throw StateError('Review requires a registered student.');
    }
    if (student.reviewSubmitted) {
      throw StateError('A review was already submitted for this student.');
    }

    final entry = Review(
      id: _uuid.v4(),
      rating: rating,
      comment: comment.trim(),
      suggestions: suggestions.trim(),
      createdAt: DateTime.now(),
      name: name?.trim().isEmpty == true
          ? student.fullName
          : name?.trim(),
      registrationId: student.registrationId,
      studentId: student.id,
      status: ReviewModerationStatus.pending,
    );
    reviews.insert(0, entry);
    markReviewSubmitted(
      registrationId: student.registrationId,
      mobile: student.mobile,
      rating: rating,
      comment: comment.trim(),
      reviewId: entry.id,
    );
    notifyListeners();
    _persistAll();
    return entry;
  }

  Registration? _resolveStudent({String? registrationId, String? mobile}) {
    if (registrationId != null && registrationId.trim().isNotEmpty) {
      final byId = findByMobileOrId(registrationId);
      if (byId != null) return byId;
    }
    if (mobile != null && mobile.trim().isNotEmpty) {
      return findByMobileOrId(mobile);
    }
    return null;
  }

  void setReviewStatus(String id, ReviewModerationStatus status) {
    final i = reviews.indexWhere((r) => r.id == id);
    if (i < 0) return;
    reviews[i] = reviews[i].copyWith(status: status);
    notifyListeners();
    _persistAll();
  }

  void deleteReview(String id) {
    reviews.removeWhere((r) => r.id == id);
    notifyListeners();
    _persistAll();
  }

  void deleteRegistrations(List<String> ids) {
    for (final id in ids) {
      final i = registrations.indexWhere((r) => r.id == id);
      if (i < 0) continue;
      final sessionId = registrations[i].sessionId;
      registrations.removeAt(i);
      final si = sessions.indexWhere((s) => s.id == sessionId);
      if (si >= 0) {
        sessions[si] = sessions[si].copyWith(
          remainingSeats: sessions[si].remainingSeats + 1,
        );
      }
    }
    notifyListeners();
    _persistAll();
  }

  void upsertSession(OpeningSession session) {
    // Official opening schedule is owned by SessionCatalog — never accept a
    // mutated date/labels for ses_glc_opening (keeps countdown correct).
    final OpeningSession toSave;
    if (session.id == SessionCatalog.officialId) {
      final catalog = SessionCatalog.official;
      toSave = catalog.copyWith(
        titleAr: session.titleAr,
        titleEn: session.titleEn,
        totalSeats: session.totalSeats,
        remainingSeats: session.remainingSeats,
        venueAr: session.venueAr,
        venueEn: session.venueEn,
        academyAr: session.academyAr,
        academyEn: session.academyEn,
        addressAr: session.addressAr,
        addressEn: session.addressEn,
        courseAr: session.courseAr,
        courseEn: session.courseEn,
        audienceAr: session.audienceAr,
        audienceEn: session.audienceEn,
        registrationOpen: session.registrationOpen,
        timeLabelAr: session.timeLabelAr,
        timeLabelEn: session.timeLabelEn,
      );
    } else {
      toSave = session;
    }
    final i = sessions.indexWhere((s) => s.id == toSave.id);
    if (i < 0) {
      sessions.add(toSave);
    } else {
      sessions[i] = toSave;
    }
    notifyListeners();
    _persistAll();
  }

  void deleteSession(String id) {
    if (registrations.any((r) => r.sessionId == id)) return;
    sessions.removeWhere((s) => s.id == id);
    notifyListeners();
    _persistAll();
  }

  void setRegistrationOpen(String id, {required bool open}) {
    final i = sessions.indexWhere((s) => s.id == id);
    if (i < 0) return;
    sessions[i] = sessions[i].copyWith(registrationOpen: open);
    notifyListeners();
    _persistAll();
  }

  AdminDashboardStats computeStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final total = registrations.length;
    final attended = registrations.where((r) => r.attendanceConfirmed).length;
    final issued = registrations.where((r) => r.certificateIssued).length;
    final downloaded =
        registrations.where((r) => r.certificateDownloaded).length;

    final perSession = <String, int>{};
    final byGrade = <String, int>{};
    final byCity = <String, int>{};
    for (final r in registrations) {
      final label = sessions
              .where((s) => s.id == r.sessionId)
              .map((s) => s.titleEn)
              .firstOrNull ??
          r.sessionLabel;
      perSession[label] = (perSession[label] ?? 0) + 1;
      byGrade[r.grade] = (byGrade[r.grade] ?? 0) + 1;
      final city = r.city.isNotEmpty
          ? r.city
          : (sessions
                  .where((s) => s.id == r.sessionId)
                  .map((s) => s.cityKey)
                  .firstOrNull ??
              'unknown');
      byCity[city] = (byCity[city] ?? 0) + 1;
    }

    return AdminDashboardStats(
      totalStudents: total,
      newToday: registrations.where((r) => r.createdAt.isAfter(todayStart)).length,
      upcomingSessions:
          sessions.where((s) => s.date.isAfter(now)).length,
      attended: attended,
      certificatesIssued: issued,
      certificatesDownloaded: downloaded,
      reviewsSubmitted: reviews.length,
      averageRating: averageRating,
      regsPerSession: perSession,
      regsByGrade: byGrade,
      regsByCity: byCity,
      attendanceRate: total == 0 ? 0 : attended / total,
      downloadRate: issued == 0 ? 0 : downloaded / issued,
    );
  }

  String exportCsv([List<Registration>? subset]) {
    final list = subset ?? registrations;
    final buf = StringBuffer(
      'registrationId,fullName,mobile,school,grade,city,session,registeredAt,attendance,certificate,review\n',
    );
    for (final r in list) {
      buf.writeln(
        '${r.registrationId},"${r.fullName}","${r.mobile}","${r.schoolName}","${r.grade}","${r.city}","${r.sessionLabel}",${r.createdAt.toIso8601String()},${r.attendanceStatus},${r.certificateStatus},${r.reviewStatus}',
      );
    }
    return buf.toString();
  }

  // --- persistence helpers -------------------------------------------------

  Registration _migrateRegistration(Registration r) {
    final official = SessionCatalog.official;
    final needsSessionFix = r.sessionId.isEmpty ||
        r.sessionId != SessionCatalog.officialId ||
        r.sessionLabel.trim().isEmpty;
    if (!needsSessionFix) return r;
    return r.copyWith(
      sessionId: SessionCatalog.officialId,
      sessionLabel: r.sessionLabel.trim().isEmpty
          ? official.displayLabel(true)
          : r.sessionLabel,
    );
  }

  void _recomputeOfficialSeats() {
    final catalog = SessionCatalog.official;
    final taken =
        registrations.where((r) => r.sessionId == catalog.id).length;
    final i = sessions.indexWhere((s) => s.id == catalog.id);
    if (i < 0) return;
    sessions[i] = sessions[i].copyWith(
      remainingSeats: (catalog.totalSeats - taken).clamp(0, catalog.totalSeats),
    );
  }

  List<Registration> _decodeRegistrations(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <Registration>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id'] as String? ?? _uuid.v4();
        try {
          out.add(Registration.fromMap(id, map));
        } catch (e) {
          debugPrint('Skip bad registration: $e');
        }
      }
      return out;
    } catch (e) {
      debugPrint('Failed to decode registrations: $e');
      return const [];
    }
  }

  List<Review> _decodeReviews(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final out = <Review>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id'] as String? ?? _uuid.v4();
        try {
          out.add(Review.fromMap(id, map));
        } catch (e) {
          debugPrint('Skip bad review: $e');
        }
      }
      return out;
    } catch (e) {
      debugPrint('Failed to decode reviews: $e');
      return const [];
    }
  }

  void _applySessionMeta(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final map = Map<String, dynamic>.from(decoded);
      for (final e in map.entries) {
        final i = sessions.indexWhere((s) => s.id == e.key);
        if (i < 0 || e.value is! Map) continue;
        final meta = Map<String, dynamic>.from(e.value as Map);
        sessions[i] = sessions[i].copyWith(
          remainingSeats: meta['remainingSeats'] as int? ??
              sessions[i].remainingSeats,
          registrationOpen: meta['registrationOpen'] as bool? ??
              sessions[i].registrationOpen,
        );
      }
    } catch (e) {
      debugPrint('Failed to apply session meta: $e');
    }
  }

  Future<void> _persistAll() {
    final future = _writePersist();
    _persistFuture = future;
    return future;
  }

  Future<void> _writePersist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final regsJson = jsonEncode([
        for (final r in registrations) {'id': r.id, ...r.toMap()},
      ]);
      final reviewsJson = jsonEncode([
        for (final r in reviews) {'id': r.id, ...r.toMap()},
      ]);
      final metaJson = jsonEncode({
        for (final s in sessions)
          s.id: {
            'remainingSeats': s.remainingSeats,
            'registrationOpen': s.registrationOpen,
          },
      });
      await prefs.setString(_regsKey, regsJson);
      await prefs.setString(_reviewsKey, reviewsJson);
      await prefs.setString(_sessionMetaKey, metaJson);
    } catch (e, st) {
      debugPrint('SessionStore.persist failed: $e');
      debugPrint('$st');
    }
  }
}
