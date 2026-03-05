import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return AuthScaffold(
      title: 'Reset Password',
      subtitle: 'Set a new password for ${widget.email}.',
      helperText: 'Enter the OTP sent to your email.',
      child: Column(
        children: [
          InputField(
            label: 'OTP',
            hint: '6-digit code',
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
          ),
          InputField(
            label: 'New password',
            hint: 'Minimum 8 characters',
            controller: _passwordCtrl,
            isPassword: true,
          ),
          InputField(
            label: 'Confirm password',
            hint: 'Re-enter new password',
            controller: _confirmCtrl,
            isPassword: true,
          ),
          CustomButton(
            text: 'Reset password',
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () async {
              final otp = _otpCtrl.text.trim();
              final password = _passwordCtrl.text;
              final confirmPassword = _confirmCtrl.text;
              final passwordPattern = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#]).{8,}$',
              );

              if (otp.length != 6 || int.tryParse(otp) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a valid 6-digit OTP')),
                );
                return;
              }
              if (!passwordPattern.hasMatch(password)) {
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

              final success =
                  await ref.read(authViewModelProvider.notifier).resetPasswordWithOtp(
                        email: widget.email,
                        otp: otp,
                        newPassword: password,
                        confirmPassword: confirmPassword,
                      );

              if (!mounted) {
                return;
              }

              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Password reset successfully')),
                );
                navigator.pushNamedAndRemoveUntil(
                  LoginScreen.routeName,
                  (route) => false,
                );
              } else {
                final message = ref.read(authViewModelProvider).errorMessage;
                messenger.showSnackBar(
                  SnackBar(
                      content: Text(message ?? 'Unable to reset password')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
