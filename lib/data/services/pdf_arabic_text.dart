import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Helpers so Arabic PDF text uses an Arabic *primary* font (not fallback).
///
/// Using Latin fonts with Arabic fallback leaves letters disconnected —
/// a known dart_pdf limitation.
abstract final class PdfArabicText {
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF]');

  static bool containsArabic(String text) => _arabic.hasMatch(text);

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
      text,
      textAlign: textAlign,
      textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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
