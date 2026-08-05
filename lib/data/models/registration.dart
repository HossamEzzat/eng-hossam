/// Student registration — aligns with Firestore `students` documents.
class Registration {
  const Registration({
    required this.id,
    required this.registrationId,
    required this.fullName,
    required this.mobile,
    required this.schoolName,
    required this.grade,
    required this.sessionId,
    required this.sessionLabel,
    required this.createdAt,
    this.city = '',
    this.parentPhone,
    this.attendanceConfirmed = false,
    this.attendanceDate,
    this.certificateIssued = false,
    this.certificateIssuedAt,
    this.certificateDownloaded = false,
    this.certificateDownloadedAt,
    this.reviewSubmitted = false,
    this.reviewSubmittedAt,
    this.rating,
    this.reviewComment,
    this.reviewId,
    this.createdBy = 'public',
    this.lastUpdated,
  });

  final String id;
  final String registrationId;
  final String fullName;
  final String mobile;
  final String schoolName;
  final String grade;
  final String sessionId;
  final String sessionLabel;
  final DateTime createdAt;
  final String city;
  final String? parentPhone;

  final bool attendanceConfirmed;
  final DateTime? attendanceDate;

  final bool certificateIssued;
  final DateTime? certificateIssuedAt;

  final bool certificateDownloaded;
  final DateTime? certificateDownloadedAt;

  final bool reviewSubmitted;
  final DateTime? reviewSubmittedAt;
  final double? rating;
  final String? reviewComment;
  final String? reviewId;

  final String createdBy;
  final DateTime? lastUpdated;

  /// Instant certificate: any registered student can download immediately.
  bool get certificateApproved => true;

  String get attendanceStatus =>
      attendanceConfirmed ? 'attended' : 'pending';

  String get certificateStatus {
    if (certificateDownloaded) return 'downloaded';
    if (certificateIssued) return 'issued';
    // Eligible as soon as they register — even before the issued flag syncs.
    return 'ready';
  }

  String get reviewStatus => reviewSubmitted ? 'submitted' : 'pending';

  String get journeyStatus {
    if (reviewSubmitted) return 'completed';
    if (certificateDownloaded) return 'review';
    // Certificate is available right after registration.
    return 'certificate';
  }

  Registration copyWith({
    String? fullName,
    String? mobile,
    String? schoolName,
    String? grade,
    String? sessionId,
    String? sessionLabel,
    String? city,
    String? parentPhone,
    bool clearParentPhone = false,
    bool? attendanceConfirmed,
    DateTime? attendanceDate,
    bool clearAttendanceDate = false,
    bool? certificateIssued,
    DateTime? certificateIssuedAt,
    bool clearCertificateIssuedAt = false,
    bool? certificateDownloaded,
    DateTime? certificateDownloadedAt,
    bool clearCertificateDownloadedAt = false,
    bool? reviewSubmitted,
    DateTime? reviewSubmittedAt,
    double? rating,
    String? reviewComment,
    String? reviewId,
    DateTime? lastUpdated,
  }) {
    return Registration(
      id: id,
      registrationId: registrationId,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      sessionId: sessionId ?? this.sessionId,
      sessionLabel: sessionLabel ?? this.sessionLabel,
      createdAt: createdAt,
      city: city ?? this.city,
      parentPhone: clearParentPhone ? null : (parentPhone ?? this.parentPhone),
      attendanceConfirmed: attendanceConfirmed ?? this.attendanceConfirmed,
      attendanceDate: clearAttendanceDate
          ? null
          : (attendanceDate ?? this.attendanceDate),
      certificateIssued: certificateIssued ?? this.certificateIssued,
      certificateIssuedAt: clearCertificateIssuedAt
          ? null
          : (certificateIssuedAt ?? this.certificateIssuedAt),
      certificateDownloaded:
          certificateDownloaded ?? this.certificateDownloaded,
      certificateDownloadedAt: clearCertificateDownloadedAt
          ? null
          : (certificateDownloadedAt ?? this.certificateDownloadedAt),
      reviewSubmitted: reviewSubmitted ?? this.reviewSubmitted,
      reviewSubmittedAt: reviewSubmittedAt ?? this.reviewSubmittedAt,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      reviewId: reviewId ?? this.reviewId,
      createdBy: createdBy,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'registrationId': registrationId,
        'fullName': fullName,
        'phone': mobile,
        'mobile': mobile,
        'school': schoolName,
        'schoolName': schoolName,
        'grade': grade,
        'city': city,
        'parentPhone': parentPhone,
        'sessionId': sessionId,
        'sessionLabel': sessionLabel,
        'registeredAt': createdAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'attendanceStatus': attendanceStatus,
        'attendanceConfirmed': attendanceConfirmed,
        'attendanceDate': attendanceDate?.toIso8601String(),
        'certificateIssued': certificateIssued,
        'certificateIssuedAt': certificateIssuedAt?.toIso8601String(),
        'certificateDownloaded': certificateDownloaded,
        'certificateDownloadedAt': certificateDownloadedAt?.toIso8601String(),
        'reviewSubmitted': reviewSubmitted,
        'reviewSubmittedAt': reviewSubmittedAt?.toIso8601String(),
        'rating': rating,
        'review': reviewComment,
        'reviewId': reviewId,
        'journeyStatus': journeyStatus,
        'lastUpdated': (lastUpdated ?? createdAt).toIso8601String(),
        'createdBy': createdBy,
        // Legacy field for older clients
        'certificateApproved': certificateApproved,
      };

  factory Registration.fromMap(String id, Map<String, dynamic> map) {
    final attended = map['attendanceConfirmed'] as bool? ??
        map['certificateApproved'] as bool? ??
        false;
    final issued = map['certificateIssued'] as bool? ?? attended;
    return Registration(
      id: id,
      registrationId: map['registrationId'] as String,
      fullName: map['fullName'] as String,
      mobile: map['phone'] as String? ?? map['mobile'] as String? ?? '',
      schoolName: map['school'] as String? ?? map['schoolName'] as String? ?? '',
      grade: map['grade'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      sessionLabel: map['sessionLabel'] as String? ?? '',
      createdAt: DateTime.parse(
        map['registeredAt'] as String? ?? map['createdAt'] as String,
      ),
      city: map['city'] as String? ?? '',
      parentPhone: map['parentPhone'] as String?,
      attendanceConfirmed: attended,
      attendanceDate: map['attendanceDate'] != null
          ? DateTime.tryParse(map['attendanceDate'] as String)
          : null,
      certificateIssued: issued,
      certificateIssuedAt: map['certificateIssuedAt'] != null
          ? DateTime.tryParse(map['certificateIssuedAt'] as String)
          : null,
      certificateDownloaded: map['certificateDownloaded'] as bool? ?? false,
      certificateDownloadedAt: map['certificateDownloadedAt'] != null
          ? DateTime.tryParse(map['certificateDownloadedAt'] as String)
          : null,
      reviewSubmitted: map['reviewSubmitted'] as bool? ?? false,
      reviewSubmittedAt: map['reviewSubmittedAt'] != null
          ? DateTime.tryParse(map['reviewSubmittedAt'] as String)
          : null,
      rating: (map['rating'] as num?)?.toDouble(),
      reviewComment: map['review'] as String?,
      reviewId: map['reviewId'] as String?,
      createdBy: map['createdBy'] as String? ?? 'public',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'] as String)
          : null,
    );
  }
}
