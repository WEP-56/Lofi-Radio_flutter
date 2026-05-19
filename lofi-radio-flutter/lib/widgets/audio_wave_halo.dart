import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AudioWaveHalo extends StatefulWidget {
  final double size;
  final bool isPlaying;
  final bool isBuffering;
  final double intensity;

  const AudioWaveHalo({
    super.key,
    required this.size,
    required this.isPlaying,
    required this.isBuffering,
    required this.intensity,
  });

  @override
  State<AudioWaveHalo> createState() => _AudioWaveHaloState();
}

class _AudioWaveHaloState extends State<AudioWaveHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isPlaying || widget.isBuffering) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AudioWaveHalo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldAnimate = widget.isPlaying || widget.isBuffering;
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.square(widget.size),
            painter: _WaveHaloPainter(
              phase: _controller.value,
              isPlaying: widget.isPlaying,
              isBuffering: widget.isBuffering,
              intensity: widget.intensity.clamp(0.0, 1.0),
            ),
          );
        },
      ),
    );
  }
}

class _WaveHaloPainter extends CustomPainter {
  final double phase;
  final bool isPlaying;
  final bool isBuffering;
  final double intensity;

  const _WaveHaloPainter({
    required this.phase,
    required this.isPlaying,
    required this.isBuffering,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const bars = 64;
    final ringRadius = size.width / 2 - 13;
    final baseLength = isPlaying ? 6 + intensity * 4 : 3.5;
    final pulseBoost = isBuffering ? 4.5 : 0.0;

    final glowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.1;

    for (var i = 0; i < bars; i++) {
      final t = i / bars;
      final angle = t * math.pi * 2;
      final seed = _hash(i);
      final seed2 = _hash(i + 91);
      final wave =
          math.sin(angle * 8 - phase * math.pi * 2) * 0.5 +
          math.cos(angle * (4.3 + seed * 2.8) + phase * math.pi * 4) * 0.5;
      final length =
          baseLength +
          ((wave + 1) * 0.5) * (isPlaying ? 9.5 : 4) +
          pulseBoost +
          seed2 * 2.5;
      final alpha = isPlaying || isBuffering
          ? 0.12 + ((wave + 1) * 0.5) * 0.32
          : 0.08;
      final color = Color.lerp(
        AppColors.accent,
        AppColors.signalPeak,
        ((wave + 1) * 0.5).clamp(0.0, 1.0),
      )!;

      final start = Offset(
        center.dx + math.cos(angle) * ringRadius,
        center.dy + math.sin(angle) * ringRadius,
      );
      final end = Offset(
        center.dx + math.cos(angle) * (ringRadius + length),
        center.dy + math.sin(angle) * (ringRadius + length),
      );

      glowPaint.color = color.withValues(alpha: alpha * 0.6);
      linePaint.color = color.withValues(alpha: alpha);
      canvas.drawLine(start, end, glowPaint);
      canvas.drawLine(start, end, linePaint);
    }
  }

  double _hash(int index) {
    final value = math.sin(index * 12.9898 + 78.233) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _WaveHaloPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.isBuffering != isBuffering ||
        oldDelegate.intensity != intensity;
  }
}
