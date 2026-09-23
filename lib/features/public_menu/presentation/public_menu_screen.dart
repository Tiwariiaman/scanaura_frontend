
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_notifier.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

import '../data/customer_selection_controller.dart';
import '../data/models/customer_selection_item.dart';
import '../data/models/menu_category_response.dart';
import '../data/models/menu_item_response.dart';
import 'theme/public_theme_resolver.dart';

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

class _PublicMenuScreenState extends ConsumerState<PublicMenuScreen> {
  String _searchQuery = '';
  bool _searchActive = false;

  final TextEditingController _searchController =
  TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String? _selectedCategory;

  bool _showVegOnly = false;
  bool _showNonVegOnly = false;
  bool _showBestSellerOnly = false;
  bool _showRecommendedOnly = false;

  final CustomerSelectionController _selection =
  CustomerSelectionController();

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

  // ===========================================================================
  // SEARCH
  // ===========================================================================

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

  // ===========================================================================
  // DATA
  // ===========================================================================

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

  bool get _whatsappEnabled {
    final landing = ref.read(publicNotifierProvider).landing;

    final number = landing?.whatsapp?.trim();

    return landing?.whatsappEnabled == true &&
        number != null &&
        number.isNotEmpty;
  }

  String? get _whatsappNumber {
    final landing = ref.read(publicNotifierProvider).landing;

    final number = landing?.whatsapp?.trim();

    if (number == null || number.isEmpty) {
      return null;
    }

    if (landing?.whatsappEnabled != true) {
      return null;
    }

    return number;
  }

  // ===========================================================================
  // FILTERED ITEMS
  // ===========================================================================

  List<_PublicMenuItem> get _filteredItems {
    final allItems = <_PublicMenuItem>[];

    for (
    var categoryIndex = 0;
    categoryIndex < _categories.length;
    categoryIndex++
    ) {
      final category = _categories[categoryIndex];

      for (
      var itemIndex = 0;
      itemIndex < category.items.length;
      itemIndex++
      ) {
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

  int _boolRank(bool value) => value ? 1 : 0;

  // ===========================================================================
  // SELECTION
  // ===========================================================================

  bool _isSelected(_PublicMenuItem entry) {
    return _selection.contains(entry.selectionId);
  }

  void _toggleSelection(_PublicMenuItem entry) {
    if (!_whatsappEnabled) {
      return;
    }

    setState(() {
      _selection.toggleItem(
        selectionId: entry.selectionId,
        itemName: entry.item.name,
        unitPrice: entry.item.price,
      );
    });
  }

  void _increaseSelection(String selectionId) {
    setState(() {
      _selection.increaseQuantity(selectionId);
    });
  }

  void _decreaseSelection(String selectionId) {
    setState(() {
      _selection.decreaseQuantity(selectionId);
    });
  }

  void _removeSelection(String selectionId) {
    setState(() {
      _selection.removeItem(selectionId);
    });
  }

  void _clearSelection() {
    setState(() {
      _selection.clear();
    });
  }

  // ===========================================================================
  // FILTERS
  // ===========================================================================

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

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicNotifierProvider);

    final terminology = _terminology;

    if (state.status == PublicStatus.loading &&
        state.menu == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == PublicStatus.error &&
        state.menu == null) {
      return _buildError(context, state);
    }

    final menu = state.menu;

    if (menu == null) {
      return const Scaffold(
        body: Center(
          child: Text('Content is unavailable.'),
        ),
      );
    }

    final publicTheme = PublicThemeResolver.resolve(
      businessName:
      state.landing?.businessName ?? menu.businessName,
      businessType: state.landing?.businessType ?? '',
      brandColor: state.landing?.brandColor,
    );

    return Theme(
      data: publicTheme.materialTheme(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 18,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menu.businessName.trim().isEmpty
                    ? terminology.collectionTitle
                    : menu.businessName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: publicTheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                terminology.collectionTitle,
                style: TextStyle(
                  color: publicTheme.onSurfaceVariant,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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

            final maxContentWidth = width >= 1000
                ? 1000.0
                : 720.0;

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(publicNotifierProvider.notifier)
                        .refreshMenu();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: publicTheme.background,
                    ),
                    child: CustomScrollView(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 12),
                        ),

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
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 20),
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
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  right: horizontalPadding,
                  bottom: _selection.isNotEmpty ? 86 : 18,
                  child: Material(
                    color: publicTheme.primary,
                    elevation: 7,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap:
                      _searchActive ? _closeSearch : _openSearch,
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

                if (_selection.isNotEmpty)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 14,
                    child: _buildSelectionBottomBar(
                      context,
                      publicTheme,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // SEARCH
  // ===========================================================================

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
              avatar: const Icon(
                Icons.clear_rounded,
                size: 18,
              ),
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
      'Menu' => width < 400
          ? 'Search menu...'
          : 'Search menu items...',
      'Services' => 'Search services...',
      _ => width < 400
          ? 'Search catalog...'
          : 'Search catalog items...',
    };
  }

  Widget _buildCategoryFilters(
      List<MenuCategoryResponse> categories,
      ) {
    final categoryNames = categories
        .where(
          (category) =>
      category.categoryName?.trim().isNotEmpty == true,
    )
        .map(
          (category) => category.categoryName!.trim(),
    )
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
          separatorBuilder: (_, _) =>
          const SizedBox(width: 8),
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

  // ===========================================================================
  // MENU
  // ===========================================================================

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
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: _buildEmptyState(context),
          ),
        ),
      );
    }

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
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: List.generate(
                  _categories.length,
                      (categoryIndex) {
                    final category = _categories[categoryIndex];

                    final available = category.items
                        .asMap()
                        .entries
                        .where(
                          (entry) => entry.value.available,
                    )
                        .toList();

                    if (available.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final title =
                    category.categoryName?.trim().isNotEmpty ==
                        true
                        ? category.categoryName!.trim()
                        : 'More ${_terminology.itemTitle}s';

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildCategoryHeader(
                            context,
                            title,
                          ),
                          const SizedBox(height: 14),
                          ...available.map(
                                (entry) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child: _buildItemCard(
                                context,
                                _PublicMenuItem(
                                  item: entry.value,
                                  categoryName:
                                  category.categoryName,
                                  selectionId:
                                  '$categoryIndex:${entry.key}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            child: _buildFilteredResults(
              context,
              items,
            ),
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
      final category =
      item.categoryName?.trim().isNotEmpty == true
          ? item.categoryName!.trim()
          : 'More ${_terminology.itemTitle}s';

      grouped.putIfAbsent(
        category,
            () => <_PublicMenuItem>[],
      ).add(item);
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
                _buildCategoryHeader(
                  context,
                  group.key,
                ),
                const SizedBox(height: 14),
                ...group.value.map(
                      (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 14,
                    ),
                    child: _buildItemCard(
                      context,
                      item,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryHeader(
      BuildContext context,
      String title,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        right: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -.45,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: .30,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }


  // ===========================================================================
  // ITEM CARD
  // ===========================================================================

  Widget _buildItemCard(
      BuildContext context,
      _PublicMenuItem entry,
      ) {
    final item = entry.item;
    final imageUrl = item.imageUrl?.trim();
    final hasImage =
        imageUrl != null && imageUrl.isNotEmpty;
    final selected = _isSelected(entry);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openItemDetails(entry),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 108,
          ),
          padding: const EdgeInsets.fromLTRB(
            10,
            10,
            9,
            10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: .92,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(
                alpha: .30,
              )
                  : const Color(0xFFE8ECEB),
              width: selected ? 1.25 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172025).withValues(
                  alpha: .035,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IMAGE
              if (hasImage) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openImageViewer(
                    context,
                    item,
                  ),
                  child: _buildItemImage(
                    context,
                    item,
                    76,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // CONTENT
              Expanded(
                child: _buildItemContent(
                  context,
                  entry,
                ),
              ),

              const SizedBox(width: 7),

              // SMALL PLUS / QUANTITY
              _buildSmallAddButton(
                context,
                entry,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSmallAddButton(
      BuildContext context,
      _PublicMenuItem entry,
      ) {
    final theme = Theme.of(context);
    final selectedItem = _selection.item(
      entry.selectionId,
    );

    if (selectedItem == null) {
      return Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(
                alpha: _whatsappEnabled ? .30 : .12,
              ),
            ),
            color: theme.colorScheme.primary.withValues(
              alpha: _whatsappEnabled ? .055 : .025,
            ),
          ),
          child: InkWell(
            onTap: _whatsappEnabled
                ? () => _toggleSelection(entry)
                : null,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 31,
              height: 31,
              child: Icon(
                Icons.add_rounded,
                size: 19,
                color: _whatsappEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: .38),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 31,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(
          alpha: .065,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: .16,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              _decreaseSelection(entry.selectionId);
            },
            child: SizedBox(
              width: 27,
              height: 31,
              child: Icon(
                Icons.remove_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Text(
            '${selectedItem.quantity}',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          InkWell(
            onTap: () {
              _increaseSelection(entry.selectionId);
            },
            child: SizedBox(
              width: 27,
              height: 31,
              child: Icon(
                Icons.add_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildItemContent(
      BuildContext context,
      _PublicMenuItem entry,
      ) {
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
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -.25,
                ),
              ),
            ),
            if (_isFoodBusiness) ...[
              const SizedBox(width: 5),
              _VegIndicator(
                veg: item.veg,
              ),
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
              fontSize: 11.5,
              height: 1.28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 7),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                letterSpacing: -.2,
              ),
            ),
            const SizedBox(width: 7),
            if (item.bestSeller)
              _CompactBadge(
                label: 'Best Seller',
                icon: Icons.star_rounded,
                color: theme.colorScheme.primary,
              ),
            if (item.recommended && !item.bestSeller)
              _CompactBadge(
                label: 'Recommended',
                icon: Icons.thumb_up_alt_outlined,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ],
    );
  }


  // ===========================================================================
  // ITEM DETAILS POPUP
  // ===========================================================================

  void _openItemDetails(_PublicMenuItem entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return _ItemDetailsSheet(
          entry: entry,
          isFoodBusiness: _isFoodBusiness,
          whatsappEnabled: _whatsappEnabled,
          isSelected: _isSelected(entry),
          onImageTap: () {
            Navigator.of(sheetContext).pop();
            Future.microtask(() {
              if (mounted) {
                _openImageViewer(
                  context,
                  entry.item,
                );
              }
            });
          },
          onAdd: () {
            if (!_whatsappEnabled) {
              return;
            }

            _toggleSelection(entry);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  // ===========================================================================
  // IMAGE VIEWER
  // ===========================================================================

  void _openImageViewer(
      BuildContext context,
      MenuItemResponse item,
      ) {
    final imageUrl = item.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .92),
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  panEnabled: true,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 56,
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 18,
                right: 18,
                child: SafeArea(
                  child: Material(
                    color: Colors.white.withValues(
                      alpha: .18,
                    ),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // IMAGE
  // ===========================================================================

  Widget _buildItemImage(
      BuildContext context,
      MenuItemResponse item,
      double size,
      ) {
    final imageUrl = item.imageUrl?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              size: 22,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
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
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SELECTION BOTTOM BAR
  // ===========================================================================

  Widget _buildSelectionBottomBar(
      BuildContext context,
      dynamic publicTheme,
      ) {
    final theme = Theme.of(context);
    final itemCount = _selection.totalUnitCount;
    final total = _selection.estimatedTotal;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _openSelectionSheet,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            11,
            9,
            9,
            9,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: .96,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(
                alpha: .14,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF172025).withValues(
                  alpha: .10,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: .075,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: theme.colorScheme.primary,
                      size: 21,
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      width: 21,
                      height: 21,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '$itemCount',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'} selected',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM SHEET
  // ===========================================================================

  void _openSelectionSheet() {
    if (_selection.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);

            return Container(
              constraints: BoxConstraints(
                maxHeight:
                MediaQuery.sizeOf(context).height * .78,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    alpha: .16,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(
                      alpha: .16,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      12,
                      10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: .10,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: theme.colorScheme.primary,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  'Your Selection',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _clearSelection();
                            Navigator.of(sheetContext).pop();
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        4,
                        20,
                        16,
                      ),
                      itemCount:
                      _selection.selectedItems.length,
                      separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final selected =
                        _selection.selectedItems[index];

                        return _buildSelectedItemRow(
                          context,
                          selected,
                          onIncrease: () {
                            _increaseSelection(
                              selected.selectionId,
                            );
                            setSheetState(() {});
                          },
                          onDecrease: () {
                            _decreaseSelection(
                              selected.selectionId,
                            );
                            setSheetState(() {});

                            if (_selection.isEmpty &&
                                Navigator.of(sheetContext)
                                    .canPop()) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          onRemove: () {
                            _removeSelection(
                              selected.selectionId,
                            );
                            setSheetState(() {});

                            if (_selection.isEmpty &&
                                Navigator.of(sheetContext)
                                    .canPop()) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      14,
                      20,
                      18,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline
                              .withValues(alpha: .18),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Estimated Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '₹${_selection.estimatedTotal.toStringAsFixed(2)}',
                              style: theme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color:
                                theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            child: Text(
                              'Continue Browsing',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        if (_whatsappEnabled) ...[
                          const SizedBox(height: 9),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                _sendSelectionToWhatsApp();
                              },
                              icon: const Icon(
                                Icons.chat_rounded,
                              ),
                              label: Text(
                                _whatsappButtonText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedItemRow(
      BuildContext context,
      CustomerSelectionItem item, {
        required VoidCallback onIncrease,
        required VoidCallback onDecrease,
        required VoidCallback onRemove,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: .12,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.unitPrice.toStringAsFixed(2)} each',
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: theme.colorScheme.outline
                    .withValues(alpha: .20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Decrease',
                  onPressed: onDecrease,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 38,
                  ),
                  icon: const Icon(
                    Icons.remove_rounded,
                    size: 17,
                  ),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  tooltip: 'Increase',
                  onPressed: onIncrease,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 38,
                  ),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          IconButton(
            tooltip: 'Remove',
            onPressed: onRemove,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WHATSAPP
  // ===========================================================================

  String get _whatsappButtonText {
    switch (_businessType) {
      case 'FOOD':
        return 'Send Order on WhatsApp';

      case 'HOTEL':
        return 'Send Enquiry on WhatsApp';

      case 'SERVICES':
        return 'Send Enquiry on WhatsApp';

      case 'RETAIL':
      case 'ECOMMERCE':
        return 'Send on WhatsApp';

      default:
        return 'Send on WhatsApp';
    }
  }

  String _buildWhatsAppMessage() {
    final businessType = _businessType;

    final buffer = StringBuffer();

    if (businessType == 'FOOD') {
      buffer.writeln('Hi, I would like to order:');
    } else if (businessType == 'HOTEL') {
      buffer.writeln('Hi, I would like to enquire about:');
    } else if (businessType == 'SERVICES') {
      buffer.writeln('Hi, I would like to enquire about:');
    } else if (businessType == 'RETAIL' ||
        businessType == 'ECOMMERCE') {
      buffer.writeln('Hi, I am interested in:');
    } else {
      buffer.writeln('Hi, I would like to know more about:');
    }

    buffer.writeln();

    for (final item in _selection.selectedItems) {
      buffer.writeln(
        '${item.quantity} × ${item.itemName} - '
            '₹${item.estimatedTotal.toStringAsFixed(2)}',
      );
    }

    buffer.writeln();
    buffer.writeln(
      'Estimated Total: '
          '₹${_selection.estimatedTotal.toStringAsFixed(2)}',
    );

    buffer.writeln();
    buffer.write('Sent via ScanAura');

    return buffer.toString();
  }

  Future<void> _sendSelectionToWhatsApp() async {
    final whatsapp = _whatsappNumber;

    if (whatsapp == null || _selection.isEmpty) {
      return;
    }

    final phone = whatsapp.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (phone.isEmpty) {
      return;
    }

    final message = _buildWhatsAppMessage();

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open WhatsApp.',
            ),
          ),
        );
        return;
      }

      if (launched && mounted) {
        _clearSelection();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open WhatsApp.',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState(BuildContext context) {
    final terminology = _terminology;

    final hasFilters =
        _searchQuery.trim().isNotEmpty ||
            _selectedCategory != null ||
            (_isFoodBusiness &&
                (_showVegOnly || _showNonVegOnly)) ||
            _showBestSellerOnly ||
            _showRecommendedOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      child: Column(
        children: [
          Icon(
            terminology.collectionTitle == 'Menu'
                ? Icons.restaurant_menu_outlined
                : terminology.collectionTitle == 'Services'
                ? Icons.design_services_outlined
                : Icons.inventory_2_outlined,
            size: 50,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            'No ${terminology.itemTitle.toLowerCase()}s found',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            hasFilters
                ? 'Try changing your search or filters.'
                : 'This business has not added any available ${terminology.itemTitle.toLowerCase()}s yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
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

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Builder(
          builder: (context) {
            final theme = Theme.of(context);

            return Column(
              children: [
                Text(
                  'Powered by ScanAura',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    'Register your business',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // ERROR
  // ===========================================================================

  Widget _buildError(
      BuildContext context,
      PublicState state,
      ) {
    if (state.isBusinessUnavailable) {
      return _buildMaintenancePage(context);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 52,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
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
                            .read(
                          publicNotifierProvider.notifier,
                        )
                            .loadMenu();
                      },
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
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
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: theme.colorScheme
                          .surfaceContainerHighest,
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
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This business\'s ScanAura page is currently under maintenance. Please check back later.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color:
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Powered by ScanAura',
                    style: TextStyle(
                      color:
                      theme.colorScheme.onSurfaceVariant,
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

// =============================================================================
// ITEM DETAILS SHEET
// =============================================================================

// =============================================================================
// ITEM DETAILS SHEET
// =============================================================================

class _ItemDetailsSheet extends StatelessWidget {
  const _ItemDetailsSheet({
    required this.entry,
    required this.isFoodBusiness,
    required this.whatsappEnabled,
    required this.isSelected,
    required this.onImageTap,
    required this.onAdd,
  });

  final _PublicMenuItem entry;
  final bool isFoodBusiness;
  final bool whatsappEnabled;
  final bool isSelected;
  final VoidCallback onImageTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;

    final imageUrl = item.imageUrl?.trim();
    final hasImage =
        imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .88,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: .14,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // HEADER
            // =================================================================
            if (hasImage)
              Stack(
                children: [
                  GestureDetector(
                    onTap: onImageTap,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: double.infinity,
                            height: 240,
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 42,
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          );
                        },
                        loadingBuilder:
                            (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return Container(
                            width: double.infinity,
                            height: 240,
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Material(
                      color: Colors.black.withValues(
                        alpha: .48,
                      ),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Zoom hint
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: .52,
                        ),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Tap image to zoom',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
            // ===============================================================
            // NO IMAGE HEADER
            // ===============================================================
              SizedBox(
                height: 64,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      right: 14,
                    ),
                    child: Material(
                      color: theme.colorScheme
                          .surfaceContainerHighest,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(
                            Icons.close_rounded,
                            color: theme
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // =================================================================
            // CONTENT
            // =================================================================
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                hasImage ? 20 : 4,
                22,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  if (entry.categoryName
                      ?.trim()
                      .isNotEmpty ==
                      true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: .10),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.categoryName!.trim(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  if (entry.categoryName
                      ?.trim()
                      .isNotEmpty ==
                      true)
                    const SizedBox(height: 14),

                  // Item name + veg indicator
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.4,
                          ),
                        ),
                      ),

                      if (isFoodBusiness) ...[
                        const SizedBox(width: 10),
                        _VegIndicator(
                          veg: item.veg,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  // Description
                  if (item.description
                      ?.trim()
                      .isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 14),
                    Text(
                      item.description!.trim(),
                      style: theme
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        height: 1.5,
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],

                  // Badges
                  if (item.bestSeller ||
                      item.recommended) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.bestSeller)
                          const _CompactBadge(
                            label: 'Best Seller',
                            icon: Icons.star_rounded,
                          ),
                        if (item.recommended)
                          const _CompactBadge(
                            label: 'Recommended',
                            icon: Icons
                                .thumb_up_alt_outlined,
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                        theme.colorScheme.primary,
                        foregroundColor:
                        theme.colorScheme.onPrimary,
                        disabledBackgroundColor:
                        theme.colorScheme.primary
                            .withValues(alpha: .10),
                        disabledForegroundColor:
                        theme
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: .55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      onPressed:
                      whatsappEnabled ? onAdd : null,
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                      ),
                      label: Text(
                        isSelected
                            ? 'Add Another'
                            : 'Add',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  // WhatsApp unavailable message
                  if (!whatsappEnabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'WhatsApp ordering is currently unavailable for this business.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                        fontSize: 11.5,
                      ),
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
}

// =============================================================================
// MODELS
// =============================================================================

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

_PublicTerminology _terminologyFor(
    String businessType,
    ) {
  switch (businessType.trim().toUpperCase()) {
    case 'FOOD':
      return const _PublicTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
        description:
        'Explore the latest menu and available items.',
      );

    case 'HOTEL':
      return const _PublicTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
        description:
        'Explore rooms, food and available offerings.',
      );

    case 'SERVICES':
      return const _PublicTerminology(
        collectionTitle: 'Services',
        itemTitle: 'Service',
        description:
        'Explore available services and offerings.',
      );

    case 'RETAIL':
    case 'ECOMMERCE':
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Product',
        description:
        'Browse available products and offerings.',
      );

    case 'PERSONAL_BRAND':
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description:
        'Explore products, services and offerings.',
      );

    case 'OTHER':
    default:
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
        description:
        'Explore products, services and offerings.',
      );
  }
}

// =============================================================================
// VEG INDICATOR
// =============================================================================

class _VegIndicator extends StatelessWidget {
  const _VegIndicator({
    required this.veg,
  });

  final bool veg;

  @override
  Widget build(BuildContext context) {
    final color = veg ? Colors.green : Colors.red;

    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// =============================================================================
// COMPACT BADGE
// =============================================================================

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({
    required this.label,
    required this.icon,
    this.color,
  });

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: accent,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SCROLL BEHAVIOR
// =============================================================================

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
