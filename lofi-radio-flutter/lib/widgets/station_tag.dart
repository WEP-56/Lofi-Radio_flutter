import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TagType { style, preset, custom, scene }

/// 电台标签组件 — 复刻原版标签设计
class StationTag extends StatelessWidget {
  final String text;
  final TagType type;

  const StationTag({super.key, required this.text, this.type = TagType.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: type != TagType.style
            ? Border.all(color: _borderColor, width: 1)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case TagType.style:
        return AppColors.tagDefault;
      case TagType.preset:
        return AppColors.tagPresetBg;
      case TagType.custom:
        return AppColors.tagCustomBg;
      case TagType.scene:
        return AppColors.tagSceneBg;
    }
  }

  Color get _textColor {
    switch (type) {
      case TagType.style:
        return AppColors.textSecondary;
      case TagType.preset:
        return AppColors.tagPresetText;
      case TagType.custom:
        return AppColors.tagCustomText;
      case TagType.scene:
        return AppColors.tagSceneText;
    }
  }

  Color get _borderColor {
    switch (type) {
      case TagType.style:
        return Colors.transparent;
      case TagType.preset:
        return const Color(0xFF3FA2FF).withValues(alpha: 0.24);
      case TagType.custom:
        return AppColors.accent.withValues(alpha: 0.3);
      case TagType.scene:
        return const Color(0xFF6495ED).withValues(alpha: 0.3);
    }
  }
}
