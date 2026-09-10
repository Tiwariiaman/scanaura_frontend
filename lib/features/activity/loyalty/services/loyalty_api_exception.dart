class LoyaltyApiException implements Exception {
  const LoyaltyApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() {
    if (statusCode != null) {
      return 'LoyaltyApiException($statusCode): $message';
    }

    return 'LoyaltyApiException: $message';
  }
}