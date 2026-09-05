import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../../qr/data/models/qr_response.dart';
import '../../qr/presentation/widgets/scanaura_qr_card.dart';

class AdminQrPackService {
  AdminQrPackService._();

  static final ScreenshotController _controller =
  ScreenshotController();

  // ============================================================
  // GENERATE PHYSICAL QR ZIP PACK
  // ============================================================

  static Future<Uint8List> generateZip({
    required BuildContext context,
    required List<QrResponse> qrCodes,
  }) async {
    if (qrCodes.isEmpty) {
      throw Exception(
        'No QR codes available for download.',
      );
    }

    final archive = Archive();

    for (var index = 0; index < qrCodes.length; index++) {
      final qr = qrCodes[index];

      // IMPORTANT:
      // Always use the actual QR code value from the
      // QrResponse object.
      //
      // Correct:
      //   ${qr.qrCode}
      //
      // NOT:
      //   $qr.qrCode
      //
      // The latter becomes:
      //   Instance of 'QrResponse'.qrCode
      //
      // The old working ScanAura physical QR format uses /q/{code}.
      final qrCode = qr.qrCode.trim();

      if (qrCode.isEmpty) {
        throw Exception(
          'QR code value is empty at index ${index + 1}.',
        );
      }

      final publicUrl =
          'https://scanaura.in/q/$qrCode';

      final imageBytes =
      await _controller.captureFromWidget(
        InheritedTheme.captureAll(
          context,
          Material(
            color: Colors.white,
            child: SizedBox(
              width: 430,
              child: ScanAuraQrCard(
                qrData: publicUrl,
                businessName: null,
                showBusinessName: true,
              ),
            ),
          ),
        ),
        context: context,
        pixelRatio: 2.0,
        delay: const Duration(
          milliseconds: 80,
        ),
      );

      final safeQrCode = qrCode.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );

      archive.addFile(
        ArchiveFile(
          'scanaura_$safeQrCode.png',
          imageBytes.length,
          imageBytes,
        ),
      );
    }

    final zipBytes = ZipEncoder().encodeBytes(
      archive,
      level: DeflateLevel.bestSpeed,
    );

    return Uint8List.fromList(
      zipBytes,
    );
  }
}