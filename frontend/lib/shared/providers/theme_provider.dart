import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeModeNotifier(storage);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final dynamic _storage;

  ThemeModeNotifier(this._storage) : super(_loadInitialMode(_storage));

  static ThemeMode _loadInitialMode(dynamic storage) {
    try {
      final saved = storage.getThemeMode();
      switch (saved) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        default:
          return ThemeMode.dark; // Default to midnight dark mode
      }
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final modeStr = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    _storage.setThemeMode(modeStr);
  }
}

