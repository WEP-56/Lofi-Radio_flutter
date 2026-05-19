import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/default_stations.dart';
import '../models/station.dart';
import 'station_repository.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService instance = AudioPlayerService._();

  static const _androidBufferWindow = Duration(seconds: 12);
  static const _androidMaxBufferWindow = Duration(seconds: 24);
  static const _rebufferWindow = Duration(seconds: 6);

  LofiAudioHandler? _handler;
  final StationRepository _stationRepository = StationRepository.instance;

  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> isBuffering = ValueNotifier(false);
  final ValueNotifier<double> volume = ValueNotifier(0.3);
  final ValueNotifier<int> currentIndex = ValueNotifier(0);
  final ValueNotifier<Station?> currentStation = ValueNotifier(null);
  final ValueNotifier<List<Station>> customStations = ValueNotifier(const []);
  final ValueNotifier<List<Station>> stations = ValueNotifier(
    List<Station>.unmodifiable(defaultStations),
  );

  bool _initialized = false;

  AudioPlayer? get player => _handler?.player;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadStations();

    _handler = await AudioService.init(
      builder: () => LofiAudioHandler(
        onPlayStateChanged: (playing) => isPlaying.value = playing,
        onBufferingStateChanged: (buffering) => isBuffering.value = buffering,
      ),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.lofiradio.audio',
        androidNotificationChannelName: 'Lofi Radio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    await _handler!.player.setVolume(volume.value);

    if (stations.value.isNotEmpty) {
      await playStation(0);
    }
  }

  Future<void> _loadStations() async {
    final loadedCustomStations = await _stationRepository.loadCustomStations();
    customStations.value = List<Station>.unmodifiable(loadedCustomStations);
    _refreshMergedStations();
  }

  void _refreshMergedStations() {
    stations.value = List<Station>.unmodifiable([
      ...defaultStations,
      ...customStations.value,
    ]);

    if (stations.value.isEmpty) {
      currentIndex.value = 0;
      currentStation.value = null;
      return;
    }

    final nextIndex = currentIndex.value.clamp(0, stations.value.length - 1);
    currentIndex.value = nextIndex;
    currentStation.value = stations.value[nextIndex];
  }

  Future<void> togglePlayPause() async {
    final handler = _handler;
    if (handler == null) return;

    if (handler.player.playing) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  Future<void> playStation(int index) async {
    if (index < 0 || index >= stations.value.length) return;
    final handler = _handler;
    if (handler == null) return;

    currentIndex.value = index;
    currentStation.value = stations.value[index];
    final station = stations.value[index];

    final subtitle = [
      station.style1,
      station.style2,
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    final mediaItem = MediaItem(
      id: station.url,
      title: station.name,
      artist: subtitle.isEmpty ? station.category : subtitle,
      album: station.isUserStation ? 'Custom Station' : 'Lofi Radio',
      extras: {'index': index},
    );

    await handler.playFromStation(mediaItem);
  }

  Future<void> nextStation() async {
    if (stations.value.isEmpty) return;
    final next = (currentIndex.value + 1) % stations.value.length;
    await playStation(next);
  }

  Future<void> previousStation() async {
    if (stations.value.isEmpty) return;
    final prev =
        (currentIndex.value - 1 + stations.value.length) %
        stations.value.length;
    await playStation(prev);
  }

  Future<void> setVolume(double v) async {
    volume.value = v.clamp(0.0, 1.0);
    await _handler?.player.setVolume(volume.value);
  }

  Future<void> addStation(Station station) async {
    final customStation = station.copyWith(isUserStation: true);
    final updated = [...customStations.value, customStation];
    customStations.value = List<Station>.unmodifiable(updated);
    _refreshMergedStations();
    await _stationRepository.saveCustomStations(updated);
  }

  Future<void> removeStation(int index) async {
    if (index < 0 || index >= stations.value.length) return;

    final station = stations.value[index];
    if (!station.isUserStation) return;

    final updated = customStations.value
        .where(
          (item) =>
              !(item.url == station.url &&
                  item.name == station.name &&
                  item.isUserStation),
        )
        .toList(growable: false);

    customStations.value = List<Station>.unmodifiable(updated);
    _refreshMergedStations();
    await _stationRepository.saveCustomStations(updated);

    if (stations.value.isEmpty) return;

    if (index == currentIndex.value) {
      final fallbackIndex = currentIndex.value.clamp(
        0,
        stations.value.length - 1,
      );
      await playStation(fallbackIndex);
      return;
    }

    if (index < currentIndex.value) {
      currentIndex.value = (currentIndex.value - 1).clamp(
        0,
        stations.value.length - 1,
      );
      currentStation.value = stations.value[currentIndex.value];
    }
  }

  Future<void> resetCustomStations() async {
    customStations.value = const [];
    _refreshMergedStations();
    await _stationRepository.clearCustomStations();
  }

  Future<void> dispose() async {
    await _handler?.stop();
  }
}

class LofiAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      darwinLoadControl: DarwinLoadControl(
        automaticallyWaitsToMinimizeStalling: true,
        preferredForwardBufferDuration: Duration(seconds: 10),
        canUseNetworkResourcesForLiveStreamingWhilePaused: true,
      ),
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: AudioPlayerService._androidBufferWindow,
        maxBufferDuration: AudioPlayerService._androidMaxBufferWindow,
        bufferForPlaybackDuration: Duration(seconds: 2),
        bufferForPlaybackAfterRebufferDuration:
            AudioPlayerService._rebufferWindow,
        prioritizeTimeOverSizeThresholds: true,
      ),
    ),
  );

  final void Function(bool playing) onPlayStateChanged;
  final void Function(bool buffering) onBufferingStateChanged;

  LofiAudioHandler({
    required this.onPlayStateChanged,
    required this.onBufferingStateChanged,
  }) {
    player.playerStateStream.listen((state) {
      onPlayStateChanged(state.playing);
      onBufferingStateChanged(
        state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering,
      );
      _broadcastState();
    });

    player.processingStateStream.listen((processingState) {
      onBufferingStateChanged(
        processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering,
      );
      _broadcastState();
    });
  }

  Future<void> playFromStation(MediaItem item) async {
    mediaItem.add(item);

    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(item.id), tag: item),
        preload: true,
      );
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
    await AudioPlayerService.instance.nextStation();
  }

  @override
  Future<void> skipToPrevious() async {
    await AudioPlayerService.instance.previousStation();
  }

  void _broadcastState() {
    final playing = player.playing;
    final processingState = player.processingState;

    playbackState.add(
      PlaybackState(
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
      ),
    );
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
