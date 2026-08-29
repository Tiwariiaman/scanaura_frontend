import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _emailController =
  TextEditingController();

  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(
      authNotifierProvider
          .notifier,
    )
        .forgotPassword(
      email:
      _emailController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        _submitted = true;
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
                'Unable to send reset instructions.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  String? _validateEmail(
      String? value,
      ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(
      email,
    )) {
      return 'Enter a valid email address';
    }

    return null;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final authState =
    ref.watch(
      authNotifierProvider,
    );

    final isLoading =
        authState.isLoading;

    if (_submitted) {
      return _buildSuccess(
        context,
      );
    }

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
                      'Forgot your password?',
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
                      'Enter your email and we’ll send you a secure password reset link.',
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
                      _emailController,
                      keyboardType:
                      TextInputType
                          .emailAddress,
                      textInputAction:
                      TextInputAction.done,
                      enabled:
                      !isLoading,
                      validator:
                      _validateEmail,
                      onFieldSubmitted:
                          (_) {
                        if (!isLoading) {
                          _submit();
                        }
                      },
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Email',
                        hintText:
                        'you@example.com',
                        prefixIcon:
                        Icon(
                          Icons
                              .email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    SizedBox(
                      height: 52,
                      child:
                      FilledButton(
                        onPressed:
                        isLoading
                            ? null
                            : _submit,
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
                          'Send Reset Link',
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
                          context
                              .go(
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

    final email =
    _emailController.text
        .trim();

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
                          .mark_email_read_outlined,
                      size: 38,
                      color:
                      colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Text(
                    'Check your email',
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
                    'If an account exists for this email, we sent password reset instructions to:',
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
                    height: 8,
                  ),

                  Text(
                    email,
                    textAlign:
                    TextAlign.center,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Container(
                    width:
                    double.infinity,
                    padding:
                    const EdgeInsets
                        .all(18),
                    decoration:
                    BoxDecoration(
                      color: colorScheme
                          .surface,
                      borderRadius:
                      BorderRadius
                          .circular(
                        18,
                      ),
                      border:
                      Border.all(
                        color: colorScheme
                            .outlineVariant,
                      ),
                    ),
                    child: Text(
                      'The reset link expires in 30 minutes and can only be used once.',
                      textAlign:
                      TextAlign.center,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                        height: 1.4,
                      ),
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
                      onPressed: () {
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

                  const SizedBox(
                    height: 10,
                  ),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _submitted =
                        false;
                      });
                    },
                    child:
                    const Text(
                      'Try another email',
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
                    .alternate_email_rounded,
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