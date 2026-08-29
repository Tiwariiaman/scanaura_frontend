import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScanAuraNotFoundScreen extends StatelessWidget {
  const ScanAuraNotFoundScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ScanAura icon
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 46,
                        color: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      '404',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Page not found',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'The ScanAura page you are looking for does not exist or may have moved.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Main action
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.go('/landing');
                        },
                        icon: const Icon(
                          Icons.home_outlined,
                        ),
                        label: const Text(
                          'Go to ScanAura',
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Secondary action
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                        label: const Text(
                          'Go Back',
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      'ScanAura',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
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
}