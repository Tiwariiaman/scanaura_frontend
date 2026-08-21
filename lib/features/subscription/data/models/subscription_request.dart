class SubscriptionRequest {
  const SubscriptionRequest({
    required this.planName,
    required this.billingCycle,
    required this.transactionId,
    required this.paymentScreenshotUrl,
  });

  final String planName;
  final String billingCycle;
  final String transactionId;
  final String paymentScreenshotUrl;

  Map<String, dynamic> toJson() {
    return {
      'planName': planName,
      'billingCycle': billingCycle,
      'transactionId': transactionId,
      'paymentScreenshotUrl': paymentScreenshotUrl,
    };
  }
}