import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/register_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:bhandarx_flutter/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (route) => false,
        );
      }
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authViewModelProvider);

    return AuthScaffold(
      title: l10n.tr('welcome_back'),
      subtitle: l10n.tr('login_subtitle'),
      helperText: l10n.tr('login_helper'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(
            label: l10n.tr('email'),
            hint: 'you@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          InputField(
            label: l10n.tr('password'),
            hint: l10n.tr('enter_password'),
            controller: _passCtrl,
            isPassword: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
              },
              child: Text(l10n.tr('forgot_password')),
            ),
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: l10n.tr('login'),
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () {
              final email = _emailCtrl.text.trim();
              final password = _passCtrl.text.trim();
              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Enter your email and password')),
                );
                return;
              }
              ref
                  .read(authViewModelProvider.notifier)
                  .login(email: email, password: password);
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.tr('new_to_bhandarx')),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterScreen.routeName);
                },
                child: Text(
                  l10n.tr('create_account'),
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
