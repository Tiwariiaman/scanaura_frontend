import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/models/subscription_request.dart';
import 'providers/subscription_notifier.dart';
import 'providers/subscription_state.dart';
import 'widgets/payment_screenshot_picker.dart';

class SubscriptionRequestScreen
    extends ConsumerStatefulWidget {
  const SubscriptionRequestScreen({
    super.key,
    required this.planName,
  });

  final String planName;

  @override
  ConsumerState<SubscriptionRequestScreen> createState() =>
      _SubscriptionRequestScreenState();
}

class _SubscriptionRequestScreenState
    extends ConsumerState<SubscriptionRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController = TextEditingController();

  static const String _upiId = '7056222557@upi';

  String _billingCycle = 'MONTHLY';

  Uint8List? _screenshotBytes;

  bool _submitting = false;

  String? _uploadedScreenshotUrl;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_screenshotBytes == null) {
      _showMessage(
        'Please upload your payment screenshot.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      // ==========================================================
      // 1. UPLOAD SCREENSHOT
      // ==========================================================

      final uploadService = ref.read(
        imageUploadServiceProvider,
      );

      final uploaded = await uploadService.uploadPaymentScreenshot(
        _screenshotBytes!,
        'payment_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _uploadedScreenshotUrl = uploaded.imageUrl;

      // ==========================================================
      // 2. SUBMIT SUBSCRIPTION REQUEST
      // ==========================================================

      await ref
          .read(
        subscriptionNotifierProvider.notifier,
      )
          .createSubscriptionRequest(
        SubscriptionRequest(
          planName: widget.planName,
          billingCycle: _billingCycle,
          transactionId:
          _transactionController.text.trim(),
          paymentScreenshotUrl:
          _uploadedScreenshotUrl!,
        ),
      );

      if (!mounted) {
        return;
      }

      final state = ref.read(
        subscriptionNotifierProvider,
      );

      if (state.status ==
          SubscriptionStatusState.success) {
        await _showSuccessDialog();

        if (!mounted) {
          return;
        }

        // Return to the Subscription screen.
        Navigator.of(context).pop(true);

        return;
      }

      _showMessage(
        state.errorMessage ??
            'Unable to submit subscription request.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString();

      _showMessage(
        message.startsWith('Exception: ')
            ? message.substring(11)
            : message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            20,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==================================================
              // SUCCESS ICON
              // ==================================================

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 58,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                'Thank you for choosing ScanAura!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // MESSAGE
              // ==================================================

              Text(
                'Your payment request has been submitted successfully.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Our team will verify your payment and approve your account within 24 hours.',
                        style:
                        theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Scan. Connect. Grow.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Powered by ScanAura',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // COPY UPI ID
  // ============================================================

  Future<void> _copyUpiId() async {
    await Clipboard.setData(
      const ClipboardData(
        text: _upiId,
      ),
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'UPI ID copied successfully.',
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.planName} Request',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 14.0
                : width < 600
                ? 18.0
                : 24.0;

            final maxWidth = width >= 900
                ? 680.0
                : 620.0;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
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
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================

                        Text(
                          'Request ${widget.planName}',
                          textAlign: width < 600
                              ? TextAlign.center
                              : TextAlign.start,
                          style: theme
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Complete your payment and submit the details below for verification.',
                          textAlign: width < 600
                              ? TextAlign.center
                              : TextAlign.start,
                          style: theme
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // PLAN SUMMARY
                        // ==================================================

                        _buildPlanSummary(context),

                        const SizedBox(height: 16),

                        // ==================================================
                        // PAYMENT INSTRUCTIONS
                        // ==================================================

                        _buildPaymentInstructions(context),

                        const SizedBox(height: 20),

                        // ==================================================
                        // BILLING CYCLE
                        // ==================================================

                        DropdownButtonFormField<String>(
                          initialValue: _billingCycle,
                          decoration: const InputDecoration(
                            labelText: 'Billing cycle',
                            prefixIcon: Icon(
                              Icons.calendar_month_outlined,
                            ),
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'MONTHLY',
                              child: Text(
                                'Monthly',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'HALF_YEARLY',
                              child: Text(
                                '6 Months',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'YEARLY',
                              child: Text(
                                'Yearly',
                              ),
                            ),
                          ],
                          onChanged: _submitting
                              ? null
                              : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _billingCycle = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // TRANSACTION ID
                        // ==================================================

                        TextFormField(
                          controller:
                          _transactionController,
                          enabled: !_submitting,
                          textInputAction:
                          TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Transaction ID',
                            hintText:
                            'Enter your UPI transaction ID',
                            prefixIcon: Icon(
                              Icons.receipt_long_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Transaction ID is required.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // SCREENSHOT
                        // ==================================================

                        _buildPaymentSection(context),

                        const SizedBox(height: 28),

                        // ==================================================
                        // SUBMIT
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed:
                            _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Icon(
                              Icons.send_rounded,
                            ),
                            label: Text(
                              _submitting
                                  ? 'Submitting...'
                                  : 'Submit Request',
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // CANCEL
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _submitting
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
                        ),

                        const SizedBox(height: 20),
                      ],
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
  // PLAN SUMMARY
  // ============================================================

  Widget _buildPlanSummary(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              color: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected plan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme
                        .colorScheme
                        .onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme
                        .colorScheme
                        .onPrimaryContainer,
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
  // PAYMENT INSTRUCTIONS
  // ============================================================

  Widget _buildPaymentInstructions(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary
              .withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.10),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete your payment',
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pay using any UPI app',
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'Pay to this UPI ID',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.55),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _upiId,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  tooltip: 'Copy UPI ID',
                  onPressed:
                  _submitting
                      ? null
                      : _copyUpiId,
                  icon: const Icon(
                    Icons.copy_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary
                  .withValues(alpha: 0.06),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 21,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pay the amount for your selected billing cycle, then send us the payment screenshot below.',
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildStep(
            context,
            number: '1',
            title: 'Pay using UPI',
            description:
            'Use the UPI ID above to complete your payment.',
          ),

          const SizedBox(height: 10),

          _buildStep(
            context,
            number: '2',
            title: 'Save your payment screenshot',
            description:
            'Make sure the screenshot clearly shows the successful transaction.',
          ),

          const SizedBox(height: 10),

          _buildStep(
            context,
            number: '3',
            title: 'Submit your details',
            description:
            'Enter the transaction ID and upload the screenshot.',
          ),

          const SizedBox(height: 16),

          Text(
            'Your account will be verified and approved within 24 hours.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'If you face any issue with the payment or transaction, please contact ScanAura support.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT STEP
  // ============================================================

  Widget _buildStep(
      BuildContext context, {
        required String number,
        required String title,
        required String description,
      }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT SCREENSHOT SECTION
  // ============================================================

  Widget _buildPaymentSection(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Screenshot',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Upload a screenshot showing your completed UPI payment.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 12),

        PaymentScreenshotPicker(
          onSelected: (bytes) {
            if (_submitting) {
              return;
            }

            setState(() {
              _screenshotBytes = bytes;
            });
          },
        ),
      ],
    );
  }
}