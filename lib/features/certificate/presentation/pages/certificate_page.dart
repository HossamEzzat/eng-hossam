import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/services/certificate_pdf_service.dart';
import 'package:lumina/features/admin/presentation/widgets/certificate_preview_card.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/student_journey_progress.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class CertificatePage extends ConsumerStatefulWidget {
  const CertificatePage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends ConsumerState<CertificatePage> {
  late final TextEditingController _query;
  bool _loading = false;
  String? _lookedUpId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

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
      }
    });
  }

  Future<void> _download(Registration reg) async {
    final bytes = await CertificatePdfService().build(reg);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'certificate_${reg.registrationId}.pdf',
      format: PdfPageFormat.a4.landscape,
    );
    await ref.read(sessionRepositoryProvider).markCertificateDownloaded(reg.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(sessionStoreProvider);
    final result = _liveRegistration();
    // Instant certificate: found registration == eligible (no attendance gate).
    final showCert = result != null;
    final unlockedReview = result != null &&
        result.certificateDownloaded &&
        !result.reviewSubmitted;

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
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
                  if (!result.certificateDownloaded) ...[
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
                  CertificatePreviewCard(registration: result)
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
