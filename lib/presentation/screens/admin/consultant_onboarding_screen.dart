import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_theme.dart';
import '../../../services/admin_service.dart';

class ConsultantOnboardingScreen extends ConsumerStatefulWidget {
  const ConsultantOnboardingScreen({super.key});

  @override
  ConsumerState<ConsultantOnboardingScreen> createState() =>
      _ConsultantOnboardingScreenState();
}

class _ConsultantOnboardingScreenState
    extends ConsumerState<ConsultantOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In production, create consultant via API
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultant created successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboard Consultant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.star),
                  hintText: 'e.g., Vedic Astrology, Numerology',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter specialization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Experience (years)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter hourly rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Consultant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

