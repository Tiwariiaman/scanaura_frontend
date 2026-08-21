import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/models/qr_response.dart';
import '../services/qr_file_service.dart';
import 'providers/qr_notifier.dart';
import 'providers/qr_state.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrNotifierProvider.notifier).loadQr();
    });
  }

  // ============================================================
  // GENERATE QR PNG BYTES
  // ============================================================

  Future<Uint8List> _generateQrBytes() async {
    final qrCode = ref.read(qrNotifierProvider).digitalQr;

    if (qrCode == null) {
      throw Exception('Digital QR not available.');
    }

    final painter = QrPainter(
      data: qrCode.qrCode,
      version: QrVersions.auto,
      gapless: true,
    );

    final byteData = await painter.toImageData(
      1000,
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Unable to generate QR image.');
    }

    return byteData.buffer.asUint8List();
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void> _downloadQr() async {
    try {
      final bytes = await _generateQrBytes();

      await QrFileService.downloadQr(
        bytes,
        'scanaura_qr.png',
      );

      if (!mounted) return;

      _showMessage('QR downloaded successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('QR download failed: $e');
    }
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _shareQr() async {
    try {
      final bytes = await _generateQrBytes();

      await QrFileService.shareQr(
        bytes,
        'scanaura_qr.png',
      );

      if (!mounted) return;

      _showMessage('QR shared successfully.');
    } catch (e) {
      if (!mounted) return;

      _showMessage('QR sharing failed: $e');
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Management'),
      ),
      body: _buildBody(
        context,
        state,
        theme,
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      QrState state,
      ThemeData theme,
      ) {
    switch (state.status) {
      case QrStatus.initial:
      case QrStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case QrStatus.error:
        return _buildError(
          context,
          state,
        );

      case QrStatus.success:
        return _buildQrContent(
          context,
          state,
          theme,
        );
    }
  }

  // ============================================================
  // QR CONTENT
  // ============================================================

  Widget _buildQrContent(
      BuildContext context,
      QrState state,
      ThemeData theme,
      ) {
    final digitalQr = state.digitalQr;

    final physicalQrs = state.qrCodes
        .where(
          (qr) => qr.type == 'PHYSICAL',
    )
        .toList();

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(qrNotifierProvider.notifier)
            .loadQr();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your QR Codes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Manage the QR codes connected to your business.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 24),

          _buildDigitalQrCard(
            context,
            theme,
            digitalQr,
          ),

          const SizedBox(height: 20),

          _buildPhysicalQrCard(
            context,
            theme,
            physicalQrs,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIGITAL QR
  // ============================================================

  Widget _buildDigitalQrCard(
      BuildContext context,
      ThemeData theme,
      QrResponse? qr,
      ) {
    if (qr == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Digital QR not found.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Digital QR',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your primary digital menu QR code.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QR PREVIEW
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: QrImageView(
                data: qr.qrCode,
                version: QrVersions.auto,
                size: 260,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              qr.qrCode,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  qr.active
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 18,
                  color: qr.active
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  qr.active ? 'Active' : 'Inactive',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadQr,
                    icon: const Icon(
                      Icons.download_rounded,
                    ),
                    label: const Text(
                      'Download QR',
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: _shareQr,
                    icon: const Icon(
                      Icons.share_rounded,
                    ),
                    label: const Text(
                      'Share QR',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PHYSICAL QR
  // ============================================================

  Widget _buildPhysicalQrCard(
      BuildContext context,
      ThemeData theme,
      List<QrResponse> physicalQrs,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical QR',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'QR codes assigned to your business.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Text(
                  'Assigned',
                  style: theme.textTheme.bodyLarge,
                ),

                const Spacer(),

                Text(
                  '${physicalQrs.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (physicalQrs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 40,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'No physical QR assigned yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else
              ...physicalQrs.map(
                    (qr) => Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,

                    leading: const Icon(
                      Icons.qr_code_2_rounded,
                    ),

                    title: Text(
                      qr.qrCode,
                    ),

                    subtitle: Text(
                      qr.active ? 'Active' : 'Inactive',
                    ),

                    trailing: Icon(
                      qr.active
                          ? Icons.check_circle
                          : Icons.cancel,
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
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      QrState state,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
            ),

            const SizedBox(height: 16),

            Text(
              state.errorMessage ??
                  'Unable to load QR codes.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                ref
                    .read(qrNotifierProvider.notifier)
                    .loadQr();
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}