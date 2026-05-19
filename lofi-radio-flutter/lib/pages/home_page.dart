import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';
import '../services/audio_service.dart';
import '../services/focus_timer_service.dart';
import '../services/overlay_service.dart';
import '../services/sleep_timer_service.dart';
import '../theme/app_colors.dart';
import '../widgets/audio_wave_halo.dart';
import '../widgets/glass_button.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/sleep_timer_ring.dart';
import '../widgets/station_list_sheet.dart';
import '../widgets/transport_console.dart';
import '../widgets/vinyl_record.dart';

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

    _audio.isPlaying.addListener(_onPlayStateChanged);
    if (_audio.isPlaying.value) {
      _focus.start();
    }

    _setupOverlayListener();
    _audio.isPlaying.addListener(_syncOverlayState);
    _audio.currentStation.addListener(_syncOverlayState);
  }

  void _setupOverlayListener() {
    _overlayPollTimer = Timer.periodic(const Duration(milliseconds: 300), (
      _,
    ) async {
      if (!OverlayService.instance.isShowing) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final ts = prefs.getInt('overlay_action_ts') ?? 0;

      if (ts <= _lastActionTs) return;

      _lastActionTs = ts;
      final action = prefs.getString('overlay_action') ?? '';
      _handleOverlayMessage({'action': action});
      await prefs.remove('overlay_action');
      await prefs.remove('overlay_action_ts');
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
    if (data is! Map) return;

    switch (data['action'] as String?) {
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

  void _syncOverlayState() {
    if (!OverlayService.instance.isShowing) return;

    FlutterOverlayWindow.shareData({
      'playing': _audio.isPlaying.value,
      'station': _audio.currentStation.value?.name ?? 'Lofi Radio',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.75),
            radius: 1.25,
            colors: [
              Color(0xFF22344A),
              AppColors.backgroundDeep,
              Color(0xFF0A0F18),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;
              final ultraCompact = constraints.maxHeight < 680;
              final vinylSize = math.min(
                constraints.maxWidth *
                    (ultraCompact
                        ? 0.45
                        : compact
                        ? 0.54
                        : 0.62),
                constraints.maxHeight *
                    (ultraCompact
                        ? 0.24
                        : compact
                        ? 0.28
                        : 0.34),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildTopBar(compact: compact),
                    SizedBox(
                      height: ultraCompact
                          ? 2
                          : compact
                          ? 6
                          : 10,
                    ),
                    _buildVinyl(
                      compact: compact,
                      ultraCompact: ultraCompact,
                      vinylSize: vinylSize,
                    ),
                    SizedBox(
                      height: ultraCompact
                          ? 10
                          : compact
                          ? 14
                          : 18,
                    ),
                    _buildStationInfo(compact: compact),
                    SizedBox(
                      height: ultraCompact
                          ? 6
                          : compact
                          ? 8
                          : 10,
                    ),
                    const Spacer(),
                    _buildControls(compact: compact),
                    SizedBox(
                      height: ultraCompact
                          ? 10
                          : compact
                          ? 12
                          : 16,
                    ),
                    _buildFocusTime(compact: compact),
                    SizedBox(
                      height: ultraCompact
                          ? 6
                          : compact
                          ? 10
                          : 14,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool compact}) {
    final buttonSize = compact ? 38.0 : 42.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: compact ? 8 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassButton(
            size: buttonSize,
            onTap: _showStationList,
            child: Icon(
              Icons.queue_music_rounded,
              size: compact ? 17 : 18,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              GlassButton(
                size: buttonSize,
                onTap: _enterOverlayMode,
                child: Icon(
                  Icons.picture_in_picture_alt_rounded,
                  size: compact ? 15 : 16,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: compact ? 8 : 10),
              GlassButton(
                size: buttonSize,
                onTap: _showSettings,
                child: Icon(
                  Icons.tune_rounded,
                  size: compact ? 15 : 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVinyl({
    required bool compact,
    required bool ultraCompact,
    required double vinylSize,
  }) {
    final sleepTimer = SleepTimerService.instance;

    return ValueListenableBuilder<bool>(
      valueListenable: _audio.isPlaying,
      builder: (context, isPlaying, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _audio.isBuffering,
          builder: (context, isBuffering, __) {
            return ValueListenableBuilder<Station?>(
              valueListenable: _audio.currentStation,
              builder: (context, station, ___) {
                return ValueListenableBuilder<double>(
                  valueListenable: _audio.volume,
                  builder: (context, volume, ____) {
                    return SizedBox(
                      height:
                          vinylSize +
                          (ultraCompact
                              ? 12
                              : compact
                              ? 18
                              : 28),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          AudioWaveHalo(
                            size:
                                vinylSize +
                                (ultraCompact
                                    ? 18
                                    : compact
                                    ? 22
                                    : 28),
                            isPlaying: isPlaying,
                            isBuffering: isBuffering,
                            intensity: volume,
                          ),
                          VinylRecord(
                            isPlaying: isPlaying,
                            onTap: _audio.togglePlayPause,
                            size: vinylSize,
                            stationName: station?.name ?? 'LOFI',
                          ),
                          Positioned(
                            right: compact ? 8 : 2,
                            bottom: ultraCompact
                                ? -1
                                : compact
                                ? -4
                                : 2,
                            child: ValueListenableBuilder<int>(
                              valueListenable: sleepTimer.remainingMinutes,
                              builder: (context, remaining, _____) {
                                if (remaining <= 0) {
                                  return const SizedBox.shrink();
                                }
                                return SleepTimerRing(
                                  remainingMinutes: remaining,
                                  totalMinutes: sleepTimer.totalMinutes,
                                  size: ultraCompact
                                      ? 36
                                      : compact
                                      ? 42
                                      : 48,
                                  onTap: _showSettings,
                                );
                              },
                            ),
                          ),
                          if (isBuffering)
                            Positioned(
                              top: ultraCompact
                                  ? -2
                                  : compact
                                  ? -4
                                  : -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.black.withValues(alpha: 0.34),
                                  border: Border.all(
                                    color: AppColors.signalPeak.withValues(
                                      alpha: 0.24,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'BUFFERING',
                                  style: TextStyle(
                                    color: AppColors.signalPeak,
                                    fontSize: ultraCompact
                                        ? 8
                                        : compact
                                        ? 9
                                        : 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStationInfo({required bool compact}) {
    return ValueListenableBuilder<Station?>(
      valueListenable: _audio.currentStation,
      builder: (context, station, _) {
        final subtitle = station == null
            ? ''
            : [
                station.style1,
                station.style2,
                station.isUserStation ? 'Custom' : 'Preset',
              ].where((value) => value.trim().isNotEmpty).join(' · ');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              station?.name ?? 'Lofi Radio',
              style: TextStyle(
                fontSize: compact ? 18 : 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls({required bool compact}) {
    return ValueListenableBuilder<double>(
      valueListenable: _audio.volume,
      builder: (context, volume, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _audio.isPlaying,
          builder: (context, isPlaying, __) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 18),
              child: TransportConsole(
                compact: compact,
                isPlaying: isPlaying,
                volume: volume,
                onPrevious: _audio.previousStation,
                onTogglePlayback: _audio.togglePlayPause,
                onNext: _audio.nextStation,
                onVolumeChanged: _audio.setVolume,
                onMuteToggle: () {
                  if (_audio.volume.value > 0) {
                    _previousVolume = _audio.volume.value;
                    _audio.setVolume(0);
                  } else {
                    _audio.setVolume(_previousVolume);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFocusTime({required bool compact}) {
    return ValueListenableBuilder<int>(
      valueListenable: _focus.focusMinutes,
      builder: (context, minutes, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: compact ? 12 : 14,
              color: AppColors.signalPeak.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Focus: $minutes min',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStationList() {
    StationListSheet.show(
      context,
      stationsListenable: _audio.stations,
      currentIndexListenable: _audio.currentIndex,
      onSelect: (index) => _audio.playStation(index),
      onDelete: _deleteCustomStation,
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

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('overlay_action');
    await prefs.remove('overlay_action_ts');
    _showSnack('已清理临时缓存。');
  }

  Future<void> _resetStations() async {
    await _audio.resetCustomStations();
    await _audio.playStation(0);
    _showSnack('已清空自定义电台并恢复预设列表。');
  }

  Future<void> _deleteCustomStation(int index) async {
    await _audio.removeStation(index);
    _showSnack('已删除自定义电台。');
  }

  Future<void> _enterOverlayMode() async {
    final overlay = OverlayService.instance;

    try {
      final granted = await overlay.hasPermission();

      if (!granted) {
        final result = await overlay.requestPermission();
        if (!result) {
          _showSnack('需要先授予悬浮窗权限。');
          return;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await overlay.show();
      await Future.delayed(const Duration(milliseconds: 800));
      _syncOverlayState();
    } catch (e) {
      debugPrint('Overlay error: $e');
      _showSnack('悬浮窗启动失败，请使用通知栏控制。');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          '添加自定义电台',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dialogInputDecoration('电台名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: _dialogInputDecoration('流媒体 URL（mp3 / m3u8）'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '取消',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isEmpty || url.isEmpty) {
                return;
              }

              final type = url.toLowerCase().contains('.m3u8') ? 'm3u8' : 'mp3';
              final station = Station(
                name: name,
                category: 'Custom',
                type: type,
                url: url,
                style1: 'Custom',
                style2: '',
                scene: '',
                custom: '用户添加',
                isUserStation: true,
              );

              await _audio.addStation(station);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              _showSnack('已保存自定义电台。');
            },
            child: const Text('添加', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.backgroundDeep,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
