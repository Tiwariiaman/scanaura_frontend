import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/admin_subscription_repository.dart';
import 'admin_subscription_state.dart';

final adminSubscriptionNotifierProvider =
NotifierProvider<
    AdminSubscriptionNotifier,
    AdminSubscriptionState>(
  AdminSubscriptionNotifier.new,
);

class AdminSubscriptionNotifier
    extends Notifier<AdminSubscriptionState> {
  late final AdminSubscriptionRepository
  _repository;

  @override
  AdminSubscriptionState build() {
    _repository = ref.read(
      adminSubscriptionRepositoryProvider,
    );

    return const AdminSubscriptionState();
  }

  Future<void> loadPendingRequests() async {
    state = state.copyWith(
      status:
      AdminSubscriptionStatus.loading,
      clearError: true,
    );

    try {
      final requests =
      await _repository.getPendingRequests();

      state = state.copyWith(
        status:
        AdminSubscriptionStatus.success,
        pendingRequests: requests,
        clearError: true,
        clearProcessingRequestId: true,
      );
    } catch (e) {
      state = state.copyWith(
        status:
        AdminSubscriptionStatus.error,
        errorMessage:
        _messageFromException(e),
        clearProcessingRequestId: true,
      );
    }
  }

  Future<void> refresh() async {
    await loadPendingRequests();
  }

  Future<bool> approveRequest(
      String requestId,
      ) async {
    state = state.copyWith(
      status:
      AdminSubscriptionStatus.actionInProgress,
      processingRequestId: requestId,
      clearError: true,
    );

    try {
      await _repository.approveRequest(
        requestId,
      );

      final updatedRequests =
      await _repository.getPendingRequests();

      state = state.copyWith(
        status:
        AdminSubscriptionStatus.success,
        pendingRequests:
        updatedRequests,
        clearError: true,
        clearProcessingRequestId: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status:
        AdminSubscriptionStatus.error,
        errorMessage:
        _messageFromException(e),
        clearProcessingRequestId: true,
      );

      return false;
    }
  }

  Future<bool> rejectRequest(
      String requestId,
      String remark,
      ) async {
    final trimmedRemark =
    remark.trim();

    if (trimmedRemark.isEmpty) {
      state = state.copyWith(
        status:
        AdminSubscriptionStatus.error,
        errorMessage:
        'Rejection remark is required.',
      );

      return false;
    }

    state = state.copyWith(
      status:
      AdminSubscriptionStatus.actionInProgress,
      processingRequestId: requestId,
      clearError: true,
    );

    try {
      await _repository.rejectRequest(
        requestId,
        trimmedRemark,
      );

      final updatedRequests =
      await _repository.getPendingRequests();

      state = state.copyWith(
        status:
        AdminSubscriptionStatus.success,
        pendingRequests:
        updatedRequests,
        clearError: true,
        clearProcessingRequestId: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status:
        AdminSubscriptionStatus.error,
        errorMessage:
        _messageFromException(e),
        clearProcessingRequestId: true,
      );

      return false;
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
      final message =
      error.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        return message.substring(
          'Exception: '.length,
        );
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}