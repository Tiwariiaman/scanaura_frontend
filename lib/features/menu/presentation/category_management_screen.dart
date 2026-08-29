import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category_request.dart';
import 'providers/menu_notifier.dart';
import 'providers/menu_state.dart';

class CategoryManagementScreen
    extends ConsumerStatefulWidget {
  const CategoryManagementScreen({
    super.key,
  });

  @override
  ConsumerState<CategoryManagementScreen>
  createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<
        CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(
        menuNotifierProvider.notifier,
      )
          .loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton:
      _buildResponsiveFab(context),
      body: _buildBody(
        context,
        state,
      ),
    );
  }

  // ============================================================
  // RESPONSIVE FAB
  // ============================================================

  Widget _buildResponsiveFab(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    if (width < 400) {
      return FloatingActionButton(
        tooltip: 'Add Category',
        onPressed:
        _showCategoryDialog,
        child: const Icon(
          Icons.add,
        ),
      );
    }

    return FloatingActionButton.extended(
      onPressed:
      _showCategoryDialog,
      icon: const Icon(
        Icons.add,
      ),
      label: const Text(
        'Add Category',
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      MenuState state,
      ) {
    if (state.status ==
        MenuStatus.loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (state.categories.isEmpty) {
      return _buildEmptyState(
        context,
      );
    }

    return RefreshIndicator(
      onRefresh: ref
          .read(
        menuNotifierProvider
            .notifier,
      )
          .refreshMenu,
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

          return ListView.separated(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              110,
            ),
            itemCount:
            state.categories.length,
            separatorBuilder:
                (_, _) =>
            const SizedBox(
              height: 10,
            ),
            itemBuilder:
                (context, index) {
              final category =
              state.categories[
              index];

              final itemCount =
                  state.catalogItems
                      .where(
                        (item) =>
                    item.categoryId ==
                        category.id,
                  )
                      .length;

              return _buildCategoryCard(
                context,
                category.name,
                category.id,
                category.displayOrder,
                itemCount,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(
      BuildContext context,
      String categoryName,
      String categoryId,
      int displayOrder,
      int itemCount,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    final compact =
        width < 500;

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        EdgeInsets.all(
          compact ? 10 : 12,
        ),
        child: compact
            ? _buildCompactCategoryCard(
          context,
          categoryName,
          categoryId,
          displayOrder,
          itemCount,
        )
            : _buildWideCategoryCard(
          context,
          categoryName,
          categoryId,
          displayOrder,
          itemCount,
        ),
      ),
    );
  }

  // ============================================================
  // WIDE CARD
  // ============================================================

  Widget _buildWideCategoryCard(
      BuildContext context,
      String categoryName,
      String categoryId,
      int displayOrder,
      int itemCount,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          child: const Icon(
            Icons.category_outlined,
            size: 21,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        _buildActions(
          context,
          categoryId,
          categoryName,
          displayOrder,
        ),
      ],
    );
  }

  // ============================================================
  // COMPACT CARD
  // ============================================================

  Widget _buildCompactCategoryCard(
      BuildContext context,
      String categoryName,
      String categoryId,
      int displayOrder,
      int itemCount,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 21,
          child: const Icon(
            Icons.category_outlined,
            size: 19,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 4,
        ),

        PopupMenuButton<String>(
          tooltip: 'More options',
          onSelected: (value) {
            if (value == 'edit') {
              _showCategoryDialog(
                categoryId:
                categoryId,
                currentName:
                categoryName,
                currentDisplayOrder:
                displayOrder,
              );
            } else if (value ==
                'delete') {
              _confirmDelete(
                categoryId,
                categoryName,
              );
            }
          },
          itemBuilder:
              (context) => const [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons
                        .edit_outlined,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons
                        .delete_outline,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions(
      BuildContext context,
      String categoryId,
      String categoryName,
      int displayOrder,
      ) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () {
            _showCategoryDialog(
              categoryId:
              categoryId,
              currentName:
              categoryName,
              currentDisplayOrder:
              displayOrder,
            );
          },
          icon: const Icon(
            Icons.edit_outlined,
          ),
        ),

        IconButton(
          tooltip: 'Delete',
          onPressed: () {
            _confirmDelete(
              categoryId,
              categoryName,
            );
          },
          icon: const Icon(
            Icons.delete_outline,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    return Center(
      child: SingleChildScrollView(
        padding:
        EdgeInsets.all(
          width < 400 ? 20 : 24,
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
                    .category_outlined,
                size: 56,
                color: Colors
                    .grey
                    .shade500,
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'No categories yet',
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

              const Text(
                'Create your first category to organize your menu.',
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
                  onPressed:
                  _showCategoryDialog,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label:
                  const Text(
                    'Add Category',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ADD / EDIT CATEGORY
  // ============================================================

  Future<void> _showCategoryDialog({
    String? categoryId,
    String? currentName,
    int? currentDisplayOrder,
  }) async {
    final nameController =
    TextEditingController(
      text: currentName ?? '',
    );

    final orderController =
    TextEditingController(
      text:
      (currentDisplayOrder ?? 0)
          .toString(),
    );

    final formKey =
    GlobalKey<FormState>();

    final isEditing =
        categoryId != null;

    final result =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: Text(
            isEditing
                ? 'Edit Category'
                : 'Add Category',
          ),

          content: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 460,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  TextFormField(
                    controller:
                    nameController,
                    autofocus:
                    !isEditing,
                    textCapitalization:
                    TextCapitalization
                        .words,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Category name',
                      hintText:
                      'e.g. Starters',
                      prefixIcon:
                      Icon(
                        Icons
                            .category_outlined,
                      ),
                    ),
                    validator:
                        (value) {
                      if (value ==
                          null ||
                          value
                              .trim()
                              .isEmpty) {
                        return 'Category name is required';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextFormField(
                    controller:
                    orderController,
                    keyboardType:
                    TextInputType
                        .number,
                    textInputAction:
                    TextInputAction
                        .done,
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Display order',
                      hintText:
                      '0',
                      prefixIcon:
                      Icon(
                        Icons
                            .format_list_numbered_rounded,
                      ),
                    ),
                    validator:
                        (value) {
                      final order =
                      int.tryParse(
                        value
                            ?.trim() ??
                            '',
                      );

                      if (order ==
                          null ||
                          order < 0) {
                        return 'Enter a valid order';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
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
              onPressed: () async {
                if (!formKey
                    .currentState!
                    .validate()) {
                  return;
                }

                final name =
                nameController
                    .text
                    .trim();

                final order =
                    int.tryParse(
                      orderController
                          .text
                          .trim(),
                    ) ??
                        0;

                final notifier =
                ref.read(
                  menuNotifierProvider
                      .notifier,
                );

                if (isEditing) {
                  await notifier
                      .updateCategory(
                    categoryId,
                    CategoryRequest(
                      name: name,
                      displayOrder:
                      order,
                    ),
                  );
                } else {
                  await notifier
                      .createCategory(
                    CategoryRequest(
                      name: name,
                      displayOrder:
                      order,
                    ),
                  );
                }

                if (!dialogContext
                    .mounted) {
                  return;
                }

                final state =
                ref.read(
                  menuNotifierProvider,
                );

                if (state.errorMessage !=
                    null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      behavior:
                      SnackBarBehavior
                          .floating,
                      content: Text(
                        state.errorMessage!,
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                isEditing
                    ? 'Save Changes'
                    : 'Create',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    orderController.dispose();

    if (result == true &&
        mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content: Text(
            isEditing
                ? 'Category updated successfully.'
                : 'Category created successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
      String categoryId,
      String categoryName,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Delete Category?',
          ),
          content: Text(
            'Delete "$categoryName"?\n\n'
                'Items in this category will remain '
                'in your catalog without a category.',
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
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final success =
    await ref
        .read(
      menuNotifierProvider
          .notifier,
    )
        .deleteCategory(
      categoryId,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      menuNotifierProvider,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content: Text(
            success
                ? 'Category deleted successfully.'
                : state.errorMessage ??
                'Unable to delete category.',
          ),
        ),
      );
  }
}