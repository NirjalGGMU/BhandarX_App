import 'package:bhandarx_flutter/app/app.dart';
import 'package:bhandarx_flutter/core/services/hive/hive_service.dart';
import 'package:bhandarx_flutter/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferenceProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
