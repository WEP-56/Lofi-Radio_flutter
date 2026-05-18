import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 黑胶唱片组件 — 核心视觉锚点
///
/// 播放时旋转，点击切换播放/暂停
/// 标签区域显示电台名称，中心点与文字分离
class VinylRecord extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;
  final String stationName;

  const VinylRecord({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 260,
    this.stationName = 'LOFI',
  });

  @override
  State<VinylRecord> createState() => _VinylRecordState();
}

class _VinylRecordState extends State<VinylRecord>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(VinylRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: _buildRecord(),
      ),
    );
  }

  Widget _buildRecord() {
    final size = widget.size;
    final labelSize = size * 0.55;
    final centerSize = size * 0.10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -0.5),
          end: Alignment(0.7, 0.7),
          colors: [AppColors.vinylLight, AppColors.vinylDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          if (widget.isPlaying)
            BoxShadow(
              color: AppColors.vinylGlow,
              blurRadius: 40,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 唱片纹路
          _buildGrooves(size),
          // 标签区域（带电台名）
          _buildLabel(labelSize),
          // 中心孔（纯装饰，不遮挡文字）
          _buildCenter(centerSize),
          // 播放/暂停指示（不旋转，需要反向旋转抵消）
          _buildPlayIndicator(),
        ],
      ),
    );
  }

  Widget _buildGrooves(double size) {
    return CustomPaint(
      size: Size(size - 12, size - 12),
      painter: _GroovesPainter(),
    );
  }

  Widget _buildLabel(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -0.5),
          end: Alignment(0.7, 0.7),
          colors: [AppColors.vinylLabelLight, AppColors.vinylLabel, Color(0xFF4A3C2B)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 标签纹理装饰线
          CustomPaint(
            size: Size(size, size),
            painter: _LabelTexturePainter(),
          ),
          // 电台名称 — 位于标签上半部分，避开中心孔
          Positioned(
            top: size * 0.18,
            child: Text(
              widget.stationName.length > 10
                  ? widget.stationName.substring(0, 10)
                  : widget.stationName,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                fontSize: size * 0.09,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // 底部小字装饰
          Positioned(
            bottom: size * 0.2,
            child: Text(
              '◆ RADIO ◆',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.4),
                fontSize: size * 0.055,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF1A1A1A)],
          stops: [0.3, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      // 中心小金属点
      child: Center(
        child: Container(
          width: size * 0.3,
          height: size * 0.3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayIndicator() {
    // 反向旋转抵消唱片旋转，让图标始终正向
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: -_controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: AnimatedOpacity(
        opacity: widget.isPlaying ? 0.0 : 0.8,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppColors.accent,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// 唱片纹路绘制
class _GroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final minRadius = maxRadius * 0.42;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double r = minRadius; r < maxRadius; r += 2.5) {
      final alpha = 0.03 + (r % 5 == 0 ? 0.04 : 0) + (r % 10 == 0 ? 0.02 : 0);
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 标签区域纹理 — 模拟真实唱片标签的同心圆装饰
class _LabelTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // 外圈装饰线
    paint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius * 0.92, paint);
    canvas.drawCircle(center, radius * 0.88, paint);

    // 内圈装饰线
    paint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(center, radius * 0.35, paint);
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
