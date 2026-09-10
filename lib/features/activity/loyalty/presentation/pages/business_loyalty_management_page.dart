import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/app_providers.dart';
import '../../models/loyalty_reward_response.dart';
import '../../models/loyalty_settings_response.dart';
import '../../services/business_loyalty_rewards_api_service.dart';
import '../../services/business_loyalty_settings_api_service.dart';

class BusinessLoyaltyManagementPage extends ConsumerStatefulWidget {
  const BusinessLoyaltyManagementPage({
    super.key,
  });

  @override
  ConsumerState<BusinessLoyaltyManagementPage> createState() =>
      _BusinessLoyaltyManagementPageState();
}

class _BusinessLoyaltyManagementPageState
    extends ConsumerState<BusinessLoyaltyManagementPage> {
  late final BusinessLoyaltySettingsApiService _settingsApi;
  late final BusinessLoyaltyRewardsApiService _rewardsApi;

  bool _loading = true;
  bool _savingSettings = false;
  bool _addingReward = false;
  bool _deletingReward = false;

  bool _enabled = false;
  int _pointsPerVisit = 10;

  List<LoyaltyRewardResponse> _rewards = [];

  @override
  void initState() {
    super.initState();

    final apiClient = ref.read(apiClientProvider);

    _settingsApi = BusinessLoyaltySettingsApiService(
      apiClient: apiClient,
    );

    _rewardsApi = BusinessLoyaltyRewardsApiService(
      apiClient: apiClient,
    );

    _loadLoyalty();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadLoyalty() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final results = await Future.wait([
        _settingsApi.getSettings(),
        _rewardsApi.getRewards(),
      ]);

      final settings = results[0] as LoyaltySettingsResponse;
      final rewards = results[1] as List<LoyaltyRewardResponse>;

      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = settings.enabled;
        _pointsPerVisit = settings.pointsPerVisit;
        _rewards = rewards;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadRewards() async {
    try {
      final rewards = await _rewardsApi.getRewards();

      if (!mounted) {
        return;
      }

      setState(() {
        _rewards = rewards;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    }
  }

  // ============================================================
  // TOGGLE LOYALTY
  // ============================================================

  Future<void> _toggleLoyalty(bool value) async {
    if (_savingSettings) {
      return;
    }

    final previousValue = _enabled;

    setState(() {
      _enabled = value;
      _savingSettings = true;
    });

    try {
      final settings = await _settingsApi.updateSettings(
        enabled: value,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = settings.enabled;
        _pointsPerVisit = settings.pointsPerVisit;
      });

      _showMessage(
        settings.enabled
            ? 'Loyalty program enabled.'
            : 'Loyalty program disabled.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = previousValue;
      });

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingSettings = false;
        });
      }
    }
  }

  // ============================================================
  // CREATE REWARD
  // ============================================================

  Future<void> _showAddRewardDialog() async {
    final titleController = TextEditingController();
    final pointsController = TextEditingController();
    final amountController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return _RewardDialog(
            title: 'Create Reward',
            confirmText: 'Create Reward',
            titleController: titleController,
            pointsController: pointsController,
            amountController: amountController,
            onSubmit: () async {
              final title = titleController.text.trim();

              final points = int.tryParse(
                pointsController.text.trim(),
              );

              final amount = double.tryParse(
                amountController.text.trim(),
              );

              if (title.isEmpty ||
                  points == null ||
                  points < 1 ||
                  amount == null ||
                  amount < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter valid reward details.',
                    ),
                  ),
                );
                return;
              }

              final success = await _createReward(
                title: title,
                pointsRequired: points,
                rewardAmount: amount,
              );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(success);
              }
            },
          );
        },
      );

      if (result == true) {
        await _loadRewards();
      }
    } finally {
      titleController.dispose();
      pointsController.dispose();
      amountController.dispose();
    }
  }

  Future<bool> _createReward({
    required String title,
    required int pointsRequired,
    required double rewardAmount,
  }) async {
    if (_addingReward) {
      return false;
    }

    setState(() {
      _addingReward = true;
    });

    try {
      await _rewardsApi.createReward(
        title: title,
        pointsRequired: pointsRequired,
        rewardAmount: rewardAmount,
      );

      if (!mounted) {
        return true;
      }

      _showMessage(
        'Reward created successfully.',
      );

      return true;
    } catch (e) {
      if (mounted) {
        _showMessage(
          _cleanError(e),
          isError: true,
        );
      }

      return false;
    } finally {
      if (mounted) {
        setState(() {
          _addingReward = false;
        });
      }
    }
  }

  // ============================================================
  // EDIT REWARD
  // ============================================================

  Future<void> _editReward(
      LoyaltyRewardResponse reward,
      ) async {
    final titleController = TextEditingController(
      text: reward.title,
    );

    final pointsController = TextEditingController(
      text: reward.pointsRequired.toString(),
    );

    final amountController = TextEditingController(
      text: reward.rewardAmount.toString(),
    );

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return _RewardDialog(
            title: 'Edit Reward',
            confirmText: 'Save Changes',
            titleController: titleController,
            pointsController: pointsController,
            amountController: amountController,
            onSubmit: () async {
              final title = titleController.text.trim();

              final points = int.tryParse(
                pointsController.text.trim(),
              );

              final amount = double.tryParse(
                amountController.text.trim(),
              );

              if (title.isEmpty ||
                  points == null ||
                  points < 1 ||
                  amount == null ||
                  amount < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Enter valid reward details.',
                    ),
                  ),
                );
                return;
              }

              final success = await _updateReward(
                id: reward.id,
                title: title,
                pointsRequired: points,
                rewardAmount: amount,
                active: reward.active,
              );

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(success);
              }
            },
          );
        },
      );

      if (result == true) {
        await _loadRewards();
      }
    } finally {
      titleController.dispose();
      pointsController.dispose();
      amountController.dispose();
    }
  }

  Future<bool> _updateReward({
    required String id,
    required String title,
    required int pointsRequired,
    required double rewardAmount,
    required bool active,
  }) async {
    try {
      await _rewardsApi.updateReward(
        rewardId: id,
        title: title,
        pointsRequired: pointsRequired,
        rewardAmount: rewardAmount,
        active: active,
      );

      if (!mounted) {
        return true;
      }

      _showMessage(
        'Reward updated successfully.',
      );

      return true;
    } catch (e) {
      if (mounted) {
        _showMessage(
          _cleanError(e),
          isError: true,
        );
      }

      return false;
    }
  }

  // ============================================================
  // DELETE REWARD
  // ============================================================

  Future<void> _deleteReward(
      LoyaltyRewardResponse reward,
      ) async {
    if (_deletingReward) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete reward?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            '“${reward.title}” will be permanently removed from your loyalty rewards.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _deletingReward = true;
    });

    try {
      await _rewardsApi.deleteReward(
        rewardId: reward.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _rewards.removeWhere(
              (item) => item.id == reward.id,
        );
      });

      _showMessage(
        'Reward deleted successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingReward = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
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

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Loyalty',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (!_loading)
            IconButton(
              tooltip: 'Refresh',
              onPressed: _loadLoyalty,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadLoyalty,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            40,
          ),
          children: [
            _buildHero(
              theme,
              colorScheme,
            ),

            const SizedBox(height: 18),

            _buildProgramCard(
              theme,
              colorScheme,
            ),

            const SizedBox(height: 28),

            _buildRewardsHeader(
              theme,
              colorScheme,
            ),

            const SizedBox(height: 14),

            if (_rewards.isEmpty)
              _buildEmptyRewards(
                theme,
                colorScheme,
              )
            else
              ..._rewards.map(
                    (reward) => Padding(
                  padding:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _buildRewardCard(
                    reward,
                    theme,
                    colorScheme,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            _buildOwnerNote(
              theme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(
              Icons.loyalty_rounded,
              color: colorScheme.onPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Build customer loyalty',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Give your customers a reason to come back with points and rewards created by your business.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                    colorScheme.onPrimaryContainer,
                    height: 1.45,
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
  // PROGRAM CARD
  // ============================================================

  Widget _buildProgramCard(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                  colorScheme.surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: _enabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loyalty program',
                      style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _enabled
                                ? colorScheme.primary
                                : colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          _enabled
                              ? 'Currently active'
                              : 'Currently inactive',
                          style:
                          theme.textTheme.bodySmall?.copyWith(
                            color: _enabled
                                ? colorScheme.primary
                                : colorScheme
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _enabled,
                onChanged:
                _savingSettings
                    ? null
                    : _toggleLoyalty,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
              colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                    colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stars_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_pointsPerVisit points',
                        style:
                        theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'earned per daily visit',
                        style:
                        theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Customers can earn visit points once per business per day.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REWARDS HEADER
  // ============================================================

  Widget _buildRewardsHeader(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Your rewards',
                style:
                theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_rewards.length} reward${_rewards.length == 1 ? '' : 's'} configured',
                style:
                theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addingReward
              ? null
              : _showAddRewardDialog,
          icon: const Icon(
            Icons.add_rounded,
            size: 19,
          ),
          label: const Text(
            'Add Reward',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REWARD CARD
  // ============================================================

  Widget _buildRewardCard(
      LoyaltyRewardResponse reward,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: reward.active
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 28,
                  color: reward.active
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
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
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        _buildRewardBadge(
                          icon: Icons.stars_rounded,
                          text:
                          '${reward.pointsRequired} pts',
                          colorScheme:
                          colorScheme,
                        ),
                        const SizedBox(width: 8),
                        _buildRewardBadge(
                          icon:
                          Icons.local_offer_outlined,
                          text:
                          '₹${reward.rewardAmount.toStringAsFixed(0)} OFF',
                          colorScheme:
                          colorScheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'Reward options',
                onSelected: (value) {
                  if (value == 'edit') {
                    _editReward(reward);
                  } else if (value == 'delete') {
                    _deleteReward(reward);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(height: 1),

          const SizedBox(height: 13),

          Row(
            children: [
              Icon(
                reward.active
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                size: 18,
                color: reward.active
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reward.active
                      ? 'Available to customers'
                      : 'Not currently available',
                  style:
                  theme.textTheme.bodySmall?.copyWith(
                    color: reward.active
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Switch.adaptive(
                value: reward.active,
                onChanged: (_) {
                  _toggleReward(reward);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyRewards(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        32,
        24,
        28,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color:
              colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 34,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first reward',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Turn loyalty points into offers your customers will love.',
            textAlign: TextAlign.center,
            style:
            theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed:
            _addingReward
                ? null
                : _showAddRewardDialog,
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Create Reward',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OWNER NOTE
  // ============================================================

  Widget _buildOwnerNote(
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 21,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You control this loyalty program. You choose whether to enable it, which rewards to offer, and their terms. ScanAura does not fund or pay for your rewards.',
              style:
              theme.textTheme.bodySmall?.copyWith(
                color:
                colorScheme.onPrimaryContainer,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOGGLE REWARD
  // ============================================================

  Future<void> _toggleReward(
      LoyaltyRewardResponse reward,
      ) async {
    try {
      final updated =
      await _rewardsApi.updateReward(
        rewardId: reward.id,
        title: reward.title,
        pointsRequired:
        reward.pointsRequired,
        rewardAmount:
        reward.rewardAmount,
        active: !reward.active,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final index = _rewards.indexWhere(
              (item) => item.id == reward.id,
        );

        if (index != -1) {
          _rewards[index] = updated;
        }
      });

      _showMessage(
        updated.active
            ? 'Reward activated.'
            : 'Reward deactivated.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(e),
        isError: true,
      );
    }
  }
}

// ================================================================
// REWARD DIALOG
// ================================================================

class _RewardDialog extends StatelessWidget {
  final String title;
  final String confirmText;
  final TextEditingController titleController;
  final TextEditingController pointsController;
  final TextEditingController amountController;
  final VoidCallback onSubmit;

  const _RewardDialog({
    required this.title,
    required this.confirmText,
    required this.titleController,
    required this.pointsController,
    required this.amountController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set the offer customers can redeem with their loyalty points.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Reward title',
                hintText: 'e.g. ₹100 OFF',
                prefixIcon: const Icon(
                  Icons.card_giftcard_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: pointsController,
              keyboardType:
              TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Points required',
                hintText: 'e.g. 100',
                prefixIcon: const Icon(
                  Icons.stars_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Reward value',
                hintText: 'e.g. 100',
                prefixText: '₹ ',
                prefixIcon: const Icon(
                  Icons.local_offer_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding:
      const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        18,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: onSubmit,
          child: Text(
            confirmText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}