import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/features/admin/data/web_download.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminExportService {
  String studentsCsv(List<Registration> list) {
    final buf = StringBuffer(
      'registrationId,fullName,mobile,school,grade,city,session,registeredAt,attendance,certificate,review\n',
    );
    for (final r in list) {
      buf.writeln(
        '${r.registrationId},"${_esc(r.fullName)}","${r.mobile}","${_esc(r.schoolName)}","${_esc(r.grade)}","${r.city}","${_esc(r.sessionLabel)}",${r.createdAt.toIso8601String()},${r.attendanceStatus},${r.certificateStatus},${r.reviewStatus}',
      );
    }
    return buf.toString();
  }

  String reviewsCsv(List<Review> list) {
    final buf = StringBuffer(
      'id,name,rating,comment,status,createdAt,registrationId\n',
    );
    for (final r in list) {
      buf.writeln(
        '${r.id},"${_esc(r.name ?? '')}",${r.rating},"${_esc(r.comment)}",${r.status.name},${r.createdAt.toIso8601String()},${r.registrationId ?? ''}',
      );
    }
    return buf.toString();
  }

  Uint8List studentsExcel(List<Registration> list) {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    excel.delete('Sheet1');
    sheet.appendRow([
      TextCellValue('Registration ID'),
      TextCellValue('Full Name'),
      TextCellValue('Mobile'),
      TextCellValue('School'),
      TextCellValue('Grade'),
      TextCellValue('City'),
      TextCellValue('Session'),
      TextCellValue('Registered At'),
      TextCellValue('Attendance'),
      TextCellValue('Certificate'),
      TextCellValue('Review'),
    ]);
    for (final r in list) {
      sheet.appendRow([
        TextCellValue(r.registrationId),
        TextCellValue(r.fullName),
        TextCellValue(r.mobile),
        TextCellValue(r.schoolName),
        TextCellValue(r.grade),
        TextCellValue(r.city),
        TextCellValue(r.sessionLabel),
        TextCellValue(r.createdAt.toIso8601String()),
        TextCellValue(r.attendanceStatus),
        TextCellValue(r.certificateStatus),
        TextCellValue(r.reviewStatus),
      ]);
    }
    return Uint8List.fromList(excel.encode()!);
  }

  Future<Uint8List> attendanceSheetPdf({
    required String sessionTitle,
    required List<Registration> students,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Attendance Sheet',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(sessionTitle),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Reg ID',
              'Name',
              'Phone',
              'School',
              'Signature',
              'Attended',
            ],
            data: [
              for (final s in students)
                [
                  s.registrationId,
                  s.fullName,
                  s.mobile,
                  s.schoolName,
                  '',
                  s.attendanceConfirmed ? '✓' : '',
                ],
            ],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );
    return doc.save();
  }

  void downloadCsv(String filename, String content) {
    downloadBytes(
      filename,
      Uint8List.fromList(utf8.encode(content)),
      'text/csv;charset=utf-8',
    );
  }

  void downloadExcel(String filename, Uint8List bytes) {
    downloadBytes(
      filename,
      bytes,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  void downloadPdf(String filename, Uint8List bytes) {
    downloadBytes(filename, bytes, 'application/pdf');
  }

  String _esc(String v) => v.replaceAll('"', '""');
}
