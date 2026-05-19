import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';

class StationRepository {
  StationRepository._();

  static final StationRepository instance = StationRepository._();

  static const _customStationsKey = 'custom_stations_v1';

  Future<List<Station>> loadCustomStations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customStationsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => Station.fromJson(
              Map<String, dynamic>.from(
                item,
              ).map((key, value) => MapEntry(key.toString(), value)),
            ).copyWith(isUserStation: true),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCustomStations(List<Station> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = stations
        .map((station) => station.copyWith(isUserStation: true).toJson())
        .toList(growable: false);
    await prefs.setString(_customStationsKey, jsonEncode(payload));
  }

  Future<void> clearCustomStations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customStationsKey);
  }
}
