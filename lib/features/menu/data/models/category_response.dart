class CategoryResponse {
  const CategoryResponse({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.active,
  });

  final String id;
  final String name;
  final int displayOrder;
  final bool active;

  factory CategoryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      displayOrder:
      (json['displayOrder'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
    );
  }
}