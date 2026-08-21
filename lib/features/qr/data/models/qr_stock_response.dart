class QrStockResponse {
  const QrStockResponse({
    required this.totalQr,
    required this.digitalQr,
    required this.assignedPhysicalQr,
    required this.availablePhysicalQr,
  });

  final int totalQr;
  final int digitalQr;
  final int assignedPhysicalQr;
  final int availablePhysicalQr;

  factory QrStockResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return QrStockResponse(
      totalQr: _toInt(json['totalQr']),
      digitalQr: _toInt(json['digitalQr']),
      assignedPhysicalQr:
      _toInt(json['assignedPhysicalQr']),
      availablePhysicalQr:
      _toInt(json['availablePhysicalQr']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}