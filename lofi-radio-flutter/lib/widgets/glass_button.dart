import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 玻璃质感按钮 — 拟真磨砂玻璃效果
///
/// 多层渐变 + 内发光 + 边框高光 + 按压反馈
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;
  final bool isCircle;
  final bool isActive;

  const GlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 48,
    this.isCircle = true,
    this.isActive = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.isCircle
        ? BorderRadius.circular(widget.size)
        : BorderRadius.circular(14);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                // 多层玻璃渐变
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isActive
                      ? [
                          AppColors.accent.withValues(alpha: 0.2),
                          AppColors.accent.withValues(alpha: 0.08),
                          AppColors.accent.withValues(alpha: 0.12),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.04),
                          Colors.white.withValues(alpha: 0.07),
                        ],
                ),
                border: Border.all(
                  color: widget.isActive
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 0.8,
                ),
                boxShadow: [
                  // 外阴影 — 悬浮感
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _pressed ? 0.1 : 0.25),
                    blurRadius: _pressed ? 4 : 10,
                    offset: Offset(0, _pressed ? 1 : 4),
                  ),
                  // 内发光（顶部边缘）
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.06),
                    blurRadius: 1,
                    offset: const Offset(0, 0.5),
                  ),
                ],
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// 大号播放控制按钮 — 更强的玻璃质感 + 光晕
class GlassPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;

  const GlassPlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 64,
  });

  @override
  State<GlassPlayButton> createState() => _GlassPlayButtonState();
}

class _GlassPlayButtonState extends State<GlassPlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 多层渐变 — 模拟厚玻璃
            gradient: RadialGradient(
              center: const Alignment(-0.2, -0.3),
              colors: [
                AppColors.accent.withValues(alpha: 0.25),
                AppColors.accent.withValues(alpha: 0.1),
                AppColors.accent.withValues(alpha: 0.15),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              // 外光晕
              BoxShadow(
                color: AppColors.accent.withValues(alpha: widget.isPlaying ? 0.2 : 0.1),
                blurRadius: widget.isPlaying ? 20 : 12,
                spreadRadius: widget.isPlaying ? 2 : 0,
              ),
              // 底部阴影
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(widget.isPlaying),
                color: AppColors.accent,
                size: widget.size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
