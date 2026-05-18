import 'dart:async';
import 'package:flutter/foundation.dart';
import 'audio_service.dart';

/// 睡眠定时服务
///
/// 设定时间后自动暂停播放
class SleepTimerService {
  SleepTimerService._();
  static final SleepTimerService instance = SleepTimerService._();

  Timer? _timer;
  final ValueNotifier<int> remainingMinutes = ValueNotifier(0);
  int totalMinutes = 0;
  bool get isActive => _timer != null;

  /// 设置定时（分钟），0 表示取消
  void set(int minutes) {
    cancel();
    if (minutes <= 0) return;

    totalMinutes = minutes;
    remainingMinutes.value = minutes;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      remainingMinutes.value--;
      if (remainingMinutes.value <= 0) {
        _onTimerEnd();
      }
    });
  }

  /// 取消定时
  void cancel() {
    _timer?.cancel();
    _timer = null;
    remainingMinutes.value = 0;
    totalMinutes = 0;
  }

  void _onTimerEnd() {
    cancel();
    // 暂停播放
    AudioPlayerService.instance.togglePlayPause();
    debugPrint('[SleepTimer] Timer ended, pausing playback');
  }
}
