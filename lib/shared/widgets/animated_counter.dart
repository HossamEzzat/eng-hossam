import 'package:flutter/material.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Counts up when scrolled into view. Shows [value] + [label] + optional [suffix].
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.label,
    this.suffix,
    this.prefix,
    this.duration = AppConstants.animSlow,
    this.valueStyle,
    this.labelStyle,
    this.visibilityFraction = 0.35,
    this.curve = Curves.easeOutCubic,
  });

  final int value;
  final String label;
  final String? suffix;
  final String? prefix;
  final Duration duration;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final double visibilityFraction;
  final Curve curve;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  bool _started = false;
  late final String _detectorKey;

  @override
  void initState() {
    super.initState();
    _detectorKey = 'animated-counter-${identityHashCode(this)}';
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.duration != widget.duration) {
      _animation = Tween<double>(begin: 0, end: widget.value.toDouble())
          .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.duration = widget.duration;
      if (_started) {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibility(VisibilityInfo info) {
    if (_started) return;
    if (info.visibleFraction >= widget.visibilityFraction) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_detectorKey),
      onVisibilityChanged: _onVisibility,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final current = _animation.value.round();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    if (widget.prefix != null)
                      TextSpan(text: widget.prefix),
                    TextSpan(text: '$current'),
                    if (widget.suffix != null)
                      TextSpan(
                        text: widget.suffix,
                        style: widget.valueStyle?.copyWith(
                              color: AppColors.primary,
                            ) ??
                            context.textTheme.displaySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                  ],
                  style: widget.valueStyle ??
                      context.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: context.colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: widget.labelStyle ??
                    context.textTheme.bodyMedium?.copyWith(
                      color: context.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
