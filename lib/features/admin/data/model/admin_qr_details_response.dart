class AdminQrDetailsResponse {
  const AdminQrDetailsResponse({
    required this.id,
    required this.qrCode,
    required this.type,
    required this.active,
    required this.assigned,
    this.businessId,
    this.businessName,
  });

  final String id;
  final String qrCode;
  final String type;
  final bool active;
  final bool assigned;
  final String? businessId;
  final String? businessName;

  factory AdminQrDetailsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminQrDetailsResponse(
      id: json['id']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      active: json['active'] as bool? ?? false,
      assigned: json['assigned'] as bool? ?? false,
      businessId:
      json['businessId']?.toString(),
      businessName:
      json['businessName']?.toString(),
    );
  }
}