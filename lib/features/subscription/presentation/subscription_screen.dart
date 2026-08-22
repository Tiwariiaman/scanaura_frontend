import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanaura_frontend/features/subscription/presentation/subscription_request_screen.dart';

import '../data/models/subscription_history_response.dart';

import 'providers/subscription_notifier.dart';
import 'providers/subscription_state.dart';

class SubscriptionScreen
    extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen>
  createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends ConsumerState<SubscriptionScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(
        subscriptionNotifierProvider.notifier,
      );

      await notifier.loadSubscription();
      await notifier.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(subscriptionNotifierProvider);

    if (state.status ==
        SubscriptionStatusState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status ==
        SubscriptionStatusState.error) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Subscription'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ??
                      'Unable to load subscription.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(
                      subscriptionNotifierProvider
                          .notifier,
                    )
                        .loadSubscription();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final subscription =
        state.subscription;

    if (subscription == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Subscription not available.',
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            subscriptionNotifierProvider
                .notifier,
          )
              .loadSubscription();
        },
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your Subscription',
              style: theme
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),
            if (state.history.isNotEmpty) ...[
              _buildRequestStatus(
                context,
                state.history.first,
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Manage your ScanAura plan and usage.',
              style: theme
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Current plan
            Card(
              elevation: 0,
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      subscription.planName,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _statusBadge(
                      context,
                      subscription
                          .status.name
                          .toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Trial / dates
            Card(
              elevation: 0,
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Period',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _detailRow(
                      context,
                      'Started',
                      _formatDate(
                        subscription.startDate,
                      ),
                    ),

                    _detailRow(
                      context,
                      'Expires',
                      _formatDate(
                        subscription.endDate,
                      ),
                    ),

                    if (subscription.status.name ==
                        'trial')
                      _detailRow(
                        context,
                        'Days remaining',
                        '${subscription.trialDaysLeft}',
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AI usage
            Card(
              elevation: 0,
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Menu Imports',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '${subscription.aiImportUsed} / ${subscription
                          .aiImportLimit}',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    LinearProgressIndicator(
                      value:
                      subscription.aiImportLimit >
                          0
                          ? (subscription
                          .aiImportUsed /
                          subscription
                              .aiImportLimit)
                          .clamp(0.0, 1.0)
                          : 0,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Features
            Card(
              elevation: 0,
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Features',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _featureRow(
                      context,
                      'Digital QR',
                      true,
                    ),

                    _featureRow(
                      context,
                      'Menu management',
                      true,
                    ),

                    _featureRow(
                      context,
                      'AI menu imports',
                      true,
                    ),

                    _featureRow(
                      context,
                      'Branded QR',
                      subscription.brandedQr,
                    ),

                    _featureRow(
                      context,
                      'Priority support',
                      subscription.prioritySupport,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Choose a paid plan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Upgrade after your trial or choose a plan for continued access.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    context,
                    planName: 'BASIC',
                    monthlyPrice: '₹99',
                    yearlyPrice: '₹999',
                    aiImports: '3 AI imports',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPlanCard(
                    context,
                    planName: 'PLUS',
                    monthlyPrice: '₹199',
                    yearlyPrice: '₹1999',
                    aiImports: '4 AI imports',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Text(
              'Request History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            FilledButton.tonal(
              onPressed: () async {
                await ref
                    .read(
                  subscriptionNotifierProvider.notifier,
                )
                    .loadHistory();

                if (!context.mounted) {
                  return;
                }

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    final history = ref
                        .read(subscriptionNotifierProvider)
                        .history;

                    if (history.isEmpty) {
                      return const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No subscription requests yet.',
                            ),
                          ),
                        ),
                      );
                    }

                    return SafeArea(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        itemCount: history.length,
                        separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final item = history[index];

                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(
                                item.planName,
                              ),
                              subtitle: Text(
                                '${item.billingCycle} • '
                                    '${item.status}',
                              ),
                              trailing: Text(
                                _formatDate(item.requestedAt),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: const Text(
                'View Request History',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context,
      String value,) {
    final theme = Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
        theme.colorScheme.primaryContainer,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: theme
            .textTheme
            .labelLarge
            ?.copyWith(
          color: theme.colorScheme
              .onPrimaryContainer,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context,
      String label,
      String value,) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(BuildContext context,
      String label,
      bool enabled,) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            enabled
                ? Icons.check_circle_rounded
                : Icons.cancel_outlined,
            size: 20,
            color: enabled
                ? Theme
                .of(context)
                .colorScheme
                .primary
                : Theme
                .of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, {
    required String planName,
    required String monthlyPrice,
    required String yearlyPrice,
    required String aiImports,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$monthlyPrice/month',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '$yearlyPrice/year',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(aiImports),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubscriptionRequestScreen(
                        planName: planName,
                      ),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  if (result == true) {
                    await ref
                        .read(
                      subscriptionNotifierProvider.notifier,
                    )
                        .loadSubscription();

                    await ref
                        .read(
                      subscriptionNotifierProvider.notifier,
                    )
                        .loadHistory();
                  }
                },
                child: const Text(
                  'Choose Plan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestStatus(
      BuildContext context,
      SubscriptionHistoryResponse request,
      ) {
    final theme = Theme.of(context);

    final status = request.status.toUpperCase();

    String title;
    IconData icon;

    switch (status) {
      case 'PENDING':
        title = 'Waiting for admin approval';
        icon = Icons.hourglass_top_rounded;
        break;

      case 'APPROVED':
        title = 'Subscription approved';
        icon = Icons.check_circle_outline_rounded;
        break;

      case 'REJECTED':
        title = 'Subscription rejected';
        icon = Icons.cancel_outlined;
        break;

      default:
        title = status;
        icon = Icons.info_outline_rounded;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Subscription Request',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _detailRow(
              context,
              'Plan',
              request.planName,
            ),

            _detailRow(
              context,
              'Billing cycle',
              request.billingCycle,
            ),

            _detailRow(
              context,
              'Status',
              status,
            ),

            _detailRow(
              context,
              'Requested',
              _formatDate(request.requestedAt),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            if (request.adminRemark != null &&
                request.adminRemark!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Admin remark',
                style:
                theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                request.adminRemark!,
                style:
                theme.textTheme.bodyMedium,
              ),
            ],
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

  // Future<void> _openUpgradeRequest(
  //     BuildContext context,
  //     String planName,
  //     ) async {
  //   final transactionController =
  //   TextEditingController();
  //
  //   String billingCycle = 'MONTHLY';
  //
  //   await showDialog<void>(
  //     context: context,
  //     builder: (dialogContext) {
  //       return StatefulBuilder(
  //         builder: (
  //             context,
  //             setDialogState,
  //             ) {
  //           return AlertDialog(
  //             title: Text(
  //               'Request $planName',
  //             ),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   DropdownButtonFormField<String>(
  //                     initialValue: billingCycle,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Billing cycle',
  //                     ),
  //                     items: const [
  //                       DropdownMenuItem(
  //                         value: 'MONTHLY',
  //                         child: Text('Monthly'),
  //                       ),
  //                       DropdownMenuItem(
  //                         value: 'YEARLY',
  //                         child: Text('Yearly'),
  //                       ),
  //                     ],
  //                     onChanged: (value) {
  //                       if (value == null) {
  //                         return;
  //                       }
  //
  //                       setDialogState(() {
  //                         billingCycle = value;
  //                       });
  //                     },
  //                   ),
  //
  //                   const SizedBox(height: 16),
  //
  //                   TextField(
  //                     controller: transactionController,
  //                     decoration: const InputDecoration(
  //                       labelText: 'Transaction ID',
  //                       hintText: 'Enter your UPI transaction ID',
  //                     ),
  //                   ),
  //
  //                   const SizedBox(height: 16),
  //
  //                   Container(
  //                     width: double.infinity,
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Theme.of(context)
  //                           .colorScheme
  //                           .surfaceContainerHighest,
  //                       borderRadius:
  //                       BorderRadius.circular(12),
  //                     ),
  //                     child: const Column(
  //                       crossAxisAlignment:
  //                       CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Payment',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w700,
  //                           ),
  //                         ),
  //                         SizedBox(height: 8),
  //                         Text(
  //                           'Complete the UPI payment and enter the transaction ID above. Payment screenshot upload will be connected next.',
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(dialogContext).pop();
  //                 },
  //                 child: const Text('Cancel'),
  //               ),
  //               FilledButton(
  //                 onPressed: () async {
  //                   final transactionId =
  //                   transactionController.text.trim();
  //
  //                   if (transactionId.isEmpty) {
  //                     ScaffoldMessenger.of(context)
  //                         .showSnackBar(
  //                       const SnackBar(
  //                         content: Text(
  //                           'Transaction ID is required.',
  //                         ),
  //                       ),
  //                     );
  //                     return;
  //                   }
  //
  //                   Navigator.of(dialogContext).pop();
  //
  //                   await ref
  //                       .read(
  //                     subscriptionNotifierProvider
  //                         .notifier,
  //                   )
  //                       .createSubscriptionRequest(
  //                     SubscriptionRequest(
  //                       planName: planName,
  //                       billingCycle: billingCycle,
  //                       transactionId: transactionId,
  //                       paymentScreenshotUrl: '',
  //                     ),
  //                   );
  //
  //                   if (!mounted) {
  //                     return;
  //                   }
  //
  //                   final state = ref.read(
  //                     subscriptionNotifierProvider,
  //                   );
  //
  //                   if (state.status ==
  //                       SubscriptionStatusState.success ||
  //                       state.errorMessage == null) {
  //                     ScaffoldMessenger.of(context)
  //                         .showSnackBar(
  //                       const SnackBar(
  //                         content: Text(
  //                           'Subscription request submitted successfully.',
  //                         ),
  //                       ),
  //                     );
  //                   } else {
  //                     ScaffoldMessenger.of(context)
  //                         .showSnackBar(
  //                       SnackBar(
  //                         content: Text(
  //                           state.errorMessage!,
  //                         ),
  //                       ),
  //                     );
  //                   }
  //                 },
  //                 child: const Text('Submit Request'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  //
  //   transactionController.dispose();
  // }
