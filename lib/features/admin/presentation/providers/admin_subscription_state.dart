import '../../data/model/pending_subscription_request_response.dart';

enum AdminSubscriptionStatus {
  initial,
  loading,
  success,
  error,
  actionInProgress,
}

class AdminSubscriptionState {
  const AdminSubscriptionState({
    this.status = AdminSubscriptionStatus.initial,
    this.pendingRequests = const [],
    this.activePlans = const [],
    this.errorMessage,
    this.processingRequestId,
    this.processingBusinessId,
  });

  final AdminSubscriptionStatus status;

  final List<PendingSubscriptionRequestResponse>
  pendingRequests;

  final List<Map<String, dynamic>> activePlans;

  final String? errorMessage;

  final String? processingRequestId;

  final String? processingBusinessId;

  bool get isLoading =>
      status == AdminSubscriptionStatus.loading;

  bool get hasError =>
      status == AdminSubscriptionStatus.error;

  bool get isActionInProgress =>
      status == AdminSubscriptionStatus.actionInProgress;

  bool get hasPlans =>
      activePlans.isNotEmpty;

  AdminSubscriptionState copyWith({
    AdminSubscriptionStatus? status,
    List<PendingSubscriptionRequestResponse>?
    pendingRequests,
    List<Map<String, dynamic>>? activePlans,
    String? errorMessage,
    String? processingRequestId,
    String? processingBusinessId,
    bool clearError = false,
    bool clearProcessingRequestId = false,
    bool clearProcessingBusinessId = false,
  }) {
    return AdminSubscriptionState(
      status: status ?? this.status,
      pendingRequests:
      pendingRequests ?? this.pendingRequests,
      activePlans:
      activePlans ?? this.activePlans,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      processingRequestId:
      clearProcessingRequestId
          ? null
          : processingRequestId ??
          this.processingRequestId,
      processingBusinessId:
      clearProcessingBusinessId
          ? null
          : processingBusinessId ??
          this.processingBusinessId,
    );
  }
}