class BusinessDashboardResponse {
  const BusinessDashboardResponse({
    required this.businessId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.city,
    required this.active,
    required this.subscriptionStatus,
    required this.currentPlan,
    required this.todayScans,
    required this.yesterdayScans,
    required this.last7DaysScans,
    required this.totalScans,
  });

  final String businessId;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String city;
  final bool active;
  final String? subscriptionStatus;
  final String? currentPlan;
  final int todayScans;
  final int yesterdayScans;
  final int last7DaysScans;
  final int totalScans;

  factory BusinessDashboardResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessDashboardResponse(
      businessId:
      json['businessId']?.toString() ?? '',

      businessName:
      json['businessName']?.toString() ?? '',

      ownerName:
      json['ownerName']?.toString() ?? '',

      email:
      json['email']?.toString() ?? '',

      phone:
      json['phone']?.toString() ?? '',

      city:
      json['city']?.toString() ?? '',

      active:
      json['active'] == true,

      subscriptionStatus:
      json['subscriptionStatus']?.toString(),

      currentPlan:
      json['currentPlan']?.toString(),

      todayScans:
      _toInt(json['todayScans']),

      yesterdayScans:
      _toInt(json['yesterdayScans']),

      last7DaysScans:
      _toInt(json['last7DaysScans']),

      totalScans:
      _toInt(json['totalScans']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }
}