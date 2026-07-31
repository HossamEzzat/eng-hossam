import 'package:flutter/foundation.dart';
import 'package:lumina/data/models/admin_models.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:uuid/uuid.dart';

class SessionStore extends ChangeNotifier {
  SessionStore._() {
    _seed();
  }

  static final SessionStore instance = SessionStore._();
  final _uuid = const Uuid();

  final List<OpeningSession> sessions =
      List<OpeningSession>.from(SessionCatalog.upcoming);
  final List<Registration> registrations = [];
  final List<Review> reviews = [];

  /// Singleton store is shared across the app and Riverpod containers.
  /// Riverpod's ChangeNotifierProvider would otherwise permanently dispose it
  /// on tear-down (widget tests / hot restart), so dispose is a no-op.
  @override
  // ignore: must_call_super
  void dispose() {}

  /// Reviews list starts empty by design.
  /// Never seed, invent, or hardcode testimonials.
  void _seed() {
    final now = DateTime.now();
    registrations.addAll([
      Registration(
        id: 'seed_1',
        registrationId: 'REG-2026-1001',
        fullName: 'يوسف علي',
        mobile: '01012345678',
        schoolName: 'مدرسة STEM الزقازيق',
        grade: 'الصف الأول الثانوي',
        sessionId: 'ses_suez_2nd_suez',
        sessionLabel: 'الثاني الثانوي · فرع السويس · ١–٣ ظهرًا',
        createdAt: now.subtract(const Duration(days: 2)),
        city: 'suez',
        attendanceConfirmed: true,
        attendanceDate: now.subtract(const Duration(days: 1)),
        certificateIssued: true,
        certificateIssuedAt: now.subtract(const Duration(days: 1)),
      ),
      Registration(
        id: 'seed_2',
        registrationId: 'REG-2026-1002',
        fullName: 'سارة محمد',
        mobile: '01098765432',
        schoolName: 'مدرسة السويس الثانوية',
        grade: 'الصف الأول الثانوي',
        sessionId: 'ses_suez_1st_suez',
        sessionLabel: 'الأول الثانوي · فرع السويس · ٣–٥ عصرًا',
        createdAt: now.subtract(const Duration(days: 1)),
        city: 'suez',
      ),
    ]);
  }

  /// Inflated for public marketing only — never use in admin.
  int get displaySocialProofRegistered => registrations.length + 248;
  int get displaySocialProofCertificates =>
      registrations.where((r) => r.certificateIssued).length + 290;

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
    required String schoolName,
    required String grade,
    required String sessionId,
  }) {
    final session = sessions.firstWhere((s) => s.id == sessionId);
    if (!session.registrationOpen) {
      throw StateError('التسجيل مغلق لهذه الجلسة.');
    }
    if (session.remainingSeats <= 0) {
      throw StateError('الجلسة دي امتلأت بالكامل.');
    }

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
      sessionId: sessionId,
      sessionLabel:
          '${session.gradeLabel(true)} · ${session.branchLabel(true)} · ${session.timeLabelAr}',
      createdAt: DateTime.now(),
      city: session.cityKey,
    );
    registrations.insert(0, entry);
    final i = sessions.indexWhere((s) => s.id == sessionId);
    sessions[i] =
        sessions[i].copyWith(remainingSeats: sessions[i].remainingSeats - 1);
    notifyListeners();
    return entry;
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
  }

  void bulkSetAttendance(List<String> ids, {required bool attended}) {
    for (final id in ids) {
      setAttendance(id, attended: attended);
    }
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
  }

  void bulkSetCertificateIssued(List<String> ids, {required bool issued}) {
    for (final id in ids) {
      setCertificateIssued(id, issued: issued);
    }
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
  }

  Review addReview({
    required double rating,
    required String comment,
    required String suggestions,
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
    if (!student.attendanceConfirmed) {
      throw StateError('Attend the session before reviewing.');
    }
    if (!student.certificateDownloaded) {
      throw StateError('Download your certificate before reviewing.');
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
  }

  void deleteReview(String id) {
    reviews.removeWhere((r) => r.id == id);
    notifyListeners();
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
  }

  void upsertSession(OpeningSession session) {
    final i = sessions.indexWhere((s) => s.id == session.id);
    if (i < 0) {
      sessions.add(session);
    } else {
      sessions[i] = session;
    }
    notifyListeners();
  }

  void deleteSession(String id) {
    if (registrations.any((r) => r.sessionId == id)) return;
    sessions.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setRegistrationOpen(String id, {required bool open}) {
    final i = sessions.indexWhere((s) => s.id == id);
    if (i < 0) return;
    sessions[i] = sessions[i].copyWith(registrationOpen: open);
    notifyListeners();
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
}
