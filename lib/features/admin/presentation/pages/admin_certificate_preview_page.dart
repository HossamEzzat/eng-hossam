import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/features/admin/presentation/widgets/certificate_preview_card.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Admin-only page to review the certificate design before publishing.
class AdminCertificatePreviewPage extends ConsumerStatefulWidget {
  const AdminCertificatePreviewPage({super.key});

  @override
  ConsumerState<AdminCertificatePreviewPage> createState() =>
      _AdminCertificatePreviewPageState();
}

class _AdminCertificatePreviewPageState
    extends ConsumerState<AdminCertificatePreviewPage> {
  String? _selectedId;
  bool _downloading = false;

  Registration _sample() {
    final now = DateTime.now();
    final session = SessionCatalog.official;
    return Registration(
      id: 'preview',
      registrationId: 'REG-2026-PREVIEW',
      fullName: 'أحمد محمد علي',
      mobile: '01000000000',
      schoolName: 'مدرسة السويس الثانوية',
      grade: 'الصف الثاني الثانوي',
      sessionId: session.id,
      sessionLabel: session.displayLabel(true),
      createdAt: now.subtract(const Duration(days: 3)),
      city: 'suez',
      attendanceConfirmed: true,
      attendanceDate: now,
      certificateIssued: true,
      certificateIssuedAt: now,
    );
  }

  Registration _current(List<Registration> students) {
    if (_selectedId == null) return _sample();
    return students.where((r) => r.id == _selectedId).firstOrNull ?? _sample();
  }

  Future<void> _downloadPdf(Registration reg) async {
    setState(() => _downloading = true);
    try {
      final bytes = await CertificatePdfService().build(reg);
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'certificate_${reg.registrationId}.pdf',
        format: PdfPageFormat.a4.landscape,
      );
      if (mounted) adminSnack(context, 'Certificate PDF ready');
    } catch (e) {
      if (mounted) adminSnack(context, 'PDF failed: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(sessionStoreProvider);
    final students = store.registrations;
    final reg = _current(students);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Certificate Preview',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review the exact certificate students receive after attendance. Admin only.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoft,
              ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedId,
                decoration: const InputDecoration(
                  labelText: 'Preview student',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sample preview student'),
                  ),
                  for (final s in students)
                    DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.fullName} · ${s.registrationId}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _selectedId = v),
              ),
              ),
            ),
            FilledButton.icon(
              onPressed: _downloading ? null : () => _downloadPdf(reg),
              icon: _downloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Download PDF'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: CertificatePreviewCard(registration: reg),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: const Text(
            'Tip: Mark attendance and publish the certificate from Students before students can download it on the public site.',
            style: TextStyle(color: AppColors.textSoft, height: 1.45),
          ),
        ),
      ],
    );
  }
}
