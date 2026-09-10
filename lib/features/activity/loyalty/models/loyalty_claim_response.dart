class LoyaltyClaimResponse {
  const LoyaltyClaimResponse({
    required this.claimId,
    required this.qrToken,
    required this.qrType,
    required this.qrVersion,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsUsed,
    required this.rewardAmount,
    required this.status,
    required this.remainingPoints,
    required this.message,
  });

  final String claimId;
  final String qrToken;
  final String qrType;
  final String qrVersion;
  final String rewardId;
  final String rewardTitle;
  final int pointsUsed;
  final double rewardAmount;
  final String status;
  final int remainingPoints;
  final String message;

  factory LoyaltyClaimResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoyaltyClaimResponse(
      claimId:
      json['claimId']?.toString() ?? '',
      qrToken:
      json['qrToken']?.toString() ?? '',
      qrType:
      json['qrType']?.toString() ?? '',
      qrVersion:
      json['qrVersion']?.toString() ?? '',
      rewardId:
      json['rewardId']?.toString() ?? '',
      rewardTitle:
      json['rewardTitle']?.toString() ?? '',
      pointsUsed:
      _toInt(json['pointsUsed']),
      rewardAmount:
      _toDouble(json['rewardAmount']),
      status:
      json['status']?.toString() ?? '',
      remainingPoints:
      _toInt(json['remainingPoints']),
      message:
      json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claimId': claimId,
      'qrToken': qrToken,
      'qrType': qrType,
      'qrVersion': qrVersion,
      'rewardId': rewardId,
      'rewardTitle': rewardTitle,
      'pointsUsed': pointsUsed,
      'rewardAmount': rewardAmount,
      'status': status,
      'remainingPoints': remainingPoints,
      'message': message,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0.0;
    }

    return 0.0;
  }

  bool get isPending =>
      status.trim().toUpperCase() == 'PENDING';

  bool get isGranted =>
      status.trim().toUpperCase() == 'GRANTED';

  bool get isCancelled =>
      status.trim().toUpperCase() == 'CANCELLED';
}