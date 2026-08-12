import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref
        .read(authNotifierProvider.notifier)
        .login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    final authState = ref.read(authNotifierProvider);

    if (authState.status == AuthStatus.authenticated) {
      context.go('/dashboard');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
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
                maxWidth: 440,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildBranding(context),

                    const SizedBox(height: 40),

                    Text(
                      'Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to manage your ScanAura business.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 32),

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

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      textInputAction:
                      TextInputAction.done,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) {
                        if (!isLoading) {
                          _login();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
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
                                ? Icons
                                .visibility_outlined
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
                        isLoading ? null : _login,
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
                          'Sign In',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                            context.go(
                              '/register',
                            );
                          },
                          child: const Text(
                            'Create account',
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

  Widget _buildBranding(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius:
            BorderRadius.circular(20),
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