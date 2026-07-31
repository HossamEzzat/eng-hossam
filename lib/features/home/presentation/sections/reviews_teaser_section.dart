import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/repositories/reviews_providers.dart';
import 'package:lumina/shared/widgets/empty_state.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

/// Home reviews teaser — real approved reviews only; empty state if none.
class ReviewsTeaserSection extends ConsumerWidget {
  const ReviewsTeaserSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(publicReviewsProvider);
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 48 : 24,
        vertical: 88,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxContentWidth,
          ),
          child: Column(
            children: [
              SectionHeader(
                centered: true,
                eyebrow: l10n.postSessionTitle,
                headline: l10n.reviewsTitle,
                subtitle: l10n.reviewsSubtitle,
              ),
              const SizedBox(height: 36),
              reviewsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
                error: (_, _) => _empty(context),
                data: (reviews) {
                  final hasReviews = reviews.isNotEmpty;
                  if (!hasReviews) return _empty(context);

                  final avg = reviews.fold<double>(0, (a, b) => a + b.rating) /
                      reviews.length;
                  final preview = reviews.take(3).toList();

                  return Column(
                    children: [
                      FadeInView(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 22,
                          ),
                          borderRadius: 20,
                          glow: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                avg.toStringAsFixed(1),
                                style:
                                    context.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        avg >= i + 1
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: AppColors.accent,
                                        size: 22,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${l10n.averageRating} · ${reviews.length}',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final gap = 16.0;
                          final cols = constraints.maxWidth >= 900
                              ? 3
                              : constraints.maxWidth >= 600
                                  ? 2
                                  : 1;
                          final width =
                              (constraints.maxWidth - gap * (cols - 1)) / cols;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: [
                              for (var i = 0; i < preview.length; i++)
                                SizedBox(
                                  width: width,
                                  child: FadeInView(
                                    delay: Duration(milliseconds: 80 * i),
                                    child: _ReviewCard(review: preview[i]),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          GradientButton(
                            label: l10n.reviewsCta,
                            onPressed: () => context.go('/reviews'),
                          ),
                          GradientButton(
                            label: l10n.addReviewCta,
                            variant: GradientButtonVariant.secondary,
                            onPressed: () => context.go('/journey'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      child: GlassCard(
        glow: true,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: EmptyState(
          icon: Icons.auto_awesome_rounded,
          title: l10n.reviewsEmptyTitle,
          subtitle: l10n.reviewsEmptySubtitle,
          actionLabel: l10n.addReviewCta,
          onAction: () => context.go('/journey'),
          compact: true,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      height: 220,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              Text(
                review.rating.toStringAsFixed(0),
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              '«${review.comment}»',
              style: context.textTheme.bodyMedium?.copyWith(
                height: 1.65,
                fontStyle: FontStyle.italic,
                color: AppColors.text,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          if (review.name != null)
            Text(
              review.name!,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
