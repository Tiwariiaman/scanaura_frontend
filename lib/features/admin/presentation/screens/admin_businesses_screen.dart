import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/business_summary_response.dart';
import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';
import '../providers/admin_subscription_notifier.dart';

class AdminBusinessesScreen extends ConsumerStatefulWidget {
  const AdminBusinessesScreen({
    super.key,
  });

  @override
  ConsumerState<AdminBusinessesScreen> createState() =>
      _AdminBusinessesScreenState();
}

class _AdminBusinessesScreenState
    extends ConsumerState<AdminBusinessesScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Future.wait([
        ref
            .read(adminNotifierProvider.notifier)
            .loadBusinesses(),
        ref
            .read(adminSubscriptionNotifierProvider.notifier)
            .loadActivePlans(),
      ]);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _search() async {
    await ref
        .read(adminNotifierProvider.notifier)
        .searchBusinesses(
      _searchController.text,
    );
  }

  // ============================================================
  // BUSINESS STATUS
  // ============================================================

  Future<void> _changeBusinessStatus(
      BusinessSummaryResponse business,
      ) async {
    final activate = !business.active;

    final confirmed = await _showConfirmation(
      context,
      business,
      activate,
    );

    if (!confirmed || !mounted) {
      return;
    }

    final notifier = ref.read(
      adminNotifierProvider.notifier,
    );

    final success = activate
        ? await notifier.activateBusiness(
      business.businessId,
    )
        : await notifier.deactivateBusiness(
      business.businessId,
    );

    if (!mounted) {
      return;
    }

    final state = ref.read(
      adminNotifierProvider,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            success
                ? activate
                ? '${business.businessName} activated successfully.'
                : '${business.businessName} deactivated successfully.'
                : state.errorMessage ??
                'Unable to update business status.',
          ),
        ),
      );
  }

  Future<bool> _showConfirmation(
      BuildContext context,
      BusinessSummaryResponse business,
      bool activate,
      ) async {
    final action = activate ? 'Activate' : 'Deactivate';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            '$action Business?',
          ),
          content: Text(
            activate
                ? 'Are you sure you want to activate "${business.businessName}"?'
                : 'Are you sure you want to deactivate "${business.businessName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                action,
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // ============================================================
  // GRANT SUBSCRIPTION
  // ============================================================

  Future<void> _grantSubscription(
      BusinessSummaryResponse business,
      ) async {
    var subscriptionState = ref.read(
      adminSubscriptionNotifierProvider,
    );

    if (subscriptionState.activePlans.isEmpty) {
      await ref
          .read(
        adminSubscriptionNotifierProvider.notifier,
      )
          .loadActivePlans();

      if (!mounted) {
        return;
      }

      subscriptionState = ref.read(
        adminSubscriptionNotifierProvider,
      );
    }

    if (subscriptionState.activePlans.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              subscriptionState.errorMessage ??
                  'No active subscription plans are available.',
            ),
          ),
        );

      return;
    }

    final result = await _showGrantSubscriptionDialog(
      context,
      business,
      subscriptionState.activePlans,
    );

    if (result == null || !mounted) {
      return;
    }

    final success = await ref
        .read(
      adminSubscriptionNotifierProvider.notifier,
    )
        .grantSubscription(
      businessId: business.businessId,
      planName: result.planName,
      billingCycle: result.billingCycle,
    );

    if (!mounted) {
      return;
    }

    final updatedSubscriptionState = ref.read(
      adminSubscriptionNotifierProvider,
    );

    if (success) {
      await ref
          .read(adminNotifierProvider.notifier)
          .loadBusinesses();
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            success
                ? '${business.businessName} subscription granted successfully.'
                : updatedSubscriptionState.errorMessage ??
                'Unable to grant subscription.',
          ),
        ),
      );
  }

  Future<_GrantSubscriptionResult?>
  _showGrantSubscriptionDialog(
      BuildContext context,
      BusinessSummaryResponse business,
      List<Map<String, dynamic>> plans,
      ) async {
    final validPlans = plans
        .where(
          (plan) =>
      plan['name'] is String &&
          (plan['name'] as String).trim().isNotEmpty &&
          !(plan['name'] as String)
              .trim()
              .toLowerCase()
              .contains('trial'),
    )
        .toList();

    if (validPlans.isEmpty) {
      return null;
    }

    String selectedPlanName =
    validPlans.first['name'] as String;

    String selectedBillingCycle = 'MONTHLY';

    return showDialog<_GrantSubscriptionResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogBuildContext,
              setDialogState,
              ) {
            Map<String, dynamic>? selectedPlan;

            for (final plan in validPlans) {
              if (plan['name'] == selectedPlanName) {
                selectedPlan = plan;
                break;
              }
            }

            final monthlyPrice =
            _formatPlanPrice(
              selectedPlan?['monthlyPrice'],
            );

            final yearlyPrice =
            _formatPlanPrice(
              selectedPlan?['yearlyPrice'],
            );

            return AlertDialog(
              title: const Text(
                'Grant Subscription',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName,
                      style: Theme.of(
                        dialogBuildContext,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Select the plan and billing duration.',
                      style: Theme.of(
                        dialogBuildContext,
                      ).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          dialogBuildContext,
                        )
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue:
                      selectedPlanName,
                      decoration:
                      const InputDecoration(
                        labelText: 'Plan Type',
                        border: OutlineInputBorder(),
                      ),
                      items: validPlans.map(
                            (plan) {
                          final name =
                          plan['name'] as String;

                          return DropdownMenuItem<
                              String>(
                            value: name,
                            child: Text(name),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedPlanName =
                              value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue:
                      selectedBillingCycle,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Billing Duration',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'MONTHLY',
                          child: Text(
                            monthlyPrice == '—'
                                ? 'Monthly'
                                : 'Monthly • $monthlyPrice',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'YEARLY',
                          child: Text(
                            yearlyPrice == '—'
                                ? 'Yearly'
                                : 'Yearly • $yearlyPrice',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedBillingCycle =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(
                      _GrantSubscriptionResult(
                        planName:
                        selectedPlanName,
                        billingCycle:
                        selectedBillingCycle,
                      ),
                    );
                  },
                  child: const Text(
                    'Grant Subscription',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatPlanPrice(
      dynamic value,
      ) {
    if (value == null) {
      return '—';
    }

    if (value is num) {
      return '₹${value.toStringAsFixed(0)}';
    }

    final parsed =
    double.tryParse(value.toString());

    if (parsed == null) {
      return '—';
    }

    return '₹${parsed.toStringAsFixed(0)}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final state = ref.watch(
      adminNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Businesses',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
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
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref
              .read(adminNotifierProvider.notifier)
              .loadBusinesses(),
          ref
              .read(
            adminSubscriptionNotifierProvider
                .notifier,
          )
              .loadActivePlans(),
        ]);
      },
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final width = constraints.maxWidth;

          final horizontalPadding =
          width < 360
              ? 12.0
              : width < 600
              ? 16.0
              : 20.0;

          final maxWidth =
          width >= 1400 ? 1250.0 : 1200.0;

          return SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchBar(
                      context,
                      state,
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    _buildBusinessCount(
                      context,
                      state,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (state.status ==
                        AdminStatus.error)
                      _buildError(
                        context,
                        state,
                      )
                    else if (state
                        .businesses
                        .isEmpty)
                      _buildEmptyState(
                        context,
                      )
                    else
                      _buildBusinessList(
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
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(
      BuildContext context,
      AdminState state,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final compact =
            constraints.maxWidth < 520;

        final searchField = TextField(
          controller: _searchController,
          textInputAction:
          TextInputAction.search,
          onSubmitted: (_) {
            _search();
          },
          decoration: InputDecoration(
            hintText: 'Search business...',
            prefixIcon: const Icon(
              Icons.search,
            ),
            suffixIcon:
            _searchController.text.isEmpty
                ? null
                : IconButton(
              tooltip: 'Clear',
              onPressed: () {
                _searchController.clear();
                _search();
                setState(() {});
              },
              icon: const Icon(
                Icons.clear,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(14),
            ),
          ),
          onChanged: (_) {
            setState(() {});
          },
        );

        final searchButton = SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed:
            state.isLoading
                ? null
                : _search,
            icon: const Icon(
              Icons.search_rounded,
            ),
            label: const Text(
              'Search',
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(
                height: 10,
              ),
              searchButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: searchField,
            ),
            const SizedBox(
              width: 10,
            ),
            searchButton,
          ],
        );
      },
    );
  }

  // ============================================================
  // COUNT
  // ============================================================

  Widget _buildBusinessCount(
      BuildContext context,
      AdminState state,
      ) {
    final theme = Theme.of(context);

    return Text(
      '${state.businesses.length} businesses',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme
            .colorScheme
            .onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildBusinessList(
      BuildContext context,
      AdminState state,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: state.businesses.map(
                  (business) {
                return Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _buildBusinessCard(
                    context,
                    business,
                    state,
                  ),
                );
              },
            ).toList(),
          );
        }

        return Card(
          clipBehavior:
          Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 18,
              columns: const [
                DataColumn(
                  label: Text('Business'),
                ),
                DataColumn(
                  label: Text('Owner'),
                ),
                DataColumn(
                  label: Text('City'),
                ),
                DataColumn(
                  label: Text('Plan'),
                ),
                DataColumn(
                  label: Text('Status'),
                ),
                DataColumn(
                  label: Text('Today'),
                ),
                DataColumn(
                  label: Text('Yesterday'),
                ),
                DataColumn(
                  label: Text('7 Days'),
                ),
                DataColumn(
                  label: Text('Total'),
                ),
                DataColumn(
                  label: Text('Action'),
                ),
              ],
              rows: state.businesses
                  .map(
                    (business) =>
                    _buildDataRow(
                      context,
                      business,
                      state,
                    ),
              )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DATA TABLE ROW
  // ============================================================

  DataRow _buildDataRow(
      BuildContext context,
      BusinessSummaryResponse business,
      AdminState state,
      ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 190,
            child: Text(
              business.businessName,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 140,
            child: Text(
              business.ownerName,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            business.city.isEmpty
                ? '—'
                : business.city,
          ),
        ),
        DataCell(
          Text(
            business.currentPlan ?? '—',
          ),
        ),
        DataCell(
          _StatusChip(
            active: business.active,
          ),
        ),
        DataCell(
          _ScanCountText(
            value: business.todayScans,
          ),
        ),
        DataCell(
          _ScanCountText(
            value:
            business.yesterdayScans,
          ),
        ),
        DataCell(
          _ScanCountText(
            value:
            business.last7DaysScans,
          ),
        ),
        DataCell(
          _ScanCountText(
            value: business.totalScans,
            emphasized: true,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed:
                state.businessActionInProgress
                    ? null
                    : () =>
                    _changeBusinessStatus(
                      business,
                    ),
                child: Text(
                  business.active
                      ? 'Deactivate'
                      : 'Activate',
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              FilledButton.icon(
                onPressed: () =>
                    _grantSubscription(
                      business,
                    ),
                icon: const Icon(
                  Icons
                      .card_membership_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Grant',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE CARD
  // ============================================================

  Widget _buildBusinessCard(
      BuildContext context,
      BusinessSummaryResponse business,
      AdminState state,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    final compact = width < 400;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        EdgeInsets.all(
          compact ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width:
                  compact ? 40 : 46,
                  height:
                  compact ? 40 : 46,
                  alignment:
                  Alignment.center,
                  decoration:
                  BoxDecoration(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .storefront_outlined,
                    size:
                    compact ? 21 : 24,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        business.businessName,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        business.ownerName,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                _StatusChip(
                  active:
                  business.active,
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            _DetailRow(
              label: 'Email',
              value: business.email,
            ),
            _DetailRow(
              label: 'Phone',
              value: business.phone,
            ),
            _DetailRow(
              label: 'City',
              value: business.city.isEmpty
                  ? '—'
                  : business.city,
            ),
            _DetailRow(
              label: 'Plan',
              value:
              business.currentPlan ??
                  '—',
            ),
            if (business
                .subscriptionStatus !=
                AdminSubscriptionStatus
                    .unknown)
              _DetailRow(
                label:
                'Subscription',
                value: business
                    .subscriptionStatus
                    .name,
              ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // QR SCAN STATISTICS
            // ==================================================

            _ScanStatsCard(
              todayScans:
              business.todayScans,
              yesterdayScans:
              business.yesterdayScans,
              last7DaysScans:
              business.last7DaysScans,
              totalScans:
              business.totalScans,
            ),

            const SizedBox(
              height: 12,
            ),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height:
                  compact ? 46 : 48,
                  child:
                  OutlinedButton(
                    onPressed:
                    state
                        .businessActionInProgress
                        ? null
                        : () =>
                        _changeBusinessStatus(
                          business,
                        ),
                    child: Text(
                      business.active
                          ? 'Deactivate Business'
                          : 'Activate Business',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: double.infinity,
                  height:
                  compact ? 46 : 48,
                  child:
                  FilledButton.icon(
                    onPressed: () =>
                        _grantSubscription(
                          business,
                        ),
                    icon: const Icon(
                      Icons
                          .card_membership_outlined,
                    ),
                    label: const Text(
                      'Grant Subscription',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .storefront_outlined,
            size: 52,
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'No businesses found.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            'Try changing your search.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      AdminState state,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(24),
      child: Center(
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
                size: 48,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .error,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                state.errorMessage ??
                    'Unable to load businesses.',
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child:
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(
                      adminNotifierProvider
                          .notifier,
                    )
                        .loadBusinesses();
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
    );
  }
}

// ================================================================
// GRANT SUBSCRIPTION RESULT
// ================================================================

class _GrantSubscriptionResult {
  const _GrantSubscriptionResult({
    required this.planName,
    required this.billingCycle,
  });

  final String planName;
  final String billingCycle;
}

// ================================================================
// QR SCAN COUNT TEXT
// ================================================================

class _ScanCountText extends StatelessWidget {
  const _ScanCountText({
    required this.value,
    this.emphasized = false,
  });

  final int value;
  final bool emphasized;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      value.toString(),
      style: TextStyle(
        fontWeight: emphasized
            ? FontWeight.w700
            : FontWeight.w500,
      ),
    );
  }
}

// ================================================================
// QR SCAN STATS CARD
// ================================================================

class _ScanStatsCard extends StatelessWidget {
  const _ScanStatsCard({
    required this.todayScans,
    required this.yesterdayScans,
    required this.last7DaysScans,
    required this.totalScans,
  });

  final int todayScans;
  final int yesterdayScans;
  final int last7DaysScans;
  final int totalScans;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: theme
              .colorScheme
              .outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons
                    .qr_code_scanner_rounded,
                size: 19,
                color: theme
                    .colorScheme
                    .primary,
              ),
              const SizedBox(
                width: 7,
              ),
              Text(
                'QR Scan Statistics',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Expanded(
                child:
                _ScanStatItem(
                  label: 'Today',
                  value:
                  todayScans,
                ),
              ),
              Expanded(
                child:
                _ScanStatItem(
                  label:
                  'Yesterday',
                  value:
                  yesterdayScans,
                ),
              ),
              Expanded(
                child:
                _ScanStatItem(
                  label: '7 Days',
                  value:
                  last7DaysScans,
                ),
              ),
              Expanded(
                child:
                _ScanStatItem(
                  label: 'Total',
                  value:
                  totalScans,
                  emphasized: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QR SCAN STAT ITEM
// ================================================================

class _ScanStatItem extends StatelessWidget {
  const _ScanStatItem({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final int value;
  final bool emphasized;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 17,
            fontWeight:
            emphasized
                ? FontWeight.w800
                : FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          label,
          textAlign:
          TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(
              context,
            )
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATUS CHIP
// ================================================================

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.active,
  });

  final bool active;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: active
            ? theme
            .colorScheme
            .secondaryContainer
            : theme
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        active
            ? 'Active'
            : 'Inactive',
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
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          if (constraints.maxWidth <
              330) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value.isEmpty
                      ? '—'
                      : value,
                  softWrap: true,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 78,
                child: Text(
                  label,
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  value.isEmpty
                      ? '—'
                      : value,
                  softWrap: true,
                  maxLines: 3,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}