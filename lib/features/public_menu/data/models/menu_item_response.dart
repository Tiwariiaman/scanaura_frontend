class MenuItemResponse {
  const MenuItemResponse({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.veg,
    required this.available,
    required this.bestSeller,
    required this.recommended,
  });

  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool veg;
  final bool available;
  final bool bestSeller;
  final bool recommended;

  factory MenuItemResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return MenuItemResponse(
      name: json['name'] as String? ?? '',
      description:
      json['description'] as String?,
      price:
      (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl:
      json['imageUrl'] as String?,
      veg:
      json['veg'] as bool? ?? true,
      available:
      json['available'] as bool? ?? false,
      bestSeller:
      json['bestSeller'] as bool? ?? false,
      recommended:
      json['recommended'] as bool? ?? false,
    );
  }
}