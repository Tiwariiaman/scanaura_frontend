import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanaura_frontend/features/subscription/presentation/subscription_request_screen.dart';

import '../data/models/subscription_history_response.dart';
import 'providers/subscription_notifier.dart';
import 'providers/subscription_state.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({
    super.key,
  });

  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends ConsumerState<SubscriptionScreen> {
  static const Color _primary = Color(0xFF00674F);
  static const Color _primaryDark = Color(0xFF004D3B);
  static const Color _softGreen = Color(0xFFE8F5F1);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  static const String _launchOriginalMonthly = '₹149';
  static const String _launchOriginalHalfYearly = '₹749';
  static const String _launchOriginalYearly = '₹1,499';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
        final notifier = ref.read(
          subscriptionNotifierProvider.notifier,
        );

        await notifier.loadSubscription();
        await notifier.loadHistory();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      subscriptionNotifierProvider,
    );

    if (state.status == SubscriptionStatusState.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == SubscriptionStatusState.error) {
      return _buildError(
        context,
        state,
      );
    }

    final subscription = state.subscription;

    if (subscription == null) {
      return _buildUnavailable(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final notifier = ref.read(
            subscriptionNotifierProvider.notifier,
          );

          await notifier.loadSubscription();
          await notifier.loadHistory();
        },
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 12.0
                : width < 600
                ? 16.0
                : 24.0;

            final maxWidth = width >= 1100
                ? 1000.0
                : width >= 800
                ? 820.0
                : 620.0;

            return ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                40,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        _buildPageHeader(context),

                        if (state.history.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildRequestStatus(
                            context,
                            state.history.first,
                          ),
                        ],

                        const SizedBox(height: 20),

                        _buildCurrentPlanCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(height: 16),

                        _buildSubscriptionPeriodCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(height: 16),

                        _buildAiUsageCard(
                          context,
                          subscription,
                        ),

                        const SizedBox(height: 28),

                        _buildLaunchSection(context),

                        const SizedBox(height: 28),

                        _buildIncludedFeatures(context),

                        const SizedBox(height: 28),

                        _buildHistorySection(context),
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
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rocket_launch_rounded,
                size: 15,
                color: _primary,
              ),
              SizedBox(width: 6),
              Text(
                'LAUNCH OFFER',
                style: TextStyle(
                  color: _primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Grow your business with ScanAura',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
            fontWeight: FontWeight.w900,
            color: _textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Everything you need to build a better digital presence and engage more customers.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
            color: _textSecondary,
            height: 1.5,
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
    final status = subscription.status
        .toString()
        .split('.')
        .last
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            _primaryDark,
          ],
        ),
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
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
                  const Text(
                    'CURRENT PLAN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subscription.planName,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _statusBadge(
                    context,
                    status,
                    light: true,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT PLAN',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subscription.planName,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _statusBadge(
                  context,
                  status,
                  light: true,
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
    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context,
            'Subscription Period',
            Icons.calendar_month_rounded,
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
    );
  }

  // ============================================================
  // AI USAGE
  // ============================================================

  Widget _buildAiUsageCard(
      BuildContext context,
      dynamic subscription,
      ) {
    final limit = subscription.aiImportLimit;
    final used = subscription.aiImportUsed;

    final progress = limit > 0
        ? (used / limit).clamp(0.0, 1.0)
        : 0.0;

    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Menu Imports',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Included with your ScanAura plan',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                        _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '$used / $limit',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (limit > 0)
                Text(
                  '${limit - used} left',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your plan includes 3 AI Menu Imports.',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAUNCH OFFER
  // ============================================================

  Widget _buildLaunchSection(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'ScanAura Launch Offer',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Full access. No feature restrictions.',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            if (constraints.maxWidth < 700) {
              return Column(
                children: [
                  _buildPricingCard(
                    context,
                    title: 'Monthly',
                    price: '₹99',
                    originalPrice:
                    _launchOriginalMonthly,
                    subtitle: 'per month',
                    badge: 'LAUNCH PRICE',
                  ),
                  const SizedBox(height: 14),
                  _buildPricingCard(
                    context,
                    title: '6 Months',
                    price: '₹499',
                    originalPrice:
                    _launchOriginalHalfYearly,
                    subtitle: 'for 6 months',
                    badge: 'BEST VALUE',
                    highlighted: true,
                  ),
                  const SizedBox(height: 14),
                  _buildPricingCard(
                    context,
                    title: 'Yearly',
                    price: '₹999',
                    originalPrice:
                    _launchOriginalYearly,
                    subtitle: 'per year',
                    badge: 'SAVE MORE',
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPricingCard(
                    context,
                    title: 'Monthly',
                    price: '₹99',
                    originalPrice:
                    _launchOriginalMonthly,
                    subtitle: 'per month',
                    badge: 'LAUNCH PRICE',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPricingCard(
                    context,
                    title: '6 Months',
                    price: '₹499',
                    originalPrice:
                    _launchOriginalHalfYearly,
                    subtitle: 'for 6 months',
                    badge: 'BEST VALUE',
                    highlighted: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPricingCard(
                    context,
                    title: 'Yearly',
                    price: '₹999',
                    originalPrice:
                    _launchOriginalYearly,
                    subtitle: 'per year',
                    badge: 'SAVE MORE',
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
  // PRICING CARD
  // ============================================================

  Widget _buildPricingCard(
      BuildContext context, {
        required String title,
        required String price,
        required String originalPrice,
        required String subtitle,
        required String badge,
        bool highlighted = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? _primary
              : _border,
          width: highlighted ? 1.7 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              highlighted ? 0.08 : 0.035,
            ),
            blurRadius:
            highlighted ? 22 : 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: highlighted
                        ? _primary
                        : _softGreen,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: highlighted
                          ? Colors.white
                          : _primary,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 3,
                  ),
                  child: Text(
                    originalPrice,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w600,
                      decoration:
                      TextDecoration
                          .lineThrough,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _softGreen,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: _primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Full ScanAura access',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: _primary,
                  size: 17,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '3 AI Menu Imports',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: highlighted
                      ? _primary
                      : _primaryDark,
                  foregroundColor:
                  Colors.white,
                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 13,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                onPressed: () async {
                  final result =
                  await Navigator.of(
                    context,
                  ).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SubscriptionRequestScreen(
                            planName: 'BASIC',
                          ),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  if (result == true) {
                    final notifier =
                    ref.read(
                      subscriptionNotifierProvider
                          .notifier,
                    );

                    await notifier
                        .loadSubscription();

                    await notifier
                        .loadHistory();
                  }
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INCLUDED FEATURES
  // ============================================================

  Widget _buildIncludedFeatures(
      BuildContext context,
      ) {
    const features = [
      (
      Icons.qr_code_2_rounded,
      'Digital QR',
      'Create a professional digital QR experience for your business.',
      ),
      (
      Icons.share_rounded,
      'Social Links',
      'Connect your Google, Instagram, Facebook and YouTube presence.',
      ),
      (
      Icons.auto_awesome_rounded,
      'AI Menu Import',
      'Turn your existing menu into a digital menu faster with AI.',
      ),
      (
      Icons.rate_review_rounded,
      'Google Reviews',
      'Help customers discover and engage with your business.',
      ),
      (
      Icons.campaign_rounded,
      'Activities',
      'Use customer activities to create meaningful engagement.',
      ),
      (
      Icons.people_alt_rounded,
      'Customer Engagement',
      'Build stronger interactions and encourage customers to return.',
      ),
      (
      Icons.support_agent_rounded,
      'Business Support',
      'Get support when you need help with ScanAura.',
      ),
      (
      Icons.more_horiz_rounded,
      'And More',
      'New business-growth tools will continue to be added.',
      ),
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Everything included',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'One plan. All the core tools your business needs.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final columns =
            constraints.maxWidth >= 650
                ? 2
                : 1;

            if (columns == 1) {
              return Column(
                children: [
                  for (var i = 0;
                  i < features.length;
                  i++) ...[
                    _buildFeatureTile(
                      context,
                      icon: features[i].$1,
                      title: features[i].$2,
                      description:
                      features[i].$3,
                    ),
                    if (i !=
                        features.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final feature in features)
                  SizedBox(
                    width:
                    (constraints.maxWidth -
                        10) /
                        2,
                    child:
                    _buildFeatureTile(
                      context,
                      icon: feature.$1,
                      title: feature.$2,
                      description:
                      feature.$3,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding:
            const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: _primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Widget _buildHistorySection(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Request History',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: _showHistory,
            icon: const Icon(
              Icons.history_rounded,
            ),
            label: const Text(
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

    final history = ref
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
                constraints.maxHeight * 0.85;

            if (history.isEmpty) {
              return SizedBox(
                height: maxHeight,
                child: const Center(
                  child: Padding(
                    padding:
                    EdgeInsets.all(24),
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
              height: maxHeight,
              child: ListView.separated(
                padding:
                const EdgeInsets.all(20),
                itemCount: history.length,
                separatorBuilder:
                    (_, _) =>
                const SizedBox(
                  height: 12,
                ),
                itemBuilder: (
                    _,
                    index,
                    ) {
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
                                  maxLines: 1,
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
                                  height: 6,
                                ),
                                Text(
                                  '${item.billingCycle} • ${item.status}',
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  _formatDate(
                                    item.requestedAt,
                                  ),
                                  style:
                                  const TextStyle(
                                    color:
                                    _textSecondary,
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
                                      height: 4,
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
                                  item.requestedAt,
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
  // REQUEST STATUS
  // ============================================================

  Widget _buildRequestStatus(
      BuildContext context,
      SubscriptionHistoryResponse request,
      ) {
    final status =
    request.status.toUpperCase();

    String title;
    IconData icon;

    switch (status) {
      case 'PENDING':
        title =
        'Waiting for admin approval';
        icon = Icons.hourglass_top_rounded;
        break;

      case 'APPROVED':
        title = 'Subscription approved';
        icon =
            Icons.check_circle_outline_rounded;
        break;

      case 'REJECTED':
        title = 'Subscription rejected';
        icon = Icons.cancel_outlined;
        break;

      default:
        title = status;
        icon = Icons.info_outline_rounded;
    }

    return _sectionCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Subscription Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
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
            _formatDate(
              request.requestedAt,
            ),
            isLast:
            request.adminRemark == null ||
                request.adminRemark!.isEmpty,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (request.adminRemark != null &&
              request.adminRemark!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Admin remark',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.adminRemark!,
              style: const TextStyle(
                color: _textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    );
  }

  Widget _sectionTitle(
      BuildContext context,
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Container(
          padding:
          const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context)
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

  Widget _statusBadge(
      BuildContext context,
      String value, {
        bool light = false,
      }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withOpacity(0.16)
            : _softGreen,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow:
        TextOverflow.ellipsis,
        style: TextStyle(
          color: light
              ? Colors.white
              : _primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext context,
      String label,
      String value, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 12,
      ),
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final compact =
              constraints.maxWidth < 400;

          if (compact) {
            return Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign:
                  TextAlign.end,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
            const EdgeInsets.all(24),
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
                      label: const Text(
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