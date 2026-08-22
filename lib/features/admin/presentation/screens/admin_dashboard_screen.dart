import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(adminNotifierProvider.notifier)
          .refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
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
                adminNotifierProvider
                    .notifier,
              )
                  .refreshAll();
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
      AdminState state,
      ) {
    if (state.status ==
        AdminStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status ==
        AdminStatus.error &&
        state.dashboard == null) {
      return _buildError(
        context,
        state,
      );
    }

    final dashboard = state.dashboard;

    if (dashboard == null) {
      return _buildError(
        context,
        state,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
          adminNotifierProvider
              .notifier,
        )
            .refreshAll();
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
              maxWidth: 1200,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),

                const SizedBox(height: 20),

                _buildBusinessStats(
                  context,
                  dashboard,
                ),

                const SizedBox(height: 20),

                _buildSubscriptionStats(
                  context,
                  dashboard,
                ),

                const SizedBox(height: 20),

                _buildQrStats(
                  context,
                  dashboard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Monitor ScanAura businesses, subscriptions and QR inventory.',
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

  Widget _buildBusinessStats(
      BuildContext context,
      dashboard,
      ) {
    return _SectionCard(
      title: 'Businesses',
      icon: Icons.storefront_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title: 'Total',
              value:
              '${dashboard.totalBusinesses}',
              icon:
              Icons.business_outlined,
            ),
            _AdminStat(
              title: 'Active',
              value:
              '${dashboard.activeBusinesses}',
              icon:
              Icons.check_circle_outline,
            ),
            _AdminStat(
              title: 'Inactive',
              value:
              '${dashboard.inactiveBusinesses}',
              icon:
              Icons.pause_circle_outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubscriptionStats(
      BuildContext context,
      dashboard,
      ) {
    return _SectionCard(
      title: 'Subscriptions',
      icon:
      Icons.card_membership_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title: 'Trial',
              value:
              '${dashboard.trialSubscriptions}',
              icon:
              Icons.hourglass_empty,
            ),
            _AdminStat(
              title: 'Active',
              value:
              '${dashboard.activeSubscriptions}',
              icon:
              Icons.verified_outlined,
            ),
            _AdminStat(
              title: 'Expired',
              value:
              '${dashboard.expiredSubscriptions}',
              icon:
              Icons.event_busy_outlined,
            ),
            _AdminStat(
              title: 'Pending Requests',
              value:
              '${dashboard.pendingSubscriptionRequests}',
              icon:
              Icons.pending_actions_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrStats(
      BuildContext context,
      dashboard,
      ) {
    return _SectionCard(
      title: 'QR Inventory',
      icon: Icons.qr_code_2_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title: 'Available Physical',
              value:
              '${dashboard.availablePhysicalQr}',
              icon:
              Icons.inventory_2_outlined,
            ),
            _AdminStat(
              title: 'Assigned Physical',
              value:
              '${dashboard.assignedPhysicalQr}',
              icon:
              Icons.assignment_outlined,
            ),
            _AdminStat(
              title: 'Digital Generated',
              value:
              '${dashboard.digitalQrGenerated}',
              icon:
              Icons.qr_code_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      BuildContext context,
      List<_AdminStat> stats,
      ) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        final columns =
        constraints.maxWidth >=
            900
            ? 3
            : constraints.maxWidth >=
            600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
            columns == 1
                ? 3.2
                : 2.2,
          ),
          itemBuilder:
              (context, index) {
            final stat = stats[index];

            return _AdminStatCard(
              stat: stat,
            );
          },
        );
      },
    );
  }

  Widget _buildError(
      BuildContext context,
      AdminState state,
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
                  'Unable to load admin dashboard.',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(
                  adminNotifierProvider
                      .notifier,
                )
                    .refreshAll();
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
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(
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
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AdminStat {
  const _AdminStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

class _AdminStatCard
    extends StatelessWidget {
  const _AdminStatCard({
    required this.stat,
  });

  final _AdminStat stat;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      elevation: 0,
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
                stat.icon,
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
                    stat.title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    stat.value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    const TextStyle(
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