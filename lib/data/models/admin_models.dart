import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';

/// Filter + sort state for admin student management.
class StudentFilters {
  const StudentFilters({
    this.query = '',
    this.sessionId,
    this.grade,
    this.city,
    this.school,
    this.attendanceStatus,
    this.certificateStatus,
    this.reviewStatus,
    this.registeredFrom,
    this.registeredTo,
  });

  final String query;
  final String? sessionId;
  final String? grade;
  final String? city;
  final String? school;
  final String? attendanceStatus;
  final String? certificateStatus;
  final String? reviewStatus;
  final DateTime? registeredFrom;
  final DateTime? registeredTo;

  StudentFilters copyWith({
    String? query,
    String? sessionId,
    bool clearSessionId = false,
    String? grade,
    bool clearGrade = false,
    String? city,
    bool clearCity = false,
    String? school,
    bool clearSchool = false,
    String? attendanceStatus,
    bool clearAttendance = false,
    String? certificateStatus,
    bool clearCertificate = false,
    String? reviewStatus,
    bool clearReview = false,
    DateTime? registeredFrom,
    bool clearFrom = false,
    DateTime? registeredTo,
    bool clearTo = false,
  }) {
    return StudentFilters(
      query: query ?? this.query,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      grade: clearGrade ? null : (grade ?? this.grade),
      city: clearCity ? null : (city ?? this.city),
      school: clearSchool ? null : (school ?? this.school),
      attendanceStatus:
          clearAttendance ? null : (attendanceStatus ?? this.attendanceStatus),
      certificateStatus: clearCertificate
          ? null
          : (certificateStatus ?? this.certificateStatus),
      reviewStatus: clearReview ? null : (reviewStatus ?? this.reviewStatus),
      registeredFrom: clearFrom ? null : (registeredFrom ?? this.registeredFrom),
      registeredTo: clearTo ? null : (registeredTo ?? this.registeredTo),
    );
  }

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      sessionId != null ||
      grade != null ||
      city != null ||
      school != null ||
      attendanceStatus != null ||
      certificateStatus != null ||
      reviewStatus != null ||
      registeredFrom != null ||
      registeredTo != null;

  List<Registration> apply(
    List<Registration> source, {
    List<OpeningSession> sessions = const [],
  }) {
    final q = query.trim().toLowerCase();
    return source.where((r) {
      if (q.isNotEmpty) {
        final hit = r.fullName.toLowerCase().contains(q) ||
            r.mobile.contains(q) ||
            r.registrationId.toLowerCase().contains(q) ||
            r.schoolName.toLowerCase().contains(q);
        if (!hit) return false;
      }
      if (sessionId != null && r.sessionId != sessionId) return false;
      if (grade != null && r.grade != grade) return false;
      if (school != null && r.schoolName != school) return false;
      if (city != null) {
        final sessionCity = sessions
            .where((s) => s.id == r.sessionId)
            .map((s) => s.cityKey)
            .firstOrNull;
        final c = r.city.isNotEmpty ? r.city : (sessionCity ?? '');
        if (c != city) return false;
      }
      if (attendanceStatus != null && r.attendanceStatus != attendanceStatus) {
        return false;
      }
      if (certificateStatus != null &&
          r.certificateStatus != certificateStatus) {
        return false;
      }
      if (reviewStatus != null && r.reviewStatus != reviewStatus) {
        return false;
      }
      if (registeredFrom != null &&
          r.createdAt.isBefore(registeredFrom!)) {
        return false;
      }
      if (registeredTo != null &&
          r.createdAt.isAfter(
            registeredTo!.add(const Duration(days: 1)),
          )) {
        return false;
      }
      return true;
    }).toList();
  }
}

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalStudents,
    required this.newToday,
    required this.upcomingSessions,
    required this.attended,
    required this.certificatesIssued,
    required this.certificatesDownloaded,
    required this.reviewsSubmitted,
    required this.averageRating,
    required this.regsPerSession,
    required this.regsByGrade,
    required this.regsByCity,
    required this.attendanceRate,
    required this.downloadRate,
  });

  final int totalStudents;
  final int newToday;
  final int upcomingSessions;
  final int attended;
  final int certificatesIssued;
  final int certificatesDownloaded;
  final int reviewsSubmitted;
  final double averageRating;
  final Map<String, int> regsPerSession;
  final Map<String, int> regsByGrade;
  final Map<String, int> regsByCity;
  final double attendanceRate;
  final double downloadRate;
}
