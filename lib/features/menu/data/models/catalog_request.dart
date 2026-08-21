class CatalogRequest {
  const CatalogRequest({
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.veg = true,
    this.available = true,
    this.bestSeller = false,
    this.recommended = false,
    this.displayOrder = 0,
  });

  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool veg;
  final bool available;
  final bool bestSeller;
  final bool recommended;
  final int displayOrder;

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'categoryId': categoryId,
      'name': name,
      if (description != null &&
          description!.trim().isNotEmpty)
        'description': description,
      'price': price,
      if (imageUrl != null &&
          imageUrl!.trim().isNotEmpty)
        'imageUrl': imageUrl,
      'veg': veg,
      'available': available,
      'bestSeller': bestSeller,
      'recommended': recommended,
      'displayOrder': displayOrder,
    };
  }
}