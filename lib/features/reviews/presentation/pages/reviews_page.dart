import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/repositories/reviews_providers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/empty_state.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Public reviews — name + phone + stars + opinion. No fabricated content.
class ReviewsPage extends ConsumerStatefulWidget {
  const ReviewsPage({super.key, this.registrationId, this.mobile, this.name});

  final String? registrationId;
  final String? mobile;
  final String? name;

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 5;
  final _comment = TextEditingController();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  bool _loading = false;
  bool _showForm = true;

  @override
  void initState() {
    super.initState();
    if (widget.name?.isNotEmpty ?? false) {
      _name.text = widget.name!;
    }
    if (widget.mobile?.isNotEmpty ?? false) {
      _mobile.text = widget.mobile!;
    }
  }

  @override
  void dispose() {
    _comment.dispose();
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (_comment.text.trim().isEmpty) {
      context.showSnack(l10n.commentLabel);
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final mobile = _mobile.text.trim();
      final name = _name.text.trim();

      var student = await repo.findCertificate(mobile);
      student ??= await repo.register(
        fullName: name,
        mobile: mobile,
      );

      if (student.reviewSubmitted) {
        if (!mounted) return;
        context.showSnack(l10n.reviewAlreadySubmitted);
        return;
      }

      await repo.submitReview(
        rating: _rating,
        comment: _comment.text,
        name: name,
        registrationId: student.registrationId,
        mobile: student.mobile,
      );
      if (!mounted) return;
      context.go('/thank-you');
    } catch (e) {
      if (!mounted) return;
      context.showSnack(
        e is StateError ? e.message : l10n.reviewNotEligible,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reviewsAsync = ref.watch(publicReviewsProvider);

    return SiteShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: reviewsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Column(
                children: [
                  _emptyBlock(context),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
              data: (reviews) {
                final hasReviews = reviews.isNotEmpty;
                final avg = hasReviews
                    ? reviews.fold<double>(0, (a, b) => a + b.rating) /
                        reviews.length
                    : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      glow: true,
                      child: Column(
                        children: [
                          Text(
                            l10n.reviewsPageTitle,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.reviewsSubtitle,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSoft,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (hasReviews) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.accent,
                                  size: 36,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  avg.toStringAsFixed(1),
                                  style: context.textTheme.displaySmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.averageRating} · ${reviews.length}',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSoft,
                              ),
                            ),
                          ] else
                            Text(
                              l10n.noRatingYet,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 28),
                    if (!hasReviews)
                      _emptyBlock(context)
                    else
                      ...reviews.asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TestimonialCard(review: e.value)
                              .animate()
                              .fadeIn(delay: (80 * e.key).ms)
                              .slideY(begin: 0.04),
                        );
                      }),
                    const SizedBox(height: 24),
                    if (_showForm)
                      _buildForm()
                    else
                      GlassCard(
                        glow: true,
                        child: Column(
                          children: [
                            Text(
                              l10n.afterCertificateNudge,
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: AppColors.text,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GradientButton(
                              label: l10n.addReviewCta,
                              onPressed: () =>
                                  setState(() => _showForm = true),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyBlock(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: Icons.reviews_outlined,
      title: l10n.reviewsEmptyTitle,
      subtitle: l10n.reviewsEmptySubtitle,
      actionLabel: l10n.addReviewCta,
      onAction: () => setState(() => _showForm = true),
      compact: true,
    ).animate().fadeIn();
  }

  Widget _buildForm() {
    final l10n = context.l10n;
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addReviewCta,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reviewFormHint,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSoft,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.ratingLabel,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled = _rating >= star;
                return IconButton(
                  onPressed: () => setState(() => _rating = star.toDouble()),
                  iconSize: 40,
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.accent,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _comment,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.commentLabel,
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.commentLabel : null,
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: l10n.submitReview,
              expand: true,
              isLoading: _loading,
              icon: Icons.send_rounded,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (i) {
                final filled = review.rating >= i + 1;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: AppColors.accent,
                );
              }),
              const Spacer(),
              if (review.name != null)
                Text(
                  review.name!,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: context.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
