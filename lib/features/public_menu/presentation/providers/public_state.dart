

import '../../data/models/landing_response.dart';
import '../../data/models/menu_response.dart';
import 'package:scanaura_frontend/features/public_menu/data/models/payment_response.dart';

enum PublicStatus {
  initial,
  loading,
  success,
  error,
}

class PublicState {
  const PublicState({
    this.status = PublicStatus.initial,
    this.qrCode,
    this.landing,
    this.menu,
    this.payment,
    this.errorMessage,
  });

  final PublicStatus status;

  final String? qrCode;

  final LandingResponse? landing;

  final MenuResponse? menu;

  final PaymentResponse? payment;

  final String? errorMessage;

  bool get isLoading =>
      status == PublicStatus.loading;

  bool get hasLanding =>
      landing != null;

  bool get hasMenu =>
      menu != null;

  bool get hasPayment =>
      payment != null;

  PublicState copyWith({
    PublicStatus? status,
    String? qrCode,
    LandingResponse? landing,
    MenuResponse? menu,
    PaymentResponse? payment,
    String? errorMessage,
    bool clearError = false,
    bool clearLanding = false,
    bool clearMenu = false,
    bool clearPayment = false,
  }) {
    return PublicState(
      status: status ?? this.status,

      qrCode: qrCode ?? this.qrCode,

      landing: clearLanding
          ? null
          : landing ?? this.landing,

      menu: clearMenu
          ? null
          : menu ?? this.menu,

      payment: clearPayment
          ? null
          : payment ?? this.payment,

      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}