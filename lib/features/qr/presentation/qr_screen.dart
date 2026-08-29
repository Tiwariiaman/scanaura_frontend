import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../business/presentation/providers/business_notifier.dart';
import '../data/models/qr_response.dart';
import '../services/qr_file_service.dart';
import 'providers/qr_notifier.dart';
import 'providers/qr_state.dart';
import 'widgets/scanaura_qr_card.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() =>
      _QrScreenState();
}

class _QrScreenState
    extends ConsumerState<QrScreen> {
  final GlobalKey _qrCardKey =
  GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {
      await Future.wait([
        ref
            .read(
          qrNotifierProvider.notifier,
        )
            .loadQr(),
        ref
            .read(
          businessNotifierProvider
              .notifier,
        )
            .loadMyBusiness(),
      ]);
    });
  }

  // ============================================================
  // PUBLIC QR URL
  // ============================================================

  String _publicQrUrl(
      String qrCode,
      ) {
    return 'https://scanaura.in/#/q/$qrCode';
  }

  // ============================================================
  // GENERATE QR CARD IMAGE
  // ============================================================

  Future<Uint8List>
  _generateQrCardBytes() async {
    await WidgetsBinding.instance
        .endOfFrame;

    final boundaryContext =
        _qrCardKey.currentContext;

    if (boundaryContext == null) {
      throw Exception(
        'QR card is not ready.',
      );
    }

    final renderObject =
    boundaryContext
        .findRenderObject();

    if (renderObject
    is! RenderRepaintBoundary) {
      throw Exception(
        'Unable to capture QR card.',
      );
    }

    final image =
    await renderObject.toImage(
      pixelRatio: 3.0,
    );

    final byteData =
    await image.toByteData(
      format:
      ui.ImageByteFormat.png,
    );

    image.dispose();

    if (byteData == null) {
      throw Exception(
        'Unable to generate QR card image.',
      );
    }

    return byteData.buffer
        .asUint8List();
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  Future<void> _downloadQr() async {
    try {
      final bytes =
      await _generateQrCardBytes();

      final business =
          ref
              .read(
            businessNotifierProvider,
          )
              .business;

      final businessName =
      business?.businessName
          .trim()
          .replaceAll(
        RegExp(
          r'[^a-zA-Z0-9]+',
        ),
        '_',
      );

      final fileName =
      businessName == null ||
          businessName.isEmpty
          ? 'scanaura_qr_card.png'
          : 'scanaura_${businessName}_qr.png';

      await QrFileService.downloadQr(
        bytes,
        fileName,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'QR downloaded successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'QR download failed: ${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // SHARE
  // ============================================================

  Future<void> _shareQr() async {
    try {
      final state =
      ref.read(
        qrNotifierProvider,
      );

      final qr =
          state.digitalQr;

      if (qr == null) {
        throw Exception(
          'Digital QR not available.',
        );
      }

      final bytes =
      await _generateQrCardBytes();

      final business =
          ref
              .read(
            businessNotifierProvider,
          )
              .business;

      final businessName =
      business?.businessName
          .trim();

      final safeBusinessName =
      businessName == null ||
          businessName.isEmpty
          ? 'business'
          : businessName
          .replaceAll(
        RegExp(
          r'[^a-zA-Z0-9]+',
        ),
        '_',
      );

      final publicUrl =
          'https://scanaura.in/#/q/${qr.qrCode}';

      final shareText =
      businessName != null &&
          businessName.isNotEmpty
          ? '''
Hi! Check out $businessName on ScanAura.

View the menu and pay with any UPI app:
$publicUrl
'''
          : '''
Hi! Check out this business on ScanAura.

View the menu and pay with any UPI app:
$publicUrl
''';

      await QrFileService.shareQr(
        bytes: bytes,
        fileName:
        'scanaura_${safeBusinessName}_qr.png',
        text: shareText,
        subject:
        '$businessName on ScanAura',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'QR shared successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'QR sharing failed: ${_cleanError(e)}',
      );
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  void _showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
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
      qrNotifierProvider,
    );

    final business =
        ref.watch(
          businessNotifierProvider,
        ).business;

    final theme =
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Management',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(
        context,
        state,
        business?.businessName,
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
      String? businessName,
      ThemeData theme,
      ) {
    switch (state.status) {
      case QrStatus.initial:
      case QrStatus.loading:
        return const Center(
          child:
          CircularProgressIndicator(),
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
          businessName,
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
      String? businessName,
      ThemeData theme,
      ) {
    final digitalQr =
        state.digitalQr;

    final physicalQrs =
    state.qrCodes
        .where(
          (qr) =>
      qr.type == 'PHYSICAL',
    )
        .toList();

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(
          qrNotifierProvider
              .notifier,
        )
            .loadQr();
      },
      child: LayoutBuilder(
        builder: (
            context,
            constraints,
            ) {
          final width =
              constraints.maxWidth;

          final horizontalPadding =
          width < 360
              ? 12.0
              : width < 600
              ? 16.0
              : 24.0;

          final maxWidth =
          width >= 1000
              ? 1000.0
              : 720.0;

          return ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              32,
            ),
            children: [
              Center(
                child:
                ConstrainedBox(
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
                      Text(
                        'Your QR Codes',
                        style: theme
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Manage the QR codes connected to your business.',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildDigitalQrCard(
                        context,
                        theme,
                        digitalQr,
                        businessName,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildPhysicalQrCard(
                        context,
                        theme,
                        physicalQrs,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
      String? businessName,
      ) {
    if (qr == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding:
          const EdgeInsets.all(
            20,
          ),
          child: Column(
            children: [
              Icon(
                Icons
                    .qr_code_2_rounded,
                size: 48,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Digital QR not found.',
                style: theme
                    .textTheme
                    .bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            Text(
              'Digital QR',
              style: theme
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Your primary digital menu QR code.',
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ========================================================
            // QR CARD
            // ========================================================

            Center(
              child:
              RepaintBoundary(
                key: _qrCardKey,
                child:
                ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth: 540,
                  ),
                  child:
                  ScanAuraQrCard(
                    qrData:
                    _publicQrUrl(
                      qr.qrCode,
                    ),
                    businessName:
                    businessName,
                    showBusinessName:
                    true,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ========================================================
            // STATUS
            // ========================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .center,
              children: [
                Icon(
                  qr.active
                      ? Icons
                      .check_circle_outline
                      : Icons
                      .cancel_outlined,
                  size: 18,
                  color: qr.active
                      ? Colors.green
                      : theme
                      .colorScheme
                      .error,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  qr.active
                      ? 'Active'
                      : 'Inactive',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w600,
                    color: qr.active
                        ? Colors.green
                        : theme
                        .colorScheme
                        .error,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ========================================================
            // ACTIONS
            // ========================================================

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                if (constraints.maxWidth <
                    500) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child:
                        OutlinedButton
                            .icon(
                          onPressed:
                          _downloadQr,
                          icon:
                          const Icon(
                            Icons
                                .download_rounded,
                          ),
                          label:
                          const Text(
                            'Download QR',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        height: 48,
                        child:
                        FilledButton
                            .icon(
                          onPressed:
                          _shareQr,
                          icon:
                          const Icon(
                            Icons
                                .share_rounded,
                          ),
                          label:
                          const Text(
                            'Share QR',
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child:
                      OutlinedButton
                          .icon(
                        onPressed:
                        _downloadQr,
                        icon:
                        const Icon(
                          Icons
                              .download_rounded,
                        ),
                        label:
                        const Text(
                          'Download QR',
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                      FilledButton
                          .icon(
                        onPressed:
                        _shareQr,
                        icon:
                        const Icon(
                          Icons
                              .share_rounded,
                        ),
                        label:
                        const Text(
                          'Share QR',
                        ),
                      ),
                    ),
                  ],
                );
              },
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
      List<QrResponse>
      physicalQrs,
      ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            Text(
              'Physical QR',
              style: theme
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'QR codes assigned to your business.',
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Assigned',
                      style: theme
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${physicalQrs.length}',
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (physicalQrs.isEmpty)
              _buildNoPhysicalQr(
                context,
                theme,
              )
            else
              ...physicalQrs.map(
                    (qr) =>
                    _buildPhysicalQrItem(
                      context,
                      theme,
                      qr,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalQrItem(
      BuildContext context,
      ThemeData theme,
      QrResponse qr,
      ) {
    return Container(
      width:
      double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration:
      BoxDecoration(
        border: Border.all(
          color: theme
              .colorScheme
              .outlineVariant,
        ),
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
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
            child: Icon(
              Icons
                  .qr_code_2_rounded,
              size: 22,
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
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
                  qr.qrCode,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  qr.active
                      ? 'Active'
                      : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                    color: qr.active
                        ? Colors.green
                        : theme
                        .colorScheme
                        .error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Icon(
            qr.active
                ? Icons
                .check_circle
                : Icons.cancel,
            color: qr.active
                ? Colors.green
                : theme
                .colorScheme
                .error,
            size: 21,
          ),
        ],
      ),
    );
  }

  Widget _buildNoPhysicalQr(
      BuildContext context,
      ThemeData theme,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        20,
      ),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .qr_code_2_rounded,
            size: 40,
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            'No physical QR assigned yet.',
            textAlign:
            TextAlign.center,
            style: theme
                .textTheme
                .bodyMedium,
          ),
        ],
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
      child: SafeArea(
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
                  'Unable to load QR codes',
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
                      'Unable to load QR codes.',
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(
                        qrNotifierProvider
                            .notifier,
                      )
                          .loadQr();
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
    );
  }
}