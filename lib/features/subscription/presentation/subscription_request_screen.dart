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
    extends ConsumerState<SubscriptionRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController =
  TextEditingController();

  String _billingCycle = 'MONTHLY';

  Uint8List? _screenshotBytes;

  bool _submitting = false;
  String? _uploadedScreenshotUrl;
  String? _uploadedScreenshotPublicId;

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_screenshotBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      // 1. Upload screenshot first.
      final uploadService =
      ref.read(imageUploadServiceProvider);

      final uploaded =
      await uploadService.uploadPaymentScreenshot(
        _screenshotBytes!,
        'payment_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _uploadedScreenshotUrl =
          uploaded.imageUrl;

      _uploadedScreenshotPublicId =
          uploaded.publicId;

      // 2. Submit subscription request
      // using the real Cloudinary URL.
      await ref
          .read(
        subscriptionNotifierProvider
            .notifier,
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
        Navigator.of(context).pop(true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ??
                'Unable to submit subscription request.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.startsWith('Exception: ')
                ? message.substring(11)
                : message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.planName} Request',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Request ${widget.planName}',
                style: theme
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Complete your payment details and submit the request for admin approval.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                initialValue: _billingCycle,
                decoration: const InputDecoration(
                  labelText: 'Billing cycle',
                  prefixIcon: Icon(
                    Icons.calendar_month_outlined,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'MONTHLY',
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: 'YEARLY',
                    child: Text('Yearly'),
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

              TextFormField(
                controller: _transactionController,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID',
                  hintText: 'Enter your UPI transaction ID',
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

              PaymentScreenshotPicker(
                onSelected: (bytes) {
                  _screenshotBytes = bytes;
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}