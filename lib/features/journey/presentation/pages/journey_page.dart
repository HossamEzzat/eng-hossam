import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/data/models/registration.dart';
import 'package:lumina/data/repositories/providers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/student_journey_progress.dart';
import 'package:lumina/theme/app_colors.dart';

/// Return-visit hub: look up registration and continue the journey.
class JourneyPage extends ConsumerStatefulWidget {
  const JourneyPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends ConsumerState<JourneyPage> {
  late final TextEditingController _query;
  bool _loading = false;
  String? _error;
  String? _registrationId;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup());
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final l10n = context.l10n;
    final q = _query.text.trim();
    if (q.isEmpty) {
      setState(() => _error = l10n.journeyLookupSubtitle);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _registrationId = null;
    });
    final reg =
        await ref.read(sessionRepositoryProvider).findCertificate(q);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (reg == null) {
        _error = l10n.certNotFound;
      } else {
        _registrationId = reg.id;
      }
    });
  }

  Registration? _live() {
    final id = _registrationId;
    if (id == null) return null;
    return ref
        .read(sessionStoreProvider)
        .registrations
        .where((r) => r.id == id)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.watch(sessionStoreProvider);
    final reg = _live();

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
                        l10n.journeyLookupTitle,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.journeyLookupSubtitle,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _query,
                        decoration: InputDecoration(
                          labelText: l10n.fieldMobile,
                          hintText: l10n.certificateQueryHint,
                          prefixIcon: const Icon(Icons.route_outlined),
                        ),
                        onSubmitted: (_) => _lookup(),
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        label: l10n.trackJourney,
                        expand: true,
                        isLoading: _loading,
                        icon: Icons.search_rounded,
                        onPressed: _lookup,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(),
                if (reg != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    reg.fullName,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${reg.registrationId} · ${reg.sessionLabel}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StudentJourneyProgress(registration: reg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
