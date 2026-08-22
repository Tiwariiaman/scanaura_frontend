import '../../../../features/subscription/data/models/subscription_response.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  error,
}

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.menuItemCount = 0,
    this.categoryCount = 0,
    this.qrCount = 0,
    this.aiImportUsed = 0,
    this.aiImportLimit = 0,
    this.subscription,
    this.errorMessage,
  });

  final DashboardStatus status;

  final int menuItemCount;
  final int categoryCount;
  final int qrCount;

  final int aiImportUsed;
  final int aiImportLimit;

  final SubscriptionResponse? subscription;

  final String? errorMessage;

  bool get isLoading =>
      status == DashboardStatus.loading;

  bool get hasError =>
      status == DashboardStatus.error;

  bool get hasSubscription =>
      subscription != null;

  int get aiImportsRemaining {
    final remaining =
        aiImportLimit - aiImportUsed;

    return remaining < 0 ? 0 : remaining;
  }

  DashboardState copyWith({
    DashboardStatus? status,
    int? menuItemCount,
    int? categoryCount,
    int? qrCount,
    int? aiImportUsed,
    int? aiImportLimit,
    SubscriptionResponse? subscription,
    String? errorMessage,
    bool clearError = false,
    bool clearSubscription = false,
  }) {
    return DashboardState(
      status: status ?? this.status,

      menuItemCount:
      menuItemCount ?? this.menuItemCount,

      categoryCount:
      categoryCount ?? this.categoryCount,

      qrCount:
      qrCount ?? this.qrCount,

      aiImportUsed:
      aiImportUsed ?? this.aiImportUsed,

      aiImportLimit:
      aiImportLimit ?? this.aiImportLimit,

      subscription:
      clearSubscription
          ? null
          : subscription ?? this.subscription,

      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}