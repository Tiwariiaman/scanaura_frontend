import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          .read(dashboardNotifierProvider.notifier)
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
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(
        context,
        state,
      ),
    );
  }

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
      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 1100,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildWelcome(context),

                const SizedBox(height: 20),

                _buildOverviewCards(
                  context,
                  state,
                ),

                const SizedBox(height: 20),

                _buildSubscriptionCard(
                  context,
                  state.subscription,
                ),

                const SizedBox(height: 20),

                _buildQuickActions(context),

                const SizedBox(height: 20),

                _buildAiUsageCard(
                  context,
                  state,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Business Overview',
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
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

  Widget _buildOverviewCards(
      BuildContext context,
      DashboardState state,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth;

        final crossAxisCount =
        width >= 900
            ? 4
            : width >= 600
            ? 2
            : 2;

        return GridView.count(
          crossAxisCount:
          crossAxisCount,
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio:
          width >= 600
              ? 1.8
              : 1.45,
          children: [
            _StatCard(
              icon:
              Icons.restaurant_menu_outlined,
              title: 'Menu Items',
              value:
              '${state.menuItemCount}',
            ),
            _StatCard(
              icon:
              Icons.category_outlined,
              title: 'Categories',
              value:
              '${state.categoryCount}',
            ),
            _StatCard(
              icon: Icons.qr_code_2_outlined,
              title: 'QR Codes',
              value:
              '${state.qrCount}',
            ),
            _StatCard(
              icon: Icons.auto_awesome,
              title: 'AI Imports',
              value:
              '${state.aiImportUsed} / ${state.aiImportLimit}',
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context,
      SubscriptionResponse? subscription,
      ) {
    final theme = Theme.of(context);

    if (subscription == null) {
      return Card(
        child: Padding(
          padding:
          const EdgeInsets.all(20),
          child: Column(
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
              const SizedBox(height: 8),
              const Text(
                'Subscription information is unavailable.',
              ),
            ],
          ),
        ),
      );
    }

    final statusLabel =
    subscription.status.name
        .toUpperCase();

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
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
                      const SizedBox(height: 6),
                      Text(
                        subscription.planName,
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
                  ),
                ),

                _StatusChip(
                  label: statusLabel,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _InfoRow(
                  icon:
                  Icons.calendar_today_outlined,
                  text:
                  'Ends ${_formatDate(subscription.endDate)}',
                ),
                _InfoRow(
                  icon:
                  Icons.autorenew_outlined,
                  text:
                  subscription.billingCycle.name
                      .toUpperCase(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push(
                    '/subscription',
                  );
                },
                child: const Text(
                  'Manage Subscription',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            LayoutBuilder(
              builder:
                  (context, constraints) {
                final isWide =
                    constraints.maxWidth >=
                        650;

                final children = [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.menu_book_outlined,
                      label: 'Manage Menu',
                      onPressed: () {
                        context.push(
                          '/menu',
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.qr_code_2_outlined,
                      label: 'Manage QR',
                      onPressed: () {
                        context.push(
                          '/qr',
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.auto_awesome,
                      label: 'AI Import',
                      onPressed: () {
                        context.push(
                          '/ai-import',
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon:
                      Icons.storefront_outlined,
                      label: 'Business',
                      onPressed: () {
                        context.push(
                          '/business',
                        );
                      },
                    ),
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: [
                      for (int i = 0;
                      i < children.length;
                      i++) ...[
                        if (i > 0)
                          const SizedBox(
                            width: 10,
                          ),
                        children[i],
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        children[0],
                        const SizedBox(
                          width: 10,
                        ),
                        children[1],
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        children[2],
                        const SizedBox(
                          width: 10,
                        ),
                        children[3],
                      ],
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

  Widget _buildAiUsageCard(
      BuildContext context,
      DashboardState state,
      ) {
    final theme = Theme.of(context);

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
          CrossAxisAlignment.start,
          children: [
            Row(
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
            ),

            const SizedBox(height: 14),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 10),

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

  Widget _buildError(
      BuildContext context,
      DashboardState state,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ??
                  'Unable to load dashboard.',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(
                  dashboardNotifierProvider
                      .notifier,
                )
                    .loadDashboard();
              },
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatCard extends StatelessWidget {
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
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

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
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
        child: Text(label),
      ),
    );
  }
}

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
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
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
          color: Theme.of(context)
              .colorScheme
              .onSecondaryContainer,
        ),
      ),
    );
  }
}

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
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}