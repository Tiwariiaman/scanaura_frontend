class CategoryRequest {
  const CategoryRequest({
    required this.name,
    this.displayOrder = 0,
  });

  final String name;
  final int displayOrder;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayOrder': displayOrder,
    };
  }
}