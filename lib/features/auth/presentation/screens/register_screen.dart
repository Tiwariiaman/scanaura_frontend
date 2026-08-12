import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      mobile: _mobileController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please sign in.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/login');
    }
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required';
    }

    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (name.length > 100) {
      return 'Name cannot exceed 100 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Mobile number is required';
    }

    final mobileRegex = RegExp(r'^[6-9]\d{9}$');

    if (!mobileRegex.hasMatch(mobile)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 20) {
      return 'Password cannot exceed 20 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    ref.listen<AuthState>(
      authNotifierProvider,
          (previous, next) {
        if (next.status == AuthStatus.error &&
            next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),

                    const SizedBox(height: 36),

                    Text(
                      'Create your account',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Start managing your restaurant with ScanAura.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _fullNameController,
                      textCapitalization:
                      TextCapitalization.words,
                      textInputAction:
                      TextInputAction.next,
                      enabled: !isLoading,
                      validator: _validateFullName,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        hintText: 'Your full name',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                      enabled: !isLoading,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      textInputAction:
                      TextInputAction.next,
                      maxLength: 10,
                      enabled: !isLoading,
                      validator: _validateMobile,
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        hintText: '10-digit mobile number',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction:
                      TextInputAction.next,
                      enabled: !isLoading,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '8–20 characters',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                            setState(() {
                              _obscurePassword =
                              !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller:
                      _confirmPasswordController,
                      obscureText:
                      _obscureConfirmPassword,
                      textInputAction:
                      TextInputAction.done,
                      enabled: !isLoading,
                      validator:
                      _validateConfirmPassword,
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          _register();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(
                          Icons.lock_reset_outlined,
                        ),
                        suffixIcon: IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                        isLoading ? null : _register,
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Create Account',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Sign in',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            size: 34,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'ScanAura',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}