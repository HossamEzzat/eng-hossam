// ignore_for_file: implementation_imports
// Uses dart_pdf's Arabic shaper (not exported publicly). We convert once and
// draw LTR so the PDF engine does not reverse names a second time.

import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/font/arabic.dart' as pdf_arabic;
import 'package:pdf/widgets.dart' as pw;

/// Arabic-safe PDF text for certificates.
///
/// [pdf_arabic.convert] already produces visual glyph order for LTR drawing.
/// Setting [pw.TextDirection.rtl] on top of that reverses the name again
/// (يوسف علي → يلع فسوي). So we convert once, then draw LTR.
abstract final class PdfArabicText {
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF]');

  static bool containsArabic(String text) => _arabic.hasMatch(text);

  /// Shape + visual order for PDF (no second RTL pass).
  static String prepare(String text) {
    if (!containsArabic(text)) return text;
    return pdf_arabic.convert(text);
  }

  static pw.Text build(
    String text, {
    required pw.Font latinFont,
    required pw.Font arabicFont,
    required double fontSize,
    required PdfColor color,
    pw.TextAlign textAlign = pw.TextAlign.center,
    double? letterSpacing,
    pw.FontStyle? fontStyle,
  }) {
    final isAr = containsArabic(text);
    return pw.Text(
      isAr ? prepare(text) : text,
      textAlign: textAlign,
      // Always LTR after arabic.convert — avoids double-reverse.
      textDirection: pw.TextDirection.ltr,
      style: pw.TextStyle(
        font: isAr ? arabicFont : latinFont,
        fontSize: fontSize,
        color: color,
        letterSpacing: isAr ? 0 : letterSpacing,
        fontStyle: fontStyle,
      ),
    );
  }
}
