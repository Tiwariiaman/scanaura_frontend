import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/menu/data/models/catalog_response.dart';

import '../../business/presentation/providers/business_notifier.dart';
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
    final state =
    ref.watch(menuNotifierProvider);

    final notifier =
    ref.read(
      menuNotifierProvider.notifier,
    );

    final businessState =
    ref.watch(businessNotifierProvider);

    final showVegIndicator =
        businessState.business?.businessType
            .toString()
            .split('.')
            .last
            .toUpperCase() ==
            'FOOD';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catalog',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Manage Categories',
            onPressed: () {
              context.push(
                '/menu/categories',
              );
            },
            icon: const Icon(
              Icons.category_outlined,
            ),
          ),

          IconButton(
            tooltip: 'AI Import',
            onPressed: () {
              context.push(
                '/ai-import',
              );
            },
            icon: const Icon(
              Icons.auto_awesome,
            ),
          ),

          IconButton(
            tooltip: 'Add Item',
            onPressed: () {
              context.push(
                '/menu/add',
              );
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: _buildBody(
        context,
        state,
        notifier,
        showVegIndicator,
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      BuildContext context,
      MenuState state,
      MenuNotifier notifier,
      bool showVegIndicator,
      ) {
    if (state.status ==
        MenuStatus.loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (state.status ==
        MenuStatus.error) {
      return _buildError(
        context,
        state,
        notifier,
      );
    }

    return RefreshIndicator(
      onRefresh:
      notifier.refreshMenu,
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

          return CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ========================================================
              // SEARCH
              // ========================================================

              SliverPadding(
                padding:
                EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  0,
                ),
                sliver:
                SliverToBoxAdapter(
                  child: Center(
                    child:
                    ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 1000,
                      ),
                      child:
                      MenuSearchBar(
                        value:
                        state.searchQuery,
                        onChanged:
                        notifier
                            .setSearchQuery,
                      ),
                    ),
                  ),
                ),
              ),

              // ========================================================
              // FILTERS
              // ========================================================

              SliverPadding(
                padding:
                EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  0,
                ),
                sliver:
                SliverToBoxAdapter(
                  child: Center(
                    child:
                    ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 1000,
                      ),
                      child:
                      MenuFilterChips(
                        state: state,
                        categories:
                        state.categories,
                        onAllSelected:
                        notifier
                            .clearCategory,
                        onCategorySelected:
                        notifier
                            .selectCategory,
                        onBestSellerSelected:
                        notifier
                            .toggleBestSellerFilter,
                        onRecommendedSelected:
                        notifier
                            .toggleRecommendedFilter,
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child:
                SizedBox(height: 20),
              ),

              // ========================================================
              // CATALOG ITEMS
              // ========================================================

              _buildCatalogList(
                context,
                state,
                horizontalPadding,
                showVegIndicator,
              ),

              const SliverPadding(
                padding:
                EdgeInsets.only(
                  bottom: 110,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // CATALOG LIST
  // ============================================================

  Widget _buildCatalogList(
      BuildContext context,
      MenuState state,
      double horizontalPadding,
      bool showVegIndicator,
      ) {
    final items = ref
        .read(
      menuNotifierProvider
          .notifier,
    )
        .filteredItems;

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 1000,
            ),
            child:
            MenuEmptyState(
              searchQuery:
              state.searchQuery,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding:
      EdgeInsets.symmetric(
        horizontal:
        horizontalPadding,
      ),
      sliver:
      SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 1000,
            ),
            child:
            ListView.separated(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount:
              items.length,
              separatorBuilder:
                  (_, _) =>
              const SizedBox(
                height: 12,
              ),
              itemBuilder:
                  (context, index) {
                final item =
                items[index];

                return MenuItemCard(
                  item: item,
                  showVegIndicator: showVegIndicator,
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
                  onAvailabilityChanged: (available) {
                    _changeAvailability(
                      item,
                      available,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      MenuState state,
      MenuNotifier notifier,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final width =
            constraints.maxWidth;

        return Center(
          child:
          SingleChildScrollView(
            padding:
            EdgeInsets.all(
              width < 400
                  ? 20
                  : 24,
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
                    size: 48,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .error,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    state.errorMessage ??
                        'Unable to load catalog.',
                    textAlign:
                    TextAlign.center,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    FilledButton.icon(
                      onPressed:
                      notifier.loadMenu,
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
        );
      },
    );
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Future<void>
  _changeAvailability(
      CatalogResponse item,
      bool available,
      ) async {
    final success =
    await ref
        .read(
      menuNotifierProvider
          .notifier,
    )
        .updateAvailability(
      item,
      available,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      menuNotifierProvider,
    );

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior:
            SnackBarBehavior
                .floating,
            content: Text(
              state.errorMessage ??
                  'Unable to update availability.',
            ),
          ),
        );

      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          content: Text(
            available
                ? '${item.name} is now available.'
                : '${item.name} is now unavailable.',
          ),
        ),
      );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
      BuildContext context,
      CatalogResponse item,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (
          dialogContext,
          ) {
        return AlertDialog(
          title: const Text(
            'Delete Item?',
          ),
          content: Text(
            'This will permanently delete "${item.name}".',
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
        .deleteCatalog(
      item.id,
    );

    if (!context.mounted) {
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
                ? 'Item deleted successfully.'
                : state.errorMessage ??
                'Unable to delete item.',
          ),
        ),
      );
  }
}