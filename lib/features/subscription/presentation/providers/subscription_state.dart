import '../../data/models/subscription_history_response.dart';
import '../../data/models/subscription_response.dart';

enum SubscriptionStatusState {
  initial,
  loading,
  success,
  error,
}

class SubscriptionState {
  const SubscriptionState({
    this.status = SubscriptionStatusState.initial,
    this.subscription,
    this.history = const [],
    this.errorMessage,
  });

  final SubscriptionStatusState status;
  final SubscriptionResponse? subscription;
  final List<SubscriptionHistoryResponse> history;
  final String? errorMessage;

  SubscriptionState copyWith({
    SubscriptionStatusState? status,
    SubscriptionResponse? subscription,
    List<SubscriptionHistoryResponse>? history,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      subscription:
      subscription ?? this.subscription,
      history: history ?? this.history,
      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}