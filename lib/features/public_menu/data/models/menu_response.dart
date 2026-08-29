import 'menu_category_response.dart';

class MenuResponse {
  const MenuResponse({
    required this.businessName,
    required this.logoUrl,
    required this.menu,
  });

  final String businessName;
  final String? logoUrl;
  final List<MenuCategoryResponse> menu;

  factory MenuResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawMenu =
    json['menu'];

    return MenuResponse(
      businessName:
      json['businessName']
      as String? ??
          '',
      logoUrl:
      json['logoUrl'] as String?,
      menu: rawMenu is List
          ? rawMenu
          .whereType<Map<String, dynamic>>()
          .map(
        MenuCategoryResponse.fromJson,
      )
          .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'logoUrl': logoUrl,
      'menu': menu
          .map(
            (category) =>
            category.toJson(),
      )
          .toList(),
    };
  }
}