import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.register) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage ?? 'Account created')),
        );
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);

    return AuthScaffold(
      title: l10n.tr('create_account'),
      subtitle: l10n.tr('register_subtitle'),
      helperText: l10n.tr('register_helper'),
      child: Column(
        children: [
          InputField(
            label: l10n.tr('full_name'),
            hint: 'Nirjal Shrestha',
            controller: _fullNameCtrl,
          ),
          InputField(
            label: l10n.tr('email'),
            hint: 'you@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          InputField(
            label: l10n.tr('password'),
            hint: 'Minimum 8 characters',
            controller: _passCtrl,
            isPassword: true,
          ),
          InputField(
            label: l10n.tr('confirm_password'),
            hint: 'Re-enter your password',
            controller: _confirmCtrl,
            isPassword: true,
          ),
          CustomButton(
            text: l10n.tr('create_account'),
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () {
              final fullName = _fullNameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              final password = _passCtrl.text;
              final confirmPassword = _confirmCtrl.text;

              if (fullName.isEmpty ||
                  email.isEmpty ||
                  password.isEmpty ||
                  confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All fields are required')),
                );
                return;
              }

              if (!email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid email')),
                );
                return;
              }

              if (password.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 8 characters'),
                  ),
                );
                return;
              }

              final strongPassword = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#]).{8,}$',
              );
              if (!strongPassword.hasMatch(password)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Use 8+ chars with upper, lower, number, and special character',
                    ),
                  ),
                );
                return;
              }

              if (password != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              ref.read(authViewModelProvider.notifier).register(
                    fullName: fullName,
                    username: email.split('@').first,
                    email: email,
                    password: password,
                    role: 'employee',
                  );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                },
                child: Text(
                  l10n.tr('login'),
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
