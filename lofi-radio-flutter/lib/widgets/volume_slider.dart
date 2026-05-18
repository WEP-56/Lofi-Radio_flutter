import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 音量滑块 — 拟真玻璃质感
///
/// 外壳：磨砂玻璃容器，带内发光和微妙边框
/// 滑块：金属质感拖拽手柄
/// 轨道：半透明凹槽感
class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;
  final VoidCallback? onMuteToggle;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onChanged,
    this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // 多层渐变模拟玻璃深度
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
            boxShadow: [
              // 内发光（顶部）
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
              // 外阴影
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 音量图标 — 金属质感
              GestureDetector(
                onTap: onMuteToggle,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    volume == 0
                        ? Icons.volume_off_rounded
                        : volume < 0.5
                            ? Icons.volume_down_rounded
                            : Icons.volume_up_rounded,
                    size: 16,
                    color: AppColors.accent.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 滑块
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.06),
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withValues(alpha: 0.08),
                    trackHeight: 3,
                    thumbShape: const _MetalThumbShape(radius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                    trackShape: const _GlassTrackShape(),
                  ),
                  child: Slider(
                    value: volume,
                    onChanged: onChanged,
                    min: 0,
                    max: 1,
                  ),
                ),
              ),
              // 音量百分比
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${(volume * 100).round()}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
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

/// 金属质感滑块手柄
class _MetalThumbShape extends SliderComponentShape {
  final double radius;
  const _MetalThumbShape({required this.radius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(radius * 2, radius * 2);

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

    // 外圈光晕
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius + 2, glowPaint);

    // 主体 — 金属渐变
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          AppColors.accent,
          AppColors.accent.withValues(alpha: 0.7),
          const Color(0xFFD4A574),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bodyPaint);

    // 高光
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(
      center + const Offset(-1.5, -1.5),
      radius * 0.4,
      highlightPaint,
    );

    // 边框
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, borderPaint);
  }
}

/// 玻璃凹槽轨道
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
    final trackHeight = sliderTheme.trackHeight ?? 3;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackLeft = offset.dx + 8;
    final trackWidth = parentBox.size.width - 16;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
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
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

    // 凹槽背景
    final bgPaint = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawRRect(rRect, bgPaint);

    // 内阴影模拟凹陷
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 1);
    canvas.drawRRect(rRect, shadowPaint);

    // 已播放部分
    final activeRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      thumbCenter.dx,
      rect.bottom,
    );
    final activeRRect =
        RRect.fromRectAndRadius(activeRect, const Radius.circular(2));
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? AppColors.accent;
    canvas.drawRRect(activeRRect, activePaint);
  }
}
