import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/phone_auth_service.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  int _resendCooldown = 0;
  bool _isSignUp = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _resendCooldown--);
        return _resendCooldown > 0;
      }
      return false;
    });
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final formattedPhone = PhoneAuthService.formatPhoneNumber(
      _phoneController.text.trim(),
    );

    try {
      await ref.read(authProvider.notifier).sendPhoneOTP(formattedPhone);
      if (mounted) {
        setState(() => _otpSent = true);
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent! Check your phone.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e')),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final formattedPhone = PhoneAuthService.formatPhoneNumber(
      _phoneController.text.trim(),
    );

    try {
      await ref.read(authProvider.notifier).verifyPhoneOTP(
            formattedPhone,
            _otpController.text.trim(),
          );
      if (mounted && ref.read(authProvider).isAuthenticated) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verification failed: $e')),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0) return;

    final formattedPhone = PhoneAuthService.formatPhoneNumber(
      _phoneController.text.trim(),
    );

    try {
      await ref.read(authProvider.notifier).sendPhoneOTP(formattedPhone);
      if (mounted) {
        _startResendCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: $e')),
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
        title: const Text('Phone Verification'),
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
                          Icons.phone_android_rounded,
                          size: 64,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _otpSent ? 'Verify OTP' : 'Enter Phone Number',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _otpSent
                              ? 'Enter the 6-digit code sent to your phone'
                              : 'We\'ll send you a verification code',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (!_otpSent)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_rounded),
                              hintText: '+91 9876543210',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your phone number';
                              }
                              final formatted =
                                  PhoneAuthService.formatPhoneNumber(value!);
                              if (!PhoneAuthService.formatPhoneNumber(formatted)
                                  .startsWith('+')) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          )
                        else ...[
                          Text(
                            'Phone: ${PhoneAuthService.formatPhoneNumber(_phoneController.text.trim())}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Enter OTP',
                              hintText: '123456',
                              prefixIcon: Icon(Icons.pin_rounded),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter the OTP';
                              }
                              if (value!.length != 6) {
                                return 'OTP must be 6 digits';
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
                                : (_otpSent ? _verifyOTP : _sendOTP),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
                          ),
                        ),
                        if (_otpSent) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Didn\'t receive code? '),
                              TextButton(
                                onPressed: _resendCooldown > 0
                                    ? null
                                    : _resendOTP,
                                child: Text(
                                  _resendCooldown > 0
                                      ? 'Resend in $_resendCooldown s'
                                      : 'Resend OTP',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                            child: const Text('Change phone number'),
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

