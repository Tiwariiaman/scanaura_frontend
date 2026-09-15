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
          .read(dashboardNotifierProvider.notifier)
          .loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
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
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(
        context,
        state,
        theme,
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      DashboardState state,
      ThemeData theme,
      ) {
    if (state.status == DashboardStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == DashboardStatus.error) {
      return _buildError(
        context,
        state,
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(
          dashboardNotifierProvider.notifier,
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
          40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 1250,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildBusinessHeader(
                  context,
                  state,
                ),

                const SizedBox(height: 20),

                _buildScanOverview(
                  context,
                  state,
                ),

                const SizedBox(height: 20),

                _buildMainStats(
                  context,
                  state,
                ),

                const SizedBox(height: 20),

                _buildTwoColumnSection(
                  context,
                  state,
                ),

                const SizedBox(height: 20),

                _buildQuickActions(
                  context,
                ),

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

  // ============================================================
  // BUSINESS HEADER
  // ============================================================

  Widget _buildBusinessHeader(
      BuildContext context,
      DashboardState state,
      ) {
    final theme = Theme.of(context);
    final business = state.businessDashboard;

    final businessName =
    business?.businessName.trim();

    final displayName =
    businessName == null ||
        businessName.isEmpty
        ? 'Your Business'
        : businessName;

    final isActive =
        business?.active ?? true;

    final city = '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),
        color: theme
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.55),
        border: Border.all(
          color: theme
              .colorScheme
              .primary
              .withValues(alpha: 0.12),
        ),
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final compact =
              constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildBusinessIdentity(
                  context,
                  displayName,
                  city,
                ),
                const SizedBox(height: 18),
                _buildBusinessStatus(
                  context,
                  isActive,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _buildBusinessIdentity(
                  context,
                  displayName,
                  city,
                ),
              ),
              const SizedBox(width: 20),
              _buildBusinessStatus(
                context,
                isActive,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusinessIdentity(
      BuildContext context,
      String businessName,
      String city,
      ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color:
            theme.colorScheme.surface,
            borderRadius:
            BorderRadius.circular(17),
          ),
          child: Icon(
            Icons.storefront_rounded,
            size: 29,
            color:
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                businessName,
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
              if (city.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  city,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessStatus(
      BuildContext context,
      bool active,
      ) {
    final theme = Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: active
            ? theme
            .colorScheme
            .secondaryContainer
            : theme
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? theme
                  .colorScheme
                  .primary
                  : theme
                  .colorScheme
                  .error,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            active
                ? 'Business Active'
                : 'Business Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              color: active
                  ? theme
                  .colorScheme
                  .onSecondaryContainer
                  : theme
                  .colorScheme
                  .onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCAN OVERVIEW
  // ============================================================

  Widget _buildScanOverview(
      BuildContext context,
      DashboardState state,
      ) {
    final theme = Theme.of(context);
    final business =
        state.businessDashboard;

    final today =
        business?.todayScans ?? 0;
    final yesterday =
        business?.yesterdayScans ?? 0;
    final last7 =
        business?.last7DaysScans ?? 0;
    final total =
        business?.totalScans ?? 0;

    final difference =
        today - yesterday;

    final increase =
        difference > 0;

    final decrease =
        difference < 0;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                  BoxDecoration(
                    color: theme
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                  child: Icon(
                    Icons
                        .qr_code_scanner_rounded,
                    color: theme
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Scan Overview',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customer activity through your QR',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final width =
                    constraints.maxWidth;

                final columns =
                width >= 900
                    ? 4
                    : width >= 560
                    ? 2
                    : 1;

                final children = [
                  _ScanMetric(
                    label: 'Today',
                    value: today,
                    icon:
                    Icons.today_outlined,
                  ),
                  _ScanMetric(
                    label: 'Yesterday',
                    value: yesterday,
                    icon: Icons
                        .history_outlined,
                  ),
                  _ScanMetric(
                    label: 'Last 7 Days',
                    value: last7,
                    icon: Icons
                        .date_range_outlined,
                  ),
                  _ScanMetric(
                    label: 'Total',
                    value: total,
                    icon: Icons
                        .bar_chart_rounded,
                  ),
                ];

                if (columns == 1) {
                  return Column(
                    children:
                    children
                        .map(
                          (child) => Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          bottom: 10,
                        ),
                        child: child,
                      ),
                    )
                        .toList(),
                  );
                }

                return GridView.count(
                  crossAxisCount:
                  columns,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                  width >= 900
                      ? 2.1
                      : 2.6,
                  children: children,
                );
              },
            ),

            if (increase || decrease) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(13),
                decoration:
                BoxDecoration(
                  color: increase
                      ? theme
                      .colorScheme
                      .secondaryContainer
                      : decrease
                      ? theme
                      .colorScheme
                      .errorContainer
                      : theme
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      increase
                          ? Icons
                          .trending_up_rounded
                          : Icons
                          .trending_down_rounded,
                      color: increase
                          ? theme
                          .colorScheme
                          .primary
                          : theme
                          .colorScheme
                          .error,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        increase
                            ? 'You received $difference more scans than yesterday.'
                            : 'You received ${difference.abs()} fewer scans than yesterday.',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN STATS
  // ============================================================

  Widget _buildMainStats(
      BuildContext context,
      DashboardState state,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final columns =
        width >= 900
            ? 4
            : width >= 560
            ? 2
            : 1;

        final children = [
          _DashboardStatCard(
            icon:
            Icons.menu_book_outlined,
            title: 'Menu Items',
            value:
            state.menuItemCount,
            onTap: () {
              context.push('/menu');
            },
          ),
          _DashboardStatCard(
            icon:
            Icons.category_outlined,
            title: 'Categories',
            value:
            state.categoryCount,
            onTap: () {
              context.push('/menu');
            },
          ),
          _DashboardStatCard(
            icon:
            Icons.qr_code_2_outlined,
            title: 'QR Codes',
            value: state.qrCount,
            onTap: () {
              context.push('/qr');
            },
          ),
          _DashboardStatCard(
            icon:
            Icons.auto_awesome_rounded,
            title: 'AI Imports',
            value:
            state.aiImportUsed,
            subtitle:
            '${state.aiImportsRemaining} remaining',
            onTap: () {
              context.push(
                '/ai-import',
              );
            },
          ),
        ];

        if (columns == 1) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                child: child,
              ),
            )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
          width >= 900
              ? 2.15
              : 1.42,
          children: children,
        );
      },
    );
  }

  // ============================================================
  // TWO COLUMN SECTION
  // ============================================================

  Widget _buildTwoColumnSection(
      BuildContext context,
      DashboardState state,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final wide =
            constraints.maxWidth >= 800;

        if (!wide) {
          return Column(
            children: [
              _buildSubscriptionCard(
                context,
                state.subscription,
              ),
              const SizedBox(height: 20),
              _buildBusinessInsights(
                context,
                state,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child:
              _buildSubscriptionCard(
                context,
                state.subscription,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child:
              _buildBusinessInsights(
                context,
                state,
              ),
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
        elevation: 0,
        child: Padding(
          padding:
          const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                context,
                icon: Icons
                    .card_membership_outlined,
                title: 'Subscription',
              ),
              const SizedBox(height: 14),
              Text(
                'Subscription information is unavailable.',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(
                      '/subscription',
                    );
                  },
                  child: const Text(
                    'View Subscription',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isExpired =
        subscription.status ==
            SubscriptionStatus.expired;

    final status =
    subscription.status.name
        .toUpperCase();

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            if (isExpired)
              _buildExpiredBanner(
                context,
                subscription,
              ),

            if (isExpired)
              const SizedBox(height: 16),

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _sectionTitle(
                    context,
                    icon: Icons
                        .card_membership_outlined,
                    title: 'Subscription',
                  ),
                ),
                _StatusPill(
                  label: status,
                  error: isExpired,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              subscription.planName,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.w800,
                color: theme
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _InfoItem(
                  icon: Icons
                      .calendar_today_outlined,
                  text:
                  'Ends ${_formatDate(subscription.endDate)}',
                ),
                _InfoItem(
                  icon:
                  Icons.autorenew_rounded,
                  text: subscription
                      .billingCycle
                      .name
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

  Widget _buildExpiredBanner(
      BuildContext context,
      SubscriptionResponse
      subscription,
      ) {
    final theme = Theme.of(context);

    final isTrial =
        subscription.planName
            .trim()
            .toLowerCase() ==
            'trial';

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color:
            theme.colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isTrial
                  ? 'Your trial has expired.'
                  : 'Your ${subscription.planName} plan has expired.',
              style: TextStyle(
                fontWeight:
                FontWeight.w700,
                color: theme
                    .colorScheme
                    .onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS INSIGHTS
  // ============================================================

  Widget _buildBusinessInsights(
      BuildContext context,
      DashboardState state,
      ) {
    final theme = Theme.of(context);
    final business =
        state.businessDashboard;

    final today =
        business?.todayScans ?? 0;
    final last7 =
        business?.last7DaysScans ?? 0;
    final total =
        business?.totalScans ?? 0;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              context,
              icon:
              Icons.insights_outlined,
              title: 'Business Insights',
            ),

            const SizedBox(height: 16),

            _InsightRow(
              icon:
              Icons.today_outlined,
              title: 'Today',
              value:
              '${_formatNumber(today)} scans',
            ),

            const SizedBox(height: 12),

            _InsightRow(
              icon:
              Icons.date_range_outlined,
              title: 'Last 7 Days',
              value:
              '${_formatNumber(last7)} scans',
            ),

            const SizedBox(height: 12),

            _InsightRow(
              icon:
              Icons.bar_chart_rounded,
              title: 'Total Reach',
              value:
              '${_formatNumber(total)} scans',
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(14),
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer
                    .withValues(
                  alpha: 0.45,
                ),
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .lightbulb_outline_rounded,
                    size: 20,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      total == 0
                          ? 'Your first QR scan will appear here.'
                          : 'Keep your menu and QR visible to increase customer engagement.',
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        height: 1.35,
                        fontWeight:
                        FontWeight.w600,
                      ),
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

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
      BuildContext context,
      ) {
    final actions = [
      _ActionData(
        icon:
        Icons.menu_book_outlined,
        title: 'Manage Menu',
        subtitle:
        'Add or edit items',
        onTap: () {
          context.push('/menu');
        },
      ),
      _ActionData(
        icon:
        Icons.qr_code_2_outlined,
        title: 'Manage QR',
        subtitle:
        'View your QR',
        onTap: () {
          context.push('/qr');
        },
      ),
      _ActionData(
        icon:
        Icons.auto_awesome_rounded,
        title: 'AI Import',
        subtitle:
        'Import menu faster',
        onTap: () {
          context.push(
            '/ai-import',
          );
        },
      ),
      _ActionData(
        icon:
        Icons.storefront_outlined,
        title: 'Business',
        subtitle:
        'Business settings',
        onTap: () {
          context.push(
            '/business',
          );
        },
      ),
      _ActionData(
        icon:
        Icons.insights_outlined,
        title: 'Activity',
        subtitle:
        'View customer activity',
        onTap: () {
          context.push(
            '/activity',
          );
        },
      ),
      _ActionData(
        icon:
        Icons.card_membership_outlined,
        title: 'Subscription',
        subtitle:
        'Manage your plan',
        onTap: () {
          context.push(
            '/subscription',
          );
        },
      ),
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              context,
              icon:
              Icons.flash_on_outlined,
              title: 'Quick Actions',
            ),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final width =
                    constraints.maxWidth;

                final columns =
                width >= 900
                    ? 3
                    : width >= 520
                    ? 2
                    : 1;

                if (columns == 1) {
                  return Column(
                    children: actions
                        .map(
                          (action) =>
                          Padding(
                            padding:
                            const EdgeInsets
                                .only(
                              bottom: 10,
                            ),
                            child:
                            _ActionTile(
                              icon:
                              action.icon,
                              title:
                              action.title,
                              subtitle:
                              action.subtitle,
                              onTap:
                              action.onTap,
                            ),
                          ),
                    )
                        .toList(),
                  );
                }

                return GridView.count(
                  crossAxisCount:
                  columns,
                  shrinkWrap: true,
                  physics:
                  const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                  columns == 3
                      ? 2.9
                      : 3.2,
                  children: actions
                      .map(
                        (action) =>
                        _ActionTile(
                          icon:
                          action.icon,
                          title:
                          action.title,
                          subtitle:
                          action.subtitle,
                          onTap:
                          action.onTap,
                        ),
                  )
                      .toList(),
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
    final theme = Theme.of(context);

    final used =
        state.aiImportUsed;
    final limit =
        state.aiImportLimit;
    final remaining =
        state.aiImportsRemaining;

    final progress = limit <= 0
        ? 0.0
        : (used / limit)
        .clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                    Icons
                        .auto_awesome_rounded,
                    color: theme
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'AI Import Usage',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$remaining imports remaining',
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$used / $limit',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(10),
              child:
              LinearProgressIndicator(
                value: progress,
                minHeight: 9,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              limit <= 0
                  ? 'No AI import limit available.'
                  : '$used of $limit AI imports used.',
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
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
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      BuildContext context, {
        required IconData icon,
        required String title,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color:
          theme.colorScheme.primary,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: theme
              .textTheme
              .titleMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      DashboardState state,
      ) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding:
        const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 430,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration:
                BoxDecoration(
                  color: theme
                      .colorScheme
                      .errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons
                      .cloud_off_rounded,
                  size: 34,
                  color: theme
                      .colorScheme
                      .error,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Unable to load dashboard',
                textAlign:
                TextAlign.center,
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                state.errorMessage ??
                    'Something went wrong while loading your dashboard.',
                textAlign:
                TextAlign.center,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () {
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
                label: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatNumber(int value) {
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ================================================================
// ACTION DATA
// ================================================================

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

// ================================================================
// SCAN METRIC
// ================================================================

class _ScanMetric
    extends StatelessWidget {
  const _ScanMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.all(15),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(
              color: theme
                  .colorScheme
                  .primaryContainer,
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme
                  .colorScheme
                  .onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _format(value),
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(int value) {
    return value.toString();
  }
}

// ================================================================
// INSIGHT ROW
// ================================================================

class _InsightRow
    extends StatelessWidget {
  const _InsightRow({
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

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration:
          BoxDecoration(
            color: theme
                .colorScheme
                .primaryContainer,
            borderRadius:
            BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme
                .colorScheme
                .onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// DASHBOARD STAT CARD
// ================================================================

class _DashboardStatCard
    extends StatelessWidget {
  const _DashboardStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final int value;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(15),
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
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: theme
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value.toString(),
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .primary,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 14,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ACTION TILE
// ================================================================

class _ActionTile
    extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding:
        const EdgeInsets.all(13),
        alignment:
        Alignment.centerLeft,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
              color: theme
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.7),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
              ],
            ),
          ),

          Icon(
            Icons
                .arrow_forward_ios_rounded,
            size: 13,
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// STATUS PILL
// ================================================================

class _StatusPill
    extends StatelessWidget {
  const _StatusPill({
    required this.label,
    this.error = false,
  });

  final String label;
  final bool error;

  @override
  Widget build(
      BuildContext context,
      ) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: error
            ? scheme.errorContainer
            : scheme.secondaryContainer,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.w800,
          color: error
              ? scheme
              .onErrorContainer
              : scheme
              .onSecondaryContainer,
        ),
      ),
    );
  }
}

// ================================================================
// INFO ITEM
// ================================================================

class _InfoItem
    extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: theme
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ],
    );
  }
}