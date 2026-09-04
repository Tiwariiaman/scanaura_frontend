enum BusinessType {
  food,
  retail,
  ecommerce,
  services,
  personalBrand,
  other,
}

extension BusinessTypeExtension on BusinessType {
  String get apiValue {
    switch (this) {
      case BusinessType.food:
        return 'FOOD';

      case BusinessType.retail:
        return 'RETAIL';

      case BusinessType.ecommerce:
        return 'ECOMMERCE';

      case BusinessType.services:
        return 'SERVICES';

      case BusinessType.personalBrand:
        return 'PERSONAL_BRAND';

      case BusinessType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case BusinessType.food:
        return 'Food';

      case BusinessType.retail:
        return 'Retail';

      case BusinessType.ecommerce:
        return 'E-commerce';

      case BusinessType.services:
        return 'Services';

      case BusinessType.personalBrand:
        return 'Personal Brand';

      case BusinessType.other:
        return 'Other';
    }
  }
}

class BusinessRequest {
  const BusinessRequest({
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
  });

  final String businessName;
  final BusinessType businessType;
  final String phone;

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

  final String? logoUrl;

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'businessType': businessType.apiValue,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'website': website,
      'description': description,
      'upiId': upiId,
      'googleReviewUrl': googleReviewUrl,
      'googleReviewEnabled': googleReviewEnabled,
      'paymentEnabled': paymentEnabled,
      'logoUrl': logoUrl,
    };
  }
}