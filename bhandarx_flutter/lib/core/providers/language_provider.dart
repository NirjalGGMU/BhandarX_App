import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { english, nepali }

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final code = ref.read(userSessionServiceProvider).getLanguageCode();
    return code == 'ne' ? AppLanguage.nepali : AppLanguage.english;
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await ref
        .read(userSessionServiceProvider)
        .setLanguageCode(language == AppLanguage.nepali ? 'ne' : 'en');
  }
}
