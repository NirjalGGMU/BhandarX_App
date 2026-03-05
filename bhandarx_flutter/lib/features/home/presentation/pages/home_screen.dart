import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/widgets/bottom_nav_bar.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/logout_confirmation_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/change_password_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/profile_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/settings_screen.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/workspace_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authViewModelProvider).entity;
    final role = (user?.role ?? 'employee').toLowerCase();

    if (role != 'employee') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tr('home'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.danger, size: 44),
                  const SizedBox(height: 12),
                  Text(
                    'Unauthorized Role',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app is employee-only. Please login with an employee account.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginScreen.routeName,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.tr('logout')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final pages = [
      _HomeOverview(userName: user?.fullName ?? 'User'),
      const NotificationsScreen(embedded: true),
      const ProfileScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(l10n)),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, NotificationsScreen.routeName),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'BhandarX User',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tr('user_dashboard'),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _DrawerAction(
                  icon: Icons.person_outline_rounded,
                  label: l10n.tr('my_profile'),
                  onTap: () =>
                      Navigator.pushNamed(context, ProfileScreen.routeName),
                ),
                _DrawerAction(
                  icon: Icons.notifications_outlined,
                  label: l10n.tr('notifications'),
                  onTap: () => Navigator.pushNamed(
                      context, NotificationsScreen.routeName),
                ),
                _DrawerAction(
                  icon: Icons.work_outline_rounded,
                  label: l10n.tr('workspace'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    WorkspaceDashboardScreen.routeName,
                  ),
                ),
                _DrawerAction(
                  icon: Icons.settings_outlined,
                  label: l10n.tr('settings'),
                  onTap: () =>
                      Navigator.pushNamed(context, SettingsScreen.routeName),
                ),
                const Spacer(),
                _DrawerAction(
                  icon: Icons.logout_rounded,
                  label: l10n.tr('logout'),
                  onTap: () => Navigator.pushNamed(
                      context, LogoutConfirmationScreen.routeName),
                ),
              ],
            ),
          ),
        ),
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BhandarXBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _appBarTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 1:
        return l10n.tr('notifications');
      case 2:
        return l10n.tr('my_profile');
      case 3:
        return l10n.tr('settings');
      default:
        return '${l10n.tr('app_name')} ${l10n.tr('home')}';
    }
  }
}

class _HomeOverview extends StatelessWidget {
  final String userName;

  const _HomeOverview({required this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = [
      (
        l10n.tr('my_profile'),
        'Your account details',
        '',
        AppColors.primary,
        const [Color(0xFF1FA866), Color(0xFF128D54)],
        Icons.person_outline_rounded,
        ProfileScreen.routeName
      ),
      (
        l10n.tr('change_password'),
        'Security update',
        '',
        AppColors.danger,
        const [Color(0xFFE53935), Color(0xFFC62828)],
        Icons.lock_outline_rounded,
        ChangePasswordScreen.routeName
      ),
      (
        l10n.tr('notifications'),
        'Alerts and notices',
        '',
        AppColors.accentPurple,
        const [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
        Icons.notifications_active_outlined,
        NotificationsScreen.routeName
      ),
      (
        l10n.tr('workspace'),
        'Products, sales, customers',
        '',
        AppColors.success,
        const [Color(0xFF2E7DFF), Color(0xFF1564E0)],
        Icons.work_outline_rounded,
        WorkspaceDashboardScreen.routeName
      ),
      (
        l10n.tr('settings'),
        'Theme and preferences',
        '',
        AppColors.info,
        const [Color(0xFFFFA726), Color(0xFFEF6C00)],
        Icons.tune_rounded,
        SettingsScreen.routeName
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.tr('welcome_back')}, $userName',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tr('quick_access'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Navigator.pushNamed(context, action.$7),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [action.$5.first, action.$5.last],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: action.$5.first.withValues(alpha: 0.28),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      top: -10,
                      child: Icon(
                        action.$6,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.04),
                              Colors.black.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child:
                                Icon(action.$6, color: Colors.white, size: 16),
                          ),
                          const Spacer(),
                          Text(
                            action.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DrawerAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}
