import 'package:flutter/material.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// On-screen certificate that renders the **exact same PDF** students download.
///
/// Preview and export stay identical by design.
class CertificatePreviewCard extends StatelessWidget {
  const CertificatePreviewCard({super.key, required this.registration});

  final Registration registration;

  static final _pageFormat = PdfPageFormat.a4.landscape;

  @override
  Widget build(BuildContext context) {
    final aspect = _pageFormat.width / _pageFormat.height;

    return AspectRatio(
      aspectRatio: aspect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B2A41).withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: PdfPreview(
            key: ValueKey(
              '${registration.id}_${registration.fullName}_'
              '${registration.certificateIssuedAt}_'
              '${registration.attendanceDate}',
            ),
            build: (_) => CertificatePdfService().build(registration),
            initialPageFormat: _pageFormat,
            maxPageWidth: 1100,
            dpi: 150,
            useActions: false,
            allowPrinting: false,
            allowSharing: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            padding: EdgeInsets.zero,
            previewPageMargin: EdgeInsets.zero,
            scrollViewDecoration: const BoxDecoration(
              color: Color(0xFFF3EEE4),
            ),
            pdfPreviewPageDecoration: const BoxDecoration(
              color: Color(0xFFFBF8F2),
            ),
            loadingWidget: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFA8894A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
