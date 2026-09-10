import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/providers/app_providers.dart';
import '../providers/loyalty_scan_result_provider.dart';
import '../../services/business_loyalty_api_service.dart';

class BusinessLoyaltyVerifyPage extends ConsumerStatefulWidget {
  final int pointsPerVisit;

  const BusinessLoyaltyVerifyPage({
    super.key,
    this.pointsPerVisit = 10,
  });

  @override
  ConsumerState<BusinessLoyaltyVerifyPage> createState() =>
      _BusinessLoyaltyVerifyPageState();
}

class _BusinessLoyaltyVerifyPageState
    extends ConsumerState<BusinessLoyaltyVerifyPage> {
  late final BusinessLoyaltyApiService _apiService;

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    _apiService = BusinessLoyaltyApiService(
      apiClient: ref.read(apiClientProvider),
    );
  }

  // ============================================================
  // PROCESS SCANNED QR
  // ============================================================

  void _processScannedQr(Map<String, dynamic> qrData) {
    if (_processing || !mounted) {
      return;
    }

    final qrToken = qrData['qrToken'];
    final type = qrData['type'];
    final version = qrData['version'];

    debugPrint(
      'LOYALTY DEBUG VERIFY: received QR',
    );

    debugPrint(
      'LOYALTY DEBUG VERIFY: qrToken = $qrToken',
    );

    debugPrint(
      'LOYALTY DEBUG VERIFY: type = $type',
    );

    debugPrint(
      'LOYALTY DEBUG VERIFY: version = $version',
    );

    if (qrToken is! String ||
        qrToken.trim().isEmpty ||
        version != '1') {
      ref.read(loyaltyScanResultProvider.notifier).state = null;

      _showError(
        'Invalid loyalty QR.',
      );

      return;
    }

    final isVisitQr =
        type == 'SCANAURA_LOYALTY_VISIT';

    final isRewardQr =
        type == 'SCANAURA_LOYALTY_CLAIM';

    if (!isVisitQr && !isRewardQr) {
      ref.read(loyaltyScanResultProvider.notifier).state = null;

      _showError(
        'Unsupported ScanAura loyalty QR.',
      );

      return;
    }

    // Prevent the same scan from being processed twice.
    ref.read(loyaltyScanResultProvider.notifier).state = null;

    setState(() {
      _processing = true;
    });

    if (isVisitQr) {
      _verifyVisitQr(
        qrToken.trim(),
        type,
        version,
      );
      return;
    }

    _verifyRewardQr(
      qrToken.trim(),
      type,
      version,
    );
  }

  // ============================================================
  // VERIFY CUSTOMER VISIT QR
  // ============================================================

  Future<void> _verifyVisitQr(
      String qrToken,
      String type,
      String version,
      ) async {
    try {
      debugPrint(
        'LOYALTY DEBUG VERIFY: visit QR detected',
      );

      final customer =
      await _apiService.verifyLoyaltyQr(
        qrPayload: jsonEncode(
          <String, dynamic>{
            'qrToken': qrToken,
            'type': type,
            'version': version,
          },
        ),
      );

      debugPrint(
        'LOYALTY DEBUG VERIFY: visit verification successful',
      );

      if (!mounted) {
        return;
      }

      final pointsAwarded =
          customer.pointsAwarded;

      if (pointsAwarded == null) {
        _showError(
          'Visit was verified, but the awarded points were not returned by the server.',
        );

        setState(() {
          _processing = false;
        });

        return;
      }

      await _showVerificationSuccessPopup(
        title: 'Visit Verified',
        message:
        'Today\'s loyalty points have been added successfully.',
        icon: Icons.check_circle_rounded,
        details: [
          _PopupDetail(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: customer.customerName,
          ),
          _PopupDetail(
            icon: Icons.stars_rounded,
            label: 'Points awarded',
            value: '+$pointsAwarded points',
          ),
          _PopupDetail(
            icon:
            Icons.account_balance_wallet_outlined,
            label: 'Points balance',
            value:
            '${customer.pointsBalance} points',
          ),
        ],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _processing = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'LOYALTY DEBUG VERIFY: VISIT ERROR = $e',
      );

      debugPrint(
        'LOYALTY DEBUG VERIFY: VISIT STACK = $stackTrace',
      );

      if (!mounted) {
        return;
      }

      _showError(
        _cleanErrorMessage(e),
      );

      setState(() {
        _processing = false;
      });
    }
  }

  // ============================================================
  // VERIFY REWARD QR
  // ============================================================

  Future<void> _verifyRewardQr(
      String qrToken,
      String type,
      String version,
      ) async {
    try {
      debugPrint(
        'LOYALTY DEBUG VERIFY: reward QR detected',
      );

      final result =
      await _apiService.verifyRewardQr(
        qrPayload: jsonEncode(
          <String, dynamic>{
            'qrToken': qrToken,
            'type': type,
            'version': version,
          },
        ),
      );

      debugPrint(
        'LOYALTY DEBUG VERIFY: reward verification successful',
      );

      if (!mounted) {
        return;
      }

      final message =
          result['message']?.toString() ??
              'Reward verified and granted successfully.';

      final data = result['data'];

      if (data is! Map) {
        throw const FormatException(
          'Invalid reward verification response.',
        );
      }

      final rewardData =
      Map<String, dynamic>.from(data);

      final customerName =
      rewardData['customerName']?.toString();

      final rewardTitle =
          rewardData['rewardTitle']?.toString() ??
              rewardData['title']?.toString();

      final rewardAmount =
      _toNumber(rewardData['rewardAmount']);

      final pointsUsed =
      _toInt(rewardData['pointsUsed']);

      final pointsBalance =
      _toInt(rewardData['pointsBalance']);

      final details = <_PopupDetail>[];

      if (customerName != null &&
          customerName.trim().isNotEmpty) {
        details.add(
          _PopupDetail(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: customerName,
          ),
        );
      }

      if (rewardTitle != null &&
          rewardTitle.trim().isNotEmpty) {
        details.add(
          _PopupDetail(
            icon: Icons.card_giftcard_rounded,
            label: 'Reward',
            value: rewardTitle,
          ),
        );
      }

      if (rewardAmount != null) {
        details.add(
          _PopupDetail(
            icon: Icons.local_offer_outlined,
            label: 'Discount',
            value:
            '₹${_formatNumber(rewardAmount)} OFF',
          ),
        );
      }

      if (pointsUsed != null) {
        details.add(
          _PopupDetail(
            icon: Icons.stars_outlined,
            label: 'Points used',
            value: '$pointsUsed points',
          ),
        );
      }

      if (pointsBalance != null) {
        details.add(
          _PopupDetail(
            icon:
            Icons.account_balance_wallet_outlined,
            label: 'Remaining points',
            value: '$pointsBalance points',
          ),
        );
      }

      await _showVerificationSuccessPopup(
        title: 'Reward Verified',
        message: message,
        icon: Icons.card_giftcard_rounded,
        details: details,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _processing = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'LOYALTY DEBUG VERIFY: REWARD ERROR = $e',
      );

      debugPrint(
        'LOYALTY DEBUG VERIFY: REWARD STACK = $stackTrace',
      );

      if (!mounted) {
        return;
      }

      _showError(
        _cleanErrorMessage(e),
      );

      setState(() {
        _processing = false;
      });
    }
  }

  // ============================================================
  // COMMON SUCCESS POPUP
  // ============================================================

  Future<void> _showVerificationSuccessPopup({
    required String title,
    required String message,
    required IconData icon,
    required List<_PopupDetail> details,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding:
          const EdgeInsets.fromLTRB(
            24,
            26,
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
                  color:
                  colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 46,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                title,
                textAlign: TextAlign.center,
                style:
                theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // MESSAGE
              // ==================================================

              Text(
                message,
                textAlign: TextAlign.center,
                style:
                theme.textTheme.bodyMedium?.copyWith(
                  color:
                  colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // DETAILS
              // ==================================================

              if (details.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: details
                        .map(
                          (detail) =>
                          _buildPopupDetail(
                            context,
                            detail,
                          ),
                    )
                        .toList(),
                  ),
                ),

              const SizedBox(height: 22),

              // ==================================================
              // DONE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Done',
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
  // POPUP DETAIL
  // ============================================================

  Widget _buildPopupDetail(
      BuildContext context,
      _PopupDetail detail,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            detail.icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detail.label,
              style:
              theme.textTheme.bodyMedium?.copyWith(
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              detail.value,
              textAlign: TextAlign.right,
              style:
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPEN UNIFIED SCANNER
  // ============================================================

  void _openScanner() {
    if (_processing || !mounted) {
      return;
    }

    context.push(
      '/activity/loyalty/scan',
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

  // ============================================================
  // HELPERS
  // ============================================================

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value != null) {
      return int.tryParse(
        value.toString().trim(),
      );
    }

    return null;
  }

  num? _toNumber(dynamic value) {
    if (value is num) {
      return value;
    }

    if (value != null) {
      return num.tryParse(
        value.toString().trim(),
      );
    }

    return null;
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
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

    // ----------------------------------------------------------
    // RECEIVE RESULT FROM UNIFIED SCANNER
    // ----------------------------------------------------------

    final scannedQr =
    ref.watch(loyaltyScanResultProvider);

    if (scannedQr != null && !_processing) {
      WidgetsBinding.instance.addPostFrameCallback(
            (_) {
          if (!mounted || _processing) {
            return;
          }

          final currentQr =
          ref.read(
            loyaltyScanResultProvider,
          );

          if (currentQr == null) {
            return;
          }

          _processScannedQr(currentQr);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Loyalty',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              24,
              28,
              24,
              36,
            ),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 620,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // ICON
                  // ==================================================

                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color:
                      colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons
                          .sentiment_very_satisfied_rounded,
                      size: 52,
                      color:
                      colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // MAIN MESSAGE
                  // ==================================================

                  Text(
                    'Serve Happiness to Your Customer',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Scan a customer loyalty QR to reward their visit or verify a claimed reward.',
                    textAlign: TextAlign.center,
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ==================================================
                  // SCAN CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:
                      colorScheme.surface,
                      borderRadius:
                      BorderRadius.circular(
                        24,
                      ),
                      border: Border.all(
                        color: colorScheme
                            .outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .qr_code_scanner_rounded,
                          size: 44,
                          color:
                          colorScheme.primary,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Text(
                          'Ready to make a customer happy?',
                          textAlign:
                          TextAlign.center,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Scan their ScanAura QR to continue.',
                          textAlign:
                          TextAlign.center,
                          style: theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          height: 56,
                          child:
                          FilledButton.icon(
                            onPressed:
                            _processing
                                ? null
                                : _openScanner,
                            icon: _processing
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2.4,
                              ),
                            )
                                : const Icon(
                              Icons
                                  .qr_code_scanner_rounded,
                            ),
                            label: Text(
                              _processing
                                  ? 'Verifying...'
                                  : 'Scan Customer QR',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SMALL INFORMATION
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding:
                    const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Icon(
                          Icons
                              .info_outline_rounded,
                          size: 20,
                          color:
                          colorScheme.primary,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Text(
                            'One scanner handles both customer visit QR codes and reward QR codes automatically.',
                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

// ================================================================
// POPUP DETAIL MODEL
// ================================================================

class _PopupDetail {
  final IconData icon;
  final String label;
  final String value;

  const _PopupDetail({
    required this.icon,
    required this.label,
    required this.value,
  });
}