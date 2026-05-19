import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class VolumeSlider extends StatelessWidget {
  final double volume;
  final bool compact;
  final ValueChanged<double> onChanged;
  final VoidCallback? onMuteToggle;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.compact,
    required this.onChanged,
    this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onMuteToggle,
                child: Icon(
                  volume == 0
                      ? Icons.volume_off_rounded
                      : volume < 0.45
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded,
                  color: AppColors.textPrimary.withValues(alpha: 0.92),
                  size: compact ? 18 : 20,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    overlayColor: AppColors.signalPeak.withValues(alpha: 0.08),
                    trackHeight: compact ? 8 : 10,
                    thumbShape: _GlassThumbShape(compact: compact),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    trackShape: const _GlassTrackShape(),
                  ),
                  child: Slider(
                    min: 0,
                    max: 1,
                    value: volume,
                    onChanged: onChanged,
                  ),
                ),
              ),
              SizedBox(width: compact ? 6 : 8),
              SizedBox(
                width: compact ? 34 : 38,
                child: Text(
                  '${(volume * 100).round()}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTrackShape extends SliderTrackShape {
  const _GlassTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 8;
    return Rect.fromLTWH(
      offset.dx,
      offset.dy + (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
    );
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(rect.height));

    final shellPaint = Paint()..color = Colors.black.withValues(alpha: 0.22);
    canvas.drawRRect(rRect, shellPaint);

    final activeRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      thumbCenter.dx,
      rect.bottom,
    );
    if (activeRect.width > 0) {
      final activePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.92),
            AppColors.signalPeak.withValues(alpha: 0.95),
          ],
        ).createShader(activeRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect, Radius.circular(activeRect.height)),
        activePaint,
      );
    }
  }
}

class _GlassThumbShape extends SliderComponentShape {
  final bool compact;

  const _GlassThumbShape({required this.compact});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(compact ? 18 : 20, compact ? 18 : 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = compact ? 9.0 : 10.0;

    final glow = Paint()
      ..color = AppColors.signalPeak.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 2, glow);

    final body = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, body);
  }
}
