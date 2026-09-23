class GalleryImage {
  final String id;
  final String imageUrl;
  final int displayOrder;

  const GalleryImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      displayOrder: json['displayOrder'] is int
          ? json['displayOrder'] as int
          : int.tryParse(
        json['displayOrder']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}