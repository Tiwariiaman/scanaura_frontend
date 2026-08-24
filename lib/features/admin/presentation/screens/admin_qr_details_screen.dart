import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_notifier.dart';

class AdminQrDetailsScreen
    extends ConsumerWidget {
  const AdminQrDetailsScreen({
    super.key,
    required this.qrCode,
  });

  final String qrCode;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final state =
    ref.watch(adminNotifierProvider);

    final details =
        state.qrDetails;

    if (details == null ||
        details.qrCode != qrCode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'QR Details',
          ),
        ),
        body: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    final isPhysical =
        details.type.toUpperCase() ==
            'PHYSICAL';

    final isAssigned =
        details.assigned;

    final isActive =
        details.active;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Details',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            adminNotifierProvider
                .notifier,
          )
              .loadQrDetails(
            qrCode,
          );
        },
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 650,
              ),
              child: Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      // =================================================
                      // HEADER
                      // =================================================

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration:
                            BoxDecoration(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                            ),
                            child: Icon(
                              isPhysical
                                  ? Icons
                                  .qr_code_2_rounded
                                  : Icons
                                  .qr_code_rounded,
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .onPrimaryContainer,
                              size: 28,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  isPhysical
                                      ? 'Physical QR'
                                      : 'Digital QR',
                                  style: Theme.of(
                                    context,
                                  )
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight
                                        .w800,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  details.qrCode,
                                  style: Theme.of(
                                    context,
                                  )
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                    letterSpacing:
                                    1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _StatusBadge(
                            active: isActive,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =================================================
                      // QR INFORMATION
                      // =================================================

                      _InfoRow(
                        label: 'Type',
                        value:
                        details.type,
                      ),

                      _InfoRow(
                        label: 'Status',
                        value: isActive
                            ? 'Active'
                            : 'Inactive',
                      ),

                      _InfoRow(
                        label: 'Assignment',
                        value: isAssigned
                            ? 'Assigned'
                            : 'Available',
                      ),

                      _InfoRow(
                        label: 'Business',
                        value:
                        details.businessName
                            ?.trim()
                            .isNotEmpty ==
                            true
                            ? details
                            .businessName!
                            : 'Not assigned',
                      ),

                      if (details.businessId !=
                          null)
                        _InfoRow(
                          label: 'Business ID',
                          value:
                          details.businessId!,
                        ),

                      const SizedBox(
                        height: 20,
                      ),

                      const Divider(),

                      const SizedBox(
                        height: 20,
                      ),

                      // =================================================
                      // PHYSICAL QR - AVAILABLE
                      // =================================================

                      if (isPhysical &&
                          !isAssigned &&
                          isActive)
                        _buildAvailablePhysicalActions(
                          context,
                          details.qrCode,
                        ),

                      // =================================================
                      // PHYSICAL QR - ASSIGNED
                      // =================================================

                      if (isPhysical &&
                          isAssigned)
                        _buildAssignedPhysicalActions(
                          context,
                          ref,
                          details.businessName,
                          details.qrCode,
                          isActive,
                        ),

                      // =================================================
                      // PHYSICAL QR - INACTIVE
                      // =================================================

                      if (isPhysical &&
                          !isActive)
                        _buildInactivePhysicalMessage(
                          context,
                        ),

                      // =================================================
                      // DIGITAL QR
                      // =================================================

                      if (!isPhysical)
                        _buildDigitalQrMessage(
                          context,
                          details.businessName,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVAILABLE PHYSICAL
  // ============================================================

  Widget _buildAvailablePhysicalActions(
      BuildContext context,
      String qrCode,
      ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons
                      .check_circle_outline_rounded,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This physical QR is available and can be assigned to a business.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      _AssignBusinessDialog(
                        qrCode: qrCode,
                      ),
                );
              },
              icon: const Icon(
                Icons.link_rounded,
              ),
              label: const Text(
                'Assign Business',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSIGNED PHYSICAL
  // ============================================================

  Widget _buildAssignedPhysicalActions(
      BuildContext context,
      WidgetRef ref,
      String? businessName,
      String qrCode,
      bool isActive,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context)
                .colorScheme
                .primaryContainer
                : Theme.of(context)
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
                isActive
                    ? Icons
                    .business_rounded
                    : Icons
                    .block_rounded,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      isActive
                          ? 'Assigned Business'
                          : 'Assigned QR is inactive',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    if (businessName
                        ?.trim()
                        .isNotEmpty ==
                        true) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        businessName!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 16,
        ),

        if (isActive)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeactivateConfirmation(
                  context,
                  ref,
                  qrCode,
                );
              },
              icon: const Icon(
                Icons
                    .block_rounded,
              ),
              label: const Text(
                'Deactivate QR',
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // INACTIVE PHYSICAL
  // ============================================================

  Widget _buildInactivePhysicalMessage(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.block_rounded,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This physical QR is inactive and cannot be used by customers.',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIGITAL QR
  // ============================================================

  Widget _buildDigitalQrMessage(
      BuildContext context,
      String? businessName,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .verified_outlined,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              businessName
                  ?.trim()
                  .isNotEmpty ==
                  true
                  ? 'Digital QR is permanently linked to ${businessName!.trim()} and cannot be assigned as a physical QR or manually deactivated.'
                  : 'Digital QR is business-linked and cannot be assigned as a physical QR or manually deactivated.',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEACTIVATE CONFIRMATION
  // ============================================================

  Future<void>
  _showDeactivateConfirmation(
      BuildContext context,
      WidgetRef ref,
      String qrCode,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Deactivate QR?',
          ),
          content: Text(
            'Are you sure you want to deactivate $qrCode?\n\n'
                'Customers will no longer be able to use this QR code.',
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
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final success = await ref
        .read(
      adminNotifierProvider
          .notifier,
    )
        .deactivateQr(qrCode);

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'QR deactivated successfully.',
          ),
        ),
      );

      // Refresh the QR details so the
      // screen immediately shows inactive.
      await ref
          .read(
        adminNotifierProvider
            .notifier,
      )
          .loadQrDetails(qrCode);
    } else {
      final message =
          ref.read(
            adminNotifierProvider,
          ).errorMessage ??
              'Unable to deactivate QR.';

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.active,
  });

  final bool active;

  @override
  Widget build(
      BuildContext context,
      ) {
    final color = active
        ? Colors.green
        : Theme.of(context)
        .colorScheme
        .error;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
            BoxDecoration(
              color: color,
              shape:
              BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Text(
            active
                ? 'Active'
                : 'Inactive',
            style: TextStyle(
              color: color,
              fontWeight:
              FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ASSIGN BUSINESS DIALOG
// ============================================================

class _AssignBusinessDialog
    extends ConsumerStatefulWidget {
  const _AssignBusinessDialog({
    required this.qrCode,
  });

  final String qrCode;

  @override
  ConsumerState<
      _AssignBusinessDialog>
  createState() =>
      _AssignBusinessDialogState();
}

class _AssignBusinessDialogState
    extends ConsumerState<
        _AssignBusinessDialog> {
  final TextEditingController
  _searchController =
  TextEditingController();

  String? _selectedBusinessId;
  String? _selectedBusinessName;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      ref
          .read(
        adminNotifierProvider
            .notifier,
      )
          .loadBusinesses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(
      String value,
      ) async {
    await ref
        .read(
      adminNotifierProvider
          .notifier,
    )
        .searchBusinesses(value);
  }

  Future<void> _assign() async {
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Select a business first.',
          ),
        ),
      );

      return;
    }

    final notifier = ref.read(
      adminNotifierProvider.notifier,
    );

    final success =
    await notifier.assignQrToBusiness(
      businessId:
      _selectedBusinessId!,
      qrCode: widget.qrCode,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context)
          .pop(true);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${widget.qrCode} assigned to '
                '${_selectedBusinessName ?? 'business'} successfully.',
          ),
        ),
      );
    } else {
      final message =
          ref
              .read(
            adminNotifierProvider,
          )
              .errorMessage ??
              'Unable to assign QR code.';

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      adminNotifierProvider,
    );

    return AlertDialog(
      title: const Text(
        'Assign Business',
      ),

      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                'QR Code: ${widget.qrCode}',
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
              _searchController,
              onChanged: _search,
              decoration:
              const InputDecoration(
                labelText:
                'Search business',
                prefixIcon: Icon(
                  Icons.search_rounded,
                ),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            if (state.isLoading &&
                state.businesses.isEmpty)
              const Padding(
                padding:
                EdgeInsets.all(20),
                child:
                CircularProgressIndicator(),
              )
            else if (state.businesses
                .isEmpty)
              const Padding(
                padding:
                EdgeInsets.all(20),
                child: Text(
                  'No businesses found.',
                  textAlign:
                  TextAlign.center,
                ),
              )
            else
              ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxHeight: 300,
                ),
                child:
                ListView.separated(
                  shrinkWrap: true,
                  itemCount:
                  state.businesses
                      .length,
                  separatorBuilder:
                      (_, __) =>
                  const Divider(
                    height: 1,
                  ),
                  itemBuilder:
                      (context, index) {
                    final business =
                    state.businesses[
                    index];

                    final selected =
                        _selectedBusinessId ==
                            business
                                .businessId;

                    return ListTile(
                      selected:
                      selected,
                      selectedTileColor:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .primaryContainer,
                      leading:
                      const Icon(
                        Icons
                            .storefront_outlined,
                      ),
                      title: Text(
                        business
                            .businessName,
                      ),
                      subtitle: Text(
                        business.city ??
                            business
                                .ownerName ??
                            '',
                      ),
                      trailing:
                      selected
                          ? const Icon(
                        Icons
                            .check_circle,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedBusinessId =
                              business
                                  .businessId;

                          _selectedBusinessName =
                              business
                                  .businessName;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed:
          state.businessActionInProgress
              ? null
              : () {
            Navigator.of(
              context,
            ).pop();
          },
          child: const Text(
            'Cancel',
          ),
        ),

        FilledButton(
          onPressed:
          state.businessActionInProgress
              ? null
              : _assign,
          child:
          state.businessActionInProgress
              ? const SizedBox(
            width: 18,
            height: 18,
            child:
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Assign',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
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
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}