import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/models/student_journey.dart';
import 'package:lumina/l10n/app_localizations.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

class StudentJourneyProgress extends StatelessWidget {
  const StudentJourneyProgress({
    super.key,
    required this.registration,
    this.showActions = true,
    this.compact = false,
  });

  final Registration registration;
  final bool showActions;
  final bool compact;

  StudentJourney get _journey => StudentJourney.fromRegistration(
        hasRegistration: true,
        attendanceConfirmed: registration.attendanceConfirmed,
        certificateIssued: registration.certificateIssued,
        certificateDownloaded: registration.certificateDownloaded,
        reviewSubmitted: registration.reviewSubmitted,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final journey = _journey;
    final horizontal = MediaQuery.sizeOf(context).width >= Breakpoints.desktop &&
        !compact;
    final milestones = JourneyMilestone.values;
    final steps = milestones.map((m) {
      return _StepData(
        milestone: m,
        visual: journey.stateFor(m),
        title: _title(l10n, m),
        description: _desc(l10n, m, journey),
        emoji: _emoji(m),
      );
    }).toList();

    return GlassCard(
      glow: journey.isFullyComplete,
      padding: EdgeInsets.all(compact ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.journeyTitle,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 18),
          if (horizontal)
            _HorizontalTimeline(steps: steps)
          else
            _VerticalTimeline(steps: steps),
          if (showActions) ...[
            const SizedBox(height: 20),
            ..._actionButtons(context, journey),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  List<Widget> _actionButtons(BuildContext context, StudentJourney journey) {
    final l10n = context.l10n;
    final current = journey.currentMilestone;
    switch (current) {
      case JourneyMilestone.attended:
        return [
          Text(
            l10n.journeyAttendDesc,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
            ),
          ),
        ];
      case JourneyMilestone.certificate:
        return [
          Text(
            l10n.attendCongrats,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: l10n.certificateTitle,
            icon: Icons.workspace_premium_outlined,
            onPressed: () => context.go('/certificate'),
          ),
        ];
      case JourneyMilestone.review:
        return [
          Text(
            l10n.journeyReviewCurrentDesc,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoft,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          GradientButton(
            label: '⭐ ${l10n.shareExperience}',
            variant: GradientButtonVariant.accent,
            onPressed: () => context.go(
              '/reviews?reg=${Uri.encodeComponent(registration.registrationId)}&mobile=${Uri.encodeComponent(registration.mobile)}',
            ),
          ),
        ];
      case JourneyMilestone.completed:
        return [
          GradientButton(
            label: l10n.upcomingSessionsCta,
            icon: Icons.event_available_outlined,
            onPressed: () => context.go('/session'),
          ),
        ];
      case JourneyMilestone.registered:
        return const [];
    }
  }

  String _title(AppLocalizations l10n, JourneyMilestone m) {
    return switch (m) {
      JourneyMilestone.registered => l10n.journeyRegisteredTitle,
      JourneyMilestone.attended => l10n.journeyAttendTitle,
      JourneyMilestone.certificate => l10n.journeyCertTitle,
      JourneyMilestone.review => l10n.journeyReviewTitle,
      JourneyMilestone.completed => l10n.journeyCompleteTitle,
    };
  }

  String _desc(
    AppLocalizations l10n,
    JourneyMilestone m,
    StudentJourney journey,
  ) {
    return switch (m) {
      JourneyMilestone.registered => l10n.journeyRegisteredDesc,
      JourneyMilestone.attended => journey.attendanceConfirmed
          ? l10n.journeyAttendDoneDesc
          : l10n.journeyAttendDesc,
      JourneyMilestone.certificate =>
        journey.stateFor(m) == JourneyStepVisual.current
            ? l10n.journeyCertCurrentDesc
            : l10n.journeyCertDesc,
      JourneyMilestone.review =>
        journey.stateFor(m) == JourneyStepVisual.current
            ? l10n.journeyReviewCurrentDesc
            : l10n.journeyReviewDesc,
      JourneyMilestone.completed => l10n.journeyCompleteDesc,
    };
  }

  String _emoji(JourneyMilestone m) {
    return switch (m) {
      JourneyMilestone.registered => '🚀',
      JourneyMilestone.attended => '🎓',
      JourneyMilestone.certificate => '📄',
      JourneyMilestone.review => '⭐',
      JourneyMilestone.completed => '🎉',
    };
  }
}

class _StepData {
  const _StepData({
    required this.milestone,
    required this.visual,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final JourneyMilestone milestone;
  final JourneyStepVisual visual;
  final String title;
  final String description;
  final String emoji;
}

class _HorizontalTimeline extends StatelessWidget {
  const _HorizontalTimeline({required this.steps});
  final List<_StepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              Expanded(child: _Node(step: steps[i])),
              if (i < steps.length - 1)
                Expanded(
                  child: _Connector(
                    completed: steps[i].visual == JourneyStepVisual.completed,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final step in steps)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _color(step.visual),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _VerticalTimeline extends StatelessWidget {
  const _VerticalTimeline({required this.steps});
  final List<_StepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _Node(step: steps[i]),
                  if (i < steps.length - 1)
                    Container(
                      width: 3,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: steps[i].visual == JourneyStepVisual.completed
                            ? AppColors.success
                            : AppColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${steps[i].emoji} ${steps[i].title}',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _color(steps[i].visual),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i].description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.step});
  final _StepData step;

  @override
  Widget build(BuildContext context) {
    final visual = step.visual;
    final color = _color(visual);
    final child = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual == JourneyStepVisual.locked
            ? AppColors.card
            : color.withValues(alpha: 0.18),
        border: Border.all(
          color: color,
          width: visual == JourneyStepVisual.current ? 2.5 : 1.5,
        ),
        boxShadow: visual == JourneyStepVisual.current
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: visual == JourneyStepVisual.completed
          ? Icon(Icons.check_rounded, color: color, size: 22)
          : visual == JourneyStepVisual.locked
              ? Icon(Icons.lock_outline_rounded, color: color, size: 18)
              : Text(step.emoji, style: const TextStyle(fontSize: 18)),
    );

    return child
        .animate(target: visual == JourneyStepVisual.current ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.completed});
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: completed
            ? const LinearGradient(
                colors: [AppColors.success, AppColors.secondary],
              )
            : null,
        color: completed ? null : AppColors.border,
      ),
    );
  }
}

Color _color(JourneyStepVisual visual) {
  return switch (visual) {
    JourneyStepVisual.completed => AppColors.success,
    JourneyStepVisual.current => AppColors.accent,
    JourneyStepVisual.locked => AppColors.textMuted,
  };
}
