class AiMenuItem {
  const AiMenuItem({
    required this.name,
    this.description,
    this.price,
    this.veg,
  });

  final String name;
  final String? description;
  final double? price;
  final bool? veg;

  factory AiMenuItem.fromJson(
      Map<String, dynamic> json,
      ) {
    return AiMenuItem(
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      veg: json['veg'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'veg': veg,
    };
  }
}