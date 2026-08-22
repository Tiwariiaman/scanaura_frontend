class AdminDashboardResponse {
  const AdminDashboardResponse({
    required this.totalBusinesses,
    required this.activeBusinesses,
    required this.inactiveBusinesses,
    required this.trialSubscriptions,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
    required this.pendingSubscriptionRequests,
    required this.availablePhysicalQr,
    required this.assignedPhysicalQr,
    required this.digitalQrGenerated,
  });

  final int totalBusinesses;
  final int activeBusinesses;
  final int inactiveBusinesses;

  final int trialSubscriptions;
  final int activeSubscriptions;
  final int expiredSubscriptions;
  final int pendingSubscriptionRequests;

  final int availablePhysicalQr;
  final int assignedPhysicalQr;
  final int digitalQrGenerated;

  factory AdminDashboardResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminDashboardResponse(
      totalBusinesses:
      (json['totalBusinesses'] as num?)?.toInt() ?? 0,
      activeBusinesses:
      (json['activeBusinesses'] as num?)?.toInt() ?? 0,
      inactiveBusinesses:
      (json['inactiveBusinesses'] as num?)?.toInt() ?? 0,
      trialSubscriptions:
      (json['trialSubscriptions'] as num?)?.toInt() ?? 0,
      activeSubscriptions:
      (json['activeSubscriptions'] as num?)?.toInt() ?? 0,
      expiredSubscriptions:
      (json['expiredSubscriptions'] as num?)?.toInt() ?? 0,
      pendingSubscriptionRequests:
      (json['pendingSubscriptionRequests'] as num?)?.toInt() ?? 0,
      availablePhysicalQr:
      (json['availablePhysicalQr'] as num?)?.toInt() ?? 0,
      assignedPhysicalQr:
      (json['assignedPhysicalQr'] as num?)?.toInt() ?? 0,
      digitalQrGenerated:
      (json['digitalQrGenerated'] as num?)?.toInt() ?? 0,
    );
  }
}