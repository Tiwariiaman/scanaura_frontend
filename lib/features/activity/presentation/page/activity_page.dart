import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // HEADER
              // =====================================================

              Text(
                'Engage your customers',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Create simple experiences that bring customers back.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 26),

              // =====================================================
              // LOYALTY
              // =====================================================

              _ActivityCard(
                icon: Icons.loyalty_rounded,
                title: 'Customer Loyalty',
                subtitle: 'Reward customers for returning visits.',
                description:
                'Give customers loyalty points on visits and let them redeem rewards you define.',
                iconBackground: colorScheme.primaryContainer,
                iconColor: colorScheme.primary,
                actionLabel: 'Manage Loyalty',
                onTap: () {
                  context.push('/activity/loyalty');
                },
              ),

              const SizedBox(height: 16),

              // =====================================================
              // OFFERS
              // =====================================================

              _ActivityCard(
                icon: Icons.local_offer_rounded,
                title: 'Offers',
                subtitle: 'Create offers customers can discover.',
                description:
                'Promote special offers and give customers another reason to visit your business.',
                iconBackground:
                colorScheme.secondaryContainer,
                iconColor: colorScheme.secondary,
                actionLabel: 'Coming Soon',
                onTap: null,
                disabled: true,
              ),

              const SizedBox(height: 16),

              // =====================================================
              // ORDER / FUTURE ACTIVITY
              // =====================================================

              _ActivityCard(
                icon: Icons.shopping_bag_rounded,
                title: 'Orders',
                subtitle: 'Make ordering easier for customers.',
                description:
                'Future ordering features will appear here when enabled for your business.',
                iconBackground:
                colorScheme.tertiaryContainer,
                iconColor: colorScheme.tertiary,
                actionLabel: 'Coming Soon',
                onTap: null,
                disabled: true,
              ),

              const SizedBox(height: 16),

              // =====================================================
              // MORE ACTIVITIES
              // =====================================================

              _ActivityCard(
                icon: Icons.auto_awesome_rounded,
                title: 'More Activities',
                subtitle: 'More customer experiences are coming.',
                description:
                'ScanAura activities will grow over time so you can choose what works best for your business.',
                iconBackground:
                colorScheme.surfaceContainerHighest,
                iconColor: colorScheme.onSurfaceVariant,
                actionLabel: 'Coming Soon',
                onTap: null,
                disabled: true,
              ),

              const SizedBox(height: 24),

              // =====================================================
              // OWNER NOTE
              // =====================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 21,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You control which activities are enabled for your business and define the offers or rewards customers can receive.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// ACTIVITY CARD
// ===============================================================

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color iconBackground;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback? onTap;
  final bool disabled;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconBackground,
    required this.iconColor,
    required this.actionLabel,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: iconColor,
                    ),
                  ),

                  const Spacer(),

                  if (!disabled)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 17),

              if (disabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    actionLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Text(
                  actionLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}