class LandingResponse {
  const LandingResponse({
    required this.businessName,
    required this.businessType,
    this.city,
    this.logoUrl,
    required this.menuAvailable,
    required this.paymentEnabled,
    this.googleReviewUrl,
    required this.googleReviewEnabled,
  });

  final String businessName;
  final String businessType;
  final String? city;
  final String? logoUrl;

  final bool menuAvailable;

  final bool paymentEnabled;

  final String? googleReviewUrl;
  final bool googleReviewEnabled;

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
      googleReviewUrl:
      json['googleReviewUrl'] as String?,
      googleReviewEnabled:
      json['googleReviewEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'businessType': businessType,
      'city': city,
      'logoUrl': logoUrl,
      'menuAvailable': menuAvailable,
      'paymentEnabled': paymentEnabled,
      'googleReviewUrl': googleReviewUrl,
      'googleReviewEnabled': googleReviewEnabled,
    };
  }
}