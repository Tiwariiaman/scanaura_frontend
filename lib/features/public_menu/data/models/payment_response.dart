class PaymentResponse {
  const PaymentResponse({
    required this.businessName,
    required this.upiId,
  });

  final String businessName;
  final String? upiId;

  factory PaymentResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentResponse(
      businessName:
      json['businessName'] as String? ?? '',
      upiId: json['upiId'] as String?,
    );
  }
}