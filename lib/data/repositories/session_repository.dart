import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/services/session_store.dart';

class SessionRepository {
  SessionRepository({
    FirebaseFirestore? firestore,
    bool forceLocal = false,
  }) : _firestore = forceLocal
            ? null
            : (firestore ??
                (AppConstants.useFirebase ? FirebaseFirestore.instance : null));

  final FirebaseFirestore? _firestore;
  final SessionStore _store = SessionStore.instance;

  static const _regsCollection = 'registrations';

  SessionStore get store => _store;

  bool get _remote => AppConstants.useFirebase && _firestore != null;

  /// Pull all registrations from Firestore into the local cache/admin list.
  Future<void> syncFromRemote() async {
    if (!_remote) return;
    try {
      final snap = await _firestore!.collection(_regsCollection).get();
      final list = snap.docs
          .map((d) => Registration.fromMap(d.id, d.data()))
          .toList();
      _store.replaceRegistrations(list);
      debugPrint('syncFromRemote: ${list.length} registrations');
    } catch (e, st) {
      debugPrint('syncFromRemote failed: $e');
      debugPrint('$st');
    }
  }

  Future<Registration> register({
    required String fullName,
    required String mobile,
    String schoolName = '',
    String grade = '',
    String? sessionId,
  }) async {
    final official = SessionCatalog.official;
    if (!_remote) {
      final entry = _store.register(
        fullName: fullName,
        mobile: mobile,
        schoolName: schoolName,
        grade: grade,
      );
      await _store.ensurePersisted();
      return entry;
    }

    if (!official.registrationOpen) {
      throw StateError('التسجيل مغلق لهذه الجلسة.');
    }

    // Reuse existing registration for the same mobile (name+phone flow).
    final existing = await findCertificate(mobile.trim());
    if (existing != null) return existing;

    final doc = _firestore!.collection(_regsCollection).doc();
    final short = doc.id.length >= 4
        ? doc.id.substring(0, 4).toUpperCase()
        : doc.id.toUpperCase();
    final entry = Registration(
      id: doc.id,
      registrationId: 'REG-2026-$short',
      fullName: fullName.trim(),
      mobile: mobile.trim(),
      schoolName: schoolName.trim(),
      grade: grade.trim(),
      sessionId: official.id,
      sessionLabel: official.displayLabel(true),
      createdAt: DateTime.now(),
      city: official.cityKey,
    );
    await doc.set(entry.toMap());
    // Keep admin list (SessionStore) in sync with Firestore writes.
    _store.adoptRegistration(entry);
    return entry;
  }

  Future<Registration?> findCertificate(String query) async {
    if (!_remote) {
      return _store.findByMobileOrId(query);
    }
    // Prefer local cache first (fresh after sync / recent register).
    final local = _store.findByMobileOrId(query);
    if (local != null) return local;

    final q = query.trim();
    for (final field in ['registrationId', 'mobile', 'fullName', 'phone']) {
      final snap = await _firestore!
          .collection(_regsCollection)
          .where(field, isEqualTo: q)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final entry =
            Registration.fromMap(snap.docs.first.id, snap.docs.first.data());
        _store.adoptRegistration(entry);
        return entry;
      }
    }
    return null;
  }

  Future<Review> submitReview({
    required double rating,
    required String comment,
    String suggestions = '',
    String? name,
    String? registrationId,
    String? mobile,
  }) async {
    // Real students only (name + phone). No fabricated reviews.
    if (!_remote) {
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
    if (student.reviewSubmitted) {
      throw StateError('Review already submitted.');
    }

    final doc = _firestore!.collection('reviews').doc();
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
    await _firestore.collection(_regsCollection).doc(student.id).update({
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
    if (!_remote) {
      _store.markCertificateDownloaded(id);
      return;
    }
    await _firestore!.collection(_regsCollection).doc(id).update({
      'certificateDownloaded': true,
      'certificateDownloadedAt': DateTime.now().toIso8601String(),
    });
    _store.markCertificateDownloaded(id);
  }

  Future<void> approveCertificate(String id, {required bool approved}) async {
    if (!_remote) {
      _store.approveCertificate(id, approved: approved);
      return;
    }
    await _firestore!.collection(_regsCollection).doc(id).update({
      'attendanceConfirmed': approved,
      'certificateIssued': approved,
      'certificateApproved': approved,
      if (approved) 'attendanceDate': DateTime.now().toIso8601String(),
      if (approved) 'certificateIssuedAt': DateTime.now().toIso8601String(),
    });
    _store.approveCertificate(id, approved: approved);
  }

  Future<void> setAttendance(String id, {required bool attended}) async {
    _store.setAttendance(id, attended: attended);
    if (!_remote) return;
    await _firestore!.collection(_regsCollection).doc(id).update({
      'attendanceConfirmed': attended,
      'attendanceStatus': attended ? 'attended' : 'pending',
      if (attended) 'attendanceDate': DateTime.now().toIso8601String(),
      if (!attended) 'attendanceDate': null,
      if (!attended) 'certificateIssued': false,
      if (!attended) 'certificateDownloaded': false,
    });
  }

  Future<void> setCertificateIssued(String id, {required bool issued}) async {
    _store.setCertificateIssued(id, issued: issued);
    if (!_remote) return;
    await _firestore!.collection(_regsCollection).doc(id).update({
      'certificateIssued': issued,
      if (issued) 'certificateIssuedAt': DateTime.now().toIso8601String(),
      if (!issued) 'certificateIssuedAt': null,
      if (!issued) 'certificateDownloaded': false,
    });
  }

  Future<void> bulkSetAttendance(
    List<String> ids, {
    required bool attended,
  }) async {
    _store.bulkSetAttendance(ids, attended: attended);
    if (!_remote || ids.isEmpty) return;
    final batch = _firestore!.batch();
    final now = DateTime.now().toIso8601String();
    for (final id in ids) {
      batch.update(_firestore.collection(_regsCollection).doc(id), {
        'attendanceConfirmed': attended,
        'attendanceStatus': attended ? 'attended' : 'pending',
        if (attended) 'attendanceDate': now,
        if (!attended) 'attendanceDate': null,
        if (!attended) 'certificateIssued': false,
        if (!attended) 'certificateDownloaded': false,
      });
    }
    await batch.commit();
  }

  Future<void> bulkSetCertificateIssued(
    List<String> ids, {
    required bool issued,
  }) async {
    _store.bulkSetCertificateIssued(ids, issued: issued);
    if (!_remote || ids.isEmpty) return;
    final batch = _firestore!.batch();
    final now = DateTime.now().toIso8601String();
    for (final id in ids) {
      batch.update(_firestore.collection(_regsCollection).doc(id), {
        'certificateIssued': issued,
        if (issued) 'certificateIssuedAt': now,
        if (!issued) 'certificateIssuedAt': null,
        if (!issued) 'certificateDownloaded': false,
      });
    }
    await batch.commit();
  }

  Future<void> deleteRegistrations(List<String> ids) async {
    _store.deleteRegistrations(ids);
    if (!_remote || ids.isEmpty) return;
    final batch = _firestore!.batch();
    for (final id in ids) {
      batch.delete(_firestore.collection(_regsCollection).doc(id));
    }
    await batch.commit();
  }
}
