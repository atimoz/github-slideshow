import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
//  CircularTimerPainter
//  Custom painter for the animated ring.
// ─────────────────────────────────────────────
class CircularTimerPainter extends CustomPainter {
  const CircularTimerPainter({
    required this.progress,
    required this.strokeWidth,
    required this.glowOpacity,
  });

  final double progress;
  final double strokeWidth;
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // top

    // ── Track ring (background) ──────────────
    final trackPaint = Paint()
      ..color = AppColors.stroke
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // ── Glow blur pass ───────────────────────
    final glowPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi * progress,
        colors: [
          AppColors.accent.withOpacity(0),
          AppColors.accentSoft.withOpacity(glowOpacity),
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth + 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      glowPaint,
    );

    // ── Progress arc (foreground) ─────────────
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi * progress,
        colors: AppColors.timerGradient,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // ── Dot at progress tip ───────────────────
    final tipAngle = startAngle + 2 * math.pi * progress;
    final tipOffset = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tipOffset,
      strokeWidth / 2,
      Paint()..color = AppColors.accentSoft,
    );
  }

  @override
  bool shouldRepaint(CircularTimerPainter old) =>
      old.progress != progress || old.glowOpacity != glowOpacity;
}

// ─────────────────────────────────────────────
//  CircularTimer widget
// ─────────────────────────────────────────────
class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.progress,
    required this.child,
    this.size = 280,
    this.strokeWidth = 6,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: CircularTimerPainter(
                progress: value,
                strokeWidth: strokeWidth,
                glowOpacity: value > 0 ? 0.6 : 0,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
