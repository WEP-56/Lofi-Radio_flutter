import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/station.dart';
import '../theme/app_colors.dart';
import 'station_tag.dart';

class StationListSheet extends StatelessWidget {
  final ValueListenable<List<Station>> stationsListenable;
  final ValueListenable<int> currentIndexListenable;
  final ValueChanged<int> onSelect;
  final Future<void> Function(int index)? onDelete;

  const StationListSheet({
    super.key,
    required this.stationsListenable,
    required this.currentIndexListenable,
    required this.onSelect,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueListenable<List<Station>> stationsListenable,
    required ValueListenable<int> currentIndexListenable,
    required ValueChanged<int> onSelect,
    Future<void> Function(int index)? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StationListSheet(
        stationsListenable: stationsListenable,
        currentIndexListenable: currentIndexListenable,
        onSelect: onSelect,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(
            child: ValueListenableBuilder<List<Station>>(
              valueListenable: stationsListenable,
              builder: (context, stations, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: currentIndexListenable,
                  builder: (context, currentIndex, __) {
                    return _buildGroupedList(
                      context,
                      stations: stations,
                      currentIndex: currentIndex,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 42,
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
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
            child: Column(
              children: [
                Text(
                  'Stations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Preset and custom streams',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context, {
    required List<Station> stations,
    required int currentIndex,
  }) {
    final presetEntries = <_StationEntry>[];
    final customEntries = <_StationEntry>[];

    for (var i = 0; i < stations.length; i++) {
      final entry = _StationEntry(index: i, station: stations[i]);
      if (stations[i].isUserStation) {
        customEntries.add(entry);
      } else {
        presetEntries.add(entry);
      }
    }

    final sections = <Widget>[
      _buildSectionHeader('预设电台', presetEntries.length),
      ...presetEntries.map((entry) => _buildRow(context, entry, currentIndex)),
      const SizedBox(height: 12),
      _buildSectionHeader('自定义电台', customEntries.length),
      if (customEntries.isEmpty)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.035),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            '还没有自定义电台。可在设置中添加新的流媒体地址。',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ...customEntries.map((entry) => _buildRow(context, entry, currentIndex)),
      const SizedBox(height: 20),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      children: sections,
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    _StationEntry entry,
    int currentIndex,
  ) {
    final station = entry.station;
    final isActive = entry.index == currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  AppColors.accentSubtle,
                  AppColors.signalPeak.withValues(alpha: 0.12),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
        border: Border.all(
          color: isActive
              ? AppColors.signalPeak.withValues(alpha: 0.35)
              : AppColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          onSelect(entry.index);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: station.isUserStation
                        ? [
                            AppColors.signalPeak.withValues(alpha: 0.95),
                            AppColors.accent.withValues(alpha: 0.75),
                          ]
                        : [
                            const Color(0xFF6AA5FF).withValues(alpha: 0.9),
                            const Color(0xFF325A95).withValues(alpha: 0.8),
                          ],
                  ),
                ),
                child: Icon(
                  station.isUserStation
                      ? Icons.radio_rounded
                      : Icons.library_music_rounded,
                  color: AppColors.backgroundDeep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      station.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textTertiary.withValues(alpha: 0.86),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        StationTag(
                          text: station.isUserStation ? 'CUSTOM' : 'PRESET',
                          type: station.isUserStation
                              ? TagType.custom
                              : TagType.preset,
                        ),
                        if (station.style1.isNotEmpty)
                          StationTag(text: station.style1),
                        if (station.style2.isNotEmpty)
                          StationTag(text: station.style2),
                        if (station.custom != null)
                          StationTag(
                            text: station.custom!,
                            type: TagType.custom,
                          ),
                        if (station.scene.isNotEmpty)
                          StationTag(text: station.scene, type: TagType.scene),
                      ],
                    ),
                  ],
                ),
              ),
              if (station.isUserStation)
                IconButton(
                  onPressed: () => onDelete?.call(entry.index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  splashRadius: 18,
                )
              else if (isActive)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.signalPeak,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationEntry {
  final int index;
  final Station station;

  const _StationEntry({required this.index, required this.station});
}
