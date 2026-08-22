enum AdminBillingCycle {
  monthly,
  yearly,
  unknown;

  static AdminBillingCycle fromString(
      String? value,
      ) {
    switch (value?.toUpperCase()) {
      case 'MONTHLY':
        return AdminBillingCycle.monthly;

      case 'YEARLY':
        return AdminBillingCycle.yearly;

      default:
        return AdminBillingCycle.unknown;
    }
  }
}

class PendingSubscriptionRequestResponse {
  const PendingSubscriptionRequestResponse({
    required this.requestId,
    required this.businessId,
    required this.businessName,
    required this.planName,
    required this.billingCycle,
    required this.transactionId,
    required this.paymentScreenshotUrl,
    required this.requestedAt,
  });

  final String requestId;
  final String businessId;
  final String businessName;
  final String planName;
  final AdminBillingCycle billingCycle;
  final String transactionId;
  final String? paymentScreenshotUrl;
  final DateTime? requestedAt;

  factory PendingSubscriptionRequestResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return PendingSubscriptionRequestResponse(
      requestId:
      json['requestId']?.toString() ?? '',
      businessId:
      json['businessId']?.toString() ?? '',
      businessName:
      json['businessName'] as String? ?? '',
      planName:
      json['planName'] as String? ?? '',
      billingCycle:
      AdminBillingCycle.fromString(
        json['billingCycle'] as String?,
      ),
      transactionId:
      json['transactionId'] as String? ?? '',
      paymentScreenshotUrl:
      json['paymentScreenshotUrl']
      as String?,
      requestedAt:
      _parseDateTime(
        json['requestedAt'],
      ),
    );
  }

  static DateTime? _parseDateTime(
      dynamic value,
      ) {
    if (value is String &&
        value.isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}