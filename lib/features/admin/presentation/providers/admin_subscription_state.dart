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
    this.errorMessage,
    this.processingRequestId,
  });

  final AdminSubscriptionStatus status;

  final List<PendingSubscriptionRequestResponse>
  pendingRequests;

  final String? errorMessage;

  final String? processingRequestId;

  bool get isLoading =>
      status == AdminSubscriptionStatus.loading;

  bool get hasError =>
      status == AdminSubscriptionStatus.error;

  bool get isActionInProgress =>
      status ==
          AdminSubscriptionStatus.actionInProgress;

  AdminSubscriptionState copyWith({
    AdminSubscriptionStatus? status,
    List<PendingSubscriptionRequestResponse>?
    pendingRequests,
    String? errorMessage,
    String? processingRequestId,
    bool clearError = false,
    bool clearProcessingRequestId = false,
  }) {
    return AdminSubscriptionState(
      status: status ?? this.status,
      pendingRequests:
      pendingRequests ?? this.pendingRequests,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      processingRequestId:
      clearProcessingRequestId
          ? null
          : processingRequestId ??
          this.processingRequestId,
    );
  }
}