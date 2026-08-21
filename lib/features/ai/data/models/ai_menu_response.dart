import 'ai_category.dart';

class AiMenuResponse {
  const AiMenuResponse({
    required this.categories,
  });

  final List<AiCategory> categories;

  factory AiMenuResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawCategories = json['categories'];

    return AiMenuResponse(
      categories: rawCategories is List
          ? rawCategories
          .whereType<Map<String, dynamic>>()
          .map(AiCategory.fromJson)
          .toList()
          : const [],
    );
  }
}