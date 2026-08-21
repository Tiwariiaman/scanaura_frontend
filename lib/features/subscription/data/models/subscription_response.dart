enum SubscriptionStatus {
  trial,
  active,
  pending,
  expired,
  cancelled,
  rejected,
}

enum BillingCycle {
  monthly,
  yearly,
}

class SubscriptionResponse {
  const SubscriptionResponse({
    required this.planName,
    required this.status,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    required this.trialDaysLeft,
    required this.aiImportLimit,
    required this.aiImportUsed,
    required this.brandedQr,
    required this.prioritySupport,
  });

  final String planName;
  final SubscriptionStatus status;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final int trialDaysLeft;
  final int aiImportLimit;
  final int aiImportUsed;
  final bool brandedQr;
  final bool prioritySupport;

  factory SubscriptionResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SubscriptionResponse(
      planName: json['planName'] as String,
      status: _parseStatus(
        json['status'] as String,
      ),
      billingCycle: _parseBillingCycle(
        json['billingCycle'] as String,
      ),
      startDate: DateTime.parse(
        json['startDate'] as String,
      ),
      endDate: DateTime.parse(
        json['endDate'] as String,
      ),
      trialDaysLeft:
      (json['trialDaysLeft'] as num).toInt(),
      aiImportLimit:
      (json['aiImportLimit'] as num).toInt(),
      aiImportUsed:
      (json['aiImportUsed'] as num).toInt(),
      brandedQr:
      json['brandedQr'] as bool,
      prioritySupport:
      json['prioritySupport'] as bool,
    );
  }

  static SubscriptionStatus _parseStatus(
      String value,
      ) {
    return SubscriptionStatus.values.firstWhere(
          (status) =>
      status.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SubscriptionStatus.expired,
    );
  }

  static BillingCycle _parseBillingCycle(
      String value,
      ) {
    return BillingCycle.values.firstWhere(
          (cycle) =>
      cycle.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BillingCycle.monthly,
    );
  }
}