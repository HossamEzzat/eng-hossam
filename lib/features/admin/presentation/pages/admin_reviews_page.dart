import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumina/data/models/review.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/features/admin/presentation/widgets/admin_ui.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminReviewsPage extends ConsumerWidget {
  const AdminReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionStoreProvider);
    final reviews = store.reviews;
    final fmt = DateFormat('yyyy-MM-dd HH:mm');

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Reviews',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Only approved reviews appear on the public website. Never invent reviews.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoft,
              ),
        ),
        const SizedBox(height: 20),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          )
        else
          ...reviews.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.name ?? 'Anonymous',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _badge(r.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.comment,
                    style: const TextStyle(color: AppColors.textSoft, height: 1.45),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(r.createdAt),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () {
                          store.setReviewStatus(
                            r.id,
                            ReviewModerationStatus.approved,
                          );
                          adminSnack(context, 'Review approved');
                        },
                        child: const Text('Approve'),
                      ),
                      TextButton(
                        onPressed: () {
                          store.setReviewStatus(
                            r.id,
                            ReviewModerationStatus.hidden,
                          );
                          adminSnack(context, 'Review hidden');
                        },
                        child: const Text('Hide'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final ok = await adminConfirm(
                            context,
                            title: 'Delete review?',
                            message: 'This cannot be undone.',
                            destructive: true,
                            confirmLabel: 'Delete',
                          );
                          if (!ok) return;
                          store.deleteReview(r.id);
                          if (context.mounted) {
                            adminSnack(context, 'Review deleted');
                          }
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _badge(ReviewModerationStatus status) {
    final color = switch (status) {
      ReviewModerationStatus.approved => AppColors.success,
      ReviewModerationStatus.hidden => AppColors.textMuted,
      ReviewModerationStatus.pending => AppColors.accent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
