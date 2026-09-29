import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide appearance preference. It deliberately stays separate from
/// temporary UI state so every route receives the selected theme.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setDarkMode(bool enabled) {
    state = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}
