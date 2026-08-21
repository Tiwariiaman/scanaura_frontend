import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/menu_repository.dart';
import '../../data/models/category_request.dart';
import '../../data/models/catalog_request.dart';
import '../../data/models/catalog_response.dart';

import 'menu_state.dart';

final menuNotifierProvider =
NotifierProvider<MenuNotifier, MenuState>(
  MenuNotifier.new,
);

class MenuNotifier extends Notifier<MenuState> {
  late final MenuRepository _repository;

  @override
  MenuState build() {
    _repository = ref.read(menuRepositoryProvider);

    return const MenuState();
  }

  // ============================================================
  // AVAILABILITY
  // ============================================================

  Future<bool> updateAvailability(
      CatalogResponse item,
      bool available,
      ) async {
    try {
      final request = CatalogRequest(
        categoryId: item.categoryId,
        name: item.name,
        description: item.description,
        price: item.price,
        imageUrl: item.imageUrl,
        veg: item.veg,
        available: available,
        bestSeller: item.bestSeller,
        recommended: item.recommended,
        displayOrder: item.displayOrder,
      );

      await _repository.updateCatalog(
        item.id,
        request,
      );

      await loadMenu();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _messageFromException(e),
      );

      return false;
    }
  }

  // ============================================================
  // LOAD MENU
  // ============================================================

  Future<void> loadMenu() async {
    state = state.copyWith(
      status: MenuStatus.loading,
      clearError: true,
    );

    try {
      final categoriesFuture =
      _repository.getCategories();

      final catalogFuture =
      _repository.getCatalogs();

      final categories =
      await categoriesFuture;

      final catalogItems =
      await catalogFuture;

      state = state.copyWith(
        status: MenuStatus.success,
        categories: categories,
        catalogItems: catalogItems,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: MenuStatus.error,
        errorMessage: _messageFromException(e),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshMenu() async {
    await loadMenu();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  void selectCategory(String? categoryId) {
    // Clicking "All"
    if (categoryId == null) {
      state = state.copyWith(
        clearCategory: true,
      );
      return;
    }

    // Clicking the already selected category
    // will unselect it.
    if (state.selectedCategoryId == categoryId) {
      state = state.copyWith(
        clearCategory: true,
      );
      return;
    }

    // Select a new category.
    state = state.copyWith(
      selectedCategoryId: categoryId,
    );
  }

  // void selectCategory(String categoryId) {
  //   if (state.selectedCategoryId == categoryId) {
  //     state = state.copyWith(
  //       clearCategory: true,
  //     );
  //   } else {
  //     state = state.copyWith(
  //       selectedCategoryId: categoryId,
  //     );
  //   }
  // }

  void clearCategory() {
    state = state.copyWith(
      clearCategory: true,
    );
  }

  // ============================================================
  // VEG / NON VEG
  // ============================================================

  void toggleVegFilter() {
    final enabled = !state.showVegOnly;

    state = state.copyWith(
      showVegOnly: enabled,
      showNonVegOnly:
      enabled ? false : state.showNonVegOnly,
    );
  }

  void toggleNonVegFilter() {
    final enabled = !state.showNonVegOnly;

    state = state.copyWith(
      showNonVegOnly: enabled,
      showVegOnly:
      enabled ? false : state.showVegOnly,
    );
  }

  // ============================================================
  // BEST SELLER
  // ============================================================

  void toggleBestSellerFilter() {
    state = state.copyWith(
      showBestSellerOnly:
      !state.showBestSellerOnly,
    );
  }

  // ============================================================
  // RECOMMENDED
  // ============================================================

  void toggleRecommendedFilter() {
    state = state.copyWith(
      showRecommendedOnly:
      !state.showRecommendedOnly,
    );
  }

  // ============================================================
  // AVAILABLE
  // ============================================================

  void toggleAvailableFilter() {
    state = state.copyWith(
      showAvailableOnly:
      !state.showAvailableOnly,
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  void setSortType(MenuSortType sortType) {
    state = state.copyWith(
      sortType: sortType,
    );
  }

  // ============================================================
  // FILTERED MENU
  // ============================================================

  List<CatalogResponse> get filteredItems {
    List<CatalogResponse> items =
    List.from(state.catalogItems);

    // ----------------------------------------------------------
    // AVAILABLE
    // ----------------------------------------------------------

    if (state.showAvailableOnly) {
      items = items
          .where((item) => item.available)
          .toList();
    }

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    final search =
    state.searchQuery.trim().toLowerCase();

    if (search.isNotEmpty) {
      items = items.where((item) {
        final name =
        item.name.toLowerCase();

        final description =
            item.description
                ?.toLowerCase() ??
                '';

        final category =
            item.categoryName
                ?.toLowerCase() ??
                '';

        return name.contains(search) ||
            description.contains(search) ||
            category.contains(search);
      }).toList();
    }

    // ----------------------------------------------------------
    // CATEGORY
    // ----------------------------------------------------------

    if (state.selectedCategoryId != null) {
      items = items
          .where(
            (item) =>
        item.categoryId ==
            state.selectedCategoryId,
      )
          .toList();
    }

    // ----------------------------------------------------------
    // VEG
    // ----------------------------------------------------------

    if (state.showVegOnly) {
      items = items
          .where((item) => item.veg)
          .toList();
    }

    // ----------------------------------------------------------
    // NON VEG
    // ----------------------------------------------------------

    if (state.showNonVegOnly) {
      items = items
          .where((item) => !item.veg)
          .toList();
    }

    // ----------------------------------------------------------
    // BEST SELLER
    // ----------------------------------------------------------

    if (state.showBestSellerOnly) {
      items = items
          .where((item) => item.bestSeller)
          .toList();
    }

    // ----------------------------------------------------------
    // RECOMMENDED
    // ----------------------------------------------------------

    if (state.showRecommendedOnly) {
      items = items
          .where((item) => item.recommended)
          .toList();
    }

    // ----------------------------------------------------------
    // SORTING
    // ----------------------------------------------------------

    if (state.sortType ==
        MenuSortType.priority) {
      items.sort((a, b) {
        final aBest =
        a.bestSeller ? 1 : 0;

        final bBest =
        b.bestSeller ? 1 : 0;

        if (aBest != bBest) {
          return bBest.compareTo(aBest);
        }

        final aRecommended =
        a.recommended ? 1 : 0;

        final bRecommended =
        b.recommended ? 1 : 0;

        if (aRecommended !=
            bRecommended) {
          return bRecommended
              .compareTo(aRecommended);
        }

        return a.displayOrder
            .compareTo(b.displayOrder);
      });
    } else {
      items.sort(
            (a, b) =>
            a.displayOrder
                .compareTo(b.displayOrder),
      );
    }

    return items;
  }

  // ============================================================
  // CREATE CATEGORY
  // ============================================================

  Future<void> createCategory(
      CategoryRequest request,
      ) async {
    try {
      await _repository.createCategory(request);

      await loadMenu();
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  // ============================================================
  // UPDATE CATEGORY
  // ============================================================

  Future<void> updateCategory(
      String id,
      CategoryRequest request,
      ) async {
    try {
      await _repository.updateCategory(
        id,
        request,
      );

      await loadMenu();
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  // ============================================================
  // DELETE CATEGORY
  // ============================================================

  Future<bool> deleteCategory(String id) async {
    try {
      // ------------------------------------------------------------
      // Remove this category from existing menu items first.
      // Items remain in the menu as uncategorized items.
      // ------------------------------------------------------------
      final itemsUsingCategory = state.catalogItems
          .where((item) => item.categoryId == id)
          .toList();

      for (final item in itemsUsingCategory) {
        final request = CatalogRequest(
          categoryId: null,
          name: item.name,
          description: item.description,
          price: item.price,
          imageUrl: item.imageUrl,
          veg: item.veg,
          available: item.available,
          bestSeller: item.bestSeller,
          recommended: item.recommended,
          displayOrder: item.displayOrder,
        );

        await _repository.updateCatalog(
          item.id,
          request,
        );
      }

      // ------------------------------------------------------------
      // Now delete the category.
      // ------------------------------------------------------------
      await _repository.deleteCategory(id);

      // Clear selected category if it was selected.
      if (state.selectedCategoryId == id) {
        state = state.copyWith(
          clearCategory: true,
        );
      }

      // Refresh categories + menu items.
      await loadMenu();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: _messageFromException(e),
      );

      return false;
    }
  }

  // ============================================================
  // CREATE ITEM
  // ============================================================

  Future<bool> createCatalog(
      CatalogRequest request,
      ) async {
    state = state.copyWith(
      status: MenuStatus.loading,
      clearError: true,
    );

    try {
      await _repository.createCatalog(request);

      await loadMenu();

      return true;
    } catch (e) {
      state = state.copyWith(
        status: MenuStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  // ============================================================
  // UPDATE ITEM
  // ============================================================

  Future<bool> updateCatalog(
      String id,
      CatalogRequest request,
      ) async {
    state = state.copyWith(
      status: MenuStatus.loading,
      clearError: true,
    );

    try {
      await _repository.updateCatalog(
        id,
        request,
      );

      await loadMenu();

      return true;
    } catch (e) {
      state = state.copyWith(
        status: MenuStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  // ============================================================
  // DELETE ITEM
  // ============================================================

  Future<bool> deleteCatalog(
      String id,
      ) async {
    state = state.copyWith(
      status: MenuStatus.loading,
      clearError: true,
    );

    try {
      await _repository.deleteCatalog(id);

      await loadMenu();

      return true;
    } catch (e) {
      state = state.copyWith(
        status: MenuStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _messageFromException(
      Object error,
      ) {
    if (error is Exception) {
      final message =
      error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        return message.substring(11);
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}