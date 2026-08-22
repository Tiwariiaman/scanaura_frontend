class RejectSubscriptionRequest {
  const RejectSubscriptionRequest({
    required this.remark,
  });

  final String remark;

  Map<String, dynamic> toJson() {
    return {
      'remark': remark.trim(),
    };
  }
}