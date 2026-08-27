import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_providers.dart';

class EmailVerificationPage
    extends ConsumerStatefulWidget {
  const EmailVerificationPage({
    super.key,
    required this.token,
  });

  final String token;

  @override
  ConsumerState<EmailVerificationPage>
  createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState
    extends ConsumerState<
        EmailVerificationPage> {
  bool _loading = true;
  bool _success = false;
  String? _message;

  @override
  void initState() {
    super.initState();

    Future.microtask(
      _verifyEmail,
    );
  }

  Future<void> _verifyEmail() async {
    try {
      final client =
      ref.read(
        apiClientProvider,
      );

      final response =
      await client.get<
          Map<String, dynamic>>(
        '/api/v1/auth/verify-email',
        queryParameters: {
          'token': widget.token,
        },
      );

      final data =
          response.data;

      if (data == null) {
        throw Exception(
          'Empty response from server.',
        );
      }

      setState(() {
        _success = true;
        _message =
            data['message']?.toString() ??
                'Email verified successfully.';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _success = false;
        _message =
            e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _loading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/scanaura_logo.png',
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Container(
                    width: 72,
                    height: 72,
                    decoration:
                    BoxDecoration(
                      color: _success
                          ? colorScheme
                          .primaryContainer
                          : colorScheme
                          .errorContainer,
                      shape:
                      BoxShape.circle,
                    ),
                    alignment:
                    Alignment.center,
                    child: Icon(
                      _success
                          ? Icons
                          .check_rounded
                          : Icons
                          .error_outline_rounded,
                      color: _success
                          ? colorScheme
                          .primary
                          : colorScheme
                          .error,
                      size: 40,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Text(
                    _success
                        ? 'Email verified'
                        : 'Verification failed',
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
                    _message ??
                        (_success
                            ? 'Your ScanAura account is ready.'
                            : 'This verification link is invalid or has expired.'),
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
                    height: 26,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          () {
                        context.go(
                          '/login',
                        );
                      },
                      child:
                      Text(
                        _success
                            ? 'Continue to Login'
                            : 'Back to Login',
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
}