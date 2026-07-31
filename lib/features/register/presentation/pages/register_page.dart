import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/opening_session.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/student_journey_progress.dart';
import 'package:lumina/theme/app_colors.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.preselectedSessionId});

  /// Ignored — every registration joins the single official session.
  final String? preselectedSessionId;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _school = TextEditingController();

  String? _grade;
  bool _loading = false;
  Registration? _success;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _school.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_grade == null) {
      context.showSnack(l10n.validateGrade);
      return;
    }
    setState(() => _loading = true);
    try {
      final reg = await ref.read(sessionRepositoryProvider).register(
            fullName: _name.text,
            mobile: _mobile.text,
            schoolName: _school.text,
            grade: _grade!,
          );
      if (!mounted) return;
      setState(() => _success = reg);
    } catch (e) {
      if (!mounted) return;
      context.showSnack(
        e is StateError ? e.message : l10n.validateSession,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _success != null ? 820 : 560,
            ),
            child:
                _success != null ? _buildSuccess(reg: _success!) : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final l10n = context.l10n;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final session = SessionCatalog.official;
    final grades = [l10n.gradeFirst, l10n.gradeSecond];

    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.registerTitle,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.registerSubtitle,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSoft,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title(isAr),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${session.cityLabel(isAr)} · 🏫 ${session.academy(isAr)}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                  Text(
                    '📌 ${session.address(isAr)}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                  Text(
                    '🕕 ${session.timeLabel(isAr)}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                  Text(
                    '👨‍🏫 ${isAr ? AppConstants.instructorNameAr : AppConstants.instructorNameEn}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.fieldFullName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? l10n.validateName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                labelText: l10n.fieldMobile,
                hintText: '01xxxxxxxxx',
                prefixIcon: const Icon(Icons.phone_iphone_rounded),
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                  return l10n.validateMobile;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _school,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.fieldSchool,
                prefixIcon: const Icon(Icons.school_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validateSchool : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(_grade),
              isExpanded: true,
              initialValue: _grade,
              decoration: InputDecoration(
                labelText: l10n.fieldGrade,
                prefixIcon: const Icon(Icons.grade_outlined),
              ),
              items: [
                for (final g in grades)
                  DropdownMenuItem(
                    value: g,
                    child: Text(g, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _grade = v),
              validator: (v) => v == null ? l10n.validateGrade : null,
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: l10n.submitRegister,
              expand: true,
              isLoading: _loading,
              icon: Icons.check_circle_outline,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.06);
  }

  Widget _buildSuccess({required Registration reg}) {
    final l10n = context.l10n;
    final store = ref.watch(sessionStoreProvider);
    final live = store.registrations
            .where((r) => r.id == reg.id)
            .firstOrNull ??
        reg;

    return Column(
      children: [
        GlassCard(
          glow: true,
          child: Column(
            children: [
              const Text('🚀', style: TextStyle(fontSize: 48))
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                l10n.registerSuccessHeadline,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                live.sessionLabel,
                textAlign: TextAlign.center,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.registerSuccessLine1,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.registerSuccessLine2,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSoft,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.registrationIdLabel,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: Text(
                  live.registrationId,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.saveIdHint,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoft,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.96, 0.96)),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: StudentJourneyProgress(registration: live),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            GradientButton(
              label: l10n.trackJourney,
              icon: Icons.route_outlined,
              onPressed: () => context.go(
                '/journey?q=${Uri.encodeComponent(live.registrationId)}',
              ),
            ),
            GradientButton(
              label: l10n.backHome,
              icon: Icons.home_outlined,
              variant: GradientButtonVariant.secondary,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ],
    );
  }
}
