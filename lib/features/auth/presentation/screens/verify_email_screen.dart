import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState
    extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  int _secondsRemaining = 0;

  bool _resending = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    if (_secondsRemaining > 0 ||
        _resending) {
      return;
    }

    setState(() {
      _resending = true;
    });

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resendVerificationEmail(
      email: widget.email,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _resending = false;
    });

    if (success) {
      _startCooldown();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Check your inbox.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final authState =
    ref.read(authNotifierProvider);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          authState.errorMessage ??
              'Unable to resend verification email.',
        ),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  void _startCooldown() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  String _maskedEmail() {
    final email =
    widget.email.trim();

    final parts =
    email.split('@');

    if (parts.length != 2) {
      return email;
    }

    final name =
        parts.first;

    final domain =
        parts.last;

    if (name.length <= 2) {
      return '${name[0]}***@$domain';
    }

    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final authState =
    ref.watch(authNotifierProvider);

    final isLoading =
        authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  _buildLogo(context),

                  const SizedBox(
                    height: 28,
                  ),

                  Text(
                    'Verify your email',
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
                    'We sent a verification link to',
                    textAlign:
                    TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    _maskedEmail(),
                    textAlign:
                    TextAlign.center,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  _buildInfoCard(context),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child:
                    FilledButton.icon(
                      onPressed:
                      isLoading ||
                          _resending ||
                          _secondsRemaining >
                              0
                          ? null
                          : _resendVerification,
                      icon: _resending
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                        ),
                      )
                          : const Icon(
                        Icons
                            .mail_outline_rounded,
                      ),
                      label: Text(
                        _resending
                            ? 'Sending...'
                            : _secondsRemaining >
                            0
                            ? 'Resend in ${_secondsRemaining}s'
                            : 'Resend Verification Email',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child:
                    OutlinedButton(
                      onPressed:
                      isLoading ||
                          _resending
                          ? null
                          : () {
                        context
                            .go(
                          '/login',
                        );
                      },
                      child:
                      const Text(
                        'Continue to Login',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextButton(
                    onPressed:
                    isLoading ||
                        _resending
                        ? null
                        : () {
                      context.go(
                        '/register',
                      );
                    },
                    child:
                    const Text(
                      'Use a different email',
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

  Widget _buildLogo(
      BuildContext context,
      ) {
    return Image.asset(
      'assets/images/scanaura_logo.png',
      width: 76,
      height: 76,
      fit: BoxFit.contain,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return const SizedBox(
          width: 76,
          height: 76,
          child: Icon(
            Icons.email_outlined,
            size: 46,
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(20),
      decoration:
      BoxDecoration(
        color:
        colorScheme.surface,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: colorScheme
              .outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(
              alpha: 0.08,
            ),
            blurRadius: 22,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color:
            colorScheme.primary,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            'Check your inbox',
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Open the email from ScanAura and click the verification link to activate your account.',
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

          const SizedBox(
            height: 8,
          ),

          Text(
            'Check your spam or promotions folder if you cannot find it.',
            textAlign:
            TextAlign.center,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}