class LandingResponse {
  const LandingResponse({
    required this.businessName,
    required this.businessType,
    this.city,
    this.logoUrl,
    required this.menuAvailable,
    required this.paymentEnabled,
  });

  final String businessName;
  final String businessType;
  final String? city;
  final String? logoUrl;
  final bool menuAvailable;
  final bool paymentEnabled;

  factory LandingResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LandingResponse(
      businessName:
      json['businessName'] as String? ?? '',
      businessType:
      json['businessType'] as String? ?? '',
      city:
      json['city'] as String?,
      logoUrl:
      json['logoUrl'] as String?,
      menuAvailable:
      json['menuAvailable'] as bool? ?? false,
      paymentEnabled:
      json['paymentEnabled'] as bool? ?? false,
    );
  }
}