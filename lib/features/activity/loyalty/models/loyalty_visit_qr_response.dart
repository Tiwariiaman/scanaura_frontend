class LoyaltyVisitQrResponse {
  const LoyaltyVisitQrResponse({
    required this.qrToken,
    required this.qrType,
    required this.qrVersion,
    required this.expiresAt,
  });

  final String qrToken;
  final String qrType;
  final String qrVersion;
  final DateTime expiresAt;

  factory LoyaltyVisitQrResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final qrToken =
        json['qrToken']?.toString().trim() ?? '';

    final qrType =
        json['qrType']?.toString().trim() ?? '';

    final qrVersion =
        json['qrVersion']?.toString().trim() ?? '';

    final expiresAtValue =
    json['expiresAt'];

    if (qrToken.isEmpty) {
      throw const FormatException(
        'Loyalty visit QR token is missing.',
      );
    }

    if (qrType.isEmpty) {
      throw const FormatException(
        'Loyalty visit QR type is missing.',
      );
    }

    if (qrVersion.isEmpty) {
      throw const FormatException(
        'Loyalty visit QR version is missing.',
      );
    }

    if (expiresAtValue == null ||
        expiresAtValue.toString().trim().isEmpty) {
      throw const FormatException(
        'Loyalty visit QR expiry time is missing.',
      );
    }

    final expiresAtString =
    expiresAtValue.toString().trim();

    DateTime expiresAt;

    try {
      expiresAt =
          DateTime.parse(expiresAtString);
    } catch (_) {
      throw FormatException(
        'Invalid loyalty visit QR expiry time: '
            '$expiresAtString',
      );
    }

    return LoyaltyVisitQrResponse(
      qrToken: qrToken,
      qrType: qrType,
      qrVersion: qrVersion,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qrToken': qrToken,
      'qrType': qrType,
      'qrVersion': qrVersion,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Duration get remainingTime {
    final difference =
    expiresAt.difference(DateTime.now());

    if (difference.isNegative) {
      return Duration.zero;
    }

    return difference;
  }

  int get remainingSeconds {
    final seconds =
        remainingTime.inSeconds;

    if (seconds <= 0) {
      return 0;
    }

    return seconds;
  }

  bool get isValid {
    return qrToken.isNotEmpty &&
        qrType == 'SCANAURA_LOYALTY_VISIT' &&
        qrVersion == '1' &&
        !isExpired;
  }
}