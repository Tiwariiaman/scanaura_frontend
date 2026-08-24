import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';


import '../data/models/menu_category_response.dart';
import '../data/models/menu_item_response.dart';

class PublicMenuScreen extends ConsumerStatefulWidget {
  const PublicMenuScreen({
    super.key,
    required this.qrCode,
  });

  final String qrCode;

  @override
  ConsumerState<PublicMenuScreen> createState() =>
      _PublicMenuScreenState();
}

class _PublicMenuScreenState
    extends ConsumerState<PublicMenuScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showBestSellerOnly = false;
  bool _showRecommendedOnly = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final notifier =
      ref.read(publicNotifierProvider.notifier);

      notifier.setQrCode(widget.qrCode);
      notifier.loadMenu();
    });
  }

  List<MenuCategoryResponse> get _categories {
    final menu =
        ref.read(publicNotifierProvider).menu;

    return menu?.menu ?? const [];
  }

  // IMPORTANT:
  // This must be List<_PublicMenuItem>, not List<Object>.
  List<_PublicMenuItem> get _filteredItems {
    final categories = _categories;

    final List<_PublicMenuItem> allItems = [];

    for (final category in categories) {
      for (final item in category.items) {
        allItems.add(
          _PublicMenuItem(
            item: item,
            categoryName: category.categoryName,
          ),
        );
      }
    }

    Iterable<_PublicMenuItem> items =
    allItems.where(
          (entry) => entry.item.available,
    );

    if (_selectedCategory != null) {
      items = items.where(
            (entry) =>
        entry.categoryName ==
            _selectedCategory,
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query =
      _searchQuery.trim().toLowerCase();

      items = items.where(
            (entry) {
          final item = entry.item;

          return item.name
              .toLowerCase()
              .contains(query) ||
              (item.description
                  ?.toLowerCase()
                  .contains(query) ??
                  false);
        },
      );
    }

    if (_showVegOnly) {
      items = items.where(
            (entry) => entry.item.veg,
      );
    }

    if (_showNonVegOnly) {
      items = items.where(
            (entry) => !entry.item.veg,
      );
    }

    if (_showBestSellerOnly) {
      items = items.where(
            (entry) => entry.item.bestSeller,
      );
    }

    if (_showRecommendedOnly) {
      items = items.where(
            (entry) => entry.item.recommended,
      );
    }

    final result = items.toList();

    // Required public ordering:
    // 1. Best Seller
    // 2. Recommended
    // 3. Normal items
    result.sort((a, b) {
      final bestSellerCompare =
      _boolRank(b.item.bestSeller).compareTo(
        _boolRank(a.item.bestSeller),
      );

      if (bestSellerCompare != 0) {
        return bestSellerCompare;
      }

      final recommendedCompare =
      _boolRank(b.item.recommended).compareTo(
        _boolRank(a.item.recommended),
      );

      if (recommendedCompare != 0) {
        return recommendedCompare;
      }

      return 0;
    });

    return result;
  }

  int _boolRank(bool value) {
    return value ? 1 : 0;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _showVegOnly = false;
      _showNonVegOnly = false;
      _showBestSellerOnly = false;
      _showRecommendedOnly = false;
    });
  }

  void _toggleCategory(String? category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(publicNotifierProvider);

    if (state.status ==
        PublicStatus.loading &&
        state.menu == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status ==
        PublicStatus.error &&
        state.menu == null) {
      return _buildError(
        context,
        state,
      );
    }

    final menu = state.menu;

    if (menu == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Menu is unavailable.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          menu.businessName,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(
            publicNotifierProvider.notifier,
          )
              .refreshMenu();
        },
        child: CustomScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration:
                  InputDecoration(
                    hintText:
                    'Search menu...',
                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                    _searchQuery.isEmpty
                        ? null
                        : IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery =
                          '';
                        });
                      },
                      icon:
                      const Icon(
                        Icons.clear,
                      ),
                    ),
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                _buildCategoryFilters(
                  menu.menu,
                ),
              ),
            ),

            SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                0,
              ),
              sliver:
              SliverToBoxAdapter(
                child:
                _buildAttributeFilters(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),

            _buildMenuList(),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 32,
              ),
            ),

            SliverToBoxAdapter(
              child: _buildFooter(),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
      List<MenuCategoryResponse> categories,
      ) {
    final categoryNames = categories
        .where(
          (category) =>
      category.categoryName
          ?.trim()
          .isNotEmpty ==
          true,
    )
        .map(
          (category) =>
          category.categoryName!.trim(),
    )
        .toList();

    return ScrollConfiguration(
      behavior: const _PublicMenuScrollBehavior(),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: categoryNames.length + 1,
          separatorBuilder: (_, index) =>
          const SizedBox(width: 8),
          itemBuilder: (context, index) {
            // ALL
            if (index == 0) {
              return FilterChip(
                label: const Text('All'),
                selected:
                _selectedCategory == null,
                onSelected: (_) {
                  _toggleCategory(null);
                },
              );
            }

            final category =
            categoryNames[index - 1];

            return FilterChip(
              label: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected:
              _selectedCategory == category,
              onSelected: (_) {
                _toggleCategory(category);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttributeFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('Veg'),
          selected: _showVegOnly,
          onSelected: (_) {
            setState(() {
              _showVegOnly =
              !_showVegOnly;

              if (_showVegOnly) {
                _showNonVegOnly = false;
              }
            });
          },
        ),

        FilterChip(
          label: const Text('Non-Veg'),
          selected: _showNonVegOnly,
          onSelected: (_) {
            setState(() {
              _showNonVegOnly =
              !_showNonVegOnly;

              if (_showNonVegOnly) {
                _showVegOnly = false;
              }
            });
          },
        ),

        FilterChip(
          avatar: const Icon(
            Icons.star_outline,
            size: 18,
          ),
          label:
          const Text('Best Seller'),
          selected:
          _showBestSellerOnly,
          onSelected: (_) {
            setState(() {
              _showBestSellerOnly =
              !_showBestSellerOnly;
            });
          },
        ),

        FilterChip(
          avatar: const Icon(
            Icons.thumb_up_alt_outlined,
            size: 18,
          ),
          label:
          const Text('Recommended'),
          selected:
          _showRecommendedOnly,
          onSelected: (_) {
            setState(() {
              _showRecommendedOnly =
              !_showRecommendedOnly;
            });
          },
        ),

        if (_selectedCategory !=
            null ||
            _showVegOnly ||
            _showNonVegOnly ||
            _showBestSellerOnly ||
            _showRecommendedOnly)
          ActionChip(
            label: const Text('Clear'),
            onPressed:
            _clearAllFilters,
          ),
      ],
    );
  }

  Widget _buildMenuList() {
    final List<_PublicMenuItem> items =
        _filteredItems;

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding:
          EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .restaurant_menu_outlined,
                  size: 48,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'No menu items found.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      sliver: SliverList(
        delegate:
        SliverChildBuilderDelegate(
              (context, index) {
            final _PublicMenuItem entry =
            items[index];

            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 12,
              ),
              child: _buildMenuItemCard(
                context,
                entry.item,
              ),
            );
          },
          childCount:
          items.length,
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
      BuildContext context,
      MenuItemResponse item,
      ) {
    final hasImage =
        item.imageUrl != null &&
            item.imageUrl!.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, _, _) {
                    return const SizedBox.shrink();
                  },
                ),
              ),

              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),

                      _VegIndicator(
                        veg: item.veg,
                      ),
                    ],
                  ),

                  if (item.description
                      ?.trim()
                      .isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 5),

                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  if (item.bestSeller ||
                      item.recommended) ...[
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (item.bestSeller)
                          const _Tag(
                            label: 'Best Seller',
                            icon: Icons.star,
                          ),

                        if (item.recommended)
                          const _Tag(
                            label: 'Recommended',
                            icon:
                            Icons.thumb_up_alt_outlined,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight:
            FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text(
            'Register your business',
          ),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                state.errorMessage ??
                    'Unable to load menu.',
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton(
                onPressed: () {
                  ref
                      .read(
                    publicNotifierProvider
                        .notifier,
                  )
                      .loadMenu();
                },
                child: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicMenuItem {
  const _PublicMenuItem({
    required this.item,
    required this.categoryName,
  });

  final MenuItemResponse item;
  final String? categoryName;
}

class _VegIndicator
    extends StatelessWidget {
  const _VegIndicator({
    required this.veg,
  });

  final bool veg;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(
          color:
          veg ? Colors.green : Colors.red,
          width: 1.5,
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration:
          BoxDecoration(
            color: veg
                ? Colors.green
                : Colors.red,
            shape:
            BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            label,
            style:
            const TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
class _PublicMenuScrollBehavior
    extends MaterialScrollBehavior {
  const _PublicMenuScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
