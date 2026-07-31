import 'package:flutter/material.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/theme/app_colors.dart';

enum GradientButtonVariant { primary, secondary, ghost, accent }

/// Primary CTA with gradient fill, hover scale, and loading state.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GradientButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.padding,
    this.borderRadius = 14,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GradientButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool expand;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scale = !_enabled
        ? 1.0
        : _pressed
            ? 0.97
            : _hovered
                ? 1.03
                : 1.0;

    final child = AnimatedScale(
      scale: scale,
      duration: AppConstants.animFast,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _enabled || widget.isLoading ? 1 : 0.55,
        duration: AppConstants.animFast,
        child: _buildSurface(context),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _enabled ? widget.onPressed : null,
        child: widget.expand
            ? SizedBox(width: double.infinity, child: child)
            : child,
      ),
    );
  }

  Widget _buildSurface(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final content = _buildContent(context);

    switch (widget.variant) {
      case GradientButtonVariant.primary:
        return Container(
          width: widget.expand ? double.infinity : widget.width,
          height: widget.height,
          padding: widget.padding ?? _defaultPadding(context),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _hovered ? 0.45 : 0.28,
                ),
                blurRadius: _hovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        );
      case GradientButtonVariant.accent:
        return Container(
          width: widget.expand ? double.infinity : widget.width,
          height: widget.height,
          padding: widget.padding ?? _defaultPadding(context),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(
                  alpha: _hovered ? 0.4 : 0.25,
                ),
                blurRadius: _hovered ? 22 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        );
      case GradientButtonVariant.secondary:
        return Container(
          width: widget.expand ? double.infinity : widget.width,
          height: widget.height,
          padding: widget.padding ?? _defaultPadding(context),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurface,
            borderRadius: radius,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDark ? 0.25 : 0.05,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        );
      case GradientButtonVariant.ghost:
        return Container(
          width: widget.expand ? double.infinity : widget.width,
          height: widget.height,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: content,
        );
    }
  }

  EdgeInsets _defaultPadding(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return EdgeInsets.symmetric(
      horizontal: narrow ? 16 : 28,
      vertical: 14,
    );
  }

  Widget _buildContent(BuildContext context) {
    final isFilled = widget.variant == GradientButtonVariant.primary ||
        widget.variant == GradientButtonVariant.accent;
    final color = isFilled
        ? Colors.white
        : widget.variant == GradientButtonVariant.ghost
            ? AppColors.primary
            : context.colorScheme.onSurface;

    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    final label = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      textAlign: TextAlign.center,
      style: context.textTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );

    if (widget.icon == null) return label;

    // Full-width buttons must use Expanded so long Arabic labels never overflow.
    if (widget.expand) {
      return Row(
        children: [
          Icon(widget.icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: label),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 18, color: color),
        const SizedBox(width: 8),
        Flexible(child: label),
      ],
    );
  }
}
