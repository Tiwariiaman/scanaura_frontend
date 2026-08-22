class QrInventoryResponse {
  const QrInventoryResponse({
    required this.availablePhysicalQr,
    required this.assignedPhysicalQr,
    required this.digitalQr,
    required this.totalQr,
  });

  final int availablePhysicalQr;
  final int assignedPhysicalQr;
  final int digitalQr;
  final int totalQr;

  factory QrInventoryResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return QrInventoryResponse(
      availablePhysicalQr:
      (json['availablePhysicalQr'] as num?)?.toInt() ?? 0,
      assignedPhysicalQr:
      (json['assignedPhysicalQr'] as num?)?.toInt() ?? 0,
      digitalQr:
      (json['digitalQr'] as num?)?.toInt() ?? 0,
      totalQr:
      (json['totalQr'] as num?)?.toInt() ?? 0,
    );
  }
}