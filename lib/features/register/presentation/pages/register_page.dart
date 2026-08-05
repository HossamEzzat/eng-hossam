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

  bool _loading = false;
  Registration? _success;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final reg = await ref.read(sessionRepositoryProvider).register(
            fullName: _name.text,
            mobile: _mobile.text,
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
            constraints: const BoxConstraints(maxWidth: 520),
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
                  const SizedBox(height: 10),
                  _SessionLine(
                    Icons.place_outlined,
                    '${session.cityLabel(isAr)} · ${session.academy(isAr)}',
                  ),
                  const SizedBox(height: 6),
                  _SessionLine(
                    Icons.calendar_month_outlined,
                    '${session.dateLabel(isAr)} · ${session.timeLabel(isAr)}',
                  ),
                  const SizedBox(height: 6),
                  _SessionLine(
                    Icons.person_outline_rounded,
                    isAr
                        ? AppConstants.instructorNameAr
                        : AppConstants.instructorNameEn,
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            GradientButton(
              label: l10n.addReviewCta,
              icon: Icons.star_rounded,
              onPressed: () => context.go(
                '/reviews?mobile=${Uri.encodeComponent(live.mobile)}'
                '&name=${Uri.encodeComponent(live.fullName)}',
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

class _SessionLine extends StatelessWidget {
  const _SessionLine(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
