enum AdminSubscriptionStatus {
  trial,
  active,
  pending,
  expired,
  cancelled,
  rejected,
  unknown,
}

class BusinessSummaryResponse {
  const BusinessSummaryResponse({
    required this.businessId,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.city,
    required this.active,
    required this.subscriptionStatus,
    required this.currentPlan,
  });

  final String businessId;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String city;
  final bool active;
  final AdminSubscriptionStatus subscriptionStatus;
  final String? currentPlan;

  factory BusinessSummaryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return BusinessSummaryResponse(
      businessId:
      json['businessId']?.toString() ?? '',
      businessName:
      json['businessName'] as String? ?? '',
      ownerName:
      json['ownerName'] as String? ?? '',
      email:
      json['email'] as String? ?? '',
      phone:
      json['phone'] as String? ?? '',
      city:
      json['city'] as String? ?? '',
      active:
      json['active'] as bool? ?? false,
      subscriptionStatus:
      _parseSubscriptionStatus(
        json['subscriptionStatus'] as String?,
      ),
      currentPlan:
      json['currentPlan'] as String?,
    );
  }

  static AdminSubscriptionStatus
  _parseSubscriptionStatus(
      String? value,
      ) {
    if (value == null) {
      return AdminSubscriptionStatus.unknown;
    }

    return AdminSubscriptionStatus.values.firstWhere(
          (status) =>
      status.name.toUpperCase() ==
          value.toUpperCase(),
      orElse: () =>
      AdminSubscriptionStatus.unknown,
    );
  }
}