// ignore_for_file: implementation_imports
// Uses dart_pdf's Arabic shaper (not exported publicly). We convert once and
// draw LTR so the PDF engine does not reverse / reshape a second time.

import 'package:pdf/pdf.dart';
import 'package:pdf/src/pdf/font/arabic.dart' as pdf_arabic;
import 'package:pdf/widgets.dart' as pw;

/// Arabic-safe PDF text for certificates.
///
/// [pdf_arabic.convert] shapes letters and reverses *within* each word for LTR
/// painting, but keeps logical word order. Drawing that result with LTR leaves
/// names like يوسف علي visually backwards (يوسف on the left).
///
/// Using [pw.TextDirection.rtl] instead would re-run convert/bidi on the span and
/// can double-flip (يوسف علي → يلع فسوي) depending on `use_arabic` / `use_bidi`.
/// So we: convert → reverse word order → draw LTR.
abstract final class PdfArabicText {
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF]');

  static bool containsArabic(String text) => _arabic.hasMatch(text);

  /// Shape + visual order for LTR PDF drawing (no second RTL pass).
  static String prepare(String text) {
    if (!containsArabic(text)) return text;
    final shaped = pdf_arabic.convert(text);
    return shaped.split('\n').map(_visualWordOrder).join('\n');
  }

  /// [pdf_arabic.convert] keeps logical word order; flip words for LTR paint.
  static String _visualWordOrder(String line) {
    if (line.isEmpty) return line;
    final words = line.split(' ');
    if (words.length < 2) return line;
    return words.reversed.join(' ');
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
      // Always LTR after prepare — avoids a second bidi/convert pass.
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
