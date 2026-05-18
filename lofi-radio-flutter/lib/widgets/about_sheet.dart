import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 关于页面 — 底部弹出
///
/// 内容：黑胶图标 + 标题 + 版本号 + 链接列表
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AboutSheet(),
    );
  }

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
          const SizedBox(height: 20),
          // 黑胶图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment(-0.5, -0.5),
                end: Alignment(0.7, 0.7),
                colors: [AppColors.vinylLight, AppColors.vinylDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.vinylGlow,
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'LOFI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lofi Radio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          _buildLink(
            context,
            icon: Icons.code_rounded,
            label: 'GitHub 主页',
            subtitle: 'Lofi-Radio_flutter',
            url: 'https://github.com/WEP-56/Lofi-Radio_flutter',
          ),
          _buildLink(
            context,
            icon: Icons.desktop_windows_rounded,
            label: '需要 Windows/Mac 版？',
            subtitle: '前往 lofi radio 获得 PC 电台体验',
            url: 'https://github.com/labilio/lofi-radio',
          ),
          _buildLink(
            context,
            icon: Icons.radio_rounded,
            label: '寻找更多电台',
            subtitle: 'recommended-radio-streams',
            url: 'https://github.com/deroverda/recommended-radio-streams',
          ),
          _buildLink(
            context,
            icon: Icons.search_rounded,
            label: '电台搜索 API',
            subtitle: 'radio-browser-api',
            url: 'https://github.com/ivandotv/radio-browser-api',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
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

  Widget _buildLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required String url,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openUrl(url),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accent.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUrl(String url) {
    // 使用 platform channel 打开浏览器
    const platform = MethodChannel('com.lofiradio/browser');
    platform.invokeMethod('open', url).catchError((_) {
      // fallback: 什么都不做
    });
  }
}
