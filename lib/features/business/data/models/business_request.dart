enum BusinessType {
  restaurant,
  cafe,
  bakery,
  grocery,
  foodOutlet,
}

extension BusinessTypeExtension on BusinessType {
  String get apiValue {
    switch (this) {
      case BusinessType.restaurant:
        return 'RESTAURANT';
      case BusinessType.cafe:
        return 'CAFE';
      case BusinessType.bakery:
        return 'BAKERY';
      case BusinessType.grocery:
        return 'GROCERY';
      case BusinessType.foodOutlet:
        return 'FOOD_OUTLET';
    }
  }

  String get displayName {
    switch (this) {
      case BusinessType.restaurant:
        return 'Restaurant';
      case BusinessType.cafe:
        return 'Cafe';
      case BusinessType.bakery:
        return 'Bakery';
      case BusinessType.grocery:
        return 'Grocery';
      case BusinessType.foodOutlet:
        return 'Food Outlet';
    }
  }
}

class BusinessRequest {
  const BusinessRequest({
    required this.businessName,
    required this.businessType,
    required this.phone,
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
    };
  }
}