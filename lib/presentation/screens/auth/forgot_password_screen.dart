import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  bool _otpSent = false;
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).forgotPassword(
            _emailOrPhoneController.text.trim(),
          );
      if (mounted) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset code sent! Check your email/phone.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset code: $e')),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).resetPassword(
            emailOrPhone: _emailOrPhoneController.text.trim(),
            code: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully!')),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryNavy,
              AppTheme.primaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.lock_reset_rounded,
                          size: 64,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reset Password',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _otpSent
                              ? 'Enter the reset code and new password'
                              : 'Enter your email or phone number',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailOrPhoneController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_otpSent,
                          decoration: const InputDecoration(
                            labelText: 'Email or Phone Number',
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email or phone';
                            }
                            return null;
                          },
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reset Code',
                              prefixIcon: Icon(Icons.pin_rounded),
                              hintText: 'Enter 6-digit code',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter the reset code';
                              }
                              if (value!.length != 6) {
                                return 'Code must be 6 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter a new password';
                              }
                              if (value!.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please confirm your password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : (_otpSent ? _resetPassword : _sendOTP),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_otpSent ? 'Reset Password' : 'Send Reset Code'),
                          ),
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() => _otpSent = false);
                            },
                            child: const Text('Change email/phone'),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

