import 'package:intl/intl.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:pdf/pdf.dart';

/// Shared certificate fields used by PDF export and on-screen preview.
class CertificateContent {
  const CertificateContent({
    required this.brandLine,
    required this.title,
    required this.titleAr,
    required this.studentName,
    required this.registrationId,
    required this.certificateNumber,
    required this.sessionName,
    required this.branch,
    required this.grade,
    required this.attendanceDateLabel,
    required this.issueDateLabel,
    required this.instructorName,
    required this.verificationUrl,
  });

  final String brandLine;
  final String title;
  final String titleAr;
  final String studentName;
  final String registrationId;
  final String certificateNumber;
  final String sessionName;
  final String branch;
  final String grade;
  final String attendanceDateLabel;
  final String issueDateLabel;
  final String instructorName;
  final String verificationUrl;

  static CertificateContent fromRegistration(Registration registration) {
    final session = SessionCatalog.byId(registration.sessionId);
    final attendance =
        registration.attendanceDate ?? registration.createdAt;
    final issued = registration.certificateIssuedAt ?? DateTime.now();
    final certNo =
        'CERT-${registration.registrationId.replaceFirst('REG-', '')}';

    return CertificateContent(
      brandLine: 'Programming with Eng. Hossam',
      title: 'Certificate of Attendance',
      titleAr: 'شهادة حضور',
      studentName: registration.fullName,
      registrationId: registration.registrationId,
      certificateNumber: certNo,
      sessionName: session?.titleEn ?? registration.sessionLabel,
      branch: session?.branchLabel(false) ?? 'Suez',
      grade: registration.grade,
      attendanceDateLabel: DateFormat.yMMMMd().format(attendance),
      issueDateLabel: DateFormat.yMMMMd().format(issued),
      instructorName: AppConstants.instructorNameEn,
      verificationUrl:
          'https://hossamezzat.github.io/eng-hossam/verify/$certNo',
    );
  }
}

/// Print-friendly premium palette (navy + muted gold on warm paper).
abstract final class CertificatePalette {
  static final PdfColor paper = PdfColor.fromHex('#FBF8F2');
  static final PdfColor paperEdge = PdfColor.fromHex('#F3EEE4');
  static final PdfColor navy = PdfColor.fromHex('#1B2A41');
  static final PdfColor navySoft = PdfColor.fromHex('#2E4057');
  static final PdfColor gold = PdfColor.fromHex('#A8894A');
  static final PdfColor goldSoft = PdfColor.fromHex('#C4A868');
  static final PdfColor ink = PdfColor.fromHex('#1E293B');
  static final PdfColor muted = PdfColor.fromHex('#64748B');
  static final PdfColor line = PdfColor.fromHex('#D6CBB5');
  static final PdfColor white = PdfColor.fromHex('#FFFFFF');
}
