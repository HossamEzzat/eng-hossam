import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumina/theme/app_colors.dart';

/// Lightweight confetti + glow celebration for journey completion.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.35, end: 0.85, duration: 1800.ms),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      Colors.white,
    ];
    for (var i = 0; i < 48; i++) {
      final x = rnd.nextDouble() * size.width;
      final startY = -20.0 - rnd.nextDouble() * 80;
      final y = startY + progress * (size.height + 120) * (0.6 + rnd.nextDouble() * 0.5);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - progress * 0.55);
      final w = 4.0 + rnd.nextDouble() * 5;
      final h = 8.0 + rnd.nextDouble() * 6;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rnd.nextDouble() * math.pi + progress * 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
