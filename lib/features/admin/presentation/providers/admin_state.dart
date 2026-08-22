import '../../data/model/admin_dashboard_response.dart';
import '../../data/model/business_summary_response.dart';
import '../../data/model/qr_inventory_response.dart';


enum AdminStatus {
  initial,
  loading,
  success,
  error,
}

class AdminState {
  const AdminState({
    this.status = AdminStatus.initial,
    this.dashboard,
    this.businesses = const [],
    this.qrInventory,
    this.errorMessage,
    this.businessSearchQuery = '',
    this.businessActionInProgress = false,
  });

  final AdminStatus status;

  final AdminDashboardResponse? dashboard;

  final List<BusinessSummaryResponse> businesses;

  final QrInventoryResponse? qrInventory;

  final String? errorMessage;

  final String businessSearchQuery;

  final bool businessActionInProgress;

  bool get isLoading =>
      status == AdminStatus.loading;

  bool get hasError =>
      status == AdminStatus.error;

  AdminState copyWith({
    AdminStatus? status,
    AdminDashboardResponse? dashboard,
    List<BusinessSummaryResponse>? businesses,
    QrInventoryResponse? qrInventory,
    String? errorMessage,
    String? businessSearchQuery,
    bool? businessActionInProgress,
    bool clearError = false,
    bool clearDashboard = false,
    bool clearQrInventory = false,
  }) {
    return AdminState(
      status: status ?? this.status,

      dashboard: clearDashboard
          ? null
          : dashboard ?? this.dashboard,

      businesses:
      businesses ?? this.businesses,

      qrInventory: clearQrInventory
          ? null
          : qrInventory ?? this.qrInventory,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,

      businessSearchQuery:
      businessSearchQuery ??
          this.businessSearchQuery,

      businessActionInProgress:
      businessActionInProgress ??
          this.businessActionInProgress,
    );
  }
}