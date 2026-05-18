import 'package:flutter/material.dart';
import '../models/station.dart';
import '../theme/app_colors.dart';
import 'station_tag.dart';

/// 电台列表底部弹出面板
///
/// 设计：全屏覆盖式面板，深色毛玻璃背景
/// 交互：点击电台切换，当前电台高亮
class StationListSheet extends StatelessWidget {
  final List<Station> stations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const StationListSheet({
    super.key,
    required this.stations,
    required this.currentIndex,
    required this.onSelect,
  });

  /// 便捷方法：以底部弹出方式显示
  static Future<void> show(
    BuildContext context, {
    required List<Station> stations,
    required int currentIndex,
    required ValueChanged<int> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StationListSheet(
        stations: stations,
        currentIndex: currentIndex,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Select Station',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 32), // 平衡布局
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final isActive = index == currentIndex;

        return GestureDetector(
          onTap: () {
            onSelect(index);
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accentSubtle
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    if (station.style1.isNotEmpty)
                      StationTag(text: station.style1),
                    if (station.style2.isNotEmpty)
                      StationTag(text: station.style2),
                    if (station.custom != null)
                      StationTag(text: station.custom!, type: TagType.custom),
                    if (station.scene.isNotEmpty)
                      StationTag(text: station.scene, type: TagType.scene),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
