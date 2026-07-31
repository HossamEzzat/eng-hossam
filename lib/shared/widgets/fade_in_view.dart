import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fades and slides in once when scrolled into view.
class FadeInView extends StatefulWidget {
  const FadeInView({
    super.key,
    required this.child,
    this.duration = AppConstants.animNormal,
    this.delay = Duration.zero,
    this.offset = 24,
    this.slideFrom = FadeInDirection.bottom,
    this.visibilityFraction = 0.15,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;
  final FadeInDirection slideFrom;
  final double visibilityFraction;
  final Curve curve;

  @override
  State<FadeInView> createState() => _FadeInViewState();
}

enum FadeInDirection { bottom, top, left, right }

class _FadeInViewState extends State<FadeInView> {
  bool _visible = false;
  late final String _key;

  @override
  void initState() {
    super.initState();
    _key = 'fade-in-${identityHashCode(this)}';
  }

  void _onVisibility(VisibilityInfo info) {
    if (_visible) return;
    if (info.visibleFraction >= widget.visibilityFraction) {
      setState(() => _visible = true);
    }
  }

  Offset get _begin {
    switch (widget.slideFrom) {
      case FadeInDirection.bottom:
        return Offset(0, widget.offset);
      case FadeInDirection.top:
        return Offset(0, -widget.offset);
      case FadeInDirection.left:
        return Offset(-widget.offset, 0);
      case FadeInDirection.right:
        return Offset(widget.offset, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_key),
      onVisibilityChanged: _onVisibility,
      child: widget.child
          .animate(target: _visible ? 1 : 0)
          .fadeIn(
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
          )
          .move(
            begin: _begin,
            end: Offset.zero,
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
          ),
    );
  }
}
