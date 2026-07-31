/// Single official opening session — Programming with Eng. Hossam.
///
/// The entire website advertises only this session (GLC Academy, Suez).
enum SessionBranch {
  /// GLC Academy · Suez (only venue).
  glc,
}

enum SessionGradeBand {
  /// Unified opening for First + Second Secondary.
  both,
  firstSecondary,
  secondSecondary,
}

class OpeningSession {
  const OpeningSession({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.branch,
    required this.gradeBand,
    required this.date,
    required this.dateLabelAr,
    required this.dateLabelEn,
    required this.timeLabelAr,
    required this.timeLabelEn,
    required this.totalSeats,
    required this.remainingSeats,
    required this.venueAr,
    required this.venueEn,
    required this.academyAr,
    required this.academyEn,
    required this.addressAr,
    required this.addressEn,
    required this.courseAr,
    required this.courseEn,
    required this.audienceAr,
    required this.audienceEn,
    this.registrationOpen = true,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final SessionBranch branch;
  final SessionGradeBand gradeBand;
  final DateTime date;
  final String dateLabelAr;
  final String dateLabelEn;
  final String timeLabelAr;
  final String timeLabelEn;
  final int totalSeats;
  final int remainingSeats;
  final String venueAr;
  final String venueEn;
  final String academyAr;
  final String academyEn;
  final String addressAr;
  final String addressEn;
  final String courseAr;
  final String courseEn;
  final String audienceAr;
  final String audienceEn;
  final bool registrationOpen;

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String dateLabel(bool isAr) => isAr ? dateLabelAr : dateLabelEn;
  String timeLabel(bool isAr) => isAr ? timeLabelAr : timeLabelEn;
  String venue(bool isAr) => isAr ? venueAr : venueEn;
  String academy(bool isAr) => isAr ? academyAr : academyEn;
  String address(bool isAr) => isAr ? addressAr : addressEn;
  String course(bool isAr) => isAr ? courseAr : courseEn;
  String audience(bool isAr) => isAr ? audienceAr : audienceEn;

  String get cityKey => 'suez';
  String get branchKey => 'glc_academy';

  String cityLabel(bool isAr) => isAr ? 'السويس' : 'Suez';

  String branchLabel(bool isAr) => academy(isAr);

  String gradeLabel(bool isAr) => audience(isAr);

  /// Public registration still asks First vs Second Secondary.
  String gradeFormValue(bool isAr) => isAr
      ? 'الصف الأول الثانوي'
      : 'First Secondary';

  int get availableSeats => remainingSeats;

  String displayLabel(bool isAr) => isAr
      ? '$courseAr · $academyAr · السويس · $timeLabelAr'
      : '$courseEn · $academyEn · Suez · $timeLabelEn';

  OpeningSession copyWith({
    String? titleAr,
    String? titleEn,
    SessionBranch? branch,
    SessionGradeBand? gradeBand,
    DateTime? date,
    String? dateLabelAr,
    String? dateLabelEn,
    String? timeLabelAr,
    String? timeLabelEn,
    int? totalSeats,
    int? remainingSeats,
    String? venueAr,
    String? venueEn,
    String? academyAr,
    String? academyEn,
    String? addressAr,
    String? addressEn,
    String? courseAr,
    String? courseEn,
    String? audienceAr,
    String? audienceEn,
    bool? registrationOpen,
  }) {
    return OpeningSession(
      id: id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      branch: branch ?? this.branch,
      gradeBand: gradeBand ?? this.gradeBand,
      date: date ?? this.date,
      dateLabelAr: dateLabelAr ?? this.dateLabelAr,
      dateLabelEn: dateLabelEn ?? this.dateLabelEn,
      timeLabelAr: timeLabelAr ?? this.timeLabelAr,
      timeLabelEn: timeLabelEn ?? this.timeLabelEn,
      totalSeats: totalSeats ?? this.totalSeats,
      remainingSeats: remainingSeats ?? this.remainingSeats,
      venueAr: venueAr ?? this.venueAr,
      venueEn: venueEn ?? this.venueEn,
      academyAr: academyAr ?? this.academyAr,
      academyEn: academyEn ?? this.academyEn,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      courseAr: courseAr ?? this.courseAr,
      courseEn: courseEn ?? this.courseEn,
      audienceAr: audienceAr ?? this.audienceAr,
      audienceEn: audienceEn ?? this.audienceEn,
      registrationOpen: registrationOpen ?? this.registrationOpen,
    );
  }

  Map<String, dynamic> toMap() => {
        'titleAr': titleAr,
        'titleEn': titleEn,
        'city': cityKey,
        'branch': branchKey,
        'gradeBand': gradeBand.name,
        'date': date.toIso8601String(),
        'dateLabelAr': dateLabelAr,
        'dateLabelEn': dateLabelEn,
        'timeLabelAr': timeLabelAr,
        'timeLabelEn': timeLabelEn,
        'totalSeats': totalSeats,
        'remainingSeats': remainingSeats,
        'venueAr': venueAr,
        'venueEn': venueEn,
        'academyAr': academyAr,
        'academyEn': academyEn,
        'addressAr': addressAr,
        'addressEn': addressEn,
        'courseAr': courseAr,
        'courseEn': courseEn,
        'audienceAr': audienceAr,
        'audienceEn': audienceEn,
        'registrationOpen': registrationOpen,
      };

  factory OpeningSession.fromMap(String id, Map<String, dynamic> map) {
    return OpeningSession(
      id: id,
      titleAr: map['titleAr'] as String? ?? 'جلسة افتتاح دورة البرمجة',
      titleEn: map['titleEn'] as String? ?? 'Programming Course Opening Session',
      branch: SessionBranch.glc,
      gradeBand: SessionGradeBand.both,
      date: DateTime.parse(
        map['date'] as String? ?? DateTime(2026, 9, 1, 18).toIso8601String(),
      ),
      dateLabelAr: map['dateLabelAr'] as String? ?? 'السويس',
      dateLabelEn: map['dateLabelEn'] as String? ?? 'Suez',
      timeLabelAr: map['timeLabelAr'] as String? ?? 'من ٦:٠٠ مساءً إلى ٨:٠٠ مساءً',
      timeLabelEn: map['timeLabelEn'] as String? ?? '6:00 PM – 8:00 PM',
      totalSeats: map['totalSeats'] as int? ?? 80,
      remainingSeats: map['remainingSeats'] as int? ?? 80,
      venueAr: map['venueAr'] as String? ?? 'أكاديمية GLC · السويس',
      venueEn: map['venueEn'] as String? ?? 'GLC Academy · Suez',
      academyAr: map['academyAr'] as String? ?? 'أكاديمية GLC',
      academyEn: map['academyEn'] as String? ?? 'GLC Academy',
      addressAr: map['addressAr'] as String? ??
          'شارع الكورنيش القديم - منتجع الواتر واي',
      addressEn: map['addressEn'] as String? ??
          'Old Corniche Street, Water Way Resort',
      courseAr: map['courseAr'] as String? ?? 'مادة البرمجة',
      courseEn: map['courseEn'] as String? ?? 'Programming',
      audienceAr: map['audienceAr'] as String? ??
          'طلاب الصف الأول والثاني الثانوي',
      audienceEn: map['audienceEn'] as String? ??
          'First & Second Secondary · Egyptian Baccalaureate',
      registrationOpen: map['registrationOpen'] as bool? ?? true,
    );
  }
}

class SessionCatalog {
  SessionCatalog._();

  static const String officialId = 'ses_glc_opening';

  static OpeningSession? byId(String id) {
    try {
      return upcoming.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// The only advertised opening session.
  static OpeningSession get official => upcoming.first;

  /// Current catalog: exactly one unified opening session.
  static final List<OpeningSession> upcoming = [
    OpeningSession(
      id: officialId,
      titleAr: 'جلسة افتتاح دورة البرمجة',
      titleEn: 'Programming Course Opening Session',
      branch: SessionBranch.glc,
      gradeBand: SessionGradeBand.both,
      date: DateTime(2026, 9, 1, 18, 0),
      dateLabelAr: 'السويس',
      dateLabelEn: 'Suez',
      timeLabelAr: 'من ٦:٠٠ مساءً إلى ٨:٠٠ مساءً',
      timeLabelEn: '6:00 PM – 8:00 PM',
      totalSeats: 80,
      remainingSeats: 80,
      venueAr: 'أكاديمية GLC · السويس',
      venueEn: 'GLC Academy · Suez',
      academyAr: 'أكاديمية GLC',
      academyEn: 'GLC Academy',
      addressAr: 'شارع الكورنيش القديم - منتجع الواتر واي',
      addressEn: 'Old Corniche Street · Water Way Resort · Suez, Egypt',
      courseAr: 'مادة البرمجة',
      courseEn: 'Programming',
      audienceAr: 'طلاب الصف الأول والثاني الثانوي',
      audienceEn: 'Egyptian Baccalaureate · First & Second Secondary',
    ),
  ];
}
