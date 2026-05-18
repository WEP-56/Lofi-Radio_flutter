import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 毛玻璃容器 — 复刻原版 backdrop-filter 效果
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.blur = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: AppColors.surface.withValues(alpha: 0.6),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
