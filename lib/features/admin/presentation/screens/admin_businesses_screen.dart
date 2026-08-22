import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/business_summary_response.dart';
import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';


class AdminBusinessesScreen extends ConsumerStatefulWidget {
  const AdminBusinessesScreen({super.key});

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

    Future.microtask(() {
      ref
          .read(adminNotifierProvider.notifier)
          .loadBusinesses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    await ref
        .read(adminNotifierProvider.notifier)
        .searchBusinesses(
      _searchController.text,
    );
  }

  Future<void> _changeBusinessStatus(
      BusinessSummaryResponse business,
      ) async {
    final activate = !business.active;

    final confirmed =
    await _showConfirmation(
      context,
      business,
      activate,
    );

    if (!confirmed || !mounted) {
      return;
    }

    final notifier =
    ref.read(
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

    final state =
    ref.read(adminNotifierProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
    final action =
    activate ? 'Activate' : 'Deactivate';

    final result =
    await showDialog<bool>(
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
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(action),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(adminNotifierProvider);

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

  Widget _buildBody(
      BuildContext context,
      AdminState state,
      ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
          adminNotifierProvider
              .notifier,
        )
            .loadBusinesses();
      },
      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
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
                _buildSearchBar(
                  context,
                  state,
                ),
                const SizedBox(height: 16),
                _buildBusinessCount(state),
                const SizedBox(height: 16),
                if (state.status ==
                    AdminStatus.error)
                  _buildError(
                    context,
                    state,
                  )
                else if (state.businesses.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildBusinessList(
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

  Widget _buildSearchBar(
      BuildContext context,
      AdminState state,
      ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller:
            _searchController,
            onSubmitted: (_) {
              _search();
            },
            decoration:
            InputDecoration(
              hintText:
              'Search business...',
              prefixIcon:
              const Icon(
                Icons.search,
              ),
              suffixIcon:
              _searchController
                  .text
                  .isEmpty
                  ? null
                  : IconButton(
                onPressed: () {
                  _searchController
                      .clear();
                  _search();
                  setState(() {});
                },
                icon:
                const Icon(
                  Icons.clear,
                ),
              ),
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: state.isLoading
              ? null
              : _search,
          child: const Text(
            'Search',
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCount(
      AdminState state,
      ) {
    return Text(
      '${state.businesses.length} businesses',
      style: TextStyle(
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBusinessList(
      BuildContext context,
      AdminState state,
      ) {
    return LayoutBuilder(
      builder:
          (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: state.businesses
                .map(
                  (business) =>
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child:
                    _buildBusinessCard(
                      context,
                      business,
                      state,
                    ),
                  ),
            )
                .toList(),
          );
        }

        return Card(
          clipBehavior:
          Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label: Text(
                    'Business',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Owner',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'City',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Plan',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                  ),
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
            business.currentPlan ??
                '—',
          ),
        ),
        DataCell(
          _StatusChip(
            active: business.active,
          ),
        ),
        DataCell(
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
        ),
      ],
    );
  }

  Widget _buildBusinessCard(
      BuildContext context,
      BusinessSummaryResponse business,
      AdminState state,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    business.businessName,
                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(
                  active: business.active,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Owner',
              value:
              business.ownerName,
            ),
            _DetailRow(
              label: 'Email',
              value:
              business.email,
            ),
            _DetailRow(
              label: 'Phone',
              value:
              business.phone,
            ),
            _DetailRow(
              label: 'City',
              value:
              business.city.isEmpty
                  ? '—'
                  : business.city,
            ),
            _DetailRow(
              label: 'Plan',
              value:
              business.currentPlan ??
                  '—',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:
                state.businessActionInProgress
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(48),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 52,
          ),
          const SizedBox(height: 12),
          const Text(
            'No businesses found.',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      AdminState state,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            state.errorMessage ??
                'Unable to load businesses.',
            textAlign:
            TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              ref
                  .read(
                adminNotifierProvider
                    .notifier,
              )
                  .loadBusinesses();
            },
            child:
            const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip
    extends StatelessWidget {
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
      decoration: BoxDecoration(
        color: active
            ? theme
            .colorScheme
            .secondaryContainer
            : theme
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(20),
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

class _DetailRow
    extends StatelessWidget {
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
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty
                  ? '—'
                  : value,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}