/// Suez-only session catalog for Programming with Eng. Hossam.
enum SessionBranch { suez, alSalam }

enum SessionGradeBand { firstSecondary, secondSecondary }

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
  final bool registrationOpen;

  String title(bool isAr) => isAr ? titleAr : titleEn;
  String dateLabel(bool isAr) => isAr ? dateLabelAr : dateLabelEn;
  String timeLabel(bool isAr) => isAr ? timeLabelAr : timeLabelEn;
  String venue(bool isAr) => isAr ? venueAr : venueEn;

  /// City is always Suez for the current catalog.
  String get cityKey => 'suez';

  String get branchKey =>
      branch == SessionBranch.suez ? 'suez_branch' : 'al_salam';

  String cityLabel(bool isAr) => isAr ? 'السويس' : 'Suez';

  String branchLabel(bool isAr) => branch == SessionBranch.suez
      ? (isAr ? 'فرع السويس' : 'Suez Branch')
      : (isAr ? 'فرع السلام' : 'Al Salam Branch');

  String gradeLabel(bool isAr) => gradeBand == SessionGradeBand.firstSecondary
      ? (isAr ? 'الصف الأول الثانوي' : 'First Secondary')
      : (isAr ? 'الصف الثاني الثانوي' : 'Second Secondary');

  /// Matches registration form grade dropdown values.
  String gradeFormValue(bool isAr) => gradeLabel(isAr);

  int get availableSeats => remainingSeats;

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
        'registrationOpen': registrationOpen,
      };

  factory OpeningSession.fromMap(String id, Map<String, dynamic> map) {
    final branchRaw = map['branch'] as String? ?? 'suez_branch';
    final gradeRaw = map['gradeBand'] as String? ?? 'secondSecondary';
    return OpeningSession(
      id: id,
      titleAr: map['titleAr'] as String? ?? 'جلسة برمجة',
      titleEn: map['titleEn'] as String? ?? 'Programming Session',
      branch: branchRaw == 'al_salam'
          ? SessionBranch.alSalam
          : SessionBranch.suez,
      gradeBand: gradeRaw == 'firstSecondary'
          ? SessionGradeBand.firstSecondary
          : SessionGradeBand.secondSecondary,
      date: DateTime.parse(map['date'] as String),
      dateLabelAr: map['dateLabelAr'] as String? ?? '',
      dateLabelEn: map['dateLabelEn'] as String? ?? '',
      timeLabelAr: map['timeLabelAr'] as String? ?? '',
      timeLabelEn: map['timeLabelEn'] as String? ?? '',
      totalSeats: map['totalSeats'] as int? ?? 40,
      remainingSeats: map['remainingSeats'] as int? ?? 40,
      venueAr: map['venueAr'] as String? ?? '',
      venueEn: map['venueEn'] as String? ?? '',
      registrationOpen: map['registrationOpen'] as bool? ?? true,
    );
  }
}

class SessionCatalog {
  SessionCatalog._();

  static OpeningSession? byId(String id) {
    try {
      return upcoming.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Current catalog: Suez sessions only (Suez Branch + Al Salam Branch).
  static final List<OpeningSession> upcoming = [
    OpeningSession(
      id: 'ses_suez_2nd_suez',
      titleAr: 'الثاني الثانوي · فرع السويس',
      titleEn: 'Second Secondary · Suez Branch',
      branch: SessionBranch.suez,
      gradeBand: SessionGradeBand.secondSecondary,
      date: DateTime(2026, 8, 5, 13, 0),
      dateLabelAr: 'السويس',
      dateLabelEn: 'Suez',
      timeLabelAr: '١:٠٠ ظهرًا – ٣:٠٠ عصرًا',
      timeLabelEn: '1:00 PM – 3:00 PM',
      totalSeats: 40,
      remainingSeats: 40,
      venueAr: 'فرع السويس',
      venueEn: 'Suez Branch',
    ),
    OpeningSession(
      id: 'ses_suez_2nd_salam',
      titleAr: 'الثاني الثانوي · فرع السلام',
      titleEn: 'Second Secondary · Al Salam Branch',
      branch: SessionBranch.alSalam,
      gradeBand: SessionGradeBand.secondSecondary,
      date: DateTime(2026, 8, 5, 19, 0),
      dateLabelAr: 'السويس',
      dateLabelEn: 'Suez',
      timeLabelAr: '٧:٠٠ مساءً – ٩:٠٠ مساءً',
      timeLabelEn: '7:00 PM – 9:00 PM',
      totalSeats: 40,
      remainingSeats: 40,
      venueAr: 'فرع السلام',
      venueEn: 'Al Salam Branch',
    ),
    OpeningSession(
      id: 'ses_suez_1st_suez',
      titleAr: 'الأول الثانوي · فرع السويس',
      titleEn: 'First Secondary · Suez Branch',
      branch: SessionBranch.suez,
      gradeBand: SessionGradeBand.firstSecondary,
      date: DateTime(2026, 8, 5, 15, 0),
      dateLabelAr: 'السويس',
      dateLabelEn: 'Suez',
      timeLabelAr: '٣:٠٠ عصرًا – ٥:٠٠ مساءً',
      timeLabelEn: '3:00 PM – 5:00 PM',
      totalSeats: 40,
      remainingSeats: 40,
      venueAr: 'فرع السويس',
      venueEn: 'Suez Branch',
    ),
  ];
}
