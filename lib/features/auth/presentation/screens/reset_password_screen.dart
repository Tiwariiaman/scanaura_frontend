import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
// import '../providers/auth_state.dart';

class ResetPasswordScreen
    extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.token,
  });

  final String token;

  @override
  ConsumerState<ResetPasswordScreen>
  createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _passwordController =
  TextEditingController();

  final _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(
      authNotifierProvider.notifier,
    )
        .resetPassword(
      token: widget.token,
      newPassword:
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _success = true;
      });

      return;
    }

    final authState =
    ref.read(
      authNotifierProvider,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            authState.errorMessage ??
                'Unable to reset your password.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  String? _validatePassword(
      String? value,
      ) {
    final password =
        value ?? '';

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

  String? _validateConfirmPassword(
      String? value,
      ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value !=
        _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_success) {
      return _buildSuccess(
        context,
      );
    }

    final authState =
    ref.watch(
      authNotifierProvider,
    );

    final isLoading =
        authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              24,
            ),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 440,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
                  children: [
                    _buildBranding(
                      context,
                    ),

                    const SizedBox(
                      height: 36,
                    ),

                    Text(
                      'Create a new password',
                      textAlign:
                      TextAlign.center,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Choose a new password for your ScanAura account.',
                      textAlign:
                      TextAlign.center,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    TextFormField(
                      controller:
                      _passwordController,
                      obscureText:
                      _obscurePassword,
                      enabled:
                      !isLoading,
                      textInputAction:
                      TextInputAction.next,
                      validator:
                      _validatePassword,
                      decoration:
                      InputDecoration(
                        labelText:
                        'New password',
                        hintText:
                        '8–20 characters',
                        prefixIcon:
                        const Icon(
                          Icons
                              .lock_outline_rounded,
                        ),
                        suffixIcon:
                        IconButton(
                          tooltip:
                          _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed:
                          isLoading
                              ? null
                              : () {
                            setState(
                                  () {
                                _obscurePassword =
                                !_obscurePassword;
                              },
                            );
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

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                      _confirmPasswordController,
                      obscureText:
                      _obscureConfirmPassword,
                      enabled:
                      !isLoading,
                      textInputAction:
                      TextInputAction.done,
                      validator:
                      _validateConfirmPassword,
                      onFieldSubmitted:
                          (_) {
                        if (!isLoading) {
                          _resetPassword();
                        }
                      },
                      decoration:
                      InputDecoration(
                        labelText:
                        'Confirm password',
                        prefixIcon:
                        const Icon(
                          Icons
                              .lock_reset_outlined,
                        ),
                        suffixIcon:
                        IconButton(
                          tooltip:
                          _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed:
                          isLoading
                              ? null
                              : () {
                            setState(
                                  () {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              },
                            );
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                .visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    SizedBox(
                      height: 52,
                      child:
                      FilledButton(
                        onPressed:
                        isLoading
                            ? null
                            : _resetPassword,
                        child:
                        isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                          ),
                        )
                            : const Text(
                          'Reset Password',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      height: 52,
                      child:
                      OutlinedButton(
                        onPressed:
                        isLoading
                            ? null
                            : () {
                          context.go(
                            '/login',
                          );
                        },
                        child:
                        const Text(
                          'Back to Login',
                        ),
                      ),
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

  Widget _buildSuccess(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child:
          SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              24,
            ),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  _buildBranding(
                    context,
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                    BoxDecoration(
                      color: colorScheme
                          .primaryContainer,
                      shape:
                      BoxShape.circle,
                    ),
                    alignment:
                    Alignment.center,
                    child: Icon(
                      Icons
                          .check_rounded,
                      size: 42,
                      color: colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Text(
                    'Password updated',
                    textAlign:
                    TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Your ScanAura password has been changed successfully.',
                    textAlign:
                    TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child:
                    FilledButton(
                      onPressed:
                          () {
                        context.go(
                          '/login',
                        );
                      },
                      child:
                      const Text(
                        'Continue to Login',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(
      BuildContext context,
      ) {
    return Column(
      children: [
        Image.asset(
          'assets/images/scanaura_logo.png',
          width: 68,
          height: 68,
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const SizedBox(
              width: 68,
              height: 68,
              child: Icon(
                Icons
                    .lock_reset_rounded,
                size: 42,
              ),
            );
          },
        ),

        const SizedBox(
          height: 12,
        ),

        Text(
          'ScanAura',
          style: Theme.of(
            context,
          )
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }
}