import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_yandex/logger/logger.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService(this._remoteConfig);

  static const String importanceColorKey = 'importanceColor';
  final colorsRed =  const Color(0xFFFF3B30);

  Future<void> initialize() async {
    await _remoteConfig.setDefaults(<String, dynamic>{
      importanceColorKey: '#FF0000',
    });

    await fetchAndActivate();
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      TaskLogger().logDebug(e.toString());
    }
  }

  Color get importanceColor {
    final colorString = _remoteConfig.getString(importanceColorKey);
    TaskLogger().logDebug('importanceColor - ${_hexToColor(colorString)}');
    return _hexToColor(colorString) ?? colorsRed;
  }

  Color? _hexToColor(String hex) {
    try {
      hex = hex.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      TaskLogger().logDebug('Error parsing color: $e');
      return null;
    }
  }
}
