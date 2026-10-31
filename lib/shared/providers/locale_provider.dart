import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LocaleNotifier(storage);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final dynamic _storage;

  LocaleNotifier(this._storage) : super(_loadInitialLocale(_storage));

  static Locale _loadInitialLocale(dynamic storage) {
    try {
      final saved = storage.getLanguage();
      if (saved == 'hi') {
        return const Locale('hi', 'IN');
      }
      return const Locale('en', 'US');
    } catch (_) {
      return const Locale('en', 'US');
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    _storage.setLanguage(locale.languageCode);
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      setLocale(const Locale('hi', 'IN'));
    } else {
      setLocale(const Locale('en', 'US'));
    }
  }
}
