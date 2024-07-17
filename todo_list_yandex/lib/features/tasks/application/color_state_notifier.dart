import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorStateNotifier extends StateNotifier<Color> {
  final Color remoteConfigColor;
  final Color redColor = const Color(0xFFFF3B30);

  ColorStateNotifier(this.remoteConfigColor) : super(remoteConfigColor);

  void toggleColor() {
    state = (state == remoteConfigColor) ? redColor : remoteConfigColor;
  }
}
