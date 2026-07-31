import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/data/repositories/reviews_providers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/empty_state.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Public reviews page — never shows fabricated content.
/// Form unlocks only after registration → attendance → certificate download.
class ReviewsPage extends ConsumerStatefulWidget {
  const ReviewsPage({super.key, this.registrationId, this.mobile});

  final String? registrationId;
  final String? mobile;

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  double _rating = 5;
  final _comment = TextEditingController();
  final _suggestions = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _showForm = (widget.registrationId?.isNotEmpty ?? false) ||
        (widget.mobile?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _comment.dispose();
    _suggestions.dispose();
    _name.dispose();
    super.dispose();
  }

  Registration? _eligibleStudent() {
    final store = ref.read(sessionStoreProvider);
    final q = widget.registrationId ?? widget.mobile;
    if (q == null || q.trim().isEmpty) return null;
    final student = store.findByMobileOrId(q);
    if (student == null) return null;
    if (!student.certificateDownloaded || student.reviewSubmitted) {
      return null;
    }
    if (!student.attendanceConfirmed) return null;
    return student;
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final eligible = _eligibleStudent();
    if (eligible == null) {
      context.showSnack(l10n.reviewNotEligible);
      return;
    }
    if (_comment.text.trim().isEmpty) {
      context.showSnack(l10n.commentLabel);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(sessionRepositoryProvider).submitReview(
            rating: _rating,
            comment: _comment.text,
            suggestions: _suggestions.text,
            name: _name.text.trim().isEmpty ? null : _name.text,
            registrationId: eligible.registrationId,
            mobile: eligible.mobile,
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
    final eligible = _eligibleStudent();

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
              error: (_, _) => _emptyBlock(context),
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
                    if (eligible != null && _showForm) ...[
                      const SizedBox(height: 24),
                      _buildForm(),
                    ] else if (hasReviews || _showForm) ...[
                      const SizedBox(height: 24),
                      _lockedOrCta(context, eligible != null),
                    ],
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
      onAction: () {
        if (_eligibleStudent() != null) {
          setState(() => _showForm = true);
        } else {
          context.go('/journey');
        }
      },
      compact: true,
    ).animate().fadeIn();
  }

  Widget _lockedOrCta(BuildContext context, bool canForm) {
    final l10n = context.l10n;
    if (canForm) {
      return GlassCard(
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
              onPressed: () => setState(() => _showForm = true),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        children: [
          Text(
            l10n.reviewLockedTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.reviewLockedBody,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSoft,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: l10n.addReviewCta,
            onPressed: () => context.go('/journey'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/journey'),
            child: Text(l10n.reviewUnlockCta),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildForm() {
    final l10n = context.l10n;
    return GlassCard(
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
            l10n.afterCertificateNudge,
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
                iconSize: 36,
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
            decoration: InputDecoration(
              labelText: l10n.contactName,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _comment,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.commentLabel,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _suggestions,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.suggestionsLabel,
              alignLabelWithHint: true,
            ),
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
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          if (review.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.suggestionsLabel}: ${review.suggestions}',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
