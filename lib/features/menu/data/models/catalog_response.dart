class CatalogResponse {
  const CatalogResponse({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.veg,
    required this.available,
    required this.bestSeller,
    required this.recommended,
    required this.displayOrder,
    required this.active,
  });

  final String id;
  final String? categoryId;
  final String? categoryName;

  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  final bool veg;
  final bool available;
  final bool bestSeller;
  final bool recommended;

  final int displayOrder;
  final bool active;

  factory CatalogResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return CatalogResponse(
      id: json['id'] as String,

      categoryId:
      json['categoryId'] as String?,

      categoryName:
      json['categoryName'] as String?,

      name: json['name'] as String,

      description:
      json['description'] as String?,

      price:
      (json['price'] as num).toDouble(),

      imageUrl:
      json['imageUrl'] as String?,

      veg:
      json['veg'] as bool? ?? true,

      available:
      json['available'] as bool? ?? true,

      bestSeller:
      json['bestSeller'] as bool? ?? false,

      recommended:
      json['recommended'] as bool? ?? false,

      displayOrder:
      (json['displayOrder'] as num?)?.toInt() ?? 0,

      active:
      json['active'] as bool? ?? true,
    );
  }
}