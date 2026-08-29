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

    Future.microtask(() async {
      final notifier =
      ref.read(publicNotifierProvider.notifier);

      notifier.setQrCode(widget.qrCode);

      // Load business type as well as catalog data.
      await notifier.loadLanding(widget.qrCode);
      await notifier.loadMenu();
    });
  }

  List<MenuCategoryResponse> get _categories {
    final menu = ref.read(publicNotifierProvider).menu;
    return menu?.menu ?? const [];
  }

  String get _businessType {
    final landing = ref.read(publicNotifierProvider).landing;
    return landing?.businessType.trim().toUpperCase() ?? 'OTHER';
  }

  bool get _isFoodBusiness => _businessType == 'FOOD';

  _PublicTerminology get _terminology =>
      _terminologyFor(_businessType);

  List<_PublicMenuItem> get _filteredItems {
    final allItems = <_PublicMenuItem>[];

    for (final category in _categories) {
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
    allItems.where((entry) => entry.item.available);

    if (_selectedCategory != null) {
      items = items.where(
            (entry) => entry.categoryName == _selectedCategory,
      );
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((entry) {
        final item = entry.item;
        return item.name.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false);
      });
    }

    if (_isFoodBusiness && _showVegOnly) {
      items = items.where((entry) => entry.item.veg);
    }

    if (_isFoodBusiness && _showNonVegOnly) {
      items = items.where((entry) => !entry.item.veg);
    }

    if (_showBestSellerOnly) {
      items = items.where((entry) => entry.item.bestSeller);
    }

    if (_showRecommendedOnly) {
      items = items.where((entry) => entry.item.recommended);
    }

    final result = items.toList();

    result.sort((a, b) {
      final bestSellerCompare =
      _boolRank(b.item.bestSeller).compareTo(
        _boolRank(a.item.bestSeller),
      );
      if (bestSellerCompare != 0) return bestSellerCompare;

      final recommendedCompare =
      _boolRank(b.item.recommended).compareTo(
        _boolRank(a.item.recommended),
      );
      if (recommendedCompare != 0) return recommendedCompare;

      return 0;
    });

    return result;
  }

  int _boolRank(bool value) => value ? 1 : 0;

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
      _selectedCategory =
      _selectedCategory == category ? null : category;
    });
  }

  void _toggleVeg() {
    if (!_isFoodBusiness) return;
    setState(() {
      _showVegOnly = !_showVegOnly;
      if (_showVegOnly) _showNonVegOnly = false;
    });
  }

  void _toggleNonVeg() {
    if (!_isFoodBusiness) return;
    setState(() {
      _showNonVegOnly = !_showNonVegOnly;
      if (_showNonVegOnly) _showVegOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicNotifierProvider);
    final terminology = _terminology;

    if (state.status == PublicStatus.loading && state.menu == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == PublicStatus.error && state.menu == null) {
      return _buildError(context, state);
    }

    final menu = state.menu;

    if (menu == null) {
      return const Scaffold(
        body: Center(child: Text('Content is unavailable.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          terminology.collectionTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding =
          width < 360 ? 12.0 : width < 600 ? 16.0 : 20.0;
          final maxContentWidth = width >= 1000 ? 1000.0 : 700.0;

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(publicNotifierProvider.notifier)
                  .refreshMenu();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ======================================================
                // SCROLLABLE SEARCH + FILTER AREA
                // These controls are part of the same scroll view as
                // the menu, so they naturally move off-screen.
                // ======================================================
                SliverToBoxAdapter(
                  child: Material(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        10,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              _buildSearchField(
                                context,
                                terminology,
                              ),
                              const SizedBox(height: 10),
                              _buildCategoryFilters(menu.menu),
                              const SizedBox(height: 8),
                              _buildAttributeFilters(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),

                _buildMenuList(
                  context,
                  horizontalPadding,
                  maxContentWidth,
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),

                SliverToBoxAdapter(
                  child: _buildFooter(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(
      BuildContext context,
      _PublicTerminology terminology,
      ) {
    final width = MediaQuery.sizeOf(context).width;

    final placeholder = switch (terminology.collectionTitle) {
      'Menu' => width < 400 ? 'Search menu...' : 'Search menu items...',
      'Services' => width < 400 ? 'Search services...' : 'Search services...',
      _ => width < 400 ? 'Search catalog...' : 'Search catalog items...',
    };

    return TextField(
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: placeholder,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
          tooltip: 'Clear',
          onPressed: () => setState(() => _searchQuery = ''),
          icon: const Icon(Icons.clear_rounded),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(
      List<MenuCategoryResponse> categories,
      ) {
    final categoryNames = categories
        .where((category) =>
    category.categoryName?.trim().isNotEmpty == true)
        .map((category) => category.categoryName!.trim())
        .toList();

    return ScrollConfiguration(
      behavior: const _PublicMenuScrollBehavior(),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: categoryNames.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              return FilterChip(
                label: const Text('All'),
                selected: _selectedCategory == null,
                onSelected: (_) => _toggleCategory(null),
              );
            }

            final category = categoryNames[index - 1];
            return FilterChip(
              label: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: _selectedCategory == category,
              onSelected: (_) => _toggleCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttributeFilters() {
    final filtersActive =
        _selectedCategory != null ||
            (_isFoodBusiness && (_showVegOnly || _showNonVegOnly)) ||
            _showBestSellerOnly ||
            _showRecommendedOnly;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (_isFoodBusiness)
          FilterChip(
            avatar: const Icon(Icons.eco_outlined, size: 18),
            label: const Text('Veg'),
            selected: _showVegOnly,
            onSelected: (_) => _toggleVeg(),
          ),

        if (_isFoodBusiness)
          FilterChip(
            label: const Text('Non-Veg'),
            selected: _showNonVegOnly,
            onSelected: (_) => _toggleNonVeg(),
          ),

        FilterChip(
          avatar: const Icon(Icons.star_outline, size: 18),
          label: const Text('Best Seller'),
          selected: _showBestSellerOnly,
          onSelected: (_) {
            setState(() => _showBestSellerOnly = !_showBestSellerOnly);
          },
        ),

        FilterChip(
          avatar: const Icon(Icons.thumb_up_alt_outlined, size: 18),
          label: const Text('Recommended'),
          selected: _showRecommendedOnly,
          onSelected: (_) {
            setState(() => _showRecommendedOnly = !_showRecommendedOnly);
          },
        ),

        if (filtersActive)
          ActionChip(
            avatar: const Icon(Icons.clear_rounded, size: 18),
            label: const Text('Clear'),
            onPressed: _clearAllFilters,
          ),
      ],
    );
  }

  Widget _buildMenuList(
      BuildContext context,
      double horizontalPadding,
      double maxContentWidth,
      ) {
    final items = _filteredItems;

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: _buildEmptyState(context),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = items[index];
                return _buildItemCard(
                  context,
                  entry.item,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final terminology = _terminology;
    final hasFilters =
        _searchQuery.trim().isNotEmpty ||
            _selectedCategory != null ||
            (_isFoodBusiness && (_showVegOnly || _showNonVegOnly)) ||
            _showBestSellerOnly ||
            _showRecommendedOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      child: Column(
        children: [
          Icon(
            terminology.collectionTitle == 'Menu'
                ? Icons.restaurant_menu_outlined
                : terminology.collectionTitle == 'Services'
                ? Icons.design_services_outlined
                : Icons.inventory_2_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No ${terminology.itemTitle.toLowerCase()}s found',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try changing your search or filters.'
                : 'This business has not added any available ${terminology.itemTitle.toLowerCase()}s yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context,
      MenuItemResponse item,
      ) {
    final hasImage = item.imageUrl?.trim().isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final imageSize = isCompact ? 76.0 : 90.0;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasImage) ...[
                  _buildItemImage(
                    context,
                    item,
                    imageSize,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _buildItemContent(
                    context,
                    item,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemContent(
      BuildContext context,
      MenuItemResponse item,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            if (_isFoodBusiness) ...[
              const SizedBox(width: 6),
              _VegIndicator(veg: item.veg),
            ],
          ],
        ),

        if (item.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            item.description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],

        const SizedBox(height: 8),

        Text(
          '₹${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        if (item.bestSeller || item.recommended) ...[
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
                  icon: Icons.thumb_up_alt_outlined,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildItemImage(
      BuildContext context,
      MenuItemResponse item,
      double size,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        item.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Container(
            width: size,
            height: size,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
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
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            context.go('/register');
          },
          child: const Text('Register your business'),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 52,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load content',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ??
                        'Unable to load content.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(publicNotifierProvider.notifier)
                            .loadMenu();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
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

class _PublicTerminology {
  const _PublicTerminology({
    required this.collectionTitle,
    required this.itemTitle,
    required this.description,
  });

  final String collectionTitle;
  final String itemTitle;
  final String description;
}

_PublicTerminology _terminologyFor(String businessType) {
  switch (businessType.trim().toUpperCase()) {
    case 'FOOD':
      return const _PublicTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
        description: 'Explore the latest menu and available items.',
      );
    case 'SERVICES':
      return const _PublicTerminology(
        collectionTitle: 'Services',
        itemTitle: 'Service',
        description: 'Explore available services and offerings.',
      );
    case 'RETAIL':
    case 'ECOMMERCE':
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Product',
        description: 'Browse available products and offerings.',
      );
    case 'PERSONAL_BRAND':
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description: 'Explore products, services and offerings.',
      );
    case 'OTHER':
    default:
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description: 'Explore products, services and offerings.',
      );
  }
}

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({
    required this.veg,
  });

  final bool veg;

  @override
  Widget build(BuildContext context) {
    final color = veg ? Colors.green : Colors.red;

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicMenuScrollBehavior extends MaterialScrollBehavior {
  const _PublicMenuScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}