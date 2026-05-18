import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../models/station.dart';
import '../data/default_stations.dart';

/// 音频播放服务 — 整合 just_audio + audio_service
///
/// 提供：
/// - 通知栏媒体控制（播放/暂停/上下首）
/// - 锁屏控制
/// - 蓝牙耳机按键响应
/// - 单一数据源状态管理
class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  LofiAudioHandler? _handler;

  // ─── 状态通知 ───
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<double> volume = ValueNotifier(0.3);
  final ValueNotifier<int> currentIndex = ValueNotifier(0);
  final ValueNotifier<Station?> currentStation = ValueNotifier(null);
  final ValueNotifier<List<Station>> stations = ValueNotifier(defaultStations);

  bool _initialized = false;

  AudioPlayer? get player => _handler?.player;

  /// 初始化：注册 AudioService，启动通知栏
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _handler = await AudioService.init(
      builder: () => LofiAudioHandler(
        onPlayStateChanged: (playing) => isPlaying.value = playing,
        onIndexChanged: (index) {
          currentIndex.value = index;
          if (index >= 0 && index < stations.value.length) {
            currentStation.value = stations.value[index];
          }
        },
      ),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.lofiradio.audio',
        androidNotificationChannelName: 'Lofi Radio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    await _handler!.player.setVolume(volume.value);

    // 开箱即用：启动即播放
    if (stations.value.isNotEmpty) {
      await playStation(0);
    }
  }

  /// 切换播放/暂停
  Future<void> togglePlayPause() async {
    final handler = _handler;
    if (handler == null) return;
    if (handler.player.playing) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  /// 播放指定电台
  Future<void> playStation(int index) async {
    if (index < 0 || index >= stations.value.length) return;
    final handler = _handler;
    if (handler == null) return;

    currentIndex.value = index;
    currentStation.value = stations.value[index];
    final station = stations.value[index];

    final mediaItem = MediaItem(
      id: station.url,
      title: station.name,
      artist: '${station.style1} · ${station.style2}',
      album: 'Lofi Radio',
      extras: {'index': index},
    );

    await handler.playFromStation(mediaItem);
  }

  /// 下一个电台
  Future<void> nextStation() async {
    final next = (currentIndex.value + 1) % stations.value.length;
    await playStation(next);
  }

  /// 上一个电台
  Future<void> previousStation() async {
    final prev =
        (currentIndex.value - 1 + stations.value.length) % stations.value.length;
    await playStation(prev);
  }

  /// 设置音量
  Future<void> setVolume(double v) async {
    volume.value = v.clamp(0.0, 1.0);
    await _handler?.player.setVolume(volume.value);
  }

  /// 添加自定义电台
  void addStation(Station station) {
    stations.value = [...stations.value, station];
  }

  /// 移除电台
  void removeStation(int index) {
    if (index < 0 || index >= stations.value.length) return;
    final list = [...stations.value];
    list.removeAt(index);
    stations.value = list;
  }

  Future<void> dispose() async {
    await _handler?.stop();
  }
}

/// AudioHandler — 处理通知栏/锁屏/蓝牙的媒体控制
class LofiAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();
  final void Function(bool playing) onPlayStateChanged;
  final void Function(int index) onIndexChanged;

  LofiAudioHandler({
    required this.onPlayStateChanged,
    required this.onIndexChanged,
  }) {
    // 监听播放状态，同步到通知栏
    player.playerStateStream.listen((state) {
      final playing = state.playing;
      onPlayStateChanged(playing);
      _broadcastState();
    });

    // 监听处理状态（加载中/就绪/错误）
    player.processingStateStream.listen((_) {
      _broadcastState();
    });
  }

  /// 播放指定电台
  Future<void> playFromStation(MediaItem item) async {
    // 更新通知栏显示的媒体信息
    mediaItem.add(item);

    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      await player.play();
    } catch (e) {
      debugPrint('Failed to play station "${item.title}": $e');
    }
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    final service = AudioPlayerService.instance;
    await service.nextStation();
  }

  @override
  Future<void> skipToPrevious() async {
    final service = AudioPlayerService.instance;
    await service.previousStation();
  }

  /// 广播当前播放状态到系统（通知栏/锁屏）
  void _broadcastState() {
    final playing = player.playing;
    final processingState = player.processingState;

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(processingState),
      playing: playing,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
