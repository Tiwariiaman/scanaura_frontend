class LoyaltySettingsResponse {
  final String? id;
  final String? businessId;
  final bool enabled;
  final int pointsPerVisit;

  const LoyaltySettingsResponse({
    this.id,
    this.businessId,
    required this.enabled,
    required this.pointsPerVisit,
  });

  factory LoyaltySettingsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoyaltySettingsResponse(
      id: json['id']?.toString(),
      businessId: json['businessId']?.toString(),
      enabled: _toBool(
        json['enabled'],
      ),
      pointsPerVisit: _toInt(
        json['pointsPerVisit'],
        fallback: 10,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'enabled': enabled,
      'pointsPerVisit': pointsPerVisit,
    };
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return false;
  }

  static int _toInt(
      dynamic value, {
        required int fallback,
      }) {
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
          fallback;
    }

    return fallback;
  }
}