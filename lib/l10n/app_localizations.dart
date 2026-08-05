import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'بشمهندس حسام · دورة البرمجة'**
  String get appTitle;

  /// No description provided for @brandName.
  ///
  /// In ar, this message translates to:
  /// **'بشمهندس حسام'**
  String get brandName;

  /// No description provided for @brandRole.
  ///
  /// In ar, this message translates to:
  /// **'مهندس برمجيات Flutter · مدرب برمجة'**
  String get brandRole;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن بشمهندس حسام'**
  String get navAbout;

  /// No description provided for @navWhyProgramming.
  ///
  /// In ar, this message translates to:
  /// **'ليه البرمجة؟'**
  String get navWhyProgramming;

  /// No description provided for @navCourse.
  ///
  /// In ar, this message translates to:
  /// **'عن الدورة'**
  String get navCourse;

  /// No description provided for @navSessions.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات'**
  String get navSessions;

  /// No description provided for @navRegister.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل'**
  String get navRegister;

  /// No description provided for @navCertificate.
  ///
  /// In ar, this message translates to:
  /// **'الشهادة'**
  String get navCertificate;

  /// No description provided for @navReviews.
  ///
  /// In ar, this message translates to:
  /// **'آراء الطلاب'**
  String get navReviews;

  /// No description provided for @navFaq.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة شائعة'**
  String get navFaq;

  /// No description provided for @navContact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get navContact;

  /// No description provided for @ctaReserve.
  ///
  /// In ar, this message translates to:
  /// **'احجز مكانك'**
  String get ctaReserve;

  /// No description provided for @ctaReserveNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز مكانك الآن'**
  String get ctaReserveNow;

  /// No description provided for @ctaLearnMore.
  ///
  /// In ar, this message translates to:
  /// **'اعرف المزيد'**
  String get ctaLearnMore;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @heroHeadline.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلتك في البرمجة مع بشمهندس حسام'**
  String get heroHeadline;

  /// No description provided for @heroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تعلّم البرمجة بطريقة عملية ومبسّطة — جلسة افتتاح واحدة في أكاديمية GLC بالسويس لطلاب الصف الأول والثاني الثانوي بنظام البكالوريا المصرية.'**
  String get heroSubtitle;

  /// No description provided for @statStudents.
  ///
  /// In ar, this message translates to:
  /// **'طالب'**
  String get statStudents;

  /// No description provided for @statApps.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق إنتاجي'**
  String get statApps;

  /// No description provided for @statAcademies.
  ///
  /// In ar, this message translates to:
  /// **'أكاديمية'**
  String get statAcademies;

  /// No description provided for @statAwards.
  ///
  /// In ar, this message translates to:
  /// **'جائزة'**
  String get statAwards;

  /// No description provided for @whyProgrammingTitle.
  ///
  /// In ar, this message translates to:
  /// **'ليه البرمجة مهارة مستقبلك؟'**
  String get whyProgrammingTitle;

  /// No description provided for @whyProgrammingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'العالم بيتكتب بالكود — ودي فرصتك تبدأ بدري وبثقة.'**
  String get whyProgrammingSubtitle;

  /// No description provided for @whyCard1Title.
  ///
  /// In ar, this message translates to:
  /// **'مستقبل الوظائف'**
  String get whyCard1Title;

  /// No description provided for @whyCard1Body.
  ///
  /// In ar, this message translates to:
  /// **'البرمجة بتفتح أبواب لوظائف حديثة برواتب قوية وفرص شغل من أي مكان.'**
  String get whyCard1Body;

  /// No description provided for @whyCard2Title.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بدري'**
  String get whyCard2Title;

  /// No description provided for @whyCard2Body.
  ///
  /// In ar, this message translates to:
  /// **'كل ما بدأت أصغر، كل ما بقت أقوى في التفكير والبناء قبل ما تدخل الجامعة.'**
  String get whyCard2Body;

  /// No description provided for @whyCard3Title.
  ///
  /// In ar, this message translates to:
  /// **'العالم الرقمي'**
  String get whyCard3Title;

  /// No description provided for @whyCard3Body.
  ///
  /// In ar, this message translates to:
  /// **'كل تطبيق بتستخدمه اتعمل بكود — وانت تقدر تبقى جزء من صناعة المستقبل.'**
  String get whyCard3Body;

  /// No description provided for @whyCard4Title.
  ///
  /// In ar, this message translates to:
  /// **'أول خطوة صح'**
  String get whyCard4Title;

  /// No description provided for @whyCard4Body.
  ///
  /// In ar, this message translates to:
  /// **'الدورة دي مش حفظ نظري — دي خريطة واضحة تبدأ بيها من غير ما تتوه.'**
  String get whyCard4Body;

  /// No description provided for @whyLearnTitle.
  ///
  /// In ar, this message translates to:
  /// **'ليه تتعلّم مع بشمهندس حسام؟'**
  String get whyLearnTitle;

  /// No description provided for @whyLearnSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خبرة سوق حقيقية + أسلوب بسيط يخلي أصعب فكرة تبقى سهلة.'**
  String get whyLearnSubtitle;

  /// No description provided for @featureIndustry.
  ///
  /// In ar, this message translates to:
  /// **'خبرة في سوق العمل'**
  String get featureIndustry;

  /// No description provided for @featureProduction.
  ///
  /// In ar, this message translates to:
  /// **'تطبيقات موبايل إنتاجية'**
  String get featureProduction;

  /// No description provided for @featurePractical.
  ///
  /// In ar, this message translates to:
  /// **'تعلّم عملي'**
  String get featurePractical;

  /// No description provided for @featureCareer.
  ///
  /// In ar, this message translates to:
  /// **'توجيه مساري'**
  String get featureCareer;

  /// No description provided for @featureProjects.
  ///
  /// In ar, this message translates to:
  /// **'مشاريع حقيقية'**
  String get featureProjects;

  /// No description provided for @featureInteractive.
  ///
  /// In ar, this message translates to:
  /// **'شرح تفاعلي'**
  String get featureInteractive;

  /// No description provided for @featureCertificate.
  ///
  /// In ar, this message translates to:
  /// **'شهادة حضور'**
  String get featureCertificate;

  /// No description provided for @featureFriendly.
  ///
  /// In ar, this message translates to:
  /// **'بيئة ودودة ومحفّزة'**
  String get featureFriendly;

  /// No description provided for @sessionsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'جلسة افتتاح رسمية واحدة في أكاديمية GLC بالسويس — من ٦:٠٠ مساءً إلى ٨:٠٠ مساءً. المقاعد محدودة.'**
  String get sessionsSubtitle;

  /// No description provided for @sessionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'جلسة افتتاح دورة البرمجة'**
  String get sessionsTitle;

  /// No description provided for @registrationOpen.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل مفتوح'**
  String get registrationOpen;

  /// No description provided for @seatsRemaining.
  ///
  /// In ar, this message translates to:
  /// **'مقاعد متبقية'**
  String get seatsRemaining;

  /// No description provided for @reserveSeat.
  ///
  /// In ar, this message translates to:
  /// **'احجز مكانك الآن'**
  String get reserveSeat;

  /// No description provided for @sessionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة الافتتاحية في البرمجة'**
  String get sessionTitle;

  /// No description provided for @countdownDays.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get countdownDays;

  /// No description provided for @countdownHours.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get countdownHours;

  /// No description provided for @countdownMinutes.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get countdownMinutes;

  /// No description provided for @countdownSeconds.
  ///
  /// In ar, this message translates to:
  /// **'ثانية'**
  String get countdownSeconds;

  /// No description provided for @contentTitle.
  ///
  /// In ar, this message translates to:
  /// **'ماذا ستتعلّم في هذه الدورة؟'**
  String get contentTitle;

  /// No description provided for @contentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'من الصفر… لحد أول مشروع حقيقي وأسئلة مفتوحة.'**
  String get contentSubtitle;

  /// No description provided for @content1.
  ///
  /// In ar, this message translates to:
  /// **'إيه هي البرمجة فعلًا؟'**
  String get content1;

  /// No description provided for @content2.
  ///
  /// In ar, this message translates to:
  /// **'حل المشكلات والتفكير المنطقي'**
  String get content2;

  /// No description provided for @content3.
  ///
  /// In ar, this message translates to:
  /// **'مقدمة في الخوارزميات'**
  String get content3;

  /// No description provided for @content4.
  ///
  /// In ar, this message translates to:
  /// **'أساسيات البرمجة'**
  String get content4;

  /// No description provided for @content5.
  ///
  /// In ar, this message translates to:
  /// **'أمثلة عملية مبسّطة'**
  String get content5;

  /// No description provided for @content6.
  ///
  /// In ar, this message translates to:
  /// **'مشاريع حقيقية'**
  String get content6;

  /// No description provided for @content7.
  ///
  /// In ar, this message translates to:
  /// **'خارطة طريق التخصصات'**
  String get content7;

  /// No description provided for @content8.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة وأجوبة'**
  String get content8;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعرّف على بشمهندس حسام'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مهندس بيبني تطبيقات حقيقية… ومدرب بيعلّم بنفس أسلوب الشغل.'**
  String get aboutSubtitle;

  /// No description provided for @aboutCta.
  ///
  /// In ar, this message translates to:
  /// **'اعرف قصتي كاملة'**
  String get aboutCta;

  /// No description provided for @reviewsTitle.
  ///
  /// In ar, this message translates to:
  /// **'آراء الطلاب'**
  String get reviewsTitle;

  /// No description provided for @reviewsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم الجلسة بنجوم واكتب رأيك — اسمك ورقم موبايلك بس.'**
  String get reviewsSubtitle;

  /// No description provided for @reviewsCta.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ كل الآراء'**
  String get reviewsCta;

  /// No description provided for @finalCtaTitle.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك تبدأ من هنا'**
  String get finalCtaTitle;

  /// No description provided for @finalCtaBody.
  ///
  /// In ar, this message translates to:
  /// **'متستناش «وقت مناسب». احجز مكانك وابدأ أول خطوة نحو مستقبلك في البرمجة.'**
  String get finalCtaBody;

  /// No description provided for @aboutPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن بشمهندس حسام'**
  String get aboutPageTitle;

  /// No description provided for @aboutPageIntro.
  ///
  /// In ar, this message translates to:
  /// **'بشمهندس حسام — مهندس برمجيات Flutter ومدرب برمجة لطلاب الثانوي.'**
  String get aboutPageIntro;

  /// No description provided for @companiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'خبرات مهنية'**
  String get companiesTitle;

  /// No description provided for @academiesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أكاديميات درّست فيها'**
  String get academiesTitle;

  /// No description provided for @awardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنجازات وجوائز'**
  String get awardsTitle;

  /// No description provided for @philosophyTitle.
  ///
  /// In ar, this message translates to:
  /// **'فلسفتي في التعليم'**
  String get philosophyTitle;

  /// No description provided for @philosophyBody.
  ///
  /// In ar, this message translates to:
  /// **'بعلّم زي ما ببني في الشغل: خطوات واضحة، مشاريع حقيقية، وتشجيع من غير ضغط. عايز الطالب يخرج فاهم — مش حافظ — وولي الأمر يطمن إن ابنه في أيد أمينة.'**
  String get philosophyBody;

  /// No description provided for @coursePageTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على الدورة'**
  String get coursePageTitle;

  /// No description provided for @courseAudience.
  ///
  /// In ar, this message translates to:
  /// **'لمن؟ طلاب أولى وتانية ثانوي — نظام البكالوريا المصرية.'**
  String get courseAudience;

  /// No description provided for @courseFree.
  ///
  /// In ar, this message translates to:
  /// **'الحضور مجاني — التسجيل مطلوب'**
  String get courseFree;

  /// No description provided for @courseLaptop.
  ///
  /// In ar, this message translates to:
  /// **'اللابتوب اختياري في الجلسة الافتتاحية'**
  String get courseLaptop;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'احجز مكانك الآن'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمك ورقم موبايلك بس — وخلاص.'**
  String get registerSubtitle;

  /// No description provided for @fieldFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالكامل'**
  String get fieldFullName;

  /// No description provided for @fieldMobile.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get fieldMobile;

  /// No description provided for @fieldSchool.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدرسة'**
  String get fieldSchool;

  /// No description provided for @fieldGrade.
  ///
  /// In ar, this message translates to:
  /// **'الصف'**
  String get fieldGrade;

  /// No description provided for @gradeFirst.
  ///
  /// In ar, this message translates to:
  /// **'الصف الأول الثانوي'**
  String get gradeFirst;

  /// No description provided for @gradeSecond.
  ///
  /// In ar, this message translates to:
  /// **'الصف الثاني الثانوي'**
  String get gradeSecond;

  /// No description provided for @fieldSession.
  ///
  /// In ar, this message translates to:
  /// **'اختر الجلسة'**
  String get fieldSession;

  /// No description provided for @citySuez.
  ///
  /// In ar, this message translates to:
  /// **'السويس'**
  String get citySuez;

  /// No description provided for @branchSuez.
  ///
  /// In ar, this message translates to:
  /// **'أكاديمية GLC'**
  String get branchSuez;

  /// No description provided for @branchAlSalam.
  ///
  /// In ar, this message translates to:
  /// **'أكاديمية GLC'**
  String get branchAlSalam;

  /// No description provided for @sessionRegionSuez.
  ///
  /// In ar, this message translates to:
  /// **'السويس'**
  String get sessionRegionSuez;

  /// No description provided for @submitRegister.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحجز'**
  String get submitRegister;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيلك بنجاح 🎉'**
  String get registerSuccessTitle;

  /// No description provided for @registerSuccessBody.
  ///
  /// In ar, this message translates to:
  /// **'مستنيينك في الجلسة.'**
  String get registerSuccessBody;

  /// No description provided for @registrationIdLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم التسجيل'**
  String get registrationIdLabel;

  /// No description provided for @saveIdHint.
  ///
  /// In ar, this message translates to:
  /// **'احفظ الرقم ده لو حابب تحمّل شهادتك بعدين.'**
  String get saveIdHint;

  /// No description provided for @backHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backHome;

  /// No description provided for @validateName.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمك بالكامل'**
  String get validateName;

  /// No description provided for @validateMobile.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم موبايل مصري صحيح يبدأ بـ 010 أو 011 أو 012 أو 015'**
  String get validateMobile;

  /// No description provided for @validateSchool.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المدرسة'**
  String get validateSchool;

  /// No description provided for @validateGrade.
  ///
  /// In ar, this message translates to:
  /// **'اختَر الصف'**
  String get validateGrade;

  /// No description provided for @validateSession.
  ///
  /// In ar, this message translates to:
  /// **'اختَر الجلسة'**
  String get validateSession;

  /// No description provided for @certificateTitle.
  ///
  /// In ar, this message translates to:
  /// **'حمّل شهادتك'**
  String get certificateTitle;

  /// No description provided for @certificateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم الموبايل أو رقم التسجيل.'**
  String get certificateSubtitle;

  /// No description provided for @certificateQueryHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل أو رقم التسجيل'**
  String get certificateQueryHint;

  /// No description provided for @findCertificate.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الشهادة'**
  String get findCertificate;

  /// No description provided for @downloadPdf.
  ///
  /// In ar, this message translates to:
  /// **'تحميل PDF'**
  String get downloadPdf;

  /// No description provided for @certNotFound.
  ///
  /// In ar, this message translates to:
  /// **'مفيش تسجيل بالبيانات دي. راجع الرقم.'**
  String get certNotFound;

  /// No description provided for @certPending.
  ///
  /// In ar, this message translates to:
  /// **'شهادتك لسه مش جاهزة — هتتوفر بعد اعتماد الحضور.'**
  String get certPending;

  /// No description provided for @certOfAttendance.
  ///
  /// In ar, this message translates to:
  /// **'شهادة حضور'**
  String get certOfAttendance;

  /// No description provided for @certCertifies.
  ///
  /// In ar, this message translates to:
  /// **'نشهد بأن'**
  String get certCertifies;

  /// No description provided for @certAttended.
  ///
  /// In ar, this message translates to:
  /// **'قد حضر الجلسة الافتتاحية في البرمجة'**
  String get certAttended;

  /// No description provided for @certInstructor.
  ///
  /// In ar, this message translates to:
  /// **'المدرب'**
  String get certInstructor;

  /// No description provided for @certNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الشهادة'**
  String get certNumber;

  /// No description provided for @certRegId.
  ///
  /// In ar, this message translates to:
  /// **'رقم التسجيل'**
  String get certRegId;

  /// No description provided for @reviewsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم الجلسة'**
  String get reviewsPageTitle;

  /// No description provided for @reviewsPageSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نجوم + رأيك — بالاسم ورقم الموبايل فقط.'**
  String get reviewsPageSubtitle;

  /// No description provided for @ratingLabel.
  ///
  /// In ar, this message translates to:
  /// **'التقييم بالنجوم'**
  String get ratingLabel;

  /// No description provided for @commentLabel.
  ///
  /// In ar, this message translates to:
  /// **'رأيك في الجلسة'**
  String get commentLabel;

  /// No description provided for @suggestionsLabel.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات (اختياري)'**
  String get suggestionsLabel;

  /// No description provided for @submitReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get submitReview;

  /// No description provided for @thanksFeedback.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا على رأيك ❤️'**
  String get thanksFeedback;

  /// No description provided for @averageRating.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التقييم'**
  String get averageRating;

  /// No description provided for @faqTitle.
  ///
  /// In ar, this message translates to:
  /// **'أسئلة بتجيلي كتير'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In ar, this message translates to:
  /// **'محتاج خبرة سابقة في البرمجة؟'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In ar, this message translates to:
  /// **'لأ خالص. الجلسة مصمّمة للمبتدئين من الصفر.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In ar, this message translates to:
  /// **'أجيب لابتوب؟'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In ar, this message translates to:
  /// **'مش إجباري في الجلسة الافتتاحية — لو معاك هيبقى ممتاز للمتابعة.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In ar, this message translates to:
  /// **'هل هاخد شهادة؟'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In ar, this message translates to:
  /// **'أيوه — شهادة حضور تقدر تحمّلها من الموقع بعد اعتماد الحضور.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة قد إيه؟'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In ar, this message translates to:
  /// **'حوالي ساعتين إلى ثلاث ساعات شاملة الشرح والأسئلة.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In ar, this message translates to:
  /// **'إزاي أتواصل معاك؟'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In ar, this message translates to:
  /// **'من صفحة تواصل — واتساب أو أي قناة تناسبك.'**
  String get faqA5;

  /// No description provided for @faqQ6.
  ///
  /// In ar, this message translates to:
  /// **'الدورة مجانية؟'**
  String get faqQ6;

  /// No description provided for @faqA6.
  ///
  /// In ar, this message translates to:
  /// **'الجلسة الافتتاحية مجانية — التسجيل مطلوب لحجز مقعدك.'**
  String get faqA6;

  /// No description provided for @faqQ7.
  ///
  /// In ar, this message translates to:
  /// **'لأي صف؟'**
  String get faqQ7;

  /// No description provided for @faqA7.
  ///
  /// In ar, this message translates to:
  /// **'أولى وتانية ثانوي — نظام البكالوريا المصرية.'**
  String get faqA7;

  /// No description provided for @contactTitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع بشمهندس حسام'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اسأل براحتك — للطلاب وأولياء الأمور.'**
  String get contactSubtitle;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @facebook.
  ///
  /// In ar, this message translates to:
  /// **'فيسبوك'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In ar, this message translates to:
  /// **'إنستجرام'**
  String get instagram;

  /// No description provided for @linkedin.
  ///
  /// In ar, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @github.
  ///
  /// In ar, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @locationLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get locationLabel;

  /// No description provided for @contactName.
  ///
  /// In ar, this message translates to:
  /// **'اسمك'**
  String get contactName;

  /// No description provided for @contactMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالتك'**
  String get contactMessage;

  /// No description provided for @sendMessage.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get sendMessage;

  /// No description provided for @messageSent.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام رسالتك — هرد عليك قريب.'**
  String get messageSent;

  /// No description provided for @adminTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get adminTitle;

  /// No description provided for @adminPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get adminPassword;

  /// No description provided for @adminEnter.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get adminEnter;

  /// No description provided for @adminStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلاب'**
  String get adminStudents;

  /// No description provided for @adminReviews.
  ///
  /// In ar, this message translates to:
  /// **'الآراء'**
  String get adminReviews;

  /// No description provided for @adminExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get adminExport;

  /// No description provided for @adminApprove.
  ///
  /// In ar, this message translates to:
  /// **'اعتماد الشهادة'**
  String get adminApprove;

  /// No description provided for @adminPending.
  ///
  /// In ar, this message translates to:
  /// **'لم يحضر بعد'**
  String get adminPending;

  /// No description provided for @adminApproved.
  ///
  /// In ar, this message translates to:
  /// **'حضر الجلسة'**
  String get adminApproved;

  /// No description provided for @adminAttendance.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحضور'**
  String get adminAttendance;

  /// No description provided for @adminSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن طالب…'**
  String get adminSearch;

  /// No description provided for @adminLogout.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get adminLogout;

  /// No description provided for @adminBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة للموقع'**
  String get adminBack;

  /// No description provided for @adminWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غلط'**
  String get adminWrongPassword;

  /// No description provided for @adminCsvCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ ملف CSV'**
  String get adminCsvCopied;

  /// No description provided for @footerTagline.
  ///
  /// In ar, this message translates to:
  /// **'دورة البرمجة · لطلاب البكالوريا المصرية'**
  String get footerTagline;

  /// No description provided for @stepLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة'**
  String get stepLabel;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات حتى الآن.'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يقيّم الجلسة — اسمك وموبايلك ونجوم ورأيك.'**
  String get reviewsEmptySubtitle;

  /// No description provided for @addReviewCta.
  ///
  /// In ar, this message translates to:
  /// **'⭐ قيّم الجلسة'**
  String get addReviewCta;

  /// No description provided for @shareExperience.
  ///
  /// In ar, this message translates to:
  /// **'شارك رأيك'**
  String get shareExperience;

  /// No description provided for @reviewLockedTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم الجلسة بسهولة'**
  String get reviewLockedTitle;

  /// No description provided for @reviewLockedBody.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسمك ورقم موبايلك، اختَر النجوم، واكتب رأيك.'**
  String get reviewLockedBody;

  /// No description provided for @reviewUnlockCta.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التقييم'**
  String get reviewUnlockCta;

  /// No description provided for @reviewNotEligible.
  ///
  /// In ar, this message translates to:
  /// **'راجع الاسم ورقم الموبايل وحاول تاني.'**
  String get reviewNotEligible;

  /// No description provided for @reviewAlreadySubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال تقييمك قبل كده — شكرًا!'**
  String get reviewAlreadySubmitted;

  /// No description provided for @reviewFormHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك + رقم موبايلك + النجوم + رأيك. بس كده.'**
  String get reviewFormHint;

  /// No description provided for @afterCertificateNudge.
  ///
  /// In ar, this message translates to:
  /// **'يسعدني معرفة رأيك في الجلسة.\nمشاركتك تساعدني على تقديم تجربة تعليمية أفضل.'**
  String get afterCertificateNudge;

  /// No description provided for @postSessionTitle.
  ///
  /// In ar, this message translates to:
  /// **'بعد الجلسة… رحلتك مستمرة'**
  String get postSessionTitle;

  /// No description provided for @postSessionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حمّل شهادتك، شارك تجربتك، وارجع لأي جلسة جاية.'**
  String get postSessionSubtitle;

  /// No description provided for @thankYouTitle.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا لك ❤️'**
  String get thankYouTitle;

  /// No description provided for @thankYouBody.
  ///
  /// In ar, this message translates to:
  /// **'سعيد جدًا بانضمامك إلى أولى خطوات رحلتك في عالم البرمجة.\n\nأتمنى أن تكون الجلسة قد أضافت لك معرفة وحماسًا لبداية قوية.\n\nتذكّر دائمًا أن النجاح لا يأتي بخطوة كبيرة واحدة، بل بخطوات صغيرة مستمرة.\n\nأتطلع لرؤيتك في الجلسات القادمة.\n\nمع خالص تمنياتي لك بالتوفيق…\n\nبشمهندس حسام'**
  String get thankYouBody;

  /// No description provided for @thankYouQuote.
  ///
  /// In ar, this message translates to:
  /// **'كل مبرمج محترف كان يومًا ما مبتدئًا… استمر في التعلّم، فمستقبلك يبدأ اليوم.'**
  String get thankYouQuote;

  /// No description provided for @followSessions.
  ///
  /// In ar, this message translates to:
  /// **'متابعة آخر الجلسات'**
  String get followSessions;

  /// No description provided for @noRatingYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات حتى الآن.'**
  String get noRatingYet;

  /// No description provided for @journeyTitle.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك التعليمية'**
  String get journeyTitle;

  /// No description provided for @journeyRegisteredTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم التسجيل'**
  String get journeyRegisteredTitle;

  /// No description provided for @journeyRegisteredDesc.
  ///
  /// In ar, this message translates to:
  /// **'حجزت مكانك في الجلسة بنجاح.'**
  String get journeyRegisteredDesc;

  /// No description provided for @journeyAttendTitle.
  ///
  /// In ar, this message translates to:
  /// **'حضور الجلسة'**
  String get journeyAttendTitle;

  /// No description provided for @journeyAttendDesc.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار تأكيد حضورك من المدرب.'**
  String get journeyAttendDesc;

  /// No description provided for @journeyAttendDoneDesc.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد حضورك — أحسنت!'**
  String get journeyAttendDoneDesc;

  /// No description provided for @journeyCertTitle.
  ///
  /// In ar, this message translates to:
  /// **'استلام الشهادة'**
  String get journeyCertTitle;

  /// No description provided for @journeyCertDesc.
  ///
  /// In ar, this message translates to:
  /// **'بعد الحضور تقدر تحمّل شهادة حضورك.'**
  String get journeyCertDesc;

  /// No description provided for @journeyCertCurrentDesc.
  ///
  /// In ar, this message translates to:
  /// **'شهادتك جاهزة — حمّلها الآن.'**
  String get journeyCertCurrentDesc;

  /// No description provided for @journeyReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التقييم'**
  String get journeyReviewTitle;

  /// No description provided for @journeyReviewDesc.
  ///
  /// In ar, this message translates to:
  /// **'بعد تحميل الشهادة تقدر تشارك رأيك (اختياري).'**
  String get journeyReviewDesc;

  /// No description provided for @journeyReviewCurrentDesc.
  ///
  /// In ar, this message translates to:
  /// **'يسعدني معرفة رأيك في الجلسة. مشاركتك تساعدني على تقديم تجربة تعليمية أفضل.'**
  String get journeyReviewCurrentDesc;

  /// No description provided for @journeyCompleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتمال الرحلة'**
  String get journeyCompleteTitle;

  /// No description provided for @journeyCompleteDesc.
  ///
  /// In ar, this message translates to:
  /// **'أول خطوة في عالم البرمجة… اكتملت!'**
  String get journeyCompleteDesc;

  /// No description provided for @registerSuccessHeadline.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيلك بنجاح.'**
  String get registerSuccessHeadline;

  /// No description provided for @registerSuccessLine1.
  ///
  /// In ar, this message translates to:
  /// **'لقد حجزت مكانك في الجلسة.'**
  String get registerSuccessLine1;

  /// No description provided for @registerSuccessLine2.
  ///
  /// In ar, this message translates to:
  /// **'نتطلع لرؤيتك قريبًا.'**
  String get registerSuccessLine2;

  /// No description provided for @attendCongrats.
  ///
  /// In ar, this message translates to:
  /// **'مبروك! تم تأكيد حضورك. استلم شهادتك الآن وكمل رحلتك.'**
  String get attendCongrats;

  /// No description provided for @trackJourney.
  ///
  /// In ar, this message translates to:
  /// **'تابع رحلتك'**
  String get trackJourney;

  /// No description provided for @journeyLookupTitle.
  ///
  /// In ar, this message translates to:
  /// **'تابع رحلتك مع بشمهندس حسام'**
  String get journeyLookupTitle;

  /// No description provided for @journeyLookupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم الموبايل أو رقم التسجيل عشان تشوف تقدمك.'**
  String get journeyLookupSubtitle;

  /// No description provided for @thankYouCongrats.
  ///
  /// In ar, this message translates to:
  /// **'مبروك!'**
  String get thankYouCongrats;

  /// No description provided for @thankYouJourneyDone.
  ///
  /// In ar, this message translates to:
  /// **'لقد أكملت أول خطوة في رحلتك مع بشمهندس حسام.'**
  String get thankYouJourneyDone;

  /// No description provided for @thankYouBodyFull.
  ///
  /// In ar, this message translates to:
  /// **'أتمنى أن تكون الجلسة قد أضافت لك معرفة جديدة وشغفًا أكبر بعالم البرمجة.\n\nتذكّر دائمًا…\nكل مبرمج محترف كان يومًا ما مبتدئًا.\n\nاستمر في التعلّم، واستمر في المحاولة، ولا تتوقف عن تطوير نفسك.\n\nأراك قريبًا في الجلسات القادمة بإذن الله.\n\nبكل التوفيق ❤️\nبشمهندس حسام'**
  String get thankYouBodyFull;

  /// No description provided for @upcomingSessionsCta.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات القادمة'**
  String get upcomingSessionsCta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
