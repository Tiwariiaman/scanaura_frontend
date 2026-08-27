import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanaura_frontend/features/subscription/presentation/subscription_request_screen.dart';

import '../data/models/subscription_history_response.dart';
import 'providers/subscription_notifier.dart';
import 'providers/subscription_state.dart';

class SubscriptionScreen
    extends ConsumerStatefulWidget {
  const SubscriptionScreen({
    super.key,
  });

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

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) async {
        final notifier = ref.read(
          subscriptionNotifierProvider
              .notifier,
        );

        await notifier.loadSubscription();
        await notifier.loadHistory();
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state = ref.watch(
      subscriptionNotifierProvider,
    );

    if (state.status ==
        SubscriptionStatusState.loading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (state.status ==
        SubscriptionStatusState.error) {
      return _buildError(
        context,
        state,
      );
    }

    final subscription =
        state.subscription;

    if (subscription == null) {
      return _buildUnavailable(
        context,
      );
    }

    final theme =
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final notifier =
          ref.read(
            subscriptionNotifierProvider
                .notifier,
          );

          await notifier
              .loadSubscription();
          await notifier
              .loadHistory();
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
                : 24.0;

            final maxWidth =
            width >= 1100
                ? 1000.0
                : width >= 800
                ? 820.0
                : 620.0;

            return ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              children: [
                Center(
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
                        _buildPageHeader(
                          context,
                        ),

                        if (state.history
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          _buildRequestStatus(
                            context,
                            state.history
                                .first,
                          ),
                        ],

                        const SizedBox(
                          height: 20,
                        ),

                        _buildCurrentPlanCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        _buildSubscriptionPeriodCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        _buildAiUsageCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        _buildFeaturesCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        _buildPaidPlansSection(
                          context,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        _buildHistorySection(
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildPageHeader(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Your Subscription',
          style: theme
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          'Manage your ScanAura plan and usage.',
          style: theme
              .textTheme
              .bodyLarge
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
  // CURRENT PLAN
  // ============================================================

  Widget _buildCurrentPlanCard(
      BuildContext context,
      dynamic subscription,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final compact =
                constraints.maxWidth <
                    430;

            if (compact) {
              return Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    subscription
                        .planName,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _statusBadge(
                    context,
                      subscription.status.toString().split('.').last.toUpperCase(),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'Current Plan',
                        style: theme
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        subscription
                            .planName,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style: theme
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                _statusBadge(
                  context,
                    subscription.status.toString().split('.').last.toUpperCase(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SUBSCRIPTION PERIOD
  // ============================================================

  Widget _buildSubscriptionPeriodCard(
      BuildContext context,
      dynamic subscription,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
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

            const SizedBox(
              height: 16,
            ),

            _detailRow(
              context,
              'Started',
              _formatDate(
                subscription
                    .startDate,
              ),
            ),

            _detailRow(
              context,
              'Expires',
              _formatDate(
                subscription
                    .endDate,
              ),
            ),

            if (subscription.status
                .toString()
                .split('.')
                .last
                .toUpperCase() ==
                'TRIAL')
              _detailRow(
                context,
                'Days remaining',
                '${subscription.trialDaysLeft}',
                isLast: true,
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
      dynamic subscription,
      ) {
    final theme =
    Theme.of(context);

    final limit =
        subscription.aiImportLimit;

    final used =
        subscription.aiImportUsed;

    final progress =
    limit > 0
        ? (used / limit)
        .clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
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

            const SizedBox(
              height: 14,
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    '$used / $limit',
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
                if (limit > 0)
                  Text(
                    '${limit - used} left',
                    style: theme
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
              child:
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeaturesCard(
      BuildContext context,
      dynamic subscription,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
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

            const SizedBox(
              height: 12,
            ),

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
              subscription
                  .brandedQr,
            ),

            _featureRow(
              context,
              'Priority support',
              subscription
                  .prioritySupport,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAID PLANS
  // ============================================================

  Widget _buildPaidPlansSection(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a paid plan',
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
          'Upgrade after your trial or choose a plan for continued access.',
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

        const SizedBox(
          height: 16,
        ),

        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            if (constraints
                .maxWidth <
                600) {
              return Column(
                children: [
                  _buildPlanCard(
                    context,
                    planName: 'BASIC',
                    monthlyPrice:
                    '₹99',
                    yearlyPrice:
                    '₹999',
                    aiImports:
                    '3 AI imports',
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildPlanCard(
                    context,
                    planName: 'PLUS',
                    monthlyPrice:
                    '₹199',
                    yearlyPrice:
                    '₹1999',
                    aiImports:
                    '4 AI imports',
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
                  _buildPlanCard(
                    context,
                    planName:
                    'BASIC',
                    monthlyPrice:
                    '₹99',
                    yearlyPrice:
                    '₹999',
                    aiImports:
                    '3 AI imports',
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                  _buildPlanCard(
                    context,
                    planName:
                    'PLUS',
                    monthlyPrice:
                    '₹199',
                    yearlyPrice:
                    '₹1999',
                    aiImports:
                    '4 AI imports',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Widget _buildHistorySection(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Request History',
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        SizedBox(
          width:
          double.infinity,
          child:
          FilledButton.tonal(
            onPressed:
            _showHistory,
            child: const Text(
              'View Request History',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showHistory() async {
    await ref
        .read(
      subscriptionNotifierProvider
          .notifier,
    )
        .loadHistory();

    if (!mounted) {
      return;
    }

    final history =
        ref
            .read(
          subscriptionNotifierProvider,
        )
            .history;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final maxHeight =
                constraints
                    .maxHeight *
                    0.85;

            if (history.isEmpty) {
              return SizedBox(
                height:
                maxHeight,
                child: const Center(
                  child: Padding(
                    padding:
                    EdgeInsets.all(
                      24,
                    ),
                    child: Text(
                      'No subscription requests yet.',
                      textAlign:
                      TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height:
              maxHeight,
              child: ListView.separated(
                padding:
                const EdgeInsets.all(
                  20,
                ),
                itemCount:
                history.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  height: 12,
                ),
                itemBuilder:
                    (_, index) {
                  final item =
                  history[index];

                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding:
                      const EdgeInsets
                          .all(14),
                      child: LayoutBuilder(
                        builder: (
                            context,
                            rowConstraints,
                            ) {
                          final compact =
                              rowConstraints
                                  .maxWidth <
                                  430;

                          if (compact) {
                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  item.planName,
                                  maxLines:
                                  1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                                const SizedBox(
                                  height:
                                  6,
                                ),
                                Text(
                                  '${item.billingCycle} • ${item.status}',
                                ),
                                const SizedBox(
                                  height:
                                  4,
                                ),
                                Text(
                                  _formatDate(
                                    item.requestedAt,
                                  ),
                                  style:
                                  TextStyle(
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

                          return Row(
                            children: [
                              Expanded(
                                child:
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      item
                                          .planName,
                                      maxLines:
                                      1,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w700,
                                      ),
                                    ),
                                    const SizedBox(
                                      height:
                                      4,
                                    ),
                                    Text(
                                      '${item.billingCycle} • ${item.status}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                _formatDate(
                                  item
                                      .requestedAt,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
      BuildContext context,
      String value,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .primaryContainer,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: theme
            .textTheme
            .labelLarge
            ?.copyWith(
          color: theme
              .colorScheme
              .onPrimaryContainer,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
      BuildContext context,
      String label,
      String value, {
        bool isLast = false,
      }) {
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      EdgeInsets.only(
        bottom:
        isLast ? 0 : 12,
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final compact =
              constraints.maxWidth <
                  400;

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
                  height: 3,
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign:
                  TextAlign.end,
                  maxLines: 2,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
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

  // ============================================================
  // FEATURE ROW
  // ============================================================

  Widget _featureRow(
      BuildContext context,
      String label,
      bool enabled, {
        bool isLast = false,
      }) {
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      EdgeInsets.only(
        bottom:
        isLast ? 0 : 12,
      ),
      child: Row(
        children: [
          Icon(
            enabled
                ? Icons
                .check_circle_rounded
                : Icons
                .cancel_outlined,
            size: 20,
            color: enabled
                ? theme
                .colorScheme
                .primary
                : theme
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow:
              TextOverflow
                  .ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAN CARD
  // ============================================================

  Widget _buildPlanCard(
      BuildContext context, {
        required String planName,
        required String monthlyPrice,
        required String yearlyPrice,
        required String aiImports,
      }) {
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
                Expanded(
                  child: Text(
                    planName,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              '$monthlyPrice/month',
              style: theme
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              '$yearlyPrice/year',
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Icon(
                  Icons
                      .check_rounded,
                  size: 18,
                  color: theme
                      .colorScheme
                      .primary,
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    aiImports,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width:
              double.infinity,
              child:
              FilledButton(
                onPressed:
                    () async {
                  final result =
                  await Navigator.of(
                    context,
                  ).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SubscriptionRequestScreen(
                            planName:
                            planName,
                          ),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  if (result ==
                      true) {
                    await ref
                        .read(
                      subscriptionNotifierProvider
                          .notifier,
                    )
                        .loadSubscription();

                    await ref
                        .read(
                      subscriptionNotifierProvider
                          .notifier,
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

  // ============================================================
  // REQUEST STATUS
  // ============================================================

  Widget _buildRequestStatus(
      BuildContext context,
      SubscriptionHistoryResponse
      request,
      ) {
    final theme =
    Theme.of(context);

    final status =
    request.status
        .toUpperCase();

    String title;
    IconData icon;

    switch (status) {
      case 'PENDING':
        title =
        'Waiting for admin approval';
        icon =
            Icons
                .hourglass_top_rounded;
        break;

      case 'APPROVED':
        title =
        'Subscription approved';
        icon =
            Icons
                .check_circle_outline_rounded;
        break;

      case 'REJECTED':
        title =
        'Subscription rejected';
        icon =
            Icons
                .cancel_outlined;
        break;

      default:
        title = status;
        icon =
            Icons
                .info_outline_rounded;
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Icon(
                  icon,
                  color: theme
                      .colorScheme
                      .primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'Subscription Request',
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
              _formatDate(
                request.requestedAt,
              ),
              isLast:
              request.adminRemark ==
                  null ||
                  request.adminRemark!
                      .isEmpty,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              style: theme
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),

            if (request.adminRemark !=
                null &&
                request.adminRemark!
                    .isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              Text(
                'Admin remark',
                style: theme
                    .textTheme
                    .labelLarge,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                request.adminRemark!,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      SubscriptionState state,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription',
        ),
      ),
      body: SafeArea(
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
                        'Unable to load subscription.',
                    textAlign:
                    TextAlign.center,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    FilledButton
                        .icon(
                      onPressed:
                          () {
                        ref
                            .read(
                          subscriptionNotifierProvider
                              .notifier,
                        )
                            .loadSubscription();
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
      ),
    );
  }

  // ============================================================
  // UNAVAILABLE
  // ============================================================

  Widget _buildUnavailable(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription',
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding:
            EdgeInsets.all(24),
            child: Text(
              'Subscription not available.',
              textAlign:
              TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}