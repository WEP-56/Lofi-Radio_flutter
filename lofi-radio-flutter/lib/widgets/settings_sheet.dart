import 'package:flutter/material.dart';
import '../services/sleep_timer_service.dart';
import '../theme/app_colors.dart';
import 'about_sheet.dart';

/// 设置弹层
///
/// 功能：缓存清理、电台源添加、恢复默认、睡眠定时
class SettingsSheet extends StatefulWidget {
  final VoidCallback? onClearCache;
  final VoidCallback? onAddStation;
  final VoidCallback? onResetStations;

  const SettingsSheet({
    super.key,
    this.onClearCache,
    this.onAddStation,
    this.onResetStations,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onClearCache,
    VoidCallback? onAddStation,
    VoidCallback? onResetStations,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsSheet(
        onClearCache: onClearCache,
        onAddStation: onAddStation,
        onResetStations: onResetStations,
      ),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final _sleepTimer = SleepTimerService.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          _buildItem(
            icon: Icons.add_rounded,
            label: '添加电台源',
            onTap: () {
              Navigator.pop(context);
              widget.onAddStation?.call();
            },
          ),
          _buildItem(
            icon: Icons.cleaning_services_rounded,
            label: '清除缓存',
            subtitle: '清除音频缓存数据',
            onTap: () {
              Navigator.pop(context);
              widget.onClearCache?.call();
            },
          ),
          _buildItem(
            icon: Icons.restart_alt_rounded,
            label: '恢复默认电台',
            subtitle: '重置为预设电台列表',
            onTap: () {
              Navigator.pop(context);
              widget.onResetStations?.call();
            },
          ),
          _buildSleepTimer(),
          _buildItem(
            icon: Icons.info_outline_rounded,
            label: '关于',
            subtitle: 'GitHub · 链接 · 版本',
            onTap: () {
              Navigator.pop(context);
              AboutSheet.show(context);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              'Lofi Radio v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 睡眠定时 — 内联选择器
  Widget _buildSleepTimer() {
    return ValueListenableBuilder<int>(
      valueListenable: _sleepTimer.remainingMinutes,
      builder: (context, remaining, _) {
        return Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '睡眠定时',
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.textPrimary),
                            ),
                            if (remaining > 0)
                              Text(
                                '$remaining 分钟后暂停',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accent.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (remaining > 0)
                        GestureDetector(
                          onTap: () {
                            _sleepTimer.cancel();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.error),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // 时间选择按钮组
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const SizedBox(width: 34), // 对齐图标
                  ...[15, 30, 45, 60, 90].map((min) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _timerChip(min, remaining),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _timerChip(int minutes, int currentRemaining) {
    final isActive = currentRemaining == minutes;
    return GestureDetector(
      onTap: () {
        _sleepTimer.set(minutes);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          '${minutes}m',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.accent : AppColors.textTertiary,
          ),
        ),
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

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.settings_rounded, size: 20, color: AppColors.accent),
          SizedBox(width: 10),
          Text(
            '设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
