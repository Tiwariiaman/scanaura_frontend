class BusinessResponse {
  const BusinessResponse({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.phone,
    this.logoUrl,
    this.whatsapp,
    this.email,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.website,
    this.description,
    this.upiId,
    this.googleReviewUrl,
    this.googleReviewEnabled,
    this.paymentEnabled,
    this.qrSlug,
    this.active,
  });

  final String id;
  final String businessName;
  final String businessType;
  final String phone;

  final String? logoUrl;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  final String? website;
  final String? description;

  final String? upiId;

  final String? googleReviewUrl;
  final bool? googleReviewEnabled;
  final bool? paymentEnabled;

  final String? qrSlug;
  final bool? active;

  factory BusinessResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessResponse(
      id: json['id']?.toString() ?? '',
      businessName:
      json['businessName'] as String? ?? '',
      businessType:
      json['businessType'] as String? ?? '',
      phone:
      json['phone'] as String? ?? '',
      logoUrl:
      json['logoUrl'] as String?,
      whatsapp:
      json['whatsapp'] as String?,
      email:
      json['email'] as String?,
      address:
      json['address'] as String?,
      city:
      json['city'] as String?,
      state:
      json['state'] as String?,
      country:
      json['country'] as String?,
      pincode:
      json['pincode'] as String?,
      website:
      json['website'] as String?,
      description:
      json['description'] as String?,
      upiId:
      json['upiId'] as String?,
      googleReviewUrl:
      json['googleReviewUrl'] as String?,
      googleReviewEnabled:
      json['googleReviewEnabled'] as bool?,
      paymentEnabled:
      json['paymentEnabled'] as bool?,
      qrSlug:
      json['qrSlug'] as String?,
      active:
      json['active'] as bool?,
    );
  }
}