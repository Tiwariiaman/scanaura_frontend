import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/menu/data/models/catalog_response.dart';

import '../widgets/menu_empty_state.dart';
import '../widgets/menu_filter_chips.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_search_bar.dart';
import 'providers/menu_notifier.dart';
import 'providers/menu_state.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() =>
      _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
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

    final notifier =
    ref.read(menuNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Manage Categories',
            onPressed: () {
              context.push('/menu/categories');
            },
            icon: const Icon(
              Icons.category_outlined,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'AI Menu Import',
            onPressed: () {
              context.push('/ai-import');
            },
            icon: const Icon(
              Icons.auto_awesome,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          context.push('/menu/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: _buildBody(
        context,
        state,
        notifier,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      MenuState state,
      MenuNotifier notifier,
      ) {
    if (state.status == MenuStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == MenuStatus.error) {
      return _buildError(
        context,
        state,
        notifier,
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refreshMenu,
      child: CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: MenuSearchBar(
                value: state.searchQuery,
                onChanged:
                notifier.setSearchQuery,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: MenuFilterChips(
                state: state,
                categories: state.categories,
                onAllSelected:
                notifier.clearCategory,
                onCategorySelected:
                notifier.selectCategory,
                onVegSelected:
                notifier.toggleVegFilter,
                onNonVegSelected:
                notifier.toggleNonVegFilter,
                onBestSellerSelected:
                notifier
                    .toggleBestSellerFilter,
                onRecommendedSelected:
                notifier
                    .toggleRecommendedFilter,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),

          _buildMenuList(
            context,
            state,
          ),

          const SliverPadding(
            padding: EdgeInsets.only(
              bottom: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(
      BuildContext context,
      MenuState state,
      ) {
    final items = ref
        .read(menuNotifierProvider.notifier)
        .filteredItems;

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: MenuEmptyState(
          searchQuery: state.searchQuery,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = items[index];

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: MenuItemCard(
                item: item,
                onEdit: () {
                  context.push(
                    '/menu/edit/${item.id}',
                  );
                },
                onDelete: () {
                  _confirmDelete(
                    context,
                    item,
                  );
                },
                onAvailabilityChanged:
                    (available) {
                  _changeAvailability(
                    item,
                    available,
                  );
                },
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      MenuState state,
      MenuNotifier notifier,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ??
                  'Unable to load menu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: notifier.loadMenu,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeAvailability(
      CatalogResponse item,
      bool available,
      ) async {
    final success = await ref
        .read(menuNotifierProvider.notifier)
        .updateAvailability(
      item,
      available,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(menuNotifierProvider);

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ??
                'Unable to update availability.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          available
              ? '${item.name} is now available.'
              : '${item.name} is now unavailable.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      CatalogResponse item,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Menu Item?',
          ),
          content: Text(
            'This will permanently delete "${item.name}".',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
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
        .deleteCatalog(item.id);

    if (!mounted) {
      return;
    }

    final state =
    ref.read(menuNotifierProvider);

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Menu item deleted successfully.'
              : state.errorMessage ??
              'Unable to delete menu item.',
        ),
      ),
    );
  }
}