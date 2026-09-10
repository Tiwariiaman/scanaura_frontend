import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../core/providers/app_providers.dart';
import '../../models/loyalty_reward_response.dart';
import '../../services/business_loyalty_rewards_api_service.dart';

class LoyaltyRewardFormPage extends ConsumerStatefulWidget {
  const LoyaltyRewardFormPage({
    super.key,
    this.reward,
  });

  final LoyaltyRewardResponse? reward;

  bool get isEditing => reward != null;

  @override
  ConsumerState<LoyaltyRewardFormPage> createState() =>
      _LoyaltyRewardFormPageState();
}

class _LoyaltyRewardFormPageState
    extends ConsumerState<LoyaltyRewardFormPage> {
  late final BusinessLoyaltyRewardsApiService _apiService;

  late final TextEditingController _titleController;
  late final TextEditingController _pointsController;
  late final TextEditingController _amountController;

  final _formKey = GlobalKey<FormState>();

  bool _saving = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();

    _apiService = BusinessLoyaltyRewardsApiService(
      apiClient: ref.read(apiClientProvider),
    );

    _titleController = TextEditingController(
      text: widget.reward?.title ?? '',
    );

    _pointsController = TextEditingController(
      text: widget.reward?.pointsRequired.toString() ?? '',
    );

    _amountController = TextEditingController(
      text: widget.reward?.rewardAmount.toStringAsFixed(0) ?? '',
    );

    _active = widget.reward?.active ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final points = int.parse(_pointsController.text.trim());
    final amount = double.parse(_amountController.text.trim());

    setState(() {
      _saving = true;
    });

    try {
      if (widget.isEditing) {
        await _apiService.updateReward(
          rewardId: widget.reward!.id,
          title: title,
          pointsRequired: points,
          rewardAmount: amount,
          active: _active,
        );
      } else {
        await _apiService.createReward(
          title: title,
          pointsRequired: points,
          rewardAmount: amount,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
      });

      _showError(_cleanErrorMessage(e));
    }
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
    final editing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? 'Edit Reward' : 'Create Reward',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              24,
              20,
              32,
            ),
            children: [
              _buildIntro(
                context,
                theme,
                colorScheme,
                editing,
              ),
              const SizedBox(height: 24),
              _buildTitleField(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 18),
              _buildPointsField(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 18),
              _buildAmountField(
                context,
                theme,
                colorScheme,
              ),
              if (editing) ...[
                const SizedBox(height: 18),
                _buildActiveSwitch(
                  context,
                  theme,
                  colorScheme,
                ),
              ],
              const SizedBox(height: 24),
              _buildPreview(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 24),
              _buildOwnerNote(
                context,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                    ),
                  )
                      : Icon(
                    editing
                        ? Icons.save_rounded
                        : Icons.add_rounded,
                  ),
                  label: Text(
                    _saving
                        ? 'Saving...'
                        : editing
                        ? 'Save Changes'
                        : 'Create Reward',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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
  // INTRO
  // ============================================================

  Widget _buildIntro(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      bool editing,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          editing
              ? 'Update your reward'
              : 'Create a customer reward',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          editing
              ? 'Change the points requirement, reward value, or active status.'
              : 'Decide how many loyalty points customers need and what reward your business will provide.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitleField(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _titleController,
      maxLength: 150,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Reward title',
        hintText: 'Example: ₹100 Off',
        prefixIcon: Icon(
          Icons.card_giftcard_rounded,
        ),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Reward title is required.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // POINTS
  // ============================================================

  Widget _buildPointsField(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _pointsController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Points required',
        hintText: 'Example: 100',
        prefixIcon: Icon(
          Icons.stars_rounded,
        ),
        suffixText: 'points',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Points required is required.';
        }

        final rewardValue = int.tryParse(text);

        if (rewardValue == null || rewardValue < 1) {
          return 'Enter a valid points amount.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountField(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: const InputDecoration(
        labelText: 'Reward amount',
        hintText: 'Example: 100',
        prefixIcon: Icon(
          Icons.currency_rupee_rounded,
        ),
        prefixText: '₹ ',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Reward amount is required.';
        }

        final amount = double.tryParse(text);

        if (amount == null || amount < 0) {
          return 'Enter a valid reward amount.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // ACTIVE SWITCH
  // ============================================================

  Widget _buildActiveSwitch(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _active
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward active',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _active
                      ? 'Customers can see and redeem this reward.'
                      : 'Customers cannot use this reward.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _active,
            onChanged: _saving
                ? null
                : (value) {
              setState(() {
                _active = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  Widget _buildPreview(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _titleController,
      builder: (_, titleValue, __) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _pointsController,
          builder: (_, pointsValue, __) {
            return ValueListenableBuilder<TextEditingValue>(
              valueListenable: _amountController,
              builder: (_, amountValue, __) {
                final title = titleValue.text.trim();
                final points = pointsValue.text.trim();
                final amount = amountValue.text.trim();

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reward preview',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color:
                              colorScheme.secondaryContainer,
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.card_giftcard_rounded,
                              color: colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isEmpty
                                      ? 'Your reward'
                                      : title,
                                  style: theme
                                      .textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${points.isEmpty ? '0' : points} points'
                                      '${amount.isEmpty ? '' : ' • ₹$amount value'}',
                                  style: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // OWNER NOTE
  // ============================================================

  Widget _buildOwnerNote(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Rewards are controlled and funded by your business. ScanAura only provides the loyalty system; it does not pay for or guarantee rewards.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}