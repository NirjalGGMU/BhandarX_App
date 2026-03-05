import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final sessionService = ref.read(userSessionServiceProvider);
    return sessionService.isDarkModeEnabled() ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme(bool isDark) async {
    await ref.read(userSessionServiceProvider).setDarkMode(isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
