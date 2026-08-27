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
    final state = ref.watch(
      adminNotifierProvider,
    );

    final details = state.qrDetails;

    if (details == null ||
        details.qrCode != qrCode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'QR Details',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isPhysical =
        details.type.toUpperCase() == 'PHYSICAL';

    final isAssigned = details.assigned;
    final isActive = details.active;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            adminNotifierProvider.notifier,
          )
              .loadQrDetails(qrCode);
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
            width >= 1000
                ? 720.0
                : 650.0;

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
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(
                        width < 400 ? 16 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildHeader(
                            context,
                            details,
                            isPhysical,
                            isActive,
                          ),
                          const SizedBox(height: 24),
                          _buildQrInformation(
                            context,
                            details,
                            isAssigned,
                            isActive,
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 20),

                          if (isPhysical &&
                              !isAssigned &&
                              isActive)
                            _buildAvailablePhysicalActions(
                              context,
                              ref,
                              details.qrCode,
                            ),

                          if (isPhysical &&
                              isAssigned)
                            _buildAssignedPhysicalActions(
                              context,
                              ref,
                              details.businessName,
                              details.qrCode,
                              isActive,
                            ),

                          if (isPhysical &&
                              !isActive)
                            _buildInactivePhysicalMessage(
                              context,
                            ),

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
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      dynamic details,
      bool isPhysical,
      bool isActive,
      ) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final compact =
            constraints.maxWidth < 430;

        if (compact) {
          return Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildQrIcon(
                    context,
                    isPhysical,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPhysical
                              ? 'Physical QR'
                              : 'Digital QR',
                          maxLines: 1,
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
                        const SizedBox(height: 6),
                        Text(
                          details.qrCode,
                          maxLines: 3,
                          overflow:
                          TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatusBadge(
                active: isActive,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildQrIcon(
              context,
              isPhysical,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    isPhysical
                        ? 'Physical QR'
                        : 'Digital QR',
                    maxLines: 1,
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
                  const SizedBox(height: 6),
                  Text(
                    details.qrCode,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _StatusBadge(
              active: isActive,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQrIcon(
      BuildContext context,
      bool isPhysical,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Icon(
        isPhysical
            ? Icons.qr_code_2_rounded
            : Icons.qr_code_rounded,
        color: theme.colorScheme.primary,
        size: 28,
      ),
    );
  }

  // ============================================================
  // QR INFORMATION
  // ============================================================

  Widget _buildQrInformation(
      BuildContext context,
      dynamic details,
      bool isAssigned,
      bool isActive,
      ) {
    return Column(
      children: [
        _InfoRow(
          label: 'Type',
          value: details.type,
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
              ? details.businessName!
              : 'Not assigned',
        ),
        if (details.businessId != null)
          _InfoRow(
            label: 'Business ID',
            value: details.businessId!,
          ),
      ],
    );
  }

  // ============================================================
  // AVAILABLE PHYSICAL
  // ============================================================

  Widget _buildAvailablePhysicalActions(
      BuildContext context,
      WidgetRef ref,
      String qrCode,
      ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                    style: TextStyle(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () async {
                final result =
                await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      _AssignBusinessDialog(
                        qrCode: qrCode,
                      ),
                );

                if (!context.mounted) {
                  return;
                }

                if (result == true) {
                  await ref
                      .read(
                    adminNotifierProvider
                        .notifier,
                  )
                      .loadQrDetails(qrCode);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        behavior:
                        SnackBarBehavior.floating,
                        content: Text(
                          'QR assigned successfully.',
                        ),
                      ),
                    );
                }
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme
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
                    ? Icons.business_rounded
                    : Icons.block_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? 'Assigned Business'
                          : 'Assigned QR is inactive',
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    if (businessName
                        ?.trim()
                        .isNotEmpty ==
                        true) ...[
                      const SizedBox(height: 4),
                      Text(
                        businessName!,
                        maxLines: 3,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isActive)
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeactivateConfirmation(
                  context,
                  ref,
                  qrCode,
                );
              },
              icon: const Icon(
                Icons.block_rounded,
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
  // INACTIVE
  // ============================================================

  Widget _buildInactivePhysicalMessage(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        theme.colorScheme.errorContainer,
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
              style: TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIGITAL
  // ============================================================

  Widget _buildDigitalQrMessage(
      BuildContext context,
      String? businessName,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              businessName
                  ?.trim()
                  .isNotEmpty ==
                  true
                  ? 'Digital QR is permanently linked to ${businessName!.trim()} and cannot be assigned as a physical QR or manually deactivated.'
                  : 'Digital QR is business-linked and cannot be assigned as a physical QR or manually deactivated.',
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEACTIVATE
  // ============================================================

  Future<void> _showDeactivateConfirmation(
      BuildContext context,
      WidgetRef ref,
      String qrCode,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
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

    final success =
    await ref
        .read(
      adminNotifierProvider.notifier,
    )
        .deactivateQr(qrCode);

    if (!context.mounted) {
      return;
    }

    if (success) {
      await ref
          .read(
        adminNotifierProvider.notifier,
      )
          .loadQrDetails(qrCode);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            content: Text(
              'QR deactivated successfully.',
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
              'Unable to deactivate QR.';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior.floating,
            content: Text(message),
          ),
        );
    }
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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

// ================================================================
// ASSIGN BUSINESS DIALOG
// ================================================================

class _AssignBusinessDialog
    extends ConsumerStatefulWidget {
  const _AssignBusinessDialog({
    required this.qrCode,
  });

  final String qrCode;

  @override
  ConsumerState<
      _AssignBusinessDialog> createState() =>
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
        .addPostFrameCallback(
          (_) {
        ref
            .read(
          adminNotifierProvider
              .notifier,
        )
            .loadBusinesses();
      },
    );
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
      adminNotifierProvider.notifier,
    )
        .searchBusinesses(value);
  }

  Future<void> _assign() async {
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            content: Text(
              'Select a business first.',
            ),
          ),
        );
      return;
    }

    final notifier =
    ref.read(
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
      // Return the result to the QR details
      // screen. Do not show success feedback
      // from the dialog context after popping.
      Navigator.of(context).pop(true);
      return;
    }

    final message =
        ref
            .read(
          adminNotifierProvider,
        )
            .errorMessage ??
            'Unable to assign QR code.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state = ref.watch(
      adminNotifierProvider,
    );

    final screenWidth =
        MediaQuery.sizeOf(context).width;

    final dialogWidth =
    screenWidth < 600
        ? screenWidth * 0.90
        : 500.0;

    final maxDialogHeight =
        MediaQuery.sizeOf(context).height *
            0.70;

    return AlertDialog(
      title: const Text(
        'Assign Business',
      ),
      content: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
            maxDialogHeight.clamp(
              320.0,
              560.0,
            ),
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'QR Code: ${widget.qrCode}',
                  maxLines: 3,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                _searchController,
                onChanged: _search,
                textInputAction:
                TextInputAction.search,
                decoration:
                InputDecoration(
                  labelText:
                  'Search business',
                  prefixIcon:
                  const Icon(
                    Icons.search_rounded,
                  ),
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                _buildBusinessList(
                  context,
                  state,
                ),
              ),
            ],
          ),
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

  Widget _buildBusinessList(
      BuildContext context,
      dynamic state,
      ) {
    if (state.isLoading &&
        state.businesses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.businesses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No businesses found.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.businesses.length,
      separatorBuilder: (
          _,
          __,
          ) =>
      const Divider(height: 1),
      itemBuilder: (
          context,
          index,
          ) {
        final business =
        state.businesses[index];

        final selected =
            _selectedBusinessId ==
                business.businessId;

        return ListTile(
          selected: selected,
          selectedTileColor:
          Theme.of(context)
              .colorScheme
              .primaryContainer,
          leading: const Icon(
            Icons.storefront_outlined,
          ),
          title: Text(
            business.businessName,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
          ),
          subtitle: Text(
            business.city.isNotEmpty
                ? business.city
                : business.ownerName,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
          ),
          trailing: selected
              ? const Icon(
            Icons.check_circle,
          )
              : null,
          onTap: () {
            setState(() {
              _selectedBusinessId =
                  business.businessId;
              _selectedBusinessName =
                  business.businessName;
            });
          },
        );
      },
    );
  }
}

// ================================================================
// INFO ROW
// ================================================================

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
    final theme = Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final compact =
              constraints.maxWidth < 380;

          if (compact) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
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
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 4,
                  overflow:
                  TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
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
                width: 110,
                child: Text(
                  label,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  maxLines: 4,
                  overflow:
                  TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
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
