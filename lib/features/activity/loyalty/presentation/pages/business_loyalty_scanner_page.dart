import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../providers/loyalty_scan_result_provider.dart';

class BusinessLoyaltyScannerPage extends ConsumerStatefulWidget {
  const BusinessLoyaltyScannerPage({
    super.key,
  });

  @override
  ConsumerState<BusinessLoyaltyScannerPage> createState() =>
      _BusinessLoyaltyScannerPageState();
}

class _BusinessLoyaltyScannerPageState
    extends ConsumerState<BusinessLoyaltyScannerPage> {
  final MobileScannerController _controller =
  MobileScannerController();

  bool _processing = false;

  @override
  void dispose() {
    debugPrint(
      'LOYALTY DEBUG SCANNER: DISPOSE',
    );

    _controller.dispose();

    super.dispose();
  }

  // ============================================================
  // QR DETECTION
  // ============================================================

  void _onDetect(BarcodeCapture capture) {
    debugPrint(
      'LOYALTY DEBUG SCANNER: onDetect called | '
          'barcodes=${capture.barcodes.length}',
    );

    if (_processing) {
      debugPrint(
        'LOYALTY DEBUG SCANNER: detection ignored '
            'because processing=true',
      );

      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      debugPrint(
        'LOYALTY DEBUG SCANNER: barcode rawValue = $rawValue',
      );

      if (rawValue == null ||
          rawValue.trim().isEmpty) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: empty/null barcode value',
        );

        continue;
      }

      _processQr(rawValue.trim());

      break;
    }
  }

  // ============================================================
  // PROCESS QR
  // ============================================================

  Future<void> _processQr(String rawValue) async {
    if (_processing || !mounted) {
      debugPrint(
        'LOYALTY DEBUG SCANNER: _processQr ignored | '
            'processing=$_processing mounted=$mounted',
      );

      return;
    }

    setState(() {
      _processing = true;
    });

    debugPrint('================================================');
    debugPrint(
      'LOYALTY DEBUG SCANNER: QR DETECTED',
    );
    debugPrint(
      'LOYALTY DEBUG SCANNER: RAW VALUE START',
    );
    debugPrint(rawValue);
    debugPrint(
      'LOYALTY DEBUG SCANNER: RAW VALUE END',
    );
    debugPrint('================================================');

    try {
      // ----------------------------------------------------------
      // STEP 1: JSON DECODE
      // ----------------------------------------------------------

      dynamic decoded;

      try {
        decoded = jsonDecode(rawValue);

        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 1 - '
              'JSON DECODE SUCCESS',
        );
      } catch (e, stackTrace) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 1 - '
              'JSON DECODE FAILED',
        );

        debugPrint(
          'LOYALTY DEBUG SCANNER: decode error = $e',
        );

        debugPrint('$stackTrace');

        throw const _InvalidLoyaltyQrException(
          'QR does not contain valid ScanAura loyalty data.',
        );
      }

      // ----------------------------------------------------------
      // STEP 2: MAP
      // ----------------------------------------------------------

      if (decoded is! Map) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 2 - '
              'decoded value is NOT a Map',
        );

        throw const _InvalidLoyaltyQrException(
          'Invalid ScanAura loyalty QR format.',
        );
      }

      final data = Map<String, dynamic>.from(decoded);

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 2 - '
            'decoded Map SUCCESS',
      );

      debugPrint(
        'LOYALTY DEBUG SCANNER: decoded data = $data',
      );

      // ----------------------------------------------------------
      // STEP 3: FIELDS
      // ----------------------------------------------------------

      final qrToken = data['qrToken'];
      final qrType = data['type'];
      final qrVersion = data['version'];

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 3 - '
            'QR TOKEN = $qrToken',
      );

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 3 - '
            'QR TOKEN TYPE = ${qrToken.runtimeType}',
      );

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 3 - '
            'QR TYPE = $qrType',
      );

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 3 - '
            'QR VERSION = $qrVersion',
      );

      // ----------------------------------------------------------
      // STEP 4: TOKEN
      // ----------------------------------------------------------

      if (qrToken is! String ||
          qrToken.trim().isEmpty) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 4 FAILED - '
              'invalid qrToken',
        );

        throw const _InvalidLoyaltyQrException(
          'Invalid ScanAura loyalty QR token.',
        );
      }

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 4 - TOKEN VALID',
      );

      // ----------------------------------------------------------
      // STEP 5: QR TYPE
      // ----------------------------------------------------------

      final isVisitQr =
          qrType == 'SCANAURA_LOYALTY_VISIT';

      final isRewardQr =
          qrType == 'SCANAURA_LOYALTY_CLAIM';

      if (!isVisitQr && !isRewardQr) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 5 FAILED - '
              'unsupported QR type',
        );

        debugPrint(
          'LOYALTY DEBUG SCANNER: received = $qrType',
        );

        throw const _InvalidLoyaltyQrException(
          'This is not a valid ScanAura loyalty QR.',
        );
      }

      if (isVisitQr) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 5 - '
              'CUSTOMER VISIT QR DETECTED',
        );
      } else {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 5 - '
              'REWARD CLAIM QR DETECTED',
        );
      }

      // ----------------------------------------------------------
      // STEP 6: VERSION
      // ----------------------------------------------------------

      if (qrVersion != '1') {
        debugPrint(
          'LOYALTY DEBUG SCANNER: STEP 6 FAILED - '
              'wrong QR version',
        );

        debugPrint(
          'LOYALTY DEBUG SCANNER: expected = 1',
        );

        debugPrint(
          'LOYALTY DEBUG SCANNER: received = $qrVersion',
        );

        throw const _InvalidLoyaltyQrException(
          'Unsupported loyalty QR version.',
        );
      }

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 6 - '
            'QR VERSION VALID',
      );

      // ----------------------------------------------------------
      // STEP 7: FULLY VALID
      // ----------------------------------------------------------

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 7 - '
            'QR IS FULLY VALID',
      );

      final result = <String, dynamic>{
        'qrToken': qrToken.trim(),
        'type': qrType,
        'version': qrVersion,
      };

      debugPrint(
        'LOYALTY DEBUG SCANNER: RESULT = $result',
      );

      // ----------------------------------------------------------
      // STEP 8: STOP CAMERA
      // ----------------------------------------------------------

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 8 - '
            'stopping camera',
      );

      try {
        await _controller.stop();

        debugPrint(
          'LOYALTY DEBUG SCANNER: '
              'camera stopped successfully',
        );
      } catch (e) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: '
              'camera stop error = $e',
        );
      }

      if (!mounted) {
        debugPrint(
          'LOYALTY DEBUG SCANNER: '
              'widget unmounted after camera stop',
        );

        return;
      }

      // ----------------------------------------------------------
      // STEP 9: STORE RESULT
      // ----------------------------------------------------------

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 9 - '
            'storing QR result in provider',
      );

      ref.read(
        loyaltyScanResultProvider.notifier,
      ).state = result;

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 9 - '
            'QR result stored successfully',
      );

      // ----------------------------------------------------------
      // STEP 10: RETURN TO VERIFY PAGE
      // ----------------------------------------------------------

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 10 - '
            'QR type = $qrType',
      );

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 10 - '
            'navigating back to Verify Loyalty',
      );

      // Both QR types return to the same verification page.
      //
      // The verification page will use the QR "type" to decide
      // whether this is:
      //
      // SCANAURA_LOYALTY_VISIT
      //      -> verify customer visit / award points
      //
      // SCANAURA_LOYALTY_CLAIM
      //      -> verify claimed reward / redeem reward
      //
      // We intentionally keep those backend operations separate.
      context.go('/activity/loyalty/verify');

      debugPrint(
        'LOYALTY DEBUG SCANNER: STEP 10 - '
            'context.go CALLED',
      );
    } catch (e, stackTrace) {
      debugPrint('================================================');
      debugPrint(
        'LOYALTY DEBUG SCANNER: ERROR',
      );
      debugPrint(
        'LOYALTY DEBUG SCANNER: ERROR = $e',
      );
      debugPrint(
        'LOYALTY DEBUG SCANNER: STACK TRACE',
      );
      debugPrint('$stackTrace');
      debugPrint('================================================');

      if (!mounted) {
        return;
      }

      final message =
      e is _InvalidLoyaltyQrException
          ? e.message
          : 'Invalid loyalty QR. Please scan a valid ScanAura loyalty QR.';

      debugPrint(
        'LOYALTY DEBUG SCANNER: USER MESSAGE = $message',
      );

      setState(() {
        _processing = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> _switchCamera() async {
    debugPrint(
      'LOYALTY DEBUG SCANNER: '
          'switch camera requested',
    );

    try {
      await _controller.switchCamera();

      debugPrint(
        'LOYALTY DEBUG SCANNER: '
            'camera switched successfully',
      );
    } catch (e) {
      debugPrint(
        'LOYALTY DEBUG SCANNER: '
            'camera switch error = $e',
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Loyalty QR',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Switch camera',
            icon: const Icon(
              Icons.flip_camera_ios,
            ),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color:
                Colors.black.withValues(
                  alpha: 0.65,
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: const Text(
                'Scan a customer visit QR or a reward QR.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          if (_processing)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _InvalidLoyaltyQrException
    implements Exception {
  const _InvalidLoyaltyQrException([
    this.message = 'Invalid loyalty QR.',
  ]);

  final String message;

  @override
  String toString() => message;
}