import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  static const routeName = '/forgot-password';
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return AuthScaffold(
      title: 'Forgot Password',
      subtitle: 'Enter your email to receive a 6-digit OTP.',
      helperText: 'Use the OTP in the next step to reset your password.',
      child: Column(
        children: [
          InputField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          CustomButton(
            text: 'Continue',
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () async {
              final email = _emailCtrl.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Enter a valid email')),
                );
                return;
              }

              final devOtp = await ref
                  .read(authViewModelProvider.notifier)
                  .requestPasswordReset(email);

              if (!mounted) {
                return;
              }

              final error = ref.read(authViewModelProvider).errorMessage;
              if (error != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(error)),
                );
                return;
              }

              final otpHint = devOtp == null || devOtp.isEmpty
                  ? 'OTP sent to your email.'
                  : 'OTP sent. Dev OTP: $devOtp';
              messenger.showSnackBar(SnackBar(content: Text(otpHint)));

              navigator.push(
                MaterialPageRoute(
                  builder: (_) => ResetPasswordScreen(email: email),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
