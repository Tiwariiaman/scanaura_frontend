import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';

class AdminDashboardScreen
    extends ConsumerStatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  ConsumerState<AdminDashboardScreen>
  createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        adminNotifierProvider
            .notifier,
      )
          .refreshAll();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      adminNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
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
          const SizedBox(
            width: 4,
          ),
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
      AdminState state,
      ) {
    if (state.status ==
        AdminStatus.loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
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

    final dashboard =
        state.dashboard;

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
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final width =
              constraints.maxWidth;

          final horizontalPadding =
          width < 360
              ? 12.0
              : width < 600
              ? 16.0
              : width < 1000
              ? 20.0
              : 24.0;

          final maxWidth =
          width >= 1400
              ? 1250.0
              : 1200.0;

          return SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                BoxConstraints(
                  maxWidth:
                  maxWidth,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
                  children: [
                    _buildHeader(
                      context,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _buildBusinessStats(
                      context,
                      dashboard,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildSubscriptionStats(
                      context,
                      dashboard,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    _buildQrStats(
                      context,
                      dashboard,
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
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

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

        const SizedBox(
          height: 6,
        ),

        Text(
          'Monitor ScanAura businesses, subscriptions and QR inventory.',
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS STATS
  // ============================================================

  Widget _buildBusinessStats(
      BuildContext context,
      dynamic dashboard,
      ) {
    return _SectionCard(
      title: 'Businesses',
      icon: Icons
          .storefront_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title: 'Total',
              value:
              '${dashboard.totalBusinesses}',
              icon: Icons
                  .business_outlined,
            ),
            _AdminStat(
              title: 'Active',
              value:
              '${dashboard.activeBusinesses}',
              icon: Icons
                  .check_circle_outline,
            ),
            _AdminStat(
              title: 'Inactive',
              value:
              '${dashboard.inactiveBusinesses}',
              icon: Icons
                  .pause_circle_outline,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SUBSCRIPTION STATS
  // ============================================================

  Widget _buildSubscriptionStats(
      BuildContext context,
      dynamic dashboard,
      ) {
    return _SectionCard(
      title: 'Subscriptions',
      icon: Icons
          .card_membership_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title: 'Trial',
              value:
              '${dashboard.trialSubscriptions}',
              icon: Icons
                  .hourglass_empty,
            ),
            _AdminStat(
              title: 'Active',
              value:
              '${dashboard.activeSubscriptions}',
              icon: Icons
                  .verified_outlined,
            ),
            _AdminStat(
              title: 'Expired',
              value:
              '${dashboard.expiredSubscriptions}',
              icon: Icons
                  .event_busy_outlined,
            ),
            _AdminStat(
              title: 'Pending Requests',
              value:
              '${dashboard.pendingSubscriptionRequests}',
              icon: Icons
                  .pending_actions_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // QR STATS
  // ============================================================

  Widget _buildQrStats(
      BuildContext context,
      dynamic dashboard,
      ) {
    return _SectionCard(
      title: 'QR Inventory',
      icon:
      Icons.qr_code_2_outlined,
      children: [
        _buildStatsGrid(
          context,
          [
            _AdminStat(
              title:
              'Available Physical',
              value:
              '${dashboard.availablePhysicalQr}',
              icon: Icons
                  .inventory_2_outlined,
            ),
            _AdminStat(
              title:
              'Assigned Physical',
              value:
              '${dashboard.assignedPhysicalQr}',
              icon: Icons
                  .assignment_outlined,
            ),
            _AdminStat(
              title:
              'Digital Generated',
              value:
              '${dashboard.digitalQrGenerated}',
              icon: Icons
                  .qr_code_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATS GRID
  // ============================================================

  Widget _buildStatsGrid(
      BuildContext context,
      List<_AdminStat> stats,
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
            ? 3
            : width >= 600
            ? 2
            : 1;

        final compact =
            width < 400;

        final childAspectRatio =
        columns == 1
            ? 3.5
            : columns == 2
            ? 2.25
            : 2.15;

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount:
          stats.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
            childAspectRatio,
          ),
          itemBuilder:
              (context, index) {
            return _AdminStatCard(
              stat:
              stats[index],
              compact:
              compact,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      AdminState state,
      ) {
    return SafeArea(
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
              maxWidth: 420,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .error_outline_rounded,
                  size: 52,
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .error,
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  state.errorMessage ??
                      'Unable to load admin dashboard.',
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 18,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton
                      .icon(
                    onPressed: () {
                      ref
                          .read(
                        adminNotifierProvider
                            .notifier,
                      )
                          .refreshAll();
                    },
                    icon:
                    const Icon(
                      Icons
                          .refresh_rounded,
                    ),
                    label:
                    const Text(
                      'Retry',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard
    extends StatelessWidget {
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
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    title,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            ...children,
          ],
        ),
      ),
    );
  }
}

// ================================================================
// STAT MODEL
// ================================================================

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

// ================================================================
// STAT CARD
// ================================================================

class _AdminStatCard
    extends StatelessWidget {
  const _AdminStatCard({
    required this.stat,
    required this.compact,
  });

  final _AdminStat stat;
  final bool compact;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: Padding(
        padding:
        EdgeInsets.all(
          compact ? 12 : 16,
        ),
        child: Row(
          children: [
            Container(
              width:
              compact ? 42 : 46,
              height:
              compact ? 42 : 46,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                BorderRadius.circular(
                  compact ? 10 : 12,
                ),
              ),
              child: Icon(
                stat.icon,
                size:
                compact ? 20 : 22,
                color: theme
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            SizedBox(
              width:
              compact ? 10 : 12,
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
                    stat.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize:
                      compact
                          ? 12
                          : 13,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    stat.value,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      fontSize:
                      compact
                          ? 21
                          : 22,
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