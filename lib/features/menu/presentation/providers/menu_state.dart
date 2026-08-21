import '../../data/models/category_response.dart';
import '../../data/models/catalog_response.dart';

enum MenuStatus {
  initial,
  loading,
  success,
  error,
}

enum MenuSortType {
  priority,
  displayOrder,
}

class MenuState {
  const MenuState({
    this.status = MenuStatus.initial,
    this.categories = const [],
    this.catalogItems = const [],
    this.searchQuery = '',
    this.selectedCategoryId,
    this.showVegOnly = false,
    this.showNonVegOnly = false,
    this.showBestSellerOnly = false,
    this.showRecommendedOnly = false,
    this.showAvailableOnly = false,
    this.sortType = MenuSortType.priority,
    this.errorMessage,
  });

  final MenuStatus status;

  final List<CategoryResponse> categories;
  final List<CatalogResponse> catalogItems;

  final String searchQuery;

  final String? selectedCategoryId;

  final bool showVegOnly;
  final bool showNonVegOnly;
  final bool showBestSellerOnly;
  final bool showRecommendedOnly;

  final bool showAvailableOnly;

  final MenuSortType sortType;

  final String? errorMessage;

  MenuState copyWith({
    MenuStatus? status,
    List<CategoryResponse>? categories,
    List<CatalogResponse>? catalogItems,
    String? searchQuery,
    String? selectedCategoryId,
    bool clearCategory = false,
    bool? showVegOnly,
    bool? showNonVegOnly,
    bool? showBestSellerOnly,
    bool? showRecommendedOnly,
    bool? showAvailableOnly,
    MenuSortType? sortType,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MenuState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      catalogItems: catalogItems ?? this.catalogItems,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId:
      clearCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      showVegOnly:
      showVegOnly ?? this.showVegOnly,
      showNonVegOnly:
      showNonVegOnly ?? this.showNonVegOnly,
      showBestSellerOnly:
      showBestSellerOnly ?? this.showBestSellerOnly,
      showRecommendedOnly:
      showRecommendedOnly ?? this.showRecommendedOnly,
      showAvailableOnly:
      showAvailableOnly ?? this.showAvailableOnly,
      sortType:
      sortType ?? this.sortType,
      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}