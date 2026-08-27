import 'dart:typed_data';

import 'package:flutter/material.dart';
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
  ConsumerState<SubscriptionRequestScreen>
  createState() =>
      _SubscriptionRequestScreenState();
}

class _SubscriptionRequestScreenState
    extends ConsumerState<
        SubscriptionRequestScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _transactionController =
  TextEditingController();

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
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_screenshotBytes == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior:
            SnackBarBehavior.floating,
            content: Text(
              'Please upload your payment screenshot.',
            ),
          ),
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

      final uploadService =
      ref.read(
        imageUploadServiceProvider,
      );

      final uploaded =
      await uploadService
          .uploadPaymentScreenshot(
        _screenshotBytes!,
        'payment_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _uploadedScreenshotUrl =
          uploaded.imageUrl;

      // ==========================================================
      // 2. SUBMIT REQUEST
      // ==========================================================

      await ref
          .read(
        subscriptionNotifierProvider
            .notifier,
      )
          .createSubscriptionRequest(
        SubscriptionRequest(
          planName:
          widget.planName,
          billingCycle:
          _billingCycle,
          transactionId:
          _transactionController
              .text
              .trim(),
          paymentScreenshotUrl:
          _uploadedScreenshotUrl!,
        ),
      );

      if (!mounted) {
        return;
      }

      final state =
      ref.read(
        subscriptionNotifierProvider,
      );

      if (state.status ==
          SubscriptionStatusState
              .success) {
        Navigator.of(
          context,
        ).pop(true);
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

      final message =
      e.toString();

      _showMessage(
        message.startsWith(
          'Exception: ',
        )
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

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content:
          Text(message),
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
    final theme =
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.planName} Request',
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width =
                constraints.maxWidth;

            final horizontalPadding =
            width < 360
                ? 14.0
                : width < 600
                ? 18.0
                : 24.0;

            final maxWidth =
            width >= 900
                ? 680.0
                : 620.0;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
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
                        // ==================================================
                        // HEADER
                        // ==================================================

                        Text(
                          'Request ${widget.planName}',
                          textAlign:
                          width < 600
                              ? TextAlign.center
                              : TextAlign.start,
                          style: theme
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Complete your payment details and submit the request for admin approval.',
                          textAlign:
                          width < 600
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

                        const SizedBox(
                          height: 24,
                        ),

                        // ==================================================
                        // PLAN SUMMARY
                        // ==================================================

                        _buildPlanSummary(
                          context,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // BILLING CYCLE
                        // ==================================================

                        DropdownButtonFormField<
                            String>(
                          initialValue:
                          _billingCycle,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Billing cycle',
                            prefixIcon:
                            Icon(
                              Icons
                                  .calendar_month_outlined,
                            ),
                          ),
                          isExpanded:
                          true,
                          items:
                          const [
                            DropdownMenuItem(
                              value:
                              'MONTHLY',
                              child:
                              Text(
                                'Monthly',
                              ),
                            ),
                            DropdownMenuItem(
                              value:
                              'YEARLY',
                              child:
                              Text(
                                'Yearly',
                              ),
                            ),
                          ],
                          onChanged:
                          _submitting
                              ? null
                              : (
                              value,
                              ) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(
                                  () {
                                _billingCycle =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // TRANSACTION ID
                        // ==================================================

                        TextFormField(
                          controller:
                          _transactionController,
                          enabled:
                          !_submitting,
                          textInputAction:
                          TextInputAction
                              .next,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Transaction ID',
                            hintText:
                            'Enter your UPI transaction ID',
                            prefixIcon:
                            Icon(
                              Icons
                                  .receipt_long_outlined,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Transaction ID is required.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // ==================================================
                        // SCREENSHOT
                        // ==================================================

                        _buildPaymentSection(
                          context,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // SUBMIT BUTTON
                        // ==================================================

                        SizedBox(
                          width:
                          double.infinity,
                          height: 54,
                          child:
                          FilledButton.icon(
                            onPressed:
                            _submitting
                                ? null
                                : _submit,
                            icon:
                            _submitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2.5,
                              ),
                            )
                                : const Icon(
                              Icons
                                  .send_rounded,
                            ),
                            label:
                            Text(
                              _submitting
                                  ? 'Submitting...'
                                  : 'Submit Request',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          height: 48,
                          child:
                          OutlinedButton(
                            onPressed:
                            _submitting
                                ? null
                                : () {
                              Navigator
                                  .of(
                                context,
                              ).pop();
                            },
                            child:
                            const Text(
                              'Cancel',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
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
    final theme =
    Theme.of(context);

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .primaryContainer,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment:
            Alignment.center,
            decoration:
            BoxDecoration(
              color: theme
                  .colorScheme
                  .surface,
              borderRadius:
              BorderRadius.circular(
                11,
              ),
            ),
            child:
            Icon(
              Icons
                  .workspace_premium_outlined,
              color: theme
                  .colorScheme
                  .primary,
            ),
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
                  'Selected plan',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onPrimaryContainer,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  widget.planName,
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
  // PAYMENT SCREENSHOT SECTION
  // ============================================================

  Widget _buildPaymentSection(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Screenshot',
          style: theme
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          'Upload a screenshot showing your completed UPI payment.',
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
          height: 12,
        ),

        PaymentScreenshotPicker(
          onSelected: (bytes) {
            setState(() {
              _screenshotBytes =
                  bytes;
            });
          },
        ),
      ],
    );
  }
}