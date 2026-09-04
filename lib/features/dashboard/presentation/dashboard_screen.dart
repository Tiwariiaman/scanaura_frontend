import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../subscription/data/models/subscription_response.dart';
import 'providers/dashboard_notifier.dart';
import 'providers/dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        dashboardNotifierProvider.notifier,
      )
          .loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(dashboardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
              ref
                  .read(
                dashboardNotifierProvider
                    .notifier,
              )
                  .refreshDashboard();
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(
        context,
        state,
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      DashboardState state,
      ) {
    if (state.status ==
        DashboardStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status ==
        DashboardStatus.error &&
        state.subscription == null &&
        state.menuItemCount == 0 &&
        state.categoryCount == 0 &&
        state.qrCount == 0) {
      return _buildError(
        context,
        state,
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(
          dashboardNotifierProvider
              .notifier,
        )
            .refreshDashboard();
      },
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          return SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
                  children: [
                    _buildWelcome(
                      context,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildOverviewCards(
                      context,
                      state,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildSubscriptionCard(
                      context,
                      state.subscription,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildQuickActions(
                      context,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildAiUsageCard(
                      context,
                      state,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Business Overview',
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          'Here is a quick look at your ScanAura business.',
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW CARDS
  // ============================================================

  Widget _buildOverviewCards(
      BuildContext context,
      DashboardState state,
      ) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final width =
            constraints.maxWidth;

        int crossAxisCount;
        double aspectRatio;

        if (width >= 1000) {
          crossAxisCount = 4;
          aspectRatio = 1.75;
        } else if (width >= 700) {
          crossAxisCount = 2;
          aspectRatio = 2.05;
        } else {
          crossAxisCount = 2;
          aspectRatio = 1.55;
        }

        return GridView.count(
          crossAxisCount:
          crossAxisCount,
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio:
          aspectRatio,
          children: [
            _StatCard(
              icon: Icons
                  .restaurant_menu_outlined,
              title: 'Menu Items',
              value:
              '${state.menuItemCount}',
            ),
            _StatCard(
              icon: Icons
                  .category_outlined,
              title: 'Categories',
              value:
              '${state.categoryCount}',
            ),
            _StatCard(
              icon: Icons
                  .qr_code_2_outlined,
              title: 'QR Codes',
              value:
              '${state.qrCount}',
            ),
            _StatCard(
              icon:
              Icons.auto_awesome,
              title: 'AI Imports',
              value:
              '${state.aiImportUsed} / ${state.aiImportLimit}',
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUBSCRIPTION
  // ============================================================

  Widget _buildSubscriptionCard(
      BuildContext context,
      SubscriptionResponse?
      subscription,
      ) {
    final theme = Theme.of(context);

    if (subscription == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Subscription information is unavailable.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isExpired =
        subscription.status == SubscriptionStatus.expired;

    final statusLabel =
    subscription.status.name.toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isExpired) ...[
              _buildExpiredSubscriptionWarning(
                context,
                subscription,
              ),
              const SizedBox(height: 18),
            ],

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final compact =
                    constraints.maxWidth < 420;

                if (compact) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _subscriptionTitle(
                        context,
                        subscription,
                      ),
                      const SizedBox(height: 12),
                      _StatusChip(
                        label: statusLabel,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _subscriptionTitle(
                        context,
                        subscription,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusChip(
                      label: statusLabel,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text:
                  'Ends ${_formatDate(subscription.endDate)}',
                ),
                _InfoRow(
                  icon: Icons.autorenew_outlined,
                  text: subscription.billingCycle.name
                      .toUpperCase(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/subscription');
                },
                child: Text(
                  isExpired
                      ? 'Renew Subscription'
                      : 'Manage Subscription',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredSubscriptionWarning(
      BuildContext context,
      SubscriptionResponse subscription,
      ) {
    final theme = Theme.of(context);

    final planName = subscription.planName.trim();

    final isTrial = subscription.status ==
        SubscriptionStatus.expired &&
        planName.toLowerCase() == 'trial';

    final title = isTrial
        ? 'Your Trial Has Expired'
        : 'Your $planName Plan Has Expired';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.error,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Your ScanAura account is currently inactive. '
                'Renew your plan to make your QR page available again.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/subscription');
                  },
                  child: const Text('Renew Plan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openSupportWhatsApp,
                  child: const Text('Contact Us'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openSupportWhatsApp() async {
    const supportNumber = '917056222557';

    final uri = Uri.parse(
      'https://wa.me/$supportNumber?text=${Uri.encodeComponent(
        'Hello ScanAura Support, my subscription has expired and I need help renewing my plan.',
      )}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget _subscriptionTitle(
      BuildContext context,
      SubscriptionResponse
      subscription,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription',
          style: TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          subscription.planName,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 24,
            fontWeight:
            FontWeight.w800,
            color: theme
                .colorScheme
                .primary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            LayoutBuilder(
              builder:
                  (context, constraints) {
                final width =
                    constraints.maxWidth;

                if (width >= 850) {
                  return Row(
                    children: [
                      Expanded(
                        child:
                        _ActionButton(
                          icon: Icons
                              .menu_book_outlined,
                          label:
                          'Manage Menu',
                          onPressed: () {
                            context.push(
                              '/menu',
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child:
                        _ActionButton(
                          icon: Icons
                              .qr_code_2_outlined,
                          label:
                          'Manage QR',
                          onPressed: () {
                            context.push(
                              '/qr',
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child:
                        _ActionButton(
                          icon: Icons
                              .auto_awesome,
                          label: 'AI Import',
                          onPressed: () {
                            context.push(
                              '/ai-import',
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child:
                        _ActionButton(
                          icon: Icons
                              .storefront_outlined,
                          label: 'Business',
                          onPressed: () {
                            context.push(
                              '/business',
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (width >= 520) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child:
                            _ActionButton(
                              icon: Icons
                                  .menu_book_outlined,
                              label:
                              'Manage Menu',
                              onPressed: () {
                                context.push(
                                  '/menu',
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                            _ActionButton(
                              icon: Icons
                                  .qr_code_2_outlined,
                              label:
                              'Manage QR',
                              onPressed: () {
                                context.push(
                                  '/qr',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child:
                            _ActionButton(
                              icon: Icons
                                  .auto_awesome,
                              label:
                              'AI Import',
                              onPressed: () {
                                context.push(
                                  '/ai-import',
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                            _ActionButton(
                              icon: Icons
                                  .storefront_outlined,
                              label:
                              'Business',
                              onPressed: () {
                                context.push(
                                  '/business',
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      _ActionButton(
                        icon: Icons
                            .menu_book_outlined,
                        label:
                        'Manage Menu',
                        onPressed: () {
                          context.push(
                            '/menu',
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      _ActionButton(
                        icon: Icons
                            .qr_code_2_outlined,
                        label: 'Manage QR',
                        onPressed: () {
                          context.push(
                            '/qr',
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      _ActionButton(
                        icon: Icons
                            .auto_awesome,
                        label: 'AI Import',
                        onPressed: () {
                          context.push(
                            '/ai-import',
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width:
                      double.infinity,
                      child:
                      _ActionButton(
                        icon: Icons
                            .storefront_outlined,
                        label: 'Business',
                        onPressed: () {
                          context.push(
                            '/business',
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AI USAGE
  // ============================================================

  Widget _buildAiUsageCard(
      BuildContext context,
      DashboardState state,
      ) {
    final theme =
    Theme.of(context);

    final limit =
        state.aiImportLimit;

    final used =
        state.aiImportUsed;

    final progress =
    limit <= 0
        ? 0.0
        : (used / limit)
        .clamp(0.0, 1.0);

    final remaining =
        state.aiImportsRemaining;

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final compact =
                    constraints.maxWidth <
                        420;

                if (compact) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons
                                .auto_awesome,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Expanded(
                            child: Text(
                              'AI Import Usage',
                              style:
                              TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '$remaining remaining',
                        style: TextStyle(
                          color: theme
                              .colorScheme
                              .primary,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Text(
                        'AI Import Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$remaining remaining',
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .primary,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(
              height: 14,
            ),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              child:
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              limit <= 0
                  ? 'No AI import limit available.'
                  : '$used of $limit AI imports used.',
              style: TextStyle(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      DashboardState state,
      ) {
    final theme =
    Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding:
        const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 420,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme
                    .colorScheme
                    .error,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                state.errorMessage ??
                    'Unable to load dashboard.',
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 16,
              ),

              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(
                    dashboardNotifierProvider
                        .notifier,
                  )
                      .loadDashboard();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label:
                const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard
    extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color: theme
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton
    extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(
      BuildContext context,
      ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow:
          TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================

class _StatusChip
    extends StatelessWidget {
  const _StatusChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme
            .secondaryContainer,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w700,
          color: colorScheme
              .onSecondaryContainer,
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
        ),

        const SizedBox(
          width: 6,
        ),

        Flexible(
          child: Text(
            text,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}