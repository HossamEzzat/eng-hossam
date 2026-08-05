/// Personal brand constants — بشمهندس حسام / Eng. Hossam
class AppConstants {
  AppConstants._();

  static const String instructorNameAr = 'بشمهندس حسام';
  static const String instructorNameEn = 'Eng. Hossam';
  static const String instructorFullNameAr = 'حسام عزت خليفة';
  static const String instructorFullNameEn = 'Hossam Ezzat Khalifa';
  static const String instructorRoleEn =
      'Flutter Software Engineer · Programming Instructor';
  static const String instructorRoleAr =
      'مهندس برمجيات Flutter · مدرب برمجة';

  static const String instructorEmail = 'hossamezzat199@gmail.com';
  static const String instructorPhone = '01064224826';
  static const String instructorWhatsApp = '201064224826';
  static const String instructorLinkedIn =
      'https://www.linkedin.com/in/hossam-ezzat-77245b204/';
  static const String instructorFacebook =
      'https://www.facebook.com/hossam.ezzat.342313/?locale=ar_AR';
  static const String location = 'Egypt';

  /// Deprecated aliases kept so older call sites compile during migration.
  static const String instructorName = instructorNameAr;
  static const String instructorShortName = 'حسام';
  static const String instructorFullName = instructorFullNameAr;
  static const String instructorRole = instructorRoleAr;
  static const String instructorBio =
      'ببني تطبيقات موبايل حقيقية لشركات شغّالة في السوق — وبعلّم بنفس الأسلوب اللي بشتغل بيه: '
      'تفكير واضح، خطوات عملية، ومشاريع تقدر تعرضها بفخر. أكتر من ٢٥٠ طالب في أكاديميات رائدة '
      'بدأوا رحلتهم البرمجية معايا. الدورة دي مصمّمة خصيصًا لطلاب أولى وتانية ثانوي '
      'في نظام البكالوريا المصرية الجديدة.';

  /// When true, Firestore is the source of truth for registrations/reviews.
  /// Local SharedPreferences remains an offline cache only.
  static const bool useFirebase = true;

  /// When true, admin login uses Firebase Auth + `admins/{uid}`.
  /// Keep false until Email/Password is enabled in Firebase Console and the
  /// owner account exists (see docs/FIREBASE.md). Local admin login still works.
  static const bool useFirebaseAuth = false;

  static const double maxContentWidth = 1120;
  static const double navHeight = 72;
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 700);

  static const companies = [
    ('Opus365', 'Flutter Developer', 'Production HR mobile platform'),
    ('AlAhram-Tech', 'Flutter Developer', 'Battaka Business'),
    ('SAF Investment Group', 'Flutter Developer', 'Business apps · Firebase'),
  ];

  static const academies = [
    'Instant Academy',
    'EraaSoft',
    'Vision Academy',
    'Bright Brain',
    'MEC',
    'Kian',
    'DR Kashkool',
  ];

  static const awards = [
    ('🥇', 'Google Solution Challenge', '1st Place — AOU 2023'),
    ('🌍', 'Climathon EUI', '1st — Africa & Middle East 2022'),
    ('🎖', 'Huawei Academy', 'Ambassador 2022'),
    ('🥈', 'DevFest', '2nd Place 2022'),
    ('🥈', 'Dell Competition', '2nd — Africa, MENA & Turkey'),
    ('🥇', 'Climate Awareness App', 'Golden Medal'),
  ];
}
