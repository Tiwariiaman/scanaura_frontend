import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/ai_category.dart';
import '../data/models/ai_menu_response.dart';
import 'providers/ai_import_notifier.dart';
import 'providers/ai_import_state.dart';

class AiImportReviewScreen extends ConsumerWidget {
  const AiImportReviewScreen({
    super.key,
    required this.menuResponse,
  });

  final AiMenuResponse menuResponse;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final state = ref.watch(
      aiImportNotifierProvider,
    );

    final totalItems = menuResponse.categories.fold<int>(
      0,
          (total, category) =>
      total + category.items.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review AI Menu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(
                  context,
                  totalItems,
                ),

                const SizedBox(height: 16),

                ...menuResponse.categories.map(
                      (category) => _buildCategoryCard(
                    context,
                    category,
                  ),
                ),

                const SizedBox(height: 12),

                _buildOverwriteCard(
                  context,
                  state,
                  ref,
                ),
              ],
            ),
          ),

          _buildImportButton(
            context,
            ref,
            state,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      int totalItems,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 32,
              color:
              Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI detected your menu',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${menuResponse.categories.length} categories • '
                        '$totalItems items',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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

  Widget _buildCategoryCard(
      BuildContext context,
      AiCategory category,
      ) {
    final categoryName =
    category.categoryName
        ?.trim()
        .isNotEmpty ==
        true
        ? category.categoryName!.trim()
        : 'Uncategorized';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  '${category.items.length} '
                      '${category.items.length == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Divider(),

            ...category.items.map(
                  (item) {
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 9,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _VegIndicator(
                        veg: item.veg,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),

                            if (item.description !=
                                null &&
                                item.description!
                                    .trim()
                                    .isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets
                                    .only(
                                  top: 3,
                                ),
                                child: Text(
                                  item.description!,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        item.price != null
                            ? '₹${item.price!.toStringAsFixed(2)}'
                            : 'Price missing',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          color: item.price != null
                              ? null
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverwriteCard(
      BuildContext context,
      AiImportState state,
      WidgetRef ref,
      ) {
    return Card(
      child: SwitchListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        title: const Text(
          'Replace existing menu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          state.overwriteExistingMenu
              ? 'Your current menu and categories '
              'will be deleted before importing.'
              : 'AI items will be added to your '
              'existing menu.',
        ),
        value: state.overwriteExistingMenu,
        onChanged: ref
            .read(
          aiImportNotifierProvider.notifier,
        )
            .setOverwriteExistingMenu,
      ),
    );
  }

  Widget _buildImportButton(
      BuildContext context,
      WidgetRef ref,
      AiImportState state,
      ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed:
            state.isImporting
                ? null
                : () => _handleImport(
              context,
              ref,
            ),
            icon: state.isImporting
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.download_done,
            ),
            label: Text(
              state.isImporting
                  ? 'Importing...'
                  : 'Import Menu',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleImport(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final notifier =
    ref.read(
      aiImportNotifierProvider.notifier,
    );

    final state =
    ref.read(aiImportNotifierProvider);

    if (state.overwriteExistingMenu) {
      final confirmed =
      await _showOverwriteConfirmation(
        context,
      );

      if (!confirmed) {
        return;
      }
    }

    final success =
    await notifier.importMenu();

    if (!context.mounted) {
      return;
    }

    if (!success) {
      final errorState =
      ref.read(
        aiImportNotifierProvider,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            errorState.errorMessage ??
                'Unable to import menu.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Menu imported successfully.',
        ),
      ),
    );

    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  Future<bool> _showOverwriteConfirmation(
      BuildContext context,
      ) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Replace Existing Menu?',
          ),
          content: const Text(
            'This will permanently delete your '
                'current menu items and categories '
                'before importing the AI menu.\n\n'
                'This action cannot be undone.',
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
                'Replace Menu',
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }
}

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({
    required this.veg,
  });

  final bool? veg;

  @override
  Widget build(BuildContext context) {
    final isVeg = veg == true;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.5,
          color:
          isVeg
              ? Colors.green
              : Colors.red,
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
            isVeg
                ? Colors.green
                : Colors.red,
          ),
        ),
      ),
    );
  }
}