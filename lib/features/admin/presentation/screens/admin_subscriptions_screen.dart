import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/pending_subscription_request_response.dart';
import '../providers/admin_subscription_notifier.dart';
import '../providers/admin_subscription_state.dart';

class AdminSubscriptionsScreen
    extends ConsumerStatefulWidget {
  const AdminSubscriptionsScreen({
    super.key,
  });

  @override
  ConsumerState<AdminSubscriptionsScreen>
  createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState
    extends ConsumerState<
        AdminSubscriptionsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        adminSubscriptionNotifierProvider
            .notifier,
      )
          .loadPendingRequests();
    });
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _approveRequest(
      PendingSubscriptionRequestResponse
      request,
      ) async {
    final confirmed =
    await _showApproveDialog(
      request,
    );

    if (!confirmed || !mounted) {
      return;
    }

    final success =
    await ref
        .read(
      adminSubscriptionNotifierProvider
          .notifier,
    )
        .approveRequest(
      request.requestId,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      adminSubscriptionNotifierProvider,
    );

    _showMessage(
      success
          ? 'Subscription approved successfully.'
          : state.errorMessage ??
          'Unable to approve subscription.',
    );
  }

  Future<bool> _showApproveDialog(
      PendingSubscriptionRequestResponse
      request,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Approve Subscription?',
          ),
          content: Text(
            'Approve ${request.planName} '
                'for ${request.businessName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text('Approve'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectRequest(
      PendingSubscriptionRequestResponse
      request,
      ) async {
    final remark =
    await _showRejectDialog();

    if (remark == null ||
        !mounted) {
      return;
    }

    final success =
    await ref
        .read(
      adminSubscriptionNotifierProvider
          .notifier,
    )
        .rejectRequest(
      request.requestId,
      remark,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      adminSubscriptionNotifierProvider,
    );

    _showMessage(
      success
          ? 'Subscription rejected successfully.'
          : state.errorMessage ??
          'Unable to reject subscription.',
    );
  }

  Future<String?> _showRejectDialog() async {
    final controller =
    TextEditingController();

    final result =
    await showDialog<String>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Reject Subscription',
          ),
          content: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 500,
            ),
            child: TextField(
              controller:
              controller,
              maxLines: 4,
              autofocus: true,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              InputDecoration(
                labelText:
                'Remark',
                hintText:
                'Enter the reason for rejection',
                alignLabelWithHint:
                true,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final remark =
                controller.text
                    .trim();

                if (remark.isEmpty) {
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(
                    const SnackBar(
                      behavior:
                      SnackBarBehavior
                          .floating,
                      content: Text(
                        'Remark is required.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(remark);
              },
              child:
              const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ============================================================
  // SCREENSHOT
  // ============================================================

  Future<void> _showScreenshot(
      PendingSubscriptionRequestResponse
      request,
      ) async {
    final url =
        request.paymentScreenshotUrl;

    if (url == null ||
        url.trim().isEmpty) {
      _showMessage(
        'No payment screenshot available.',
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return Dialog(
          insetPadding:
          const EdgeInsets.all(
            16,
          ),
          child: LayoutBuilder(
            builder: (
                context,
                constraints,
                ) {
              final width =
                  constraints.maxWidth;

              final maxHeight =
                  MediaQuery.sizeOf(
                    context,
                  ).height *
                      0.80;

              return ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 720,
                ),
                child: SizedBox(
                  height:
                  maxHeight.clamp(
                    300.0,
                    800.0,
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets
                        .all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Payment Screenshot',
                                style:
                                TextStyle(
                                  fontSize:
                                  18,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip:
                              'Close',
                              onPressed: () {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              },
                              icon:
                              const Icon(
                                Icons.close,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Expanded(
                          child:
                          InteractiveViewer(
                            minScale:
                            0.5,
                            maxScale:
                            4,
                            child:
                            Center(
                              child:
                              Image.network(
                                url,
                                width:
                                width,
                                fit: BoxFit
                                    .contain,
                                loadingBuilder:
                                    (
                                    context,
                                    child,
                                    progress,
                                    ) {
                                  if (progress ==
                                      null) {
                                    return child;
                                  }

                                  return const Center(
                                    child:
                                    CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return const Center(
                                    child:
                                    Padding(
                                      padding:
                                      EdgeInsets
                                          .all(
                                        24,
                                      ),
                                      child:
                                      Text(
                                        'Unable to load payment screenshot.',
                                        textAlign:
                                        TextAlign
                                            .center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      adminSubscriptionNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscriptions',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            state.isLoading ||
                state
                    .isActionInProgress
                ? null
                : () {
              ref
                  .read(
                adminSubscriptionNotifierProvider
                    .notifier,
              )
                  .refresh();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            adminSubscriptionNotifierProvider
                .notifier,
          )
              .refresh();
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
                : 20.0;

            final maxWidth =
            width >= 1400
                ? 1200.0
                : 1100.0;

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
                child:
                ConstrainedBox(
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
                        state,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      if (state.isLoading &&
                          state.pendingRequests
                              .isEmpty)
                        const Center(
                          child:
                          CircularProgressIndicator(),
                        )
                      else if (state.hasError &&
                          state.pendingRequests
                              .isEmpty)
                        _buildError(
                          context,
                          state,
                        )
                      else if (state
                            .pendingRequests
                            .isEmpty)
                          _buildEmptyState(
                            context,
                          )
                        else
                          _buildRequestList(
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
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      AdminSubscriptionState state,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        Text(
          'Subscription Requests',
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
          '${state.pendingRequests.length} pending request'
              '${state.pendingRequests.length == 1 ? '' : 's'}',
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
  // REQUEST LIST
  // ============================================================

  Widget _buildRequestList(
      BuildContext context,
      AdminSubscriptionState state,
      ) {
    return Column(
      children: state
          .pendingRequests
          .map(
            (request) => Padding(
          padding:
          const EdgeInsets.only(
            bottom: 16,
          ),
          child:
          _buildRequestCard(
            context,
            request,
            state,
          ),
        ),
      )
          .toList(),
    );
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestCard(
      BuildContext context,
      PendingSubscriptionRequestResponse
      request,
      AdminSubscriptionState state,
      ) {
    final processing =
        state.processingRequestId ==
            request.requestId;

    return Card(
      clipBehavior:
      Clip.antiAlias,
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
            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final compact =
                    constraints
                        .maxWidth <
                        430;

                if (compact) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Expanded(
                            child:
                            _buildRequestTitle(
                              context,
                              request,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          _CycleChip(
                            cycle: request
                                .billingCycle,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Expanded(
                      child:
                      _buildRequestTitle(
                        context,
                        request,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    _CycleChip(
                      cycle: request
                          .billingCycle,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(
              height: 18,
            ),

            _InfoRow(
              label:
              'Transaction ID',
              value:
              request.transactionId
                  .trim()
                  .isEmpty
                  ? '—'
                  : request
                  .transactionId,
            ),

            _InfoRow(
              label: 'Requested',
              value:
              _formatDateTime(
                request.requestedAt,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            if (request
                .paymentScreenshotUrl
                ?.trim()
                .isNotEmpty ==
                true)
              SizedBox(
                width:
                double.infinity,
                child:
                OutlinedButton
                    .icon(
                  onPressed:
                  processing
                      ? null
                      : () =>
                      _showScreenshot(
                        request,
                      ),
                  icon:
                  const Icon(
                    Icons
                        .image_outlined,
                  ),
                  label:
                  const Text(
                    'View Payment Screenshot',
                  ),
                ),
              )
            else
              Text(
                'No payment screenshot available.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

            const SizedBox(
              height: 18,
            ),

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                final compact =
                    constraints.maxWidth <
                        520;

                if (compact) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child:
                        FilledButton(
                          onPressed:
                          processing ||
                              state
                                  .isActionInProgress
                              ? null
                              : () =>
                              _approveRequest(
                                request,
                              ),
                          child: Text(
                            processing
                                ? 'Processing...'
                                : 'Approve',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 48,
                        child:
                        OutlinedButton(
                          onPressed:
                          processing ||
                              state
                                  .isActionInProgress
                              ? null
                              : () =>
                              _rejectRequest(
                                request,
                              ),
                          child:
                          const Text(
                            'Reject',
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child:
                      SizedBox(
                        height: 48,
                        child:
                        FilledButton(
                          onPressed:
                          processing ||
                              state
                                  .isActionInProgress
                              ? null
                              : () =>
                              _approveRequest(
                                request,
                              ),
                          child: Text(
                            processing
                                ? 'Processing...'
                                : 'Approve',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                      SizedBox(
                        height: 48,
                        child:
                        OutlinedButton(
                          onPressed:
                          processing ||
                              state
                                  .isActionInProgress
                              ? null
                              : () =>
                              _rejectRequest(
                                request,
                              ),
                          child:
                          const Text(
                            'Reject',
                          ),
                        ),
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

  Widget _buildRequestTitle(
      BuildContext context,
      PendingSubscriptionRequestResponse
      request,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        Text(
          request.businessName,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          request.planName,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: theme
                .colorScheme
                .primary,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

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
                .assignment_turned_in_outlined,
            size: 56,
            color: theme
                .colorScheme
                .primary,
          ),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'No pending subscription requests.',
            textAlign:
            TextAlign.center,
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
            'New requests will appear here for review.',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color: theme
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
      AdminSubscriptionState state,
      ) {
    return Padding(
      padding:
      const EdgeInsets.all(
        24,
      ),
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
                    'Unable to load subscription requests.',
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width:
                double.infinity,
                child:
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(
                      adminSubscriptionNotifierProvider
                          .notifier,
                    )
                        .refresh();
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

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(
      DateTime? dateTime,
      ) {
    if (dateTime == null) {
      return '—';
    }

    final local =
    dateTime.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// ================================================================
// BILLING CYCLE CHIP
// ================================================================

class _CycleChip
    extends StatelessWidget {
  const _CycleChip({
    required this.cycle,
  });

  final AdminBillingCycle cycle;

  @override
  Widget build(
      BuildContext context,
      ) {
    final label =
    switch (cycle) {
      AdminBillingCycle.monthly =>
      'Monthly',
      AdminBillingCycle.yearly =>
      'Yearly',
      AdminBillingCycle.unknown =>
      'Unknown',
    };

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
        color: theme
            .colorScheme
            .secondaryContainer,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w700,
          color: theme
              .colorScheme
              .onSecondaryContainer,
        ),
      ),
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
          final compact =
              constraints.maxWidth <
                  380;

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
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value.isEmpty
                      ? '—'
                      : value,
                  softWrap: true,
                  maxLines: 4,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              SizedBox(
                width: 125,
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
                width: 10,
              ),
              Expanded(
                child: Text(
                  value.isEmpty
                      ? '—'
                      : value,
                  softWrap: true,
                  maxLines: 4,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  const TextStyle(
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