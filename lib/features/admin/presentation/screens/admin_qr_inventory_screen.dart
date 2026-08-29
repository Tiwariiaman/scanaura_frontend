import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_qr_pack_downloader.dart';
import '../../services/admin_qr_pack_service.dart';
import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';

class AdminQrInventoryScreen
    extends ConsumerStatefulWidget {
  const AdminQrInventoryScreen({
    super.key,
  });

  @override
  ConsumerState<AdminQrInventoryScreen>
  createState() =>
      _AdminQrInventoryScreenState();
}

class _AdminQrInventoryScreenState
    extends ConsumerState<
        AdminQrInventoryScreen> {
  final TextEditingController
  _countController =
  TextEditingController(
    text: '10',
  );

  bool _isGenerating = false;
  bool _isDownloadingPack = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        adminNotifierProvider
            .notifier,
      )
          .loadQrInventory();
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  // ============================================================
  // DOWNLOAD QR PACK
  // ============================================================

  Future<void> _downloadQrPack() async {
    if (_isDownloadingPack) {
      return;
    }

    final state =
    ref.read(
      adminNotifierProvider,
    );

    final qrCodes =
        state.generatedPhysicalQrs;

    if (qrCodes.isEmpty) {
      _showMessage(
        'Generate physical QR codes first.',
      );
      return;
    }

    setState(() {
      _isDownloadingPack = true;
    });

    try {
      _showMessage(
        'Preparing ${qrCodes.length} QR cards...',
      );

      final zipBytes =
      await AdminQrPackService
          .generateZip(
        context: context,
        qrCodes: qrCodes,
      );

      await downloadQrPack(
        zipBytes,
        'scanaura_physical_qr_pack.zip',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        '${qrCodes.length} QR cards downloaded successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to create QR pack: ${_cleanError(e)}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingPack = false;
        });
      }
    }
  }

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

  // ============================================================
  // GENERATE QR
  // ============================================================

  Future<void> _generateQr() async {
    if (_isGenerating) {
      return;
    }

    final count =
    int.tryParse(
      _countController.text.trim(),
    );

    if (count == null ||
        count <= 0) {
      _showMessage(
        'Enter a valid QR quantity.',
      );
      return;
    }

    final confirmed =
    await _showGenerateConfirmation(
      count,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final success =
      await ref
          .read(
        adminNotifierProvider
            .notifier,
      )
          .generatePhysicalQr(
        count,
      );

      if (!mounted) {
        return;
      }

      final state =
      ref.read(
        adminNotifierProvider,
      );

      _showMessage(
        success
            ? '$count physical QR codes generated successfully.'
            : state.errorMessage ??
            'Unable to generate QR codes.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<bool>
  _showGenerateConfirmation(
      int count,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Generate Physical QR Codes?',
          ),
          content: Text(
            'Generate $count physical QR '
                '${count == 1 ? 'code' : 'codes'}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text('Generate'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  void _showMessage(
      String message,
      ) {
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
      adminNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Inventory',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
            'Scan QR to Assign',
            onPressed: () async {
              await context.push(
                '/admin/qr/scan',
              );
            },
            icon: const Icon(
              Icons
                  .qr_code_scanner_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading
                ? null
                : () {
              ref
                  .read(
                adminNotifierProvider
                    .notifier,
              )
                  .loadQrInventory();
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            adminNotifierProvider
                .notifier,
          )
              .loadQrInventory();
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
                : 20.0;

            final maxWidth =
            width >= 1400
                ? 1200.0
                : 1100.0;

            return SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Center(
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
                      _buildHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      if (state.qrInventory !=
                          null)
                        _buildInventoryCards(
                          context,
                          state,
                        ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildGenerateCard(
                        context,
                      ),

                      if (state
                          .generatedPhysicalQrs
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 20,
                        ),
                        _buildGeneratedQrResult(
                          context,
                          state,
                        ),
                      ],

                      if (state.errorMessage !=
                          null) ...[
                        const SizedBox(
                          height: 16,
                        ),
                        _buildErrorMessage(
                          context,
                          state.errorMessage!,
                        ),
                      ],
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
  // HEADER
  // ============================================================

  Widget _buildHeader(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        Text(
          'QR Inventory',
          style: theme
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          'Manage ScanAura physical and digital QR inventory.',
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
          height: 14,
        ),

        // Mobile/tablet action area.
        LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final compact =
                constraints.maxWidth <
                    520;

            if (compact) {
              return SizedBox(
                width:
                double.infinity,
                child:
                FilledButton.icon(
                  onPressed: () async {
                    await context.push(
                      '/admin/qr/scan',
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .qr_code_scanner_rounded,
                  ),
                  label:
                  const Text(
                    'Scan QR to Assign',
                  ),
                ),
              );
            }

            return Align(
              alignment:
              Alignment.centerLeft,
              child:
              FilledButton.icon(
                onPressed: () async {
                  await context.push(
                    '/admin/qr/scan',
                  );
                },
                icon:
                const Icon(
                  Icons
                      .qr_code_scanner_rounded,
                ),
                label:
                const Text(
                  'Scan QR to Assign',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // GENERATED QR RESULT
  // ============================================================

  Widget _buildGeneratedQrResult(
      BuildContext context,
      AdminState state,
      ) {
    final qrs =
        state.generatedPhysicalQrs;

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
            Text(
              '${qrs.length} QR codes generated',
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'These QR codes are available for printing and assignment.',
              style: TextStyle(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              constraints:
              const BoxConstraints(
                maxHeight: 300,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount:
                qrs.length,
                separatorBuilder:
                    (_, _) =>
                const Divider(),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final qr =
                  qrs[index];

                  return ListTile(
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 4,
                    ),
                    leading:
                    const Icon(
                      Icons
                          .qr_code_2_rounded,
                    ),
                    title: Text(
                      qr.qrCode,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),
                    subtitle:
                    const Text(
                      'Physical • Available',
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width:
              double.infinity,
              height: 50,
              child:
              FilledButton.icon(
                onPressed:
                _isDownloadingPack
                    ? null
                    : _downloadQrPack,
                icon:
                _isDownloadingPack
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : const Icon(
                  Icons
                      .download_rounded,
                ),
                label:
                Text(
                  _isDownloadingPack
                      ? 'Preparing QR Pack...'
                      : 'Download QR Pack',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INVENTORY CARDS
  // ============================================================

  Widget _buildInventoryCards(
      BuildContext context,
      AdminState state,
      ) {
    final inventory =
    state.qrInventory!;

    final stats = [
      _QrStat(
        title:
        'Available Physical',
        value:
        '${inventory.availablePhysicalQr}',
        icon:
        Icons.inventory_2_outlined,
      ),
      _QrStat(
        title:
        'Assigned Physical',
        value:
        '${inventory.assignedPhysicalQr}',
        icon:
        Icons.assignment_outlined,
      ),
      _QrStat(
        title: 'Digital QR',
        value:
        '${inventory.digitalQr}',
        icon:
        Icons.qr_code_outlined,
      ),
      _QrStat(
        title: 'Total QR',
        value:
        '${inventory.totalQr}',
        icon:
        Icons.qr_code_2_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        final columns =
        width >= 1000
            ? 4
            : width >= 600
            ? 2
            : 1;

        final compact =
            width < 400;

        final aspectRatio =
        columns == 1
            ? 3.45
            : columns == 2
            ? 2.20
            : 1.85;

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount:
          stats.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
            aspectRatio,
          ),
          itemBuilder:
              (context, index) {
            return _QrStatCard(
              stat:
              stats[index],
              compact:
              compact,
            );
          },
        );
      },
    );
  }

  // ============================================================
  // GENERATE CARD
  // ============================================================

  Widget _buildGenerateCard(
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
            Row(
              children: [
                Icon(
                  Icons
                      .add_box_outlined,
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    'Generate Physical QR',
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Generate QR codes to add to your physical inventory.',
              style: TextStyle(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            LayoutBuilder(
              builder: (
                  context,
                  constraints,
                  ) {
                if (constraints
                    .maxWidth <
                    520) {
                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      _buildCountField(),
                      const SizedBox(
                        height: 12,
                      ),
                      _buildGenerateButton(),
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child:
                      _buildCountField(),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    _buildGenerateButton(),
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
  // COUNT FIELD
  // ============================================================

  Widget _buildCountField() {
    return TextField(
      controller:
      _countController,
      keyboardType:
      TextInputType.number,
      textInputAction:
      TextInputAction.done,
      decoration:
      InputDecoration(
        labelText: 'Quantity',
        hintText: '10',
        prefixIcon:
        const Icon(
          Icons.numbers_rounded,
        ),
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // GENERATE BUTTON
  // ============================================================

  Widget _buildGenerateButton() {
    return FilledButton.icon(
      onPressed:
      _isGenerating
          ? null
          : _generateQr,
      icon: _isGenerating
          ? const SizedBox(
        width: 18,
        height: 18,
        child:
        CircularProgressIndicator(
          strokeWidth: 2,
        ),
      )
          : const Icon(
        Icons
            .qr_code_2,
      ),
      label: Padding(
        padding:
        const EdgeInsets
            .symmetric(
          vertical: 12,
        ),
        child: Text(
          _isGenerating
              ? 'Generating...'
              : 'Generate QR',
        ),
      ),
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  Widget _buildErrorMessage(
      BuildContext context,
      String message,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .errorContainer,
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
          Icon(
            Icons
                .error_outline,
            color: theme
                .colorScheme
                .onErrorContainer,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              message,
              softWrap: true,
              style: TextStyle(
                color: theme
                    .colorScheme
                    .onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// QR STAT
// ================================================================

class _QrStat {
  const _QrStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}

// ================================================================
// QR STAT CARD
// ================================================================

class _QrStatCard
    extends StatelessWidget {
  const _QrStatCard({
    required this.stat,
    required this.compact,
  });

  final _QrStat stat;
  final bool compact;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: Padding(
        padding:
        EdgeInsets.all(
          compact ? 12 : 16,
        ),
        child: Row(
          children: [
            Container(
              width:
              compact ? 42 : 46,
              height:
              compact ? 42 : 46,
              alignment:
              Alignment.center,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                BorderRadius.circular(
                  compact ? 10 : 12,
                ),
              ),
              child: Icon(
                stat.icon,
                size:
                compact ? 20 : 22,
                color: theme
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            SizedBox(
              width:
              compact ? 10 : 12,
            ),

            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    stat.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      fontSize:
                      compact
                          ? 12
                          : 13,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    stat.value,
                    maxLines: 1,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      fontSize:
                      compact
                          ? 21
                          : 22,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}