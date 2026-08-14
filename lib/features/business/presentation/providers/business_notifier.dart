import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/business_repository.dart';
import '../../data/models/business_request.dart';

import 'business_state.dart';

final businessNotifierProvider =
NotifierProvider<BusinessNotifier, BusinessState>(
  BusinessNotifier.new,
);

class BusinessNotifier extends Notifier<BusinessState> {
  late final BusinessRepository _repository;

  @override
  BusinessState build() {
    _repository = ref.read(businessRepositoryProvider);

    return const BusinessState();
  }

  Future<void> createBusiness(
      BusinessRequest request,
      ) async {
    state = state.copyWith(
      status: BusinessStatus.loading,
      clearError: true,
    );

    try {
      final business =
      await _repository.createBusiness(request);

      state = state.copyWith(
        status: BusinessStatus.success,
        business: business,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessStatus.error,
        errorMessage: _messageFromException(e),
      );
    }
  }

  Future<void> loadMyBusiness() async {
    state = state.copyWith(
      status: BusinessStatus.loading,
      clearError: true,
    );

    try {
      final business =
      await _repository.getMyBusiness();

      state = state.copyWith(
        status: BusinessStatus.success,
        business: business,
        clearError: true,
      );
    } catch (e) {
      final message = _messageFromException(e);

      state = state.copyWith(
        status: BusinessStatus.error,
        errorMessage: message,
      );
    }
  }

  Future<void> updateBusiness(
      BusinessRequest request,
      ) async {
    state = state.copyWith(
      status: BusinessStatus.loading,
      clearError: true,
    );

    try {
      final business =
      await _repository.updateBusiness(request);

      state = state.copyWith(
        status: BusinessStatus.success,
        business: business,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessStatus.error,
        errorMessage: _messageFromException(e),
      );
    }
  }

  Future<void> deleteBusiness() async {
    state = state.copyWith(
      status: BusinessStatus.loading,
      clearError: true,
    );

    try {
      await _repository.deleteBusiness();

      state = const BusinessState(
        status: BusinessStatus.initial,
      );
    } catch (e) {
      state = state.copyWith(
        status: BusinessStatus.error,
        errorMessage: _messageFromException(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  String _messageFromException(Object error) {
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