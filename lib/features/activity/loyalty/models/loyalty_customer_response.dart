class LoyaltyCustomerResponse {
  const LoyaltyCustomerResponse({
    required this.id,
    required this.businessId,
    required this.customerName,
    required this.mobileNumber,
    required this.pointsBalance,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    this.pointsAwarded,
  });

  final String id;
  final String businessId;
  final String customerName;
  final String mobileNumber;
  final int pointsBalance;
  final int totalPointsEarned;
  final int totalPointsRedeemed;

  /// Points awarded by the latest successful loyalty action.
  ///
  /// This is populated for visit verification responses.
  /// It remains null for normal customer/profile responses.
  final int? pointsAwarded;

  factory LoyaltyCustomerResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoyaltyCustomerResponse(
      id: json['id']?.toString() ?? '',
      businessId: json['businessId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      pointsBalance: _toInt(json['pointsBalance']),
      totalPointsEarned: _toInt(json['totalPointsEarned']),
      totalPointsRedeemed: _toInt(json['totalPointsRedeemed']),
      pointsAwarded: _toNullableInt(json['pointsAwarded']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'pointsBalance': pointsBalance,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsRedeemed': totalPointsRedeemed,
      'pointsAwarded': pointsAwarded,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }
}