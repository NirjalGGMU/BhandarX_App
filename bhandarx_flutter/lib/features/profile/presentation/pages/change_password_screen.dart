import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile/change-password';
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InputField(
            label: 'Current password',
            controller: _currentCtrl,
            isPassword: true,
          ),
          InputField(
            label: 'New password',
            controller: _newCtrl,
            isPassword: true,
          ),
          InputField(
            label: 'Confirm new password',
            controller: _confirmCtrl,
            isPassword: true,
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Update password',
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () async {
              if (_newCtrl.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New password must be at least 8 characters'),
                  ),
                );
                return;
              }
              if (_newCtrl.text != _confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              final success = await ref
                  .read(authViewModelProvider.notifier)
                  .changePassword(
                    currentPassword: _currentCtrl.text,
                    newPassword: _newCtrl.text,
                  );
              if (!mounted) {
                return;
              }
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Password changed')),
                );
                navigator.pop();
              } else {
                final error = ref.read(authViewModelProvider).errorMessage;
                messenger.showSnackBar(
                  SnackBar(content: Text(error ?? 'Unable to change password')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
