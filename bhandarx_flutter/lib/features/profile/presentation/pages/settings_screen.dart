import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/app/themes/theme_mode_provider.dart';
import 'package:bhandarx_flutter/core/providers/language_provider.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/sensors/presentation/pages/sensors_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  static const routeName = '/settings';
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authViewModelProvider).entity;
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSwitchTile(
          title: l10n.tr('dark_mode'),
          subtitle: l10n.tr('dark_mode_sub'),
          value: themeMode == ThemeMode.dark,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).toggleTheme(value);
          },
        ),
        _SettingsSwitchTile(
          title: l10n.tr('push_notifications'),
          subtitle: l10n.tr('push_notifications_sub'),
          value: user?.notificationsEnabled ?? true,
          onChanged: (value) async {
            final currentUser = ref.read(authViewModelProvider).entity;
            if (currentUser == null) {
              return;
            }
            await ref.read(authViewModelProvider.notifier).saveUser(
                  currentUser.copyWith(notificationsEnabled: value),
                );
          },
        ),
        _SettingsSwitchTile(
          title: l10n.tr('email_alerts'),
          subtitle: l10n.tr('email_alerts_sub'),
          value: user?.emailAlertsEnabled ?? true,
          onChanged: (value) async {
            final currentUser = ref.read(authViewModelProvider).entity;
            if (currentUser == null) {
              return;
            }
            await ref.read(authViewModelProvider.notifier).saveUser(
                  currentUser.copyWith(emailAlertsEnabled: value),
                );
          },
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.border,
            ),
          ),
          child: ListTile(
            title: Text(l10n.tr('language')),
            subtitle: Text(l10n.tr('language_sub')),
            trailing: SegmentedButton<AppLanguage>(
              selected: {language},
              onSelectionChanged: (selection) {
                ref
                    .read(languageProvider.notifier)
                    .setLanguage(selection.first);
              },
              segments: const [
                ButtonSegment(value: AppLanguage.english, label: Text('EN')),
                ButtonSegment(value: AppLanguage.nepali, label: Text('NE')),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.border,
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.sensors_rounded),
            title: const Text('Sensors'),
            subtitle: const Text('Accelerometer and Gyroscope'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                Navigator.pushNamed(context, SensorsDashboardScreen.routeName),
          ),
        ),
      ],
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('settings'))),
      body: content,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
