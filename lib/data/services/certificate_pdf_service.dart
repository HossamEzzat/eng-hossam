import 'dart:math' as math;
import 'dart:typed_data';

import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/services/certificate_content.dart';
import 'package:lumina/data/services/pdf_arabic_text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds a premium A4-landscape certificate PDF suitable for print.
///
/// On-screen preview renders this same document so download === preview.
class CertificatePdfService {
  String certificateNumber(Registration registration) =>
      CertificateContent.fromRegistration(registration).certificateNumber;

  String verificationUrl(Registration registration) =>
      CertificateContent.fromRegistration(registration).verificationUrl;

  Future<Uint8List> build(Registration registration) async {
    final content = CertificateContent.fromRegistration(registration);
    final doc = pw.Document(
      title: '${content.title} — ${content.studentName}',
      author: content.brandLine,
    );

    final cinzel = await PdfGoogleFonts.cinzelBold();
    final cinzelReg = await PdfGoogleFonts.cinzelRegular();
    final display = await PdfGoogleFonts.cormorantGaramondBold();
    final displayReg = await PdfGoogleFonts.cormorantGaramondRegular();
    final body = await PdfGoogleFonts.sourceSans3Regular();
    final bodySemi = await PdfGoogleFonts.sourceSans3SemiBold();
    final bodyBold = await PdfGoogleFonts.sourceSans3Bold();
    final script = await PdfGoogleFonts.greatVibesRegular();
    // Tajawal shapes Arabic reliably for PDF print.
    final arabic = await PdfGoogleFonts.tajawalRegular();
    final arabicBold = await PdfGoogleFonts.tajawalBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(
          base: body,
          bold: bodyBold,
          fontFallback: [arabic, arabicBold],
        ),
        build: (context) {
          return pw.Container(
            color: CertificatePalette.paperEdge,
            padding: const pw.EdgeInsets.all(18),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: CertificatePalette.paper,
                border: pw.Border.all(
                  color: CertificatePalette.navy,
                  width: 2.4,
                ),
              ),
              child: pw.Container(
                margin: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: CertificatePalette.gold,
                    width: 1.1,
                  ),
                ),
                child: pw.Stack(
                  children: [
                    pw.Positioned.fill(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            begin: pw.Alignment.topLeft,
                            end: pw.Alignment.bottomRight,
                            colors: [
                              CertificatePalette.paper,
                              CertificatePalette.paperEdge,
                              CertificatePalette.paper,
                            ],
                          ),
                        ),
                      ),
                    ),
                    pw.Center(
                      child: pw.Opacity(
                        opacity: 0.045,
                        child: pw.Text(
                          '{  }',
                          style: pw.TextStyle(
                            font: bodyBold,
                            fontSize: 220,
                            color: CertificatePalette.navy,
                          ),
                        ),
                      ),
                    ),
                    pw.Positioned(
                      left: 36,
                      top: 36,
                      child: _cornerOrnament(),
                    ),
                    pw.Positioned(
                      right: 36,
                      top: 36,
                      child: pw.Transform.rotate(
                        angle: math.pi / 2,
                        child: _cornerOrnament(),
                      ),
                    ),
                    pw.Positioned(
                      left: 36,
                      bottom: 36,
                      child: pw.Transform.rotate(
                        angle: -math.pi / 2,
                        child: _cornerOrnament(),
                      ),
                    ),
                    pw.Positioned(
                      right: 36,
                      bottom: 36,
                      child: pw.Transform.rotate(
                        angle: math.pi,
                        child: _cornerOrnament(),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(52, 34, 52, 28),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          _header(
                            content,
                            cinzel: cinzel,
                            cinzelReg: cinzelReg,
                            body: body,
                          ),
                          pw.SizedBox(height: 18),
                          pw.Center(child: _goldRule()),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            content.title.toUpperCase(),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: cinzel,
                              fontSize: 28,
                              letterSpacing: 3.2,
                              color: CertificatePalette.navy,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          PdfArabicText.build(
                            content.titleAr,
                            latinFont: bodySemi,
                            arabicFont: arabicBold,
                            fontSize: 14,
                            color: CertificatePalette.muted,
                          ),
                          pw.SizedBox(height: 18),
                          pw.Text(
                            'This is to certify that',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: body,
                              fontSize: 11,
                              color: CertificatePalette.muted,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          PdfArabicText.build(
                            content.studentName,
                            latinFont: display,
                            arabicFont: arabicBold,
                            fontSize: 34,
                            color: CertificatePalette.ink,
                          ),
                          pw.SizedBox(height: 6),
                          pw.Center(
                            child: pw.Container(
                              width: 220,
                              height: 1.2,
                              color: CertificatePalette.gold,
                            ),
                          ),
                          pw.SizedBox(height: 12),
                          pw.Text(
                            'has successfully attended the programming session',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              font: body,
                              fontSize: 11,
                              color: CertificatePalette.muted,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          PdfArabicText.build(
                            content.sessionName,
                            latinFont: displayReg,
                            arabicFont: arabicBold,
                            fontSize: 15,
                            color: CertificatePalette.navySoft,
                          ),
                          pw.SizedBox(height: 20),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceEvenly,
                            children: [
                              _metaBlock(
                                'Registration ID',
                                content.registrationId,
                                latinBody: body,
                                latinBold: bodySemi,
                                arabicBold: arabicBold,
                              ),
                              _metaBlock(
                                'Certificate No.',
                                content.certificateNumber,
                                latinBody: body,
                                latinBold: bodySemi,
                                arabicBold: arabicBold,
                              ),
                              _metaBlock(
                                'Branch',
                                content.branch,
                                latinBody: body,
                                latinBold: bodySemi,
                                arabicBold: arabicBold,
                              ),
                              _metaBlock(
                                'Grade',
                                content.grade,
                                latinBody: body,
                                latinBold: bodySemi,
                                arabicBold: arabicBold,
                              ),
                              _metaBlock(
                                'Attendance Date',
                                content.attendanceDateLabel,
                                latinBody: body,
                                latinBold: bodySemi,
                                arabicBold: arabicBold,
                              ),
                            ],
                          ),
                          pw.Spacer(),
                          pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Expanded(
                                flex: 3,
                                child: _signatureBlock(
                                  content,
                                  script: script,
                                  body: body,
                                  bodySemi: bodySemi,
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Column(
                                  children: [
                                    pw.Text(
                                      'Issue Date',
                                      style: pw.TextStyle(
                                        font: body,
                                        fontSize: 8,
                                        color: CertificatePalette.muted,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      content.issueDateLabel,
                                      style: pw.TextStyle(
                                        font: bodySemi,
                                        fontSize: 11,
                                        color: CertificatePalette.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Column(
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(6),
                                      decoration: pw.BoxDecoration(
                                        color: CertificatePalette.white,
                                        border: pw.Border.all(
                                          color: CertificatePalette.line,
                                          width: 0.8,
                                        ),
                                      ),
                                      child: pw.BarcodeWidget(
                                        barcode: pw.Barcode.qrCode(),
                                        data: content.verificationUrl,
                                        width: 68,
                                        height: 68,
                                        color: CertificatePalette.navy,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      'Scan to verify',
                                      style: pw.TextStyle(
                                        font: body,
                                        fontSize: 7.5,
                                        color: CertificatePalette.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 14),
                          pw.Container(
                            padding: const pw.EdgeInsets.only(top: 10),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(
                                top: pw.BorderSide(
                                  color: CertificatePalette.line,
                                  width: 0.8,
                                ),
                              ),
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  content.brandLine.toUpperCase(),
                                  style: pw.TextStyle(
                                    font: cinzelReg,
                                    fontSize: 7.5,
                                    letterSpacing: 1.4,
                                    color: CertificatePalette.navySoft,
                                  ),
                                ),
                                pw.Text(
                                  'Official training certificate · Print on A4',
                                  style: pw.TextStyle(
                                    font: body,
                                    fontSize: 7.5,
                                    color: CertificatePalette.muted,
                                  ),
                                ),
                                pw.Text(
                                  content.certificateNumber,
                                  style: pw.TextStyle(
                                    font: bodySemi,
                                    fontSize: 7.5,
                                    color: CertificatePalette.navySoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _header(
    CertificateContent content, {
    required pw.Font cinzel,
    required pw.Font cinzelReg,
    required pw.Font body,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                content.brandLine.toUpperCase(),
                style: pw.TextStyle(
                  font: cinzel,
                  fontSize: 11,
                  letterSpacing: 2.4,
                  color: CertificatePalette.navy,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Professional Programming Training',
                style: pw.TextStyle(
                  font: body,
                  fontSize: 9,
                  color: CertificatePalette.muted,
                ),
              ),
            ],
          ),
        ),
        _seal(cinzelReg),
      ],
    );
  }

  pw.Widget _seal(pw.Font font) {
    return pw.Container(
      width: 54,
      height: 54,
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: CertificatePalette.gold, width: 1.6),
      ),
      child: pw.Container(
        margin: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          border: pw.Border.all(color: CertificatePalette.navy, width: 0.8),
        ),
        child: pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'EH',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 13,
                  color: CertificatePalette.navy,
                  letterSpacing: 1,
                ),
              ),
              pw.Text(
                'CERT',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 6,
                  color: CertificatePalette.gold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pw.Widget _goldRule() {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 56,
          height: 1,
          color: CertificatePalette.gold,
        ),
        pw.SizedBox(width: 8),
        pw.Transform.rotate(
          angle: math.pi / 4,
          child: pw.Container(
            width: 7,
            height: 7,
            color: CertificatePalette.gold,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Container(
          width: 56,
          height: 1,
          color: CertificatePalette.gold,
        ),
      ],
    );
  }

  pw.Widget _cornerOrnament() {
    return pw.Container(
      width: 26,
      height: 26,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: CertificatePalette.gold, width: 1.8),
          left: pw.BorderSide(color: CertificatePalette.navy, width: 1.8),
        ),
      ),
    );
  }

  pw.Widget _metaBlock(
    String label,
    String value, {
    required pw.Font latinBody,
    required pw.Font latinBold,
    required pw.Font arabicBold,
  }) {
    return pw.ConstrainedBox(
      constraints: const pw.BoxConstraints(maxWidth: 130),
      child: pw.Column(
        children: [
          pw.Text(
            label.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: latinBody,
              fontSize: 7,
              letterSpacing: 0.7,
              color: CertificatePalette.muted,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: CertificatePalette.line,
                  width: 0.7,
                ),
              ),
            ),
            child: PdfArabicText.build(
              value,
              latinFont: latinBold,
              arabicFont: arabicBold,
              fontSize: 9.5,
              color: CertificatePalette.ink,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _signatureBlock(
    CertificateContent content, {
    required pw.Font script,
    required pw.Font body,
    required pw.Font bodySemi,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          content.instructorName,
          style: pw.TextStyle(
            font: script,
            fontSize: 26,
            color: CertificatePalette.navy,
          ),
        ),
        pw.Container(
          width: 150,
          height: 1,
          color: CertificatePalette.navySoft,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          content.instructorName,
          style: pw.TextStyle(
            font: bodySemi,
            fontSize: 10,
            color: CertificatePalette.ink,
          ),
        ),
        pw.Text(
          'Instructor Signature',
          style: pw.TextStyle(
            font: body,
            fontSize: 8,
            color: CertificatePalette.muted,
          ),
        ),
      ],
    );
  }
}
