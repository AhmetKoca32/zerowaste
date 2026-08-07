import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';

/// Persisted locale selection.
///
/// Defaults to the device language when no preference is saved.
/// User can switch from the AppBar button; preference survives restarts.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr'));

  static const _kLocaleKey = 'app_locale';

  /// Call once at startup to restore the persisted locale.
  /// No saved preference → follow device language (en → English, else Turkish).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code == 'en' || code == 'tr') {
      state = Locale(code!);
      return;
    }
    final device =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    state = device == 'en' ? const Locale('en') : const Locale('tr');
  }

  /// Toggle between Turkish and English, persists the choice.
  Future<void> toggle() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final next = state.languageCode == 'tr'
        ? const Locale('en')
        : const Locale('tr');
    state = next;
    // Locale rebuild can restore TextField focus; clear again next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, next.languageCode);
    if (await NotificationService.instance.hasPermission()) {
      await NotificationService.instance.scheduleDailyReminders(next);
    }
  }
}
