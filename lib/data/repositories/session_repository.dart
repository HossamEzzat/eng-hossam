import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/services/session_store.dart';

class SessionRepository {
  SessionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (AppConstants.useFirebase ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;
  final SessionStore _store = SessionStore.instance;

  SessionStore get store => _store;

  Future<Registration> register({
    required String fullName,
    required String mobile,
    required String schoolName,
    required String grade,
    required String sessionId,
  }) async {
    if (!AppConstants.useFirebase || _firestore == null) {
      return _store.register(
        fullName: fullName,
        mobile: mobile,
        schoolName: schoolName,
        grade: grade,
        sessionId: sessionId,
      );
    }

    final doc = _firestore.collection('registrations').doc();
    final session = _store.sessions.firstWhere((s) => s.id == sessionId);
    final entry = Registration(
      id: doc.id,
      registrationId: 'REG-2026-${doc.id.substring(0, 4).toUpperCase()}',
      fullName: fullName.trim(),
      mobile: mobile.trim(),
      schoolName: schoolName.trim(),
      grade: grade.trim(),
      sessionId: sessionId,
      sessionLabel:
          '${session.gradeLabel(true)} · ${session.branchLabel(true)} · ${session.timeLabelAr}',
      createdAt: DateTime.now(),
      city: 'suez',
    );
    await doc.set(entry.toMap());
    return entry;
  }

  Future<Registration?> findCertificate(String query) async {
    if (!AppConstants.useFirebase || _firestore == null) {
      return _store.findByMobileOrId(query);
    }
    final q = query.trim();
    for (final field in ['registrationId', 'mobile', 'fullName']) {
      final snap = await _firestore
          .collection('registrations')
          .where(field, isEqualTo: q)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return Registration.fromMap(snap.docs.first.id, snap.docs.first.data());
      }
    }
    return null;
  }

  Future<Review> submitReview({
    required double rating,
    required String comment,
    required String suggestions,
    String? name,
    String? registrationId,
    String? mobile,
  }) async {
    // Strict policy: only real eligible students; never invent reviews.
    if (!AppConstants.useFirebase || _firestore == null) {
      return _store.addReview(
        rating: rating,
        comment: comment,
        suggestions: suggestions,
        name: name,
        registrationId: registrationId,
        mobile: mobile,
      );
    }

    final student = await findCertificate(registrationId ?? mobile ?? '');
    if (student == null) {
      throw StateError('Review requires a registered student.');
    }
    if (!student.attendanceConfirmed || !student.certificateDownloaded) {
      throw StateError('Journey not unlocked for review.');
    }
    if (student.reviewSubmitted) {
      throw StateError('Review already submitted.');
    }

    final doc = _firestore.collection('reviews').doc();
    final entry = Review(
      id: doc.id,
      rating: rating,
      comment: comment.trim(),
      suggestions: suggestions.trim(),
      createdAt: DateTime.now(),
      name: name?.trim().isEmpty == true ? student.fullName : name?.trim(),
      registrationId: student.registrationId,
      studentId: student.id,
      status: ReviewModerationStatus.pending,
    );
    await doc.set(entry.toMap());
    await _firestore.collection('registrations').doc(student.id).update({
      'reviewSubmitted': true,
      'reviewSubmittedAt': entry.createdAt.toIso8601String(),
      'rating': rating,
      'review': entry.comment,
      'reviewId': entry.id,
    });
    _store.markReviewSubmitted(
      registrationId: student.registrationId,
      mobile: student.mobile,
      rating: rating,
      comment: entry.comment,
      reviewId: entry.id,
    );
    return entry;
  }

  Future<void> markCertificateDownloaded(String id) async {
    if (!AppConstants.useFirebase || _firestore == null) {
      _store.markCertificateDownloaded(id);
      return;
    }
    await _firestore.collection('registrations').doc(id).update({
      'certificateDownloaded': true,
    });
    _store.markCertificateDownloaded(id);
  }

  Future<void> approveCertificate(String id, {required bool approved}) async {
    if (!AppConstants.useFirebase || _firestore == null) {
      _store.approveCertificate(id, approved: approved);
      return;
    }
    await _firestore.collection('registrations').doc(id).update({
      'attendanceConfirmed': approved,
      'certificateIssued': approved,
      'certificateApproved': approved,
    });
    _store.approveCertificate(id, approved: approved);
  }

  Future<void> setAttendance(String id, {required bool attended}) async {
    _store.setAttendance(id, attended: attended);
  }

  Future<void> setCertificateIssued(String id, {required bool issued}) async {
    _store.setCertificateIssued(id, issued: issued);
  }
}
