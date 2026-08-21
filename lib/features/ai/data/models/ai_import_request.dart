import 'ai_category.dart';

class AiImportRequest {
  const AiImportRequest({
    required this.overwriteExistingMenu,
    required this.categories,
  });

  final bool overwriteExistingMenu;
  final List<AiCategory> categories;

  Map<String, dynamic> toJson() {
    return {
      'overwriteExistingMenu': overwriteExistingMenu,
      'categories': categories
          .map((category) => category.toJson())
          .toList(),
    };
  }
}