import '../../data/models/business_response.dart';

enum BusinessStatus {
  initial,
  loading,
  success,
  noBusiness,
  error,
}

class BusinessState {
  const BusinessState({
    this.status = BusinessStatus.initial,
    this.business,
    this.errorMessage,
  });

  final BusinessStatus status;
  final BusinessResponse? business;
  final String? errorMessage;

  BusinessState copyWith({
    BusinessStatus? status,
    BusinessResponse? business,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BusinessState(
      status: status ?? this.status,
      business: business ?? this.business,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}