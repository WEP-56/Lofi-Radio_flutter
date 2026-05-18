import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/default_stations.dart';
import '../models/station.dart';
import '../services/audio_service.dart';
import '../services/focus_timer_service.dart';
import '../services/overlay_service.dart';
import '../services/sleep_timer_service.dart';
import '../theme/app_colors.dart';
import '../widgets/vinyl_record.dart';
import '../widgets/volume_slider.dart';
import '../widgets/glass_button.dart';
import '../widgets/station_list_sheet.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/sleep_timer_ring.dart';

/// 主页面 — 单页面设计
///
/// 布局：Spotify 音乐详情页风格
/// - 顶部：电台列表 / 悬浮窗 / 设置（玻璃按钮）
/// - 中心：黑胶唱片（主视觉）
/// - 底部：电台名 + 玻璃控件 + 音量 + Focus
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _audio = AudioPlayerService.instance;
  final _focus = FocusTimerService.instance;
  double _previousVolume = 0.3;
  Timer? _overlayPollTimer;
  int _lastActionTs = 0;

  @override
  void initState() {
    super.initState();
    _focus.init();

    // 监听播放状态，联动 Focus 计时器
    _audio.isPlaying.addListener(_onPlayStateChanged);
    if (_audio.isPlaying.value) {
      _focus.start();
    }

    // 监听悬浮窗发来的消息（overlay → main app）
    _setupOverlayListener();

    // 同步状态到悬浮窗
    _audio.isPlaying.addListener(_syncOverlayState);
    _audio.currentStation.addListener(_syncOverlayState);
  }

  void _setupOverlayListener() {
    // 轮询 SharedPreferences 检查 overlay 发来的 action
    _overlayPollTimer = Timer.periodic(const Duration(milliseconds: 300), (_) async {
      if (!OverlayService.instance.isShowing) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // 强制从磁盘重新读取（跨进程）
      final ts = prefs.getInt('overlay_action_ts') ?? 0;

      if (ts > _lastActionTs) {
        _lastActionTs = ts;
        final action = prefs.getString('overlay_action') ?? '';
        _handleOverlayMessage({'action': action});
        // 清除 action
        await prefs.remove('overlay_action');
        await prefs.remove('overlay_action_ts');
      }
    });
  }

  void _onPlayStateChanged() {
    if (_audio.isPlaying.value) {
      _focus.start();
    } else {
      _focus.stop();
    }
  }

  @override
  void dispose() {
    _overlayPollTimer?.cancel();
    _audio.isPlaying.removeListener(_onPlayStateChanged);
    _audio.isPlaying.removeListener(_syncOverlayState);
    _audio.currentStation.removeListener(_syncOverlayState);
    super.dispose();
  }

  void _handleOverlayMessage(dynamic data) {
    if (data is Map) {
      final action = data['action'] as String?;
      switch (action) {
        case 'togglePlay':
          _audio.togglePlayPause();
          break;
        case 'next':
          _audio.nextStation();
          break;
        case 'previous':
          _audio.previousStation();
          break;
        case 'close':
          OverlayService.instance.markClosed();
          break;
      }
    }
  }

  void _syncOverlayState() {
    if (OverlayService.instance.isShowing) {
      FlutterOverlayWindow.shareData({
        'playing': _audio.isPlaying.value,
        'station': _audio.currentStation.value?.name ?? 'Lofi Radio',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(flex: 2),
            _buildVinyl(),
            const Spacer(flex: 1),
            _buildStationInfo(),
            const SizedBox(height: 28),
            _buildControls(),
            const SizedBox(height: 24),
            _buildVolumeControl(),
            const Spacer(flex: 2),
            _buildFocusTime(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 顶部栏 — 玻璃质感按钮
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassButton(
            size: 40,
            onTap: _showStationList,
            child: const Icon(
              Icons.list_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              GlassButton(
                size: 40,
                onTap: _enterOverlayMode,
                child: const Icon(
                  Icons.picture_in_picture_alt_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              GlassButton(
                size: 40,
                onTap: _showSettings,
                child: const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 黑胶唱片 — 显示电台名 + 睡眠倒计时叠加在右下角
  Widget _buildVinyl() {
    final sleepTimer = SleepTimerService.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: _audio.isPlaying,
      builder: (context, isPlaying, _) {
        return ValueListenableBuilder(
          valueListenable: _audio.currentStation,
          builder: (context, station, _) {
            final vinylSize = MediaQuery.of(context).size.width * 0.65;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                VinylRecord(
                  isPlaying: isPlaying,
                  onTap: _audio.togglePlayPause,
                  size: vinylSize,
                  stationName: station?.name ?? 'LOFI',
                ),
                // 睡眠倒计时环 — 右下角
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: ValueListenableBuilder<int>(
                    valueListenable: sleepTimer.remainingMinutes,
                    builder: (context, remaining, _) {
                      if (remaining <= 0) return const SizedBox.shrink();
                      return SleepTimerRing(
                        remainingMinutes: remaining,
                        totalMinutes: sleepTimer.totalMinutes,
                        size: 52,
                        onTap: () => _showSettings(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 电台信息
  Widget _buildStationInfo() {
    return ValueListenableBuilder(
      valueListenable: _audio.currentStation,
      builder: (context, station, _) {
        return Column(
          children: [
            Text(
              station?.name ?? 'Lofi Radio',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              station != null ? '${station.style1} · ${station.style2}' : '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 播放控制 — 玻璃质感
  Widget _buildControls() {
    return ValueListenableBuilder<bool>(
      valueListenable: _audio.isPlaying,
      builder: (context, isPlaying, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassButton(
              size: 44,
              onTap: () => _audio.previousStation(),
              child: const Icon(
                Icons.skip_previous_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 28),
            GlassPlayButton(
              isPlaying: isPlaying,
              onTap: () => _audio.togglePlayPause(),
              size: 64,
            ),
            const SizedBox(width: 28),
            GlassButton(
              size: 44,
              onTap: () => _audio.nextStation(),
              child: const Icon(
                Icons.skip_next_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 音量控制
  Widget _buildVolumeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: ValueListenableBuilder<double>(
        valueListenable: _audio.volume,
        builder: (context, volume, _) {
          return VolumeSlider(
            volume: volume,
            onChanged: (v) => _audio.setVolume(v),
            onMuteToggle: () {
              if (_audio.volume.value > 0) {
                _previousVolume = _audio.volume.value;
                _audio.setVolume(0);
              } else {
                _audio.setVolume(_previousVolume);
              }
            },
          );
        },
      ),
    );
  }

  /// Focus 时间
  Widget _buildFocusTime() {
    return ValueListenableBuilder<int>(
      valueListenable: _focus.focusMinutes,
      builder: (context, minutes, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 14,
              color: AppColors.accent.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              'Focus: $minutes min',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── 操作 ───

  void _showStationList() {
    StationListSheet.show(
      context,
      stations: _audio.stations.value,
      currentIndex: _audio.currentIndex.value,
      onSelect: (index) => _audio.playStation(index),
    );
  }

  void _showSettings() {
    SettingsSheet.show(
      context,
      onClearCache: _clearCache,
      onAddStation: _showAddStationDialog,
      onResetStations: _resetStations,
    );
  }

  void _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('overlay_action');
    await prefs.remove('overlay_action_ts');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('缓存已清除', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetStations() {
    _audio.stations.value = [...defaultStations];
    _audio.playStation(0);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已恢复默认电台列表', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _enterOverlayMode() async {
    final overlay = OverlayService.instance;

    try {
      final granted = await overlay.hasPermission();

      if (!granted) {
        final result = await overlay.requestPermission();
        if (!result) {
          _showSnack('需要在系统设置中开启悬浮窗权限');
          return;
        }
        // 权限刚授予，等一下再启动
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await overlay.show();

      // 延迟发送状态
      await Future.delayed(const Duration(milliseconds: 800));
      _syncOverlayState();
    } catch (e) {
      debugPrint('Overlay error: $e');
      _showSnack('悬浮窗启动失败，请使用通知栏控制');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAddStationDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '添加电台',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '电台名称',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.backgroundDeep,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '流媒体 URL (mp3/m3u8)',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.backgroundDeep,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                final type = url.contains('.m3u8') ? 'm3u8' : 'mp3';
                _audio.addStation(Station(
                  name: name,
                  category: 'Custom',
                  type: type,
                  url: url,
                  style1: 'Custom',
                  style2: '',
                  scene: '',
                ));
                Navigator.pop(ctx);
              }
            },
            child:
                const Text('添加', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
