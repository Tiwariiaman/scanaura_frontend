import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/payment_response.dart';


class PublicPaymentScreen
    extends ConsumerStatefulWidget {
  const PublicPaymentScreen({
    super.key,
    required this.qrCode,
  });

  final String qrCode;

  @override
  ConsumerState<PublicPaymentScreen> createState() =>
      _PublicPaymentScreenState();
}

class _PublicPaymentScreenState
    extends ConsumerState<PublicPaymentScreen> {
  final TextEditingController _amountController =
  TextEditingController();

  bool _isOpeningPayment = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(publicNotifierProvider.notifier)
          .setQrCode(widget.qrCode);

      ref
          .read(publicNotifierProvider.notifier)
          .loadPayment();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _payViaUpi() async {
    if (_isOpeningPayment) {
      return;
    }

    final state =
    ref.read(publicNotifierProvider);

    final payment = state.payment;

    if (payment == null ||
        payment.upiId == null ||
        payment.upiId!.trim().isEmpty) {
      _showMessage(
        'UPI payment is not available.',
      );
      return;
    }

    final amountText =
    _amountController.text.trim();

    final amount =
    double.tryParse(amountText);

    if (amount == null ||
        amount <= 0) {
      _showMessage(
        'Please enter a valid amount.',
      );
      return;
    }

    final upiUri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': payment.upiId!.trim(),
        'pn': payment.businessName,
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
      },
    );

    setState(() {
      _isOpeningPayment = true;
    });

    try {
      final launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage(
          'Unable to open a UPI payment app.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to open UPI payment.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPayment = false;
        });
      }
    }
  }

  void _copyUpiId(String upiId) {
    Clipboard.setData(
      ClipboardData(text: upiId),
    );

    _showMessage(
      'UPI ID copied.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(publicNotifierProvider);

    if (state.status ==
        PublicStatus.loading &&
        state.payment == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status ==
        PublicStatus.error &&
        state.payment == null) {
      return _buildError(
        context,
        state,
      );
    }

    final payment = state.payment;

    if (payment == null ||
        payment.upiId == null ||
        payment.upiId!.trim().isEmpty) {
      return _buildUnavailable(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay via UPI',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 560,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                _buildBusinessCard(
                  context,
                  payment,
                ),

                const SizedBox(height: 20),

                _buildAmountCard(context),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed:
                  _isOpeningPayment
                      ? null
                      : _payViaUpi,
                  icon: _isOpeningPayment
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons
                        .account_balance_wallet_outlined,
                  ),
                  label: Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    child: Text(
                      _isOpeningPayment
                          ? 'Opening UPI...'
                          : 'Pay by any UPI app',
                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _buildUpiIdCard(
                  context,
                  payment.upiId!.trim(),
                ),

                const SizedBox(height: 24),

                _buildInfoCard(context),

                const SizedBox(height: 36),

                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessCard(
      BuildContext context,
      PaymentResponse payment,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              child: const Icon(
                Icons.storefront_outlined,
                size: 30,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              payment.businessName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Digital Payment',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiIdCard(
      BuildContext context,
      String upiId,
      ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.alternate_email,
        ),
        title: const Text(
          'UPI ID',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(upiId),
        trailing: IconButton(
          tooltip: 'Copy UPI ID',
          onPressed: () {
            _copyUpiId(upiId);
          },
          icon: const Icon(
            Icons.copy_outlined,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You will be redirected to your selected UPI app to complete the payment.',
              style: TextStyle(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text(
            'Register your business',
          ),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ??
                    'Unable to load payment details.',
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref
                      .read(
                    publicNotifierProvider
                        .notifier,
                  )
                      .loadPayment();
                },
                child:
                const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnavailable(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'UPI payment is not available for this business.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}