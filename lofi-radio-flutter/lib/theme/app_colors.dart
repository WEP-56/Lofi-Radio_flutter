import 'package:flutter/material.dart';

/// 色彩系统 — 复刻原版深夜学霸主题
///
/// 主色调：深靛蓝
/// 点缀色：暖黄铜/蜜桃
/// 文字色：米白色层级
class AppColors {
  AppColors._();

  // ─── 背景层级 ───
  static const Color backgroundDeep = Color(0xFF0F1729);
  static const Color background = Color(0xFF1E2A3B);
  static const Color surface = Color(0xFF253347);
  static const Color surfaceLight = Color(0xFF2D3D54);

  // ─── 点缀色（暖黄铜/蜜桃） ───
  static const Color accent = Color(0xFFFFDAB9); // rgba(255, 218, 185)
  static const Color accentDim = Color(0xB3FFDAB9); // 70% opacity
  static const Color accentSubtle = Color(0x33FFDAB9); // 20% opacity

  // ─── 文字层级 ───
  static const Color textPrimary = Color(0xF2F8FAFC); // 95%
  static const Color textSecondary = Color(0xB3F1F5F9); // 70%
  static const Color textTertiary = Color(0x80F1F5F9); // 50%

  // ─── 功能色 ───
  static const Color border = Color(0x2694A3B8); // 15% slate
  static const Color divider = Color(0x1AFFFFFF); // 10% white
  static const Color error = Color(0xFFF44336);

  // ─── 标签色 ───
  static const Color tagDefault = Color(0x1AFFFFFF);
  static const Color tagCustomBg = Color(0x33FFDAB9);
  static const Color tagCustomText = Color(0xF2FFDAB9);
  static const Color tagSceneBg = Color(0x336495ED);
  static const Color tagSceneText = Color(0xF2ADD8E6);

  // ─── 黑胶唱片 ───
  static const Color vinylDark = Color(0xFF0F0F0F);
  static const Color vinylLight = Color(0xFF1E1E1E);
  static const Color vinylLabel = Color(0xFF6B5B47);
  static const Color vinylLabelLight = Color(0xFF8B7355);
  static const Color vinylGlow = Color(0x33FFDAB9); // 播放时的光晕
}
