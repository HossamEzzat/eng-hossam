import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumina/theme/app_colors.dart';

class FloatingBlobs extends StatefulWidget {
  const FloatingBlobs({super.key});

  @override
  State<FloatingBlobs> createState() => _FloatingBlobsState();
}

class _FloatingBlobsState extends State<FloatingBlobs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Stack(
          children: [
            _blob(
              alignment: Alignment(-0.85 + t * 0.1, -0.7),
              size: 280,
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            _blob(
              alignment: Alignment(0.9 - t * 0.08, -0.2),
              size: 220,
              color: AppColors.secondary.withValues(alpha: 0.16),
            ),
            _blob(
              alignment: Alignment(-0.2, 0.75 - t * 0.1),
              size: 260,
              color: AppColors.accent.withValues(alpha: 0.10),
            ),
          ],
        );
      },
    );
  }

  Widget _blob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        ),
      ),
    );
  }
}

class ParticleField extends StatelessWidget {
  const ParticleField({super.key, this.count = 24});
  final int count;

  @override
  Widget build(BuildContext context) {
    final rnd = math.Random(7);
    return IgnorePointer(
      child: CustomPaint(
        painter: _DotsPainter(count: count, seed: rnd),
        size: Size.infinite,
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.count, required this.seed});
  final int count;
  final math.Random seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.12);
    for (var i = 0; i < count; i++) {
      final x = seed.nextDouble() * size.width;
      final y = seed.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + seed.nextDouble() * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
