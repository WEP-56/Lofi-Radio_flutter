import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Focus 计时器服务
///
/// 播放时计时，暂停时停止
/// 每日自动重置，数据持久化到 SharedPreferences
class FocusTimerService {
  FocusTimerService._();
  static final FocusTimerService instance = FocusTimerService._();

  final ValueNotifier<int> focusMinutes = ValueNotifier(0);

  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  String _lastDate = '';

  static const _keyMinutes = 'focus_minutes';
  static const _keyDate = 'focus_date';

  /// 初始化：加载今日数据
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate == today) {
      focusMinutes.value = prefs.getInt(_keyMinutes) ?? 0;
    } else {
      // 新的一天，重置
      focusMinutes.value = 0;
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyMinutes, 0);
    }

    _lastDate = today;
    _seconds = focusMinutes.value * 60;
  }

  /// 开始计时（播放时调用）
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      final newMinutes = _seconds ~/ 60;
      if (newMinutes != focusMinutes.value) {
        focusMinutes.value = newMinutes;
        _save();
      }

      // 检查日期变更
      final today = _todayString();
      if (today != _lastDate) {
        _lastDate = today;
        _seconds = 0;
        focusMinutes.value = 0;
        _save();
      }
    });
  }

  /// 停止计时（暂停时调用）
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// 重置今日时间
  Future<void> reset() async {
    _seconds = 0;
    focusMinutes.value = 0;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMinutes, focusMinutes.value);
    await prefs.setString(_keyDate, _todayString());
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
