import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/core/utils/url_helpers.dart';
import 'package:lumina/shared/layouts/site_shell.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/promo_qr_section.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _sending = false);
    _name.clear();
    _message.clear();
    context.showSnack(context.l10n.messageSent);
  }

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);
    final l10n = context.l10n;

    return SiteShell(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: 48,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInView(
                  child: SectionHeader(
                    eyebrow: l10n.navContact,
                    headline: l10n.contactTitle,
                    subtitle: l10n.contactSubtitle,
                    centered: true,
                  ),
                ),
                const SizedBox(height: 40),
                const _ContactChannels(),
                const SizedBox(height: 24),
                const PromoQrSection(compact: true),
                const SizedBox(height: 24),
                _MessageForm(
                  formKey: _formKey,
                  name: _name,
                  message: _message,
                  sending: _sending,
                  onSubmit: _submit,
                ),
                const SizedBox(height: 48),
                FadeInView(
                  child: GlassCard(
                    glow: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 36,
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.finalCtaTitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.registerSubtitle,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSoft,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GradientButton(
                          label: l10n.ctaReserveNow,
                          icon: Icons.event_available_rounded,
                          onPressed: () => context.go('/register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactChannels extends StatelessWidget {
  const _ContactChannels();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phoneDisplay = AppConstants.instructorPhone;

    final channels = <_ContactChannelData>[
      _ContactChannelData(
        title: l10n.linkedin,
        subtitle: 'linkedin.com/in/hossam-ezzat-77245b204',
        brand: const Color(0xFF0A66C2),
        glyph: 'in',
        onTap: UrlHelpers.launchLinkedIn,
      ),
      _ContactChannelData(
        title: l10n.facebook,
        subtitle: 'facebook.com/hossam.ezzat.342313',
        brand: const Color(0xFF1877F2),
        icon: Icons.facebook_rounded,
        onTap: UrlHelpers.launchFacebook,
      ),
      _ContactChannelData(
        title: l10n.whatsapp,
        subtitle: phoneDisplay,
        brand: const Color(0xFF25D366),
        icon: Icons.chat_rounded,
        onTap: UrlHelpers.launchWhatsApp,
      ),
      _ContactChannelData(
        title: 'Gmail',
        subtitle: AppConstants.instructorEmail,
        brand: const Color(0xFFEA4335),
        icon: Icons.mail_rounded,
        onTap: UrlHelpers.launchEmail,
      ),
    ];

    return FadeInView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 16.0;
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;
          final cardW = columns == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - gap * (columns - 1)) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < channels.length; i++)
                SizedBox(
                  width: cardW,
                  child: _ContactCard(data: channels[i], index: i),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ContactChannelData {
  const _ContactChannelData({
    required this.title,
    required this.subtitle,
    required this.brand,
    required this.onTap,
    this.glyph,
    this.icon,
  });

  final String title;
  final String subtitle;
  final Color brand;
  final Future<bool> Function() onTap;
  final String? glyph;
  final IconData? icon;
}

class _ContactCard extends StatefulWidget {
  const _ContactCard({required this.data, required this.index});

  final _ContactChannelData data;
  final int index;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brand = widget.data.brand;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1,
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.card,
            border: Border.all(
              color: brand.withValues(alpha: _hovered ? 0.55 : 0.22),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: brand.withValues(alpha: _hovered ? 0.28 : 0.08),
                blurRadius: _hovered ? 28 : 14,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                brand.withValues(alpha: _hovered ? 0.16 : 0.07),
                AppColors.card.withValues(alpha: 0.92),
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.data.onTap(),
              borderRadius: BorderRadius.circular(20),
              splashColor: brand.withValues(alpha: 0.12),
              highlightColor: brand.withValues(alpha: 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: AppConstants.animFast,
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: brand.withValues(alpha: _hovered ? 0.28 : 0.16),
                      border: Border.all(
                        color: brand.withValues(alpha: 0.35),
                      ),
                    ),
                    child: widget.data.glyph != null
                        ? Text(
                            widget.data.glyph!,
                            style: TextStyle(
                              color: brand,
                              fontWeight: FontWeight.w900,
                              fontSize: widget.data.glyph == 'in' ? 20 : 26,
                              height: 1,
                              letterSpacing: widget.data.glyph == 'in' ? -1 : 0,
                            ),
                          )
                        : Icon(widget.data.icon, color: brand, size: 26),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'فتح'
                            : 'Open',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: AppConstants.animFast,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: brand.withValues(alpha: _hovered ? 0.22 : 0.1),
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                          color: brand,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (70 * widget.index).ms, duration: 450.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}

class _MessageForm extends StatelessWidget {
  const _MessageForm({
    required this.formKey,
    required this.name,
    required this.message,
    required this.sending,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController message;
  final bool sending;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FadeInView(
      delay: 80.ms,
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.sendMessage,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  labelText: l10n.contactName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.validateName : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: message,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l10n.contactMessage,
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.contactMessage : null,
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: l10n.sendMessage,
                expand: true,
                isLoading: sending,
                icon: Icons.send_rounded,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
