import 'dart:ui';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_yandex/features/tasks/application/color_state_notifier.dart';
import 'package:todo_list_yandex/features/tasks/data/services/remote_config_service.dart';

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  final remoteConfig = FirebaseRemoteConfig.instance;
  final service = RemoteConfigService(remoteConfig);
  service.initialize();
  return service;
});

final colorStateProvider =
    StateNotifierProvider<ColorStateNotifier, Color>((ref) {
  final remoteConfigService = ref.watch(remoteConfigProvider);
  return ColorStateNotifier(remoteConfigService.importanceColor);
});
