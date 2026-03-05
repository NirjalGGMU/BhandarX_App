import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/widgets/bottom_nav_bar.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/profile_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.entity;

    final pages = [
      _HomeOverview(userName: user?.fullName ?? 'User', role: user?.role ?? 'employee'),
      const NotificationsScreen(embedded: true),
      const ProfileScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, NotificationsScreen.routeName);
            },
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (user?.role ?? 'employee').toUpperCase(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _DrawerAction(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
                ),
                _DrawerAction(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () =>
                      Navigator.pushNamed(context, NotificationsScreen.routeName),
                ),
                _DrawerAction(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                ),
                const Spacer(),
                _DrawerAction(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  onTap: _logout,
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

  String get _appBarTitle {
    switch (_currentIndex) {
      case 1:
        return 'Notifications';
      case 2:
        return 'My Profile';
      case 3:
        return 'Settings';
      default:
        return 'BhandarX';
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await ref.read(authViewModelProvider.notifier).logout();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
  }
}

class _HomeOverview extends StatelessWidget {
  final String userName;
  final String role;

  const _HomeOverview({required this.userName, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final cards = isAdmin
        ? const [
            ('Products overview', AppColors.accentBlue, Icons.inventory_2_outlined),
            ('Notifications', AppColors.accentPurple, Icons.notifications_active_outlined),
            ('Profile controls', AppColors.primary, Icons.manage_accounts_outlined),
            ('Settings', AppColors.accentOrange, Icons.settings_outlined),
          ]
        : const [
            ('My alerts', AppColors.accentPurple, Icons.notifications_active_outlined),
            ('Profile', AppColors.primary, Icons.person_outline_rounded),
            ('Password', AppColors.accentRed, Icons.lock_outline_rounded),
            ('Preferences', AppColors.accentBlue, Icons.tune_rounded),
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
                'Welcome back, $userName',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This mobile app focuses on your account, profile, notifications, and settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Pill(label: role.toUpperCase(), color: AppColors.primary),
                  const _Pill(label: 'Mobile user scope', color: AppColors.accentBlue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: card.$2.withValues(alpha: 0.12),
                    child: Icon(card.$3, color: card.$2),
                  ),
                  const Spacer(),
                  Text(
                    card.$1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
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
