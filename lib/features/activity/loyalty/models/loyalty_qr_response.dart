class LoyaltyQrResponse {
  final String qrToken;
  final String customerId;
  final String customerName;
  final String mobileNumber;
  final DateTime expiresAt;

  const LoyaltyQrResponse({
    required this.qrToken,
    required this.customerId,
    required this.customerName,
    required this.mobileNumber,
    required this.expiresAt,
  });

  factory LoyaltyQrResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final qrToken = json['qrToken']?.toString().trim() ?? '';
    final customerId = json['customerId']?.toString().trim() ?? '';
    final customerName = json['customerName']?.toString().trim() ?? '';
    final mobileNumber = json['mobileNumber']?.toString().trim() ?? '';

    final expiresAtValue = json['expiresAt'];

    if (qrToken.isEmpty) {
      throw const FormatException(
        'Loyalty QR token is missing.',
      );
    }

    if (expiresAtValue == null ||
        expiresAtValue.toString().trim().isEmpty) {
      throw const FormatException(
        'Loyalty QR expiry time is missing.',
      );
    }

    final expiresAtString =
    expiresAtValue.toString().trim();

    DateTime expiresAt;

    try {
      expiresAt = DateTime.parse(
        expiresAtString,
      );
    } catch (_) {
      throw FormatException(
        'Invalid loyalty QR expiry time: $expiresAtString',
      );
    }

    return LoyaltyQrResponse(
      qrToken: qrToken,
      customerId: customerId,
      customerName: customerName,
      mobileNumber: mobileNumber,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrToken': qrToken,
      'customerId': customerId,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Duration get remainingTime {
    final difference = expiresAt.difference(
      DateTime.now(),
    );

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }
}