class QrResponse {
  const QrResponse({
    required this.id,
    required this.qrCode,
    required this.type,
    required this.assigned,
    required this.active,
    this.businessId,
    this.businessName,
  });

  final String id;
  final String qrCode;
  final String type;
  final bool assigned;
  final bool active;
  final String? businessId;
  final String? businessName;

  factory QrResponse.fromJson(Map<String, dynamic> json) {
    return QrResponse(
      id: json['id']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      assigned: json['assigned'] == true,
      active: json['active'] == true,
      businessId: json['businessId']?.toString(),
      businessName: json['businessName']?.toString(),
    );
  }
}