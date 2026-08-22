import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_notifier.dart';
import '../providers/admin_state.dart';

class AdminQrInventoryScreen
    extends ConsumerStatefulWidget {
  const AdminQrInventoryScreen({
    super.key,
  });

  @override
  ConsumerState<AdminQrInventoryScreen> createState() =>
      _AdminQrInventoryScreenState();
}

class _AdminQrInventoryScreenState
    extends ConsumerState<AdminQrInventoryScreen> {
  final TextEditingController _countController =
  TextEditingController(
    text: '10',
  );

  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(adminNotifierProvider.notifier)
          .loadQrInventory();
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _generateQr() async {
    if (_isGenerating) {
      return;
    }

    final count =
    int.tryParse(
      _countController.text.trim(),
    );

    if (count == null || count <= 0) {
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
      final success = await ref
          .read(
        adminNotifierProvider.notifier,
      )
          .generatePhysicalQr(count);

      if (!mounted) {
        return;
      }

      final state =
      ref.read(adminNotifierProvider);

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

  Future<bool> _showGenerateConfirmation(
      int count,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Generate',
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(adminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Inventory',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
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
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  if (state.qrInventory != null)
                    _buildInventoryCards(
                      context,
                      state,
                    ),

                  const SizedBox(height: 20),

                  _buildGenerateCard(
                    context,
                  ),

                  if (state.errorMessage !=
                      null) ...[
                    const SizedBox(
                      height: 16,
                    ),
                    _buildErrorMessage(
                      state.errorMessage!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
        const SizedBox(height: 6),
        Text(
          'Manage ScanAura physical and digital QR inventory.',
          style: theme
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCards(
      BuildContext context,
      AdminState state,
      ) {
    final inventory =
    state.qrInventory!;

    final stats = [
      _QrStat(
        title: 'Available Physical',
        value:
        '${inventory.availablePhysicalQr}',
        icon: Icons.inventory_2_outlined,
      ),
      _QrStat(
        title: 'Assigned Physical',
        value:
        '${inventory.assignedPhysicalQr}',
        icon:
        Icons.assignment_outlined,
      ),
      _QrStat(
        title: 'Digital QR',
        value:
        '${inventory.digitalQr}',
        icon: Icons.qr_code_outlined,
      ),
      _QrStat(
        title: 'Total QR',
        value:
        '${inventory.totalQr}',
        icon: Icons.qr_code_2_outlined,
      ),
    ];

    return LayoutBuilder(
      builder:
          (context, constraints) {
        final columns =
        constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
            columns == 1
                ? 3.2
                : 1.8,
          ),
          itemBuilder:
              (context, index) {
            return _QrStatCard(
              stat: stats[index],
            );
          },
        );
      },
    );
  }

  Widget _buildGenerateCard(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.add_box_outlined,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Generate Physical QR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Generate QR codes to add to your physical inventory.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 18),

            LayoutBuilder(
              builder:
                  (context, constraints) {
                if (constraints.maxWidth <
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

  Widget _buildCountField() {
    return TextField(
      controller: _countController,
      keyboardType:
      TextInputType.number,
      decoration:
      InputDecoration(
        labelText: 'Quantity',
        hintText: '10',
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
        Icons.qr_code_2,
      ),
      label: Padding(
        padding:
        const EdgeInsets.symmetric(
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

  Widget _buildErrorMessage(
      String message,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context)
                .colorScheme
                .onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context)
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

class _QrStatCard
    extends StatelessWidget {
  const _QrStatCard({
    required this.stat,
  });

  final _QrStat stat;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
              BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                stat.icon,
                color: theme
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.title,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
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
                    style:
                    const TextStyle(
                      fontSize: 22,
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