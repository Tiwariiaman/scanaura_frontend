import 'package:flutter/material.dart';

class LoyaltyVerificationResultPage extends StatelessWidget {
  final bool success;
  final String title;
  final String message;
  final String? customerName;
  final int? points;

  const LoyaltyVerificationResultPage({
    super.key,
    required this.success,
    required this.title,
    required this.message,
    this.customerName,
    this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final resultColor = success
        ? colorScheme.primary
        : colorScheme.error;

    final resultBackground = success
        ? colorScheme.primaryContainer
        : colorScheme.errorContainer;

    final resultForeground = success
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loyalty Verification',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            28,
          ),
          child: Column(
            children: [
              const Spacer(),

              // --------------------------------------------------
              // RESULT ICON
              // --------------------------------------------------

              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: resultBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  size: 54,
                  color: resultForeground,
                ),
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // TITLE
              // --------------------------------------------------

              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              // --------------------------------------------------
              // MESSAGE
              // --------------------------------------------------

              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              // --------------------------------------------------
              // CUSTOMER
              // --------------------------------------------------

              if (customerName != null &&
                  customerName!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              customerName!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // --------------------------------------------------
              // POINTS
              // --------------------------------------------------

              if (success && points != null) ...[
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 28,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '+$points points awarded',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color:
                            colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // --------------------------------------------------
              // DONE BUTTON
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    success ? 'Done' : 'Scan Again',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}