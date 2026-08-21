import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/models/subscription_request.dart';
import '../../data/subscription_repository.dart';
import 'subscription_state.dart';

final subscriptionNotifierProvider =
NotifierProvider<
    SubscriptionNotifier,
    SubscriptionState>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier
    extends Notifier<SubscriptionState> {

  late final SubscriptionRepository _repository;

  @override
  SubscriptionState build() {
    _repository =
        ref.read(subscriptionRepositoryProvider);

    return const SubscriptionState();
  }

  Future<void> loadSubscription() async {
    state = state.copyWith(
      status:
      SubscriptionStatusState.loading,
      clearError: true,
    );

    try {
      final subscription =
      await _repository.getMySubscription();

      state = state.copyWith(
        status:
        SubscriptionStatusState.success,
        subscription: subscription,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status:
        SubscriptionStatusState.error,
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> loadHistory() async {
    try {
      final history =
      await _repository.getRequestHistory();

      state = state.copyWith(
        history: history,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> createSubscriptionRequest(
      SubscriptionRequest request,
      ) async {
    state = state.copyWith(
      status:
      SubscriptionStatusState.loading,
      clearError: true,
    );

    try {
      await _repository
          .createSubscriptionRequest(request);

      await loadSubscription();
      await loadHistory();
    } catch (e) {
      state = state.copyWith(
        status:
        SubscriptionStatusState.error,
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _messageFromException(
      Object error,
      ) {
    if (error is Exception) {
      final message = error.toString();

      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}