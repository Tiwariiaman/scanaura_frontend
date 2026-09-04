import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import '../providers/admin_notifier.dart';

class AdminQrScannerScreen extends ConsumerStatefulWidget {
  const AdminQrScannerScreen({
    super.key,
  });

  @override
  ConsumerState<AdminQrScannerScreen> createState() =>
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

  // ============================================================
  // QR SCAN HANDLER
  // ============================================================

  Future<void> _handleScan(
      BarcodeCapture capture,
      ) async {
    if (_processing) {
      return;
    }

    String? rawValue;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;

      if (value != null && value.trim().isNotEmpty) {
        rawValue = value.trim();
        break;
      }
    }

    if (rawValue == null) {
      return;
    }

    final qrCode = _extractQrCode(rawValue);

    if (qrCode == null) {
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

      final message = ref
          .read(adminNotifierProvider)
          .errorMessage ??
          'Unable to load QR details.';

      _showMessage(message);
      return;
    }

    // ==========================================================
    // OPEN QR DETAILS
    // ==========================================================

    context.push(
      '/admin/qr/details',
      extra: qrCode,
    );

    // Scanner will automatically be available
    // again when the user returns to this screen.
    setState(() {
      _processing = false;
    });
  }

  // ============================================================
  // QR CODE EXTRACTION
  // ============================================================
  //
  // Supports:
  //
  // SA-P-000001
  // SA-D-XXXXXXXX
  //
  // https://scanaura.in/q/SA-D-XXXXXXXX
  //
  // https://scanaura.in/#/q/SA-D-XXXXXXXX
  //
  // Any URL containing a valid ScanAura QR code.
  //
  // ============================================================

  String? _extractQrCode(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    // ----------------------------------------------------------
    // 1. DIRECT RAW SCANAURA QR
    // ----------------------------------------------------------

    final directMatch = RegExp(
      r'^(SA-(?:P|D)-[A-Za-z0-9-]+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (directMatch != null) {
      return directMatch.group(1)!.toUpperCase();
    }

    // ----------------------------------------------------------
    // 2. SEARCH THE ENTIRE SCANNED VALUE
    // ----------------------------------------------------------
    //
    // This is intentionally done before URL parsing.
    //
    // It handles:
    //
    // https://scanaura.in/q/SA-D-12345678
    //
    // https://scanaura.in/#/q/SA-D-12345678
    //
    // https://scanaura.in/#/q/SA-P-000001
    //
    // and future ScanAura URL structures.
    // ----------------------------------------------------------

    final embeddedMatch = RegExp(
      r'(SA-(?:P|D)-[A-Za-z0-9-]+)',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (embeddedMatch != null) {
      return embeddedMatch.group(1)!.toUpperCase();
    }

    // ----------------------------------------------------------
    // 3. URL PARSING FALLBACK
    // ----------------------------------------------------------

    try {
      final uri = Uri.tryParse(trimmed);

      if (uri == null) {
        return null;
      }

      // --------------------------------------------------------
      // NORMAL PATH
      // Example:
      // /q/SA-D-XXXXXXXX
      // --------------------------------------------------------

      for (final segment in uri.pathSegments) {
        final match = RegExp(
          r'^(SA-(?:P|D)-[A-Za-z0-9-]+)$',
          caseSensitive: false,
        ).firstMatch(segment);

        if (match != null) {
          return match.group(1)!.toUpperCase();
        }
      }

      // --------------------------------------------------------
      // FLUTTER WEB HASH ROUTE
      //
      // Example:
      //
      // https://scanaura.in/#/q/SA-D-XXXXXXXX
      //
      // The QR code exists inside uri.fragment.
      // --------------------------------------------------------

      final fragment = uri.fragment.trim();

      if (fragment.isNotEmpty) {
        final fragmentMatch = RegExp(
          r'(SA-(?:P|D)-[A-Za-z0-9-]+)',
          caseSensitive: false,
        ).firstMatch(fragment);

        if (fragmentMatch != null) {
          return fragmentMatch.group(1)!.toUpperCase();
        }
      }

      // --------------------------------------------------------
      // QUERY PARAMETERS FALLBACK
      // --------------------------------------------------------

      for (final entry in uri.queryParameters.entries) {
        final match = RegExp(
          r'(SA-(?:P|D)-[A-Za-z0-9-]+)',
          caseSensitive: false,
        ).firstMatch(entry.value);

        if (match != null) {
          return match.group(1)!.toUpperCase();
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

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

  // ============================================================
  // UI
  // ============================================================

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
          // ======================================================
          // CAMERA
          // ======================================================

          MobileScanner(
            controller: _controller,
            onDetect: _handleScan,
          ),

          // ======================================================
          // SCANNER FRAME
          // ======================================================

          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // ======================================================
          // INSTRUCTIONS
          // ======================================================

          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.72,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Scan any ScanAura QR code.\n'
                    'Physical and Digital QR are supported.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // ======================================================
          // PROCESSING
          // ======================================================

          if (_processing)
            Container(
              color: Colors.black.withValues(
                alpha: 0.55,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}