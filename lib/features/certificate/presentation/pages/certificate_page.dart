import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/student_journey_progress.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CertificatePage extends ConsumerStatefulWidget {
  const CertificatePage({super.key});

  @override
  ConsumerState<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends ConsumerState<CertificatePage> {
  final _query = TextEditingController();
  bool _loading = false;
  String? _lookedUpId;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Registration? _liveRegistration() {
    final id = _lookedUpId;
    if (id == null) return null;
    return ref
        .read(sessionStoreProvider)
        .registrations
        .where((r) => r.id == id)
        .firstOrNull;
  }

  Future<void> _lookup() async {
    final l10n = context.l10n;
    final q = _query.text.trim();
    if (q.isEmpty) {
      setState(() => _error = l10n.certificateSubtitle);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _lookedUpId = null;
    });
    final reg = await ref.read(sessionRepositoryProvider).findCertificate(q);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _lookedUpId = reg?.id;
      if (reg == null) {
        _error = l10n.certNotFound;
      } else if (!reg.certificateApproved) {
        _error = l10n.certPending;
      }
    });
  }

  Future<void> _download(Registration reg) async {
    final bytes = await CertificatePdfService().build(reg);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
    await ref.read(sessionRepositoryProvider).markCertificateDownloaded(reg.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(sessionStoreProvider);
    final result = _liveRegistration();
    final showCert = result != null && result.certificateApproved;
    final unlockedReview =
        result != null && result.certificateDownloaded && !result.reviewSubmitted;

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.certificateTitle,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.certificateSubtitle,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _query,
                        decoration: InputDecoration(
                          labelText: l10n.fieldMobile,
                          hintText: l10n.certificateQueryHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onSubmitted: (_) => _lookup(),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: l10n.findCertificate,
                        expand: true,
                        isLoading: _loading,
                        icon: Icons.workspace_premium_outlined,
                        onPressed: _lookup,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: showCert
                                ? AppColors.primary
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(),
                if (result != null) ...[
                  const SizedBox(height: 24),
                  StudentJourneyProgress(registration: result),
                ],
                if (showCert) ...[
                  const SizedBox(height: 24),
                  if (result.certificateApproved &&
                      !result.certificateDownloaded) ...[
                    Text(
                      l10n.attendCongrats,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.textSoft,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _Preview(registration: result)
                      .animate()
                      .fadeIn()
                      .slideY(begin: 0.06),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: l10n.downloadPdf,
                    icon: Icons.download_rounded,
                    onPressed: () => _download(result),
                  ),
                  if (unlockedReview) ...[
                    const SizedBox(height: 24),
                    GlassCard(
                      glow: true,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            l10n.afterCertificateNudge,
                            textAlign: TextAlign.center,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.text,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GradientButton(
                            label: '⭐ ${l10n.shareExperience}',
                            icon: Icons.favorite_border_rounded,
                            variant: GradientButtonVariant.accent,
                            onPressed: () => context.go(
                              '/reviews?reg=${Uri.encodeComponent(result.registrationId)}&mobile=${Uri.encodeComponent(result.mobile)}',
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.96, 0.96)),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.registration});
  final Registration registration;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassCard(
      glow: true,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Text(
            l10n.brandName,
            style: context.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.certOfAttendance,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.certCertifies,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            registration.fullName,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.certAttended,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.sessionTitle,
            style: context.textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            registration.sessionLabel,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _meta(context, l10n.certInstructor, l10n.brandName),
              ),
              Expanded(
                child: _meta(context, l10n.fieldSchool, registration.schoolName),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _meta(context, l10n.certNumber, registration.registrationId),
          const SizedBox(height: 8),
          _meta(context, l10n.certRegId, registration.registrationId),
          const SizedBox(height: 24),
          QrImageView(
            data: 'hossam://${registration.registrationId}',
            size: 96,
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
