// ignore_for_file: implementation_imports

import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/data/services/pdf_arabic_text.dart';
import 'package:pdf/src/pdf/font/arabic.dart' as pdf_arabic;

void main() {
  group('PdfArabicText.prepare', () {
    test('leaves Latin names unchanged', () {
      expect(PdfArabicText.prepare('Youssef Ali'), 'Youssef Ali');
    });

    test('does not character-reverse Arabic names (يلع فسوي)', () {
      const name = 'يوسف علي';
      final prepared = PdfArabicText.prepare(name);
      final charReversed = String.fromCharCodes(name.runes.toList().reversed);
      expect(prepared, isNot(charReversed));
      expect(prepared, isNot(name));
    });

    test('puts last logical word first for LTR visual order', () {
      const name = 'يوسف علي';
      final prepared = PdfArabicText.prepare(name);
      // convert shapes each word; visual LTR needs علي then يوسف.
      final expected =
          '${pdf_arabic.convert('علي')} ${pdf_arabic.convert('يوسف')}';
      expect(prepared, expected);
    });

    test('single Arabic word stays a single shaped token', () {
      const name = 'سارة';
      final prepared = PdfArabicText.prepare(name);
      expect(prepared, pdf_arabic.convert(name));
      expect(prepared.split(' '), hasLength(1));
    });

    test('titleAr uses visual word order', () {
      const title = 'شهادة حضور';
      expect(
        PdfArabicText.prepare(title),
        '${pdf_arabic.convert('حضور')} ${pdf_arabic.convert('شهادة')}',
      );
    });
  });
}
