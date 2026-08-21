import 'ai_menu_item.dart';

class AiCategory {
  const AiCategory({
    this.categoryName,
    required this.items,
  });

  final String? categoryName;
  final List<AiMenuItem> items;

  factory AiCategory.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawItems = json['items'];

    return AiCategory(
      categoryName: json['categoryName'] as String?,
      items: rawItems is List
          ? rawItems
          .whereType<Map<String, dynamic>>()
          .map(AiMenuItem.fromJson)
          .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}