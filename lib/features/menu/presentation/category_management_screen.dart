import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category_request.dart';
import 'providers/menu_notifier.dart';
import 'providers/menu_state.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(menuNotifierProvider.notifier)
          .loadMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),

      body: _buildBody(state),
    );
  }

  Widget _buildBody(MenuState state) {
    if (state.status == MenuStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category_outlined,
                size: 56,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 16),
              const Text(
                'No categories yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your first category to organize your menu.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _showCategoryDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ref
          .read(menuNotifierProvider.notifier)
          .refreshMenu,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = state.categories[index];

          final itemCount = state.catalogItems
              .where(
                (item) => item.categoryId == category.id,
          )
              .length;

          return Card(
            elevation: 0,
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  Icons.category_outlined,
                  size: 20,
                ),
              ),

              title: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () {
                      _showCategoryDialog(
                        categoryId: category.id,
                        currentName: category.name,
                        currentDisplayOrder:
                        category.displayOrder,
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
                        category.id,
                        category.name,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showCategoryDialog({
    String? categoryId,
    String? currentName,
    int? currentDisplayOrder,
  }) async {
    final nameController = TextEditingController(
      text: currentName ?? '',
    );

    final orderController = TextEditingController(
      text: (currentDisplayOrder ?? 0).toString(),
    );

    final formKey = GlobalKey<FormState>();

    final isEditing = categoryId != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEditing
                ? 'Edit Category'
                : 'Add Category',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    hintText: 'e.g. Starters',
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Category name is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Display order',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final name =
                nameController.text.trim();

                final order =
                    int.tryParse(
                      orderController.text.trim(),
                    ) ??
                        0;

                final notifier = ref.read(
                  menuNotifierProvider.notifier,
                );

                if (isEditing) {
                  await notifier.updateCategory(
                    categoryId,
                    CategoryRequest(
                      name: name,
                      displayOrder: order,
                    ),
                  );
                } else {
                  await notifier.createCategory(
                    CategoryRequest(
                      name: name,
                      displayOrder: order,
                    ),
                  );
                }

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
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
  }

  Future<void> _confirmDelete(
      String categoryId,
      String categoryName,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Category?',
          ),
          content: Text(
            'Delete "$categoryName"?\n\n'
                'Menu items in this category will remain '
                'in your menu without a category.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success = await ref
        .read(menuNotifierProvider.notifier)
        .deleteCategory(categoryId);

    if (!mounted) {
      return;
    }

    final state = ref.read(menuNotifierProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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