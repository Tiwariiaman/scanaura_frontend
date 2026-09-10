import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/loyalty_visit_qr_response.dart';
import '../../../../public_menu/presentation/theme/public_theme_resolver.dart';

class CustomerLoyaltyVisitQrPage extends StatefulWidget {
  final String businessName;
  final String businessType;
  final String? brandColor;
  final LoyaltyVisitQrResponse qrResponse;

  const CustomerLoyaltyVisitQrPage({
    super.key,
    required this.businessName,
    this.businessType = '',
    this.brandColor,
    required this.qrResponse,
  });

  @override
  State<CustomerLoyaltyVisitQrPage> createState() =>
      _CustomerLoyaltyVisitQrPageState();
}

class _CustomerLoyaltyVisitQrPageState
    extends State<CustomerLoyaltyVisitQrPage> {
  Timer? _timer;

  late LoyaltyVisitQrResponse _qrResponse;

  int _remainingSeconds = 0;
  bool _expired = false;

  @override
  void initState() {
    super.initState();

    _qrResponse = widget.qrResponse;
    _updateTimer();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateTimer(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _updateTimer() {
    if (!mounted) {
      return;
    }

    final seconds = _qrResponse.remainingSeconds;

    if (seconds <= 0) {
      _timer?.cancel();

      setState(() {
        _remainingSeconds = 0;
        _expired = true;
      });

      return;
    }

    setState(() {
      _remainingSeconds = seconds;
      _expired = false;
    });
  }

  // ============================================================
  // QR PAYLOAD
  // ============================================================

  String get _qrPayload {
    return jsonEncode(
      <String, dynamic>{
        'qrToken': _qrResponse.qrToken,
        'type': _qrResponse.qrType,
        'version': _qrResponse.qrVersion,
      },
    );
  }

  // ============================================================
  // TIME TEXT
  // ============================================================

  String get _remainingText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final publicTheme = PublicThemeResolver.resolve(
      businessName: widget.businessName,
      businessType: widget.businessType,
      brandColor: widget.brandColor,
    );
    return Theme(
      data: publicTheme.materialTheme(context),
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today’s Loyalty QR',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28,
          ),
          child: Column(
            children: [
              // ==================================================
              // BUSINESS
              // ==================================================

              Text(
                widget.businessName,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                _expired
                    ? 'This QR has expired'
                    : 'Show this QR to the business',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 26),

              // ==================================================
              // QR CARD
              // ==================================================

              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 360,
                      maxHeight: 460,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                          color: Colors.black.withValues(
                            alpha: 0.08,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        // ========================================
                        // QR
                        // ========================================

                        AnimatedOpacity(
                          duration:
                          const Duration(milliseconds: 250),
                          opacity: _expired ? 0.18 : 1,
                          child: QrImageView(
                            data: _qrPayload,
                            version: QrVersions.auto,
                            size: 260,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ========================================
                        // TIMER
                        // ========================================

                        if (!_expired)
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color:
                              colorScheme.primaryContainer,
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 19,
                                  color: colorScheme
                                      .onPrimaryContainer,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Expires in $_remainingText',
                                  style: TextStyle(
                                    color: colorScheme
                                        .onPrimaryContainer,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color:
                              colorScheme.errorContainer,
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                            child: Text(
                              'QR expired',
                              style: TextStyle(
                                color: colorScheme
                                    .onErrorContainer,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFORMATION
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                  colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Keep this screen open while the business scans your QR. It is temporary and can only be used once.',
                        style:
                        theme.textTheme.bodySmall?.copyWith(
                          color:
                          colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // CLOSE / EXPIRED ACTION
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    _expired ? 'Close' : 'Done',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
