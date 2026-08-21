class SubscriptionHistoryResponse {
  const SubscriptionHistoryResponse({
    required this.planName,
    required this.billingCycle,
    required this.status,
    required this.transactionId,
    required this.paymentScreenshotUrl,
    required this.adminRemark,
    required this.requestedAt,
  });

  final String planName;
  final String billingCycle;
  final String status;
  final String? transactionId;
  final String? paymentScreenshotUrl;
  final String? adminRemark;
  final DateTime requestedAt;

  factory SubscriptionHistoryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SubscriptionHistoryResponse(
      planName: json['planName'] as String,
      billingCycle: json['billingCycle'] as String,
      status: json['status'] as String,
      transactionId:
      json['transactionId'] as String?,
      paymentScreenshotUrl:
      json['paymentScreenshotUrl'] as String?,
      adminRemark:
      json['adminRemark'] as String?,
      requestedAt: DateTime.parse(
        json['requestedAt'] as String,
      ),
    );
  }
}