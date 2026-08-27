import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/payment_response.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

class PublicPaymentScreen
    extends ConsumerStatefulWidget {
  const PublicPaymentScreen({
    super.key,
    required this.qrCode,
  });

  final String qrCode;

  @override
  ConsumerState<PublicPaymentScreen>
  createState() =>
      _PublicPaymentScreenState();
}

class _PublicPaymentScreenState
    extends ConsumerState<
        PublicPaymentScreen> {
  final TextEditingController
  _amountController =
  TextEditingController();

  bool _isOpeningPayment = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final notifier =
      ref.read(
        publicNotifierProvider
            .notifier,
      );

      notifier.setQrCode(
        widget.qrCode,
      );

      notifier.loadPayment();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAY VIA UPI
  // ============================================================

  Future<void> _payViaUpi() async {
    if (_isOpeningPayment) {
      return;
    }

    final state =
    ref.read(
      publicNotifierProvider,
    );

    final payment =
        state.payment;

    if (payment == null ||
        payment.upiId == null ||
        payment.upiId!
            .trim()
            .isEmpty) {
      _showMessage(
        'UPI payment is not available.',
      );
      return;
    }

    final amountText =
    _amountController.text.trim();

    final amount =
    double.tryParse(
      amountText,
    );

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
        'pa':
        payment.upiId!
            .trim(),
        'pn':
        payment.businessName,
        'am':
        amount.toStringAsFixed(
          2,
        ),
        'cu': 'INR',
      },
    );

    setState(() {
      _isOpeningPayment = true;
    });

    try {
      final launched =
      await launchUrl(
        upiUri,
        mode:
        LaunchMode
            .externalApplication,
      );

      if (!launched &&
          mounted) {
        _showMessage(
          'Unable to open a UPI payment app.',
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to open UPI payment.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningPayment =
          false;
        });
      }
    }
  }

  // ============================================================
  // COPY UPI
  // ============================================================

  void _copyUpiId(
      String upiId,
      ) {
    Clipboard.setData(
      ClipboardData(
        text: upiId,
      ),
    );

    _showMessage(
      'UPI ID copied.',
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior
              .floating,
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
    final state =
    ref.watch(
      publicNotifierProvider,
    );

    if (state.status ==
        PublicStatus.loading &&
        state.payment == null) {
      return _buildLoading();
    }

    if (state.status ==
        PublicStatus.error &&
        state.payment == null) {
      return _buildError(
        context,
        state,
      );
    }

    final payment =
        state.payment;

    if (payment == null ||
        payment.upiId == null ||
        payment.upiId!
            .trim()
            .isEmpty) {
      return _buildUnavailable(
        context,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay via UPI',
          style: TextStyle(
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
                ? 16.0
                : width < 600
                ? 20.0
                : 24.0;

            final maxWidth =
            width >= 900
                ? 620.0
                : 560.0;

            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
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
                      _buildBusinessCard(
                        context,
                        payment,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildAmountCard(
                        context,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildPayButton(
                        context,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildUpiIdCard(
                        context,
                        payment.upiId!
                            .trim(),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildInfoCard(
                        context,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildFooter(
                        context,
                      ),
                    ],
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      ),
    );
  }

  // ============================================================
  // BUSINESS CARD
  // ============================================================

  Widget _buildBusinessCard(
      BuildContext context,
      PaymentResponse payment,
      ) {
    final theme =
    Theme.of(context);

    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    final avatarSize =
    width < 360
        ? 52.0
        : 60.0;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        EdgeInsets.all(
          width < 400
              ? 16
              : 20,
        ),
        child: Column(
          children: [
            Container(
              width:
              avatarSize,
              height:
              avatarSize,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .storefront_outlined,
                size:
                avatarSize *
                    0.5,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              payment.businessName,
              textAlign:
              TextAlign.center,
              maxLines: 3,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w800,
                height: 1.2,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Digital Payment',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _buildAmountCard(
      BuildContext context,
      ) {
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
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextField(
              controller:
              _amountController,
              keyboardType:
              const TextInputType
                  .numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter
                    .allow(
                  RegExp(
                    r'^\d*\.?\d{0,2}',
                  ),
                ),
              ],
              textInputAction:
              TextInputAction.done,
              decoration:
              InputDecoration(
                prefixText: '₹ ',
                hintText: '0.00',
                prefixIcon:
                const Icon(
                  Icons
                      .currency_rupee_outlined,
                ),
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
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
  // PAY BUTTON
  // ============================================================

  Widget _buildPayButton(
      BuildContext context,
      ) {
    return SizedBox(
      width:
      double.infinity,
      height: 54,
      child:
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
        label: Text(
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
    );
  }

  // ============================================================
  // UPI ID
  // ============================================================

  Widget _buildUpiIdCard(
      BuildContext context,
      String upiId,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment
              .center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
              child: const Icon(
                Icons
                    .alternate_email,
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
                    'UPI ID',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    upiId,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip:
              'Copy UPI ID',
              onPressed: () {
                _copyUpiId(
                  upiId,
                );
              },
              icon:
              const Icon(
                Icons
                    .copy_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoCard(
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
            .surfaceContainerHighest,
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
          Icon(
            Icons
                .verified_user_outlined,
            color: theme
                .colorScheme
                .primary,
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
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

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter(
      BuildContext context,
      ) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          textAlign:
          TextAlign.center,
          style: TextStyle(
            color: Colors
                .grey
                .shade600,
            fontWeight:
            FontWeight.w600,
          ),
        ),

        TextButton(
          onPressed: () {
            context.go(
              '/register',
            );
          },
          child: const Text(
            'Register your business',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
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

                  const Text(
                    'Unable to load payment details',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    state.errorMessage ??
                        'Unable to load payment details.',
                    textAlign:
                    TextAlign.center,
                  ),

                  const SizedBox(
                    height: 16,
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
                          publicNotifierProvider
                              .notifier,
                        )
                            .loadPayment();
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
          'Payment',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
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
                        .account_balance_wallet_outlined,
                    size: 56,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurfaceVariant,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'UPI payment is not available',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    'This business has not configured a UPI payment ID yet.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).maybePop();
                    },
                    child:
                    const Text(
                      'Go Back',
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
}