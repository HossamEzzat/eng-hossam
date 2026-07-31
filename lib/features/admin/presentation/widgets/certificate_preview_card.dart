import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// On-screen premium certificate matching the PDF layout.
class CertificatePreviewCard extends StatelessWidget {
  const CertificatePreviewCard({super.key, required this.registration});

  final Registration registration;

  @override
  Widget build(BuildContext context) {
    final pdf = CertificatePdfService();
    final certNo = pdf.certificateNumber(registration);
    final verifyUrl = pdf.verificationUrl(registration);
    final session = SessionCatalog.byId(registration.sessionId);
    final attendanceDate =
        registration.attendanceDate ?? registration.createdAt;
    final dateStr = DateFormat.yMMMMd().format(attendanceDate);

    return AspectRatio(
      aspectRatio: 1.414, // A4 landscape-ish
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF), Color(0xFFF0FDFA)],
          ),
          border: Border.all(color: AppColors.primary, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
            ..._corners(),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 22),
              child: Column(
                children: [
                  Text(
                    AppConstants.instructorNameEn.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Programming with Eng. Hossam',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 88,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.accent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Certificate of Attendance',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF0B1120),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'شهادة حضور',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This certifies that',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    registration.fullName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF0B1120),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'has successfully attended the programming session',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    registration.sessionLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _meta('Registration ID', registration.registrationId),
                      _meta('Grade', registration.grade),
                      _meta(
                        'Branch',
                        session?.branchLabel(false) ?? 'Suez',
                      ),
                      _meta('Attendance Date', dateStr),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 1.5,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              AppConstants.instructorNameEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF0B1120),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Instructor Signature',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          children: [
                            const Text(
                              'Certificate No.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              certNo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0B1120),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            children: [
                              QrImageView(
                                data: verifyUrl,
                                size: 56,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Verify',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    Widget corner({required Alignment alignment, double rot = 0}) {
      return Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Transform.rotate(
            angle: rot,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.primary, width: 2.5),
                  left: BorderSide(color: AppColors.secondary, width: 2.5),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft),
      corner(alignment: Alignment.topRight, rot: 1.5708),
      corner(alignment: Alignment.bottomLeft, rot: -1.5708),
      corner(alignment: Alignment.bottomRight, rot: 3.1416),
    ];
  }

  Widget _meta(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140, minWidth: 100),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B1120),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
