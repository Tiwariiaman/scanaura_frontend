import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LoyaltyQrScannerPage extends StatefulWidget {
  const LoyaltyQrScannerPage({
    super.key,
  });

  @override
  State<LoyaltyQrScannerPage> createState() =>
      _LoyaltyQrScannerPageState();
}

class _LoyaltyQrScannerPageState
    extends State<LoyaltyQrScannerPage> {

  final MobileScannerController _scannerController =
  MobileScannerController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQrCode(
      BarcodeCapture capture,
      ) async {

    if (_isProcessing) {
      return;
    }

    final barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      return;
    }

    final rawValue = barcodes.first.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    _isProcessing = true;

    await _scannerController.stop();

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid QR format.',
        );
      }

      final qrToken = decoded['qrToken'];
      final type = decoded['type'];
      final version = decoded['version'];

      if (qrToken is! String ||
          qrToken.trim().isEmpty) {
        throw const FormatException(
          'QR token is missing.',
        );
      }

      if (type != 'SCANAURA_LOYALTY_CLAIM') {
        throw const FormatException(
          'This is not a ScanAura loyalty QR.',
        );
      }

      if (version != '1') {
        throw const FormatException(
          'This loyalty QR version is not supported.',
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        <String, dynamic>{
          'qrToken': qrToken,
          'type': type,
          'version': version,
        },
      );
    } catch (_) {

      if (!mounted) {
        return;
      }

      await _showInvalidQr();

      if (mounted) {
        _isProcessing = false;
        await _scannerController.start();
      }
    }
  }

  Future<void> _showInvalidQr() async {

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .error,
                  size: 28,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Invalid QR Code',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Please scan the loyalty QR shown by the customer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Scan Again',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Verify Loyalty Reward',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            onPressed: () {
              _scannerController.switchCamera();
            },
            icon: const Icon(
              Icons.cameraswitch_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [

          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQrCode,
          ),

          IgnorePointer(
            child: Center(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius:
                  BorderRadius.circular(28),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 42,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.72,
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Scan customer loyalty QR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Position the QR code inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}