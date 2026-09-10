import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/app_providers.dart';
import '../../models/loyalty_customer_response.dart';
import '../../models/loyalty_reward_response.dart';
import '../../models/loyalty_claim_response.dart';
import '../../services/loyalty_api_service.dart';

import 'customer_loyalty_qr_page.dart';
import 'customer_loyalty_visit_qr_page.dart';

class CustomerLoyaltyPage extends ConsumerStatefulWidget {
  final String businessId;
  final String businessName;

  const CustomerLoyaltyPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  @override
  ConsumerState<CustomerLoyaltyPage> createState() =>
      _CustomerLoyaltyPageState();
}

class _CustomerLoyaltyPageState
    extends ConsumerState<CustomerLoyaltyPage> {
  late final LoyaltyApiService _apiService;

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  LoyaltyCustomerResponse? _customer;
  List<LoyaltyRewardResponse> _rewards = [];

  bool _loading = false;
  bool _loadingRewards = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    _apiService = LoyaltyApiService(
      apiClient: ref.read(apiClientProvider),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE / UPDATE CUSTOMER
  // ============================================================

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (mobile.isEmpty) {
      _showError('Please enter your mobile number.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final customer =
      await _apiService.createOrUpdateCustomer(
        businessId: widget.businessId,
        customerName: name,
        mobileNumber: mobile,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _customer = customer;
        _submitted = true;
      });

      await _loadRewards();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // GENERATE VISIT QR
  // ============================================================

  Future<void> _generateVisitQr() async {
    final customer = _customer;

    if (customer == null) {
      _showError(
        'Please complete your loyalty profile first.',
      );
      return;
    }

    final mobile = customer.mobileNumber.trim();

    if (mobile.isEmpty) {
      _showError(
        'Customer mobile number is missing.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final qr = await _apiService.createVisitQr(
        businessId: widget.businessId,
        mobileNumber: mobile,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CustomerLoyaltyVisitQrPage(
            businessName: widget.businessName,
            qrResponse: qr,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // LOAD REWARDS
  // ============================================================

  Future<void> _loadRewards() async {
    if (_loadingRewards) {
      return;
    }

    setState(() {
      _loadingRewards = true;
    });

    try {
      final rewards = await _apiService.getRewards(
        businessId: widget.businessId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _rewards = rewards;
      });
    } catch (_) {
      /*
       * Rewards are optional for the core loyalty visit flow.
       * If reward loading fails, the customer can still earn
       * today's loyalty points.
       */
    } finally {
      if (mounted) {
        setState(() {
          _loadingRewards = false;
        });
      }
    }
  }

  // ============================================================
  // CLAIM REWARD
  // ============================================================

  Future<void> _claimReward(
      LoyaltyRewardResponse reward,
      ) async {
    final customer = _customer;

    if (customer == null) {
      _showError(
        'Please complete your loyalty profile first.',
      );
      return;
    }

    if (!reward.active) {
      _showError(
        'This reward is no longer available.',
      );
      return;
    }

    if (customer.pointsBalance <
        reward.pointsRequired) {
      _showError(
        'You need ${reward.pointsRequired} points to claim this reward.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final claim =
      await _apiService.claimReward(
        businessId: widget.businessId,
        mobileNumber: customer.mobileNumber,
        rewardId: reward.id,
      );

      if (!mounted) {
        return;
      }

      await _openRewardQr(claim);

      /*
       * Refresh the customer balance after claiming.
       *
       * The backend is the source of truth, so reload the
       * customer rather than manually subtracting points.
       */
      try {
        final refreshed =
        await _apiService.getCustomer(
          businessId: widget.businessId,
          mobileNumber: customer.mobileNumber,
        );

        if (mounted) {
          setState(() {
            _customer = refreshed;
          });
        }
      } catch (_) {
        // QR claim already succeeded. Don't block the user.
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(_cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // OPEN REWARD QR
  // ============================================================

  Future<void> _openRewardQr(
      LoyaltyClaimResponse claim,
      ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerLoyaltyQrPage(
          qrToken: claim.qrToken,
          businessName: widget.businessName,
          rewardTitle: claim.rewardTitle,
          rewardAmount: claim.rewardAmount,
          pointsUsed: claim.pointsUsed,
          remainingPoints: claim.remainingPoints,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _cleanErrorMessage(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_submitted) {
      return _buildRegistration(
        context,
        theme,
        colorScheme,
      );
    }

    return _buildDashboard(
      context,
      theme,
      colorScheme,
    );
  }

  // ============================================================
  // REGISTRATION
  // ============================================================

  Widget _buildRegistration(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Loyalty',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 42,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                widget.businessName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Join the loyalty program',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Enter your name',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  _continue();
                },
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: 'Enter your mobile number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _loading
                      ? null
                      : _continue,
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Your loyalty points and activity are linked to your mobile number for this business.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    final customer = _customer!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Loyalty',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              final refreshed =
              await _apiService.getCustomer(
                businessId: widget.businessId,
                mobileNumber:
                customer.mobileNumber,
              );

              if (mounted) {
                setState(() {
                  _customer = refreshed;
                });
              }
            } catch (_) {}

            await _loadRewards();
          },
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            children: [
              Text(
                'Hi, ${customer.customerName}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.businessName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                  colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // POINTS
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color:
                  colorScheme.primaryContainer,
                  borderRadius:
                  BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Points',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${customer.pointsBalance}',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Available points',
                      style:
                      theme.textTheme.bodySmall
                          ?.copyWith(
                        color: colorScheme
                            .onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // EARN VISIT POINTS
              // ==================================================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                  BorderRadius.circular(24),
                  border: Border.all(
                    color:
                    colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          color:
                          colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Earn Today’s Points',
                            style: theme.textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Generate a temporary QR and show it to the business to record today’s visit.',
                      style: theme.textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading
                            ? null
                            : _generateVisitQr,
                        icon: const Icon(
                          Icons.qr_code_rounded,
                        ),
                        label: Text(
                          _loading
                              ? 'Generating...'
                              : 'Generate Today’s QR',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // REWARDS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available Rewards',
                      style: theme.textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_loadingRewards)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (_rewards.isEmpty)
                _buildEmptyRewards(
                  theme,
                  colorScheme,
                )
              else
                ..._rewards.map(
                      (reward) => _buildRewardCard(
                    context,
                    theme,
                    colorScheme,
                    reward,
                    customer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY REWARDS
  // ============================================================

  Widget _buildEmptyRewards(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
        colorScheme.surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        'No rewards are currently available.',
        textAlign: TextAlign.center,
        style:
        theme.textTheme.bodyMedium?.copyWith(
          color:
          colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  // ============================================================
  // REWARD CARD
  // ============================================================

  Widget _buildRewardCard(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      LoyaltyRewardResponse reward,
      LoyaltyCustomerResponse customer,
      ) {
    final canClaim =
        reward.active &&
            customer.pointsBalance >=
                reward.pointsRequired;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
              colorScheme.secondaryContainer,
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              color: colorScheme
                  .onSecondaryContainer,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: theme.textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${reward.pointsRequired} points • ₹${reward.rewardAmount}',
                  style: theme.textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          FilledButton(
            onPressed: canClaim && !_loading
                ? () => _claimReward(reward)
                : null,
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }
}