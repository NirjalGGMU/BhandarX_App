import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/config/app_config.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/change_password_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profile';
  final bool embedded;

  const ProfileScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).entity;

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 0,
              ),
              _ProfileAvatar(imagePath: user?.profilePicture),
              const SizedBox(height: 14),
              Text(user?.fullName ?? 'No user',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(user?.email ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _displayRole(user?.role),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ProfileTile(
          title: 'Username',
          value: user?.username ?? '-',
          icon: Icons.alternate_email_rounded,
        ),
        _ProfileTile(
          title: 'Phone',
          value: user?.phoneNumber ?? 'Not added',
          icon: Icons.phone_outlined,
        ),
        _ProfileTile(
          title: 'Notification access',
          value: user?.notificationsEnabled == true ? 'Enabled' : 'Disabled',
          icon: Icons.notifications_active_outlined,
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pushNamed(context, EditProfileScreen.routeName);
          },
          child: const Text('Edit profile'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            Navigator.pushNamed(context, ChangePasswordScreen.routeName);
          },
          child: const Text('Change password'),
        ),
      ],
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: content,
    );
  }
}

String _displayRole(String? role) {
  if ((role ?? '').toLowerCase() == 'employee') {
    return 'USER';
  }
  return (role ?? 'USER').toUpperCase();
}

class _ProfileAvatar extends StatelessWidget {
  final String? imagePath;

  const _ProfileAvatar({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = AppConfig.resolveMediaUrl(imagePath);
    if (resolvedUrl.isEmpty) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person, color: Colors.white, size: 32),
      );
    }

    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolvedUrl,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const Icon(
            Icons.person,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
