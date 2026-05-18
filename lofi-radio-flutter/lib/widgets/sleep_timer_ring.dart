import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 睡眠倒计时环形组件 — 拟真质感
///
/// 设计：
/// - 外圈：渐变弧形进度条，带发光尾迹
/// - 内部：剩余分钟数，大号数字
/// - 底部：小字 "sleep"
/// - 整体：玻璃容器内嵌
class SleepTimerRing extends StatefulWidget {
  final int remainingMinutes;
  final int totalMinutes;
  final double size;
  final VoidCallback? onTap;

  const SleepTimerRing({
    super.key,
    required this.remainingMinutes,
    required this.totalMinutes,
    this.size = 72,
    this.onTap,
  });

  @override
  State<SleepTimerRing> createState() => _SleepTimerRingState();
}

class _SleepTimerRingState extends State<SleepTimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.remainingMinutes <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseValue = _pulseController.value;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundDeep.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.08 + pulseValue * 0.06),
                  blurRadius: 12 + pulseValue * 6,
                  spreadRadius: pulseValue * 1.5,
                ),
              ],
            ),
            child: child,
          );
        },
        child: CustomPaint(
          painter: _TimerRingPainter(
            progress: widget.totalMinutes > 0
                ? widget.remainingMinutes / widget.totalMinutes
                : 0,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.remainingMinutes}',
                  style: TextStyle(
                    fontSize: widget.size * 0.28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    height: 1.1,
                  ),
                ),
                Text(
                  'min',
                  style: TextStyle(
                    fontSize: widget.size * 0.12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 环形进度条绘制 — 渐变弧 + 发光端点
class _TimerRingPainter extends CustomPainter {
  final double progress;

  _TimerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 3.0;

    // 背景轨道
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(center, radius, bgPaint);

    // 内凹阴影（模拟凹槽）
    final innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);
    canvas.drawCircle(center, radius, innerShadow);

    if (progress <= 0) return;

    // 进度弧 — 渐变
    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2; // 从顶部开始

    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          AppColors.accent.withValues(alpha: 0.3),
          AppColors.accent.withValues(alpha: 0.7),
          AppColors.accent,
        ],
        stops: const [0.0, 0.7, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // 端点发光
    final endAngle = startAngle + sweepAngle;
    final endPoint = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(endPoint, 2.5, glowPaint);

    final dotPaint = Paint()..color = AppColors.accent;
    canvas.drawCircle(endPoint, 1.8, dotPaint);
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
