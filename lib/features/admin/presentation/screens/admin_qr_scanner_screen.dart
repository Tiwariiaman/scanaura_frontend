import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import '../providers/admin_notifier.dart';

class AdminQrScannerScreen
    extends ConsumerStatefulWidget {
  const AdminQrScannerScreen({
    super.key,
  });

  @override
  ConsumerState<AdminQrScannerScreen>
  createState() =>
      _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState
    extends ConsumerState<AdminQrScannerScreen> {
  final MobileScannerController _controller =
  MobileScannerController();

  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(
      BarcodeCapture capture,
      ) async {
    if (_processing) {
      return;
    }

    String? rawValue;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value != null &&
          value.trim().isNotEmpty) {
        rawValue = value.trim();
        break;
      }
    }

    if (rawValue == null) {
      return;
    }

    final qrCode =
    _extractQrCode(rawValue);

    if (qrCode == null) {
      await _showInvalidQr();
      return;
    }

    setState(() {
      _processing = true;
    });

    await _controller.stop();

    final success = await ref
        .read(
      adminNotifierProvider.notifier,
    )
        .loadQrDetails(qrCode);

    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _processing = false;
      });

      await _controller.start();

      final message =
          ref
              .read(adminNotifierProvider)
              .errorMessage ??
              'Unable to load QR details.';

      _showMessage(message);
      return;
    }

    // Open the QR details screen.
    context.push(
      '/admin/qr/details',
      extra: qrCode,
    );

    // Allow the scanner page to resume if
    // the user comes back to it.
    setState(() {
      _processing = false;
    });
  }

  String? _extractQrCode(String value) {
    final trimmed = value.trim();

    // ----------------------------------------------------------
    // RAW QR CODE
    // ----------------------------------------------------------

    if (trimmed.startsWith('SA-P-') ||
        trimmed.startsWith('SA-D-')) {
      return trimmed;
    }

    // ----------------------------------------------------------
    // SCANAURA PUBLIC URL
    // ----------------------------------------------------------

    try {
      final uri = Uri.tryParse(trimmed);

      if (uri == null) {
        return null;
      }

      final segments = uri.pathSegments;

      final qIndex =
      segments.indexOf('q');

      if (qIndex != -1 &&
          qIndex + 1 < segments.length) {
        final code =
        segments[qIndex + 1].trim();

        if (code.startsWith('SA-P-') ||
            code.startsWith('SA-D-')) {
          return code;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> _showInvalidQr() async {
    if (!mounted) {
      return;
    }

    _showMessage(
      'This is not a valid ScanAura QR code.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan QR',
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: _processing
                ? null
                : () {
              _controller.toggleTorch();
            },
            icon: const Icon(
              Icons.flashlight_on_outlined,
            ),
          ),

          IconButton(
            tooltip: 'Switch camera',
            onPressed: _processing
                ? null
                : () {
              _controller.switchCamera();
            },
            icon: const Icon(
              Icons.cameraswitch_outlined,
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleScan,
          ),

          // Scanner frame
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius:
                BorderRadius.circular(24),
              ),
            ),
          ),

          // Instruction
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black
                    .withValues(alpha: 0.72),
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: const Text(
                'Scan any ScanAura QR code.\n'
                    'Physical and Digital QR are supported.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),

          if (_processing)
            Container(
              color: Colors.black
                  .withValues(alpha: 0.55),
              child: const Center(
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}