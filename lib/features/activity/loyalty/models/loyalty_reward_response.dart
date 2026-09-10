class LoyaltyRewardResponse {
  final String id;
  final String? businessId;
  final String title;
  final String? description;
  final int pointsRequired;
  final double rewardAmount;
  final bool active;

  const LoyaltyRewardResponse({
    required this.id,
    this.businessId,
    required this.title,
    this.description,
    required this.pointsRequired,
    required this.rewardAmount,
    required this.active,
  });

  factory LoyaltyRewardResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoyaltyRewardResponse(
      id: json['id']?.toString() ?? '',
      businessId: json['businessId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      pointsRequired: _toInt(
        json['pointsRequired'],
      ),
      rewardAmount: _toDouble(
        json['rewardAmount'],
      ),
      active: json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'rewardAmount': rewardAmount,
      'active': active,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value != null) {
      return int.tryParse(
        value.toString(),
      ) ??
          0;
    }

    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value != null) {
      return double.tryParse(
        value.toString(),
      ) ??
          0.0;
    }

    return 0.0;
  }
}