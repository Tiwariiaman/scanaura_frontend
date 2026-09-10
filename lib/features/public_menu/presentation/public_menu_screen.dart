import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

import '../data/customer_selection_controller.dart';
import '../data/models/menu_category_response.dart';
import '../data/models/menu_item_response.dart';
import 'theme/public_theme_resolver.dart';

class PublicMenuScreen extends ConsumerStatefulWidget {
  const PublicMenuScreen({super.key, required this.qrCode});

  final String qrCode;

  @override
  ConsumerState<PublicMenuScreen> createState() => _PublicMenuScreenState();
}

class _PublicMenuScreenState extends ConsumerState<PublicMenuScreen> {
  String _searchQuery = '';
  bool _searchActive = false;

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String? _selectedCategory;

  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showBestSellerOnly = false;
  bool _showRecommendedOnly = false;

  // Kept intentionally for the future estimate/selection feature.
  // Customer-facing controls are currently hidden.
  final CustomerSelectionController _selection = CustomerSelectionController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier = ref.read(publicNotifierProvider.notifier);

      notifier.setQrCode(widget.qrCode);

      await notifier.loadLanding(widget.qrCode);
      await notifier.loadMenu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _searchActive = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();

    setState(() {
      _searchActive = false;
      _searchQuery = '';
      _searchController.clear();
      _clearAllFilters();
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

  _PublicTerminology get _terminology => _terminologyFor(_businessType);

  List<_PublicMenuItem> get _filteredItems {
    final allItems = <_PublicMenuItem>[];

    for (
      var categoryIndex = 0;
      categoryIndex < _categories.length;
      categoryIndex++
    ) {
      final category = _categories[categoryIndex];

      for (var itemIndex = 0; itemIndex < category.items.length; itemIndex++) {
        final item = category.items[itemIndex];

        allItems.add(
          _PublicMenuItem(
            item: item,
            categoryName: category.categoryName,
            selectionId: '$categoryIndex:$itemIndex',
          ),
        );
      }
    }

    Iterable<_PublicMenuItem> items = allItems.where(
      (entry) => entry.item.available,
    );

    if (_selectedCategory != null) {
      items = items.where((entry) => entry.categoryName == _selectedCategory);
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
      final bestSellerCompare = _boolRank(
        b.item.bestSeller,
      ).compareTo(_boolRank(a.item.bestSeller));

      if (bestSellerCompare != 0) {
        return bestSellerCompare;
      }

      final recommendedCompare = _boolRank(
        b.item.recommended,
      ).compareTo(_boolRank(a.item.recommended));

      if (recommendedCompare != 0) {
        return recommendedCompare;
      }

      return 0;
    });

    return result;
  }

  int _boolRank(bool value) => value ? 1 : 0;

  // Future selection support.
  bool _isSelected(_PublicMenuItem entry) {
    return _selection.contains(entry.selectionId);
  }

  // Future selection support.
  void _toggleSelection(_PublicMenuItem entry) {
    setState(() {
      _selection.toggleItem(
        selectionId: entry.selectionId,
        itemName: entry.item.name,
        unitPrice: entry.item.price,
      );
    });
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
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }

  void _toggleVeg() {
    if (!_isFoodBusiness) {
      return;
    }

    setState(() {
      _showVegOnly = !_showVegOnly;

      if (_showVegOnly) {
        _showNonVegOnly = false;
      }
    });
  }

  void _toggleNonVeg() {
    if (!_isFoodBusiness) {
      return;
    }

    setState(() {
      _showNonVegOnly = !_showNonVegOnly;

      if (_showNonVegOnly) {
        _showVegOnly = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicNotifierProvider);

    final terminology = _terminology;

    if (state.status == PublicStatus.loading && state.menu == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

    final publicTheme = PublicThemeResolver.resolve(
      businessName: state.landing?.businessName ?? menu.businessName,
      businessType: state.landing?.businessType ?? '',
      brandColor: state.landing?.brandColor,
    );

    return Theme(
      data: publicTheme.materialTheme(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            menu.businessName.trim().isEmpty
                ? terminology.collectionTitle
                : menu.businessName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width < 360
                ? 12.0
                : width < 600
                ? 16.0
                : 20.0;

            final maxContentWidth = width >= 1000 ? 1000.0 : 720.0;

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(publicNotifierProvider.notifier)
                        .refreshMenu();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Search and filters are intentionally
                      // integrated together. They appear only
                      // when the floating search is opened.
                      if (_searchActive)
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxContentWidth,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: _buildSearchAndFilters(
                                  context,
                                  terminology,
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (_searchActive)
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      _buildMenuList(
                        context,
                        horizontalPadding,
                        maxContentWidth,
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 28)),

                      SliverToBoxAdapter(child: _buildFooter()),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),

                // Floating search button.
                Positioned(
                  right: horizontalPadding,
                  bottom: 18,
                  child: Material(
                    color: publicTheme.primary,
                    elevation: 7,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _searchActive ? _closeSearch : _openSearch,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          _searchActive
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: publicTheme.onPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    _PublicTerminology terminology,
  ) {
    final theme = Theme.of(context);

    final filtersActive =
        _selectedCategory != null ||
        _showVegOnly ||
        _showNonVegOnly ||
        _showBestSellerOnly ||
        _showRecommendedOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.surface,
          elevation: 5,
          borderRadius: BorderRadius.circular(18),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: _searchHint(terminology),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        _buildCategoryFilters(_categories),

        const SizedBox(height: 10),

        _buildAttributeFilters(),

        if (filtersActive) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.clear_rounded, size: 18),
              label: const Text('Clear'),
              onPressed: _clearAllFilters,
            ),
          ),
        ],
      ],
    );
  }

  String _searchHint(_PublicTerminology terminology) {
    final width = MediaQuery.sizeOf(context).width;

    return switch (terminology.collectionTitle) {
      'Menu' => width < 400 ? 'Search menu...' : 'Search menu items...',
      'Services' => width < 400 ? 'Search services...' : 'Search services...',
      _ => width < 400 ? 'Search catalog...' : 'Search catalog items...',
    };
  }

  Widget _buildCategoryFilters(List<MenuCategoryResponse> categories) {
    final categoryNames = categories
        .where((category) => category.categoryName?.trim().isNotEmpty == true)
        .map((category) => category.categoryName!.trim())
        .toList();

    if (categoryNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return ScrollConfiguration(
      behavior: const _PublicMenuScrollBehavior(),
      child: SizedBox(
        height: 42,
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
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (_) => _toggleCategory(category),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttributeFilters() {
    final chips = <Widget>[];

    if (_isFoodBusiness) {
      chips.add(
        FilterChip(
          avatar: const _VegIndicator(veg: true),
          label: const Text('Veg'),
          selected: _showVegOnly,
          onSelected: (_) => _toggleVeg(),
        ),
      );

      chips.add(
        FilterChip(
          avatar: const _VegIndicator(veg: false),
          label: const Text('Non-Veg'),
          selected: _showNonVegOnly,
          onSelected: (_) => _toggleNonVeg(),
        ),
      );
    }

    chips.add(
      FilterChip(
        avatar: const Icon(
          Icons.star_rounded,
          size: 17,
        ),
        label: const Text('Best Seller'),
        selected: _showBestSellerOnly,
        onSelected: (_) {
          setState(() {
            _showBestSellerOnly = !_showBestSellerOnly;
          });
        },
      ),
    );

    chips.add(
      FilterChip(
        avatar: const Icon(
          Icons.thumb_up_alt_outlined,
          size: 16,
        ),
        label: const Text('Recommended'),
        selected: _showRecommendedOnly,
        onSelected: (_) {
          setState(() {
            _showRecommendedOnly = !_showRecommendedOnly;
          });
        },
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
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

    // Normal browsing:
    // keep every category together with
    // its own items.
    final browsingNaturally =
        !_searchActive &&
        _selectedCategory == null &&
        _searchQuery.trim().isEmpty &&
        !_showVegOnly &&
        !_showNonVegOnly &&
        !_showBestSellerOnly &&
        !_showRecommendedOnly;

    if (browsingNaturally) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(_categories.length, (categoryIndex) {
                  final category = _categories[categoryIndex];

                  final available = category.items
                      .asMap()
                      .entries
                      .where((entry) => entry.value.available)
                      .toList();

                  if (available.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final title = category.categoryName?.trim().isNotEmpty == true
                      ? category.categoryName!.trim()
                      : 'More ${_terminology.itemTitle}s';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryHeader(context, title),
                        const SizedBox(height: 10),
                        ...available.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildItemCard(
                              context,
                              _PublicMenuItem(
                                item: entry.value,
                                categoryName: category.categoryName,
                                selectionId: '$categoryIndex:${entry.key}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
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
            child: _buildFilteredResults(context, items),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredResults(
    BuildContext context,
    List<_PublicMenuItem> items,
  ) {
    final grouped = <String, List<_PublicMenuItem>>{};

    for (final item in items) {
      final category = item.categoryName?.trim().isNotEmpty == true
          ? item.categoryName!.trim()
          : 'More ${_terminology.itemTitle}s';

      grouped.putIfAbsent(category, () => <_PublicMenuItem>[]).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in grouped.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(context, group.key),
                const SizedBox(height: 10),
                ...group.value.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildItemCard(context, item),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Column(
        children: [
          Icon(
            terminology.collectionTitle == 'Menu'
                ? Icons.restaurant_menu_outlined
                : terminology.collectionTitle == 'Services'
                ? Icons.design_services_outlined
                : Icons.inventory_2_outlined,
            size: 50,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            'No ${terminology.itemTitle.toLowerCase()}s found',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            hasFilters
                ? 'Try changing your search or filters.'
                : 'This business has not added any available ${terminology.itemTitle.toLowerCase()}s yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
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

  Widget _buildItemCard(BuildContext context, _PublicMenuItem entry) {
    final item = entry.item;
    final hasImage = item.imageUrl?.trim().isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 430;

        final imageSize = isSmall ? 74.0 : 82.0;

        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(isSmall ? 10 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: .45),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasImage) ...[
                    _buildItemImage(context, item, imageSize),
                    SizedBox(width: isSmall ? 11 : 13),
                  ],

                  Expanded(child: _buildItemContent(context, entry)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemContent(BuildContext context, _PublicMenuItem entry) {
    final item = entry.item;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            if (_isFoodBusiness) ...[
              const SizedBox(width: 7),
              _VegIndicator(veg: item.veg),
            ],
          ],
        ),

        if (item.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            item.description!.trim(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.3,
            ),
          ),
        ],

        const SizedBox(height: 7),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            if (item.bestSeller)
              const _CompactBadge(
                label: 'Best Seller',
                icon: Icons.star_rounded,
              ),
            if (item.recommended && !item.bestSeller)
              const _CompactBadge(
                label: 'Recommended',
                icon: Icons.thumb_up_alt_outlined,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemImage(
    BuildContext context,
    MenuItemResponse item,
    double size,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        item.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  Widget _buildError(BuildContext context, PublicState state) {
    if (state.isBusinessUnavailable) {
      return _buildMaintenancePage(context);
    }

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Unable to load content.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.read(publicNotifierProvider.notifier).loadMenu();
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

  Widget _buildMaintenancePage(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.engineering_outlined,
                      size: 44,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'This page is temporarily unavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This business\'s ScanAura page is currently under maintenance. Please check back later.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Powered by ScanAura',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
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
    required this.selectionId,
  });

  final MenuItemResponse item;
  final String? categoryName;
  final String selectionId;
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
  const _VegIndicator({required this.veg});

  final bool veg;

  @override
  Widget build(BuildContext context) {
    final color = veg ? Colors.green : Colors.red;

    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
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
