import 'menu_item_response.dart';

class MenuCategoryResponse {
  const MenuCategoryResponse({
    required this.categoryName,
    required this.items,
  });

  final String? categoryName;
  final List<MenuItemResponse> items;

  factory MenuCategoryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawItems = json['items'];

    return MenuCategoryResponse(
      categoryName:
      json['categoryName'] as String?,
      items: rawItems is List
          ? rawItems
          .whereType<Map<String, dynamic>>()
          .map(
        MenuItemResponse.fromJson,
      )
          .toList()
          : const [],
    );
  }
}