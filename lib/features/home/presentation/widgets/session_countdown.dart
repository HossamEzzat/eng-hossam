import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/theme/app_colors.dart';

/// Live countdown until [target]. Shows days, hours, minutes, seconds.
class SessionCountdown extends StatefulWidget {
  const SessionCountdown({
    super.key,
    required this.target,
    this.compact = false,
    this.label,
  });

  final DateTime target;
  final bool compact;
  final String? label;

  @override
  State<SessionCountdown> createState() => _SessionCountdownState();
}

class _SessionCountdownState extends State<SessionCountdown> {
  late Duration _left;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant SessionCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) _tick();
  }

  void _tick() {
    final d = widget.target.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _left = d.isNegative ? Duration.zero : d);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = _left.inDays;
    final hours = _left.inHours % 24;
    final mins = _left.inMinutes % 60;
    final secs = _left.inSeconds % 60;
    final ended = _left == Duration.zero;

    if (ended) {
      return Text(
        l10n.sessionTitle,
        style: context.textTheme.labelLarge?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    Widget cell(String value, String unit) {
      if (widget.compact) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.padLeft(2, '0'),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.text,
              ),
            ),
            Text(
              unit,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        );
      }

      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.padLeft(2, '0'),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label ?? l10n.sessionsTitle,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.compact)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.secondary.withValues(alpha: 0.12),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: [
                cell('$days', l10n.countdownDays),
                _sep(context),
                cell('$hours', l10n.countdownHours),
                _sep(context),
                cell('$mins', l10n.countdownMinutes),
                _sep(context),
                cell('$secs', l10n.countdownSeconds),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              cell('$days', l10n.countdownDays),
              cell('$hours', l10n.countdownHours),
              cell('$mins', l10n.countdownMinutes),
              cell('$secs', l10n.countdownSeconds),
            ],
          ),
      ],
    );
  }

  Widget _sep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
