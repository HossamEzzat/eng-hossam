import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CertificatePdfService {
  String certificateNumber(Registration registration) =>
      'CERT-${registration.registrationId.replaceFirst('REG-', '')}';

  String verificationUrl(Registration registration) =>
      'https://eng-hossam.web.app/verify/${certificateNumber(registration)}';

  Future<Uint8List> build(Registration registration) async {
    final doc = pw.Document();
    final certNo = certificateNumber(registration);
    final verifyUrl = verificationUrl(registration);
    final session = SessionCatalog.byId(registration.sessionId);
    final attendanceDate = registration.attendanceDate ?? registration.createdAt;
    final dateStr = DateFormat.yMMMMd().format(attendanceDate);

    pw.Font? arabic;
    pw.Font? arabicBold;
    try {
      arabic = await PdfGoogleFonts.notoSansArabicRegular();
      arabicBold = await PdfGoogleFonts.notoSansArabicBold();
    } catch (_) {}

    final primary = PdfColor.fromHex('#3B82F6');
    final secondary = PdfColor.fromHex('#06B6D4');
    final accent = PdfColor.fromHex('#F59E0B');
    final dark = PdfColor.fromHex('#0B1120');
    final muted = PdfColor.fromHex('#64748B');
    final cream = PdfColor.fromHex('#F8FAFC');

    final baseFont = arabic;
    final boldFont = arabicBold;
    final useArabic = baseFont != null && boldFont != null;

    final baseStyle = useArabic
        ? pw.TextStyle(font: baseFont, fontFallback: [baseFont])
        : const pw.TextStyle();
    final boldStyle = useArabic
        ? pw.TextStyle(font: boldFont, fontFallback: [boldFont])
        : pw.TextStyle(fontWeight: pw.FontWeight.bold);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        theme: useArabic
            ? pw.ThemeData.withFont(base: baseFont, bold: boldFont)
            : null,
        textDirection:
            useArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: cream,
              border: pw.Border.all(color: primary, width: 3),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Stack(
              children: [
                // Inner decorative border
                pw.Positioned.fill(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#67E8F9'),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                // Corner accents
                pw.Positioned(
                  left: 18,
                  top: 18,
                  child: _corner(primary, secondary),
                ),
                pw.Positioned(
                  right: 18,
                  top: 18,
                  child: pw.Transform.rotate(
                    angle: 1.5708,
                    child: _corner(primary, secondary),
                  ),
                ),
                pw.Positioned(
                  left: 18,
                  bottom: 18,
                  child: pw.Transform.rotate(
                    angle: -1.5708,
                    child: _corner(primary, secondary),
                  ),
                ),
                pw.Positioned(
                  right: 18,
                  bottom: 18,
                  child: pw.Transform.rotate(
                    angle: 3.1416,
                    child: _corner(primary, secondary),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(48, 36, 48, 28),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        AppConstants.instructorNameEn.toUpperCase(),
                        style: boldStyle.copyWith(
                          color: primary,
                          fontSize: 12,
                          letterSpacing: 3,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Programming with Eng. Hossam',
                        style: baseStyle.copyWith(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 14),
                      pw.Container(
                        width: 80,
                        height: 2,
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            colors: [primary, secondary, accent],
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 14),
                      pw.Text(
                        'Certificate of Attendance',
                        style: boldStyle.copyWith(
                          color: dark,
                          fontSize: 30,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'شهادة حضور',
                        style: boldStyle.copyWith(
                          color: muted,
                          fontSize: 14,
                        ),
                      ),
                      pw.SizedBox(height: 18),
                      pw.Text(
                        'This certifies that',
                        style: baseStyle.copyWith(color: muted, fontSize: 11),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        registration.fullName,
                        style: boldStyle.copyWith(
                          color: dark,
                          fontSize: 28,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'has successfully attended the programming session',
                        style: baseStyle.copyWith(color: muted, fontSize: 11),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        registration.sessionLabel,
                        style: boldStyle.copyWith(
                          color: primary,
                          fontSize: 14,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          _meta('Registration ID', registration.registrationId,
                              baseStyle, boldStyle),
                          _meta(
                            'Grade',
                            registration.grade,
                            baseStyle,
                            boldStyle,
                          ),
                          _meta(
                            'Branch',
                            session?.branchLabel(false) ??
                                registration.sessionLabel,
                            baseStyle,
                            boldStyle,
                          ),
                          _meta(
                            'Attendance Date',
                            dateStr,
                            baseStyle,
                            boldStyle,
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Container(
                                width: 150,
                                height: 1.2,
                                color: muted,
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                AppConstants.instructorNameEn,
                                style: boldStyle.copyWith(
                                  color: dark,
                                  fontSize: 11,
                                ),
                              ),
                              pw.Text(
                                'Instructor Signature',
                                style: baseStyle.copyWith(
                                  color: muted,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                'Certificate No.',
                                style: baseStyle.copyWith(
                                  color: muted,
                                  fontSize: 8,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                certNo,
                                style: boldStyle.copyWith(
                                  color: dark,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.BarcodeWidget(
                                barcode: pw.Barcode.qrCode(),
                                data: verifyUrl,
                                width: 64,
                                height: 64,
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Verify',
                                style: baseStyle.copyWith(
                                  color: muted,
                                  fontSize: 7,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _corner(PdfColor a, PdfColor b) {
    return pw.Container(
      width: 28,
      height: 28,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: a, width: 2.5),
          left: pw.BorderSide(color: b, width: 2.5),
        ),
      ),
    );
  }

  pw.Widget _meta(
    String label,
    String value,
    pw.TextStyle base,
    pw.TextStyle bold,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label.toUpperCase(),
          style: base.copyWith(
            color: PdfColor.fromHex('#94A3B8'),
            fontSize: 7,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: bold.copyWith(
            color: PdfColor.fromHex('#0B1120'),
            fontSize: 10,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
