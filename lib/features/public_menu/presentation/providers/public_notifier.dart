

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanaura_frontend/features/public_menu/presentation/providers/public_state.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/models/landing_response.dart';
import '../../data/models/menu_response.dart';
import '../../data/models/payment_response.dart';
import '../../data/public_repository.dart';

final publicNotifierProvider =
NotifierProvider<PublicNotifier, PublicState>(
  PublicNotifier.new,
);

class PublicNotifier extends Notifier<PublicState> {
  late final PublicRepository _repository;

  @override
  PublicState build() {
    _repository =
        ref.read(publicRepositoryProvider);

    return const PublicState();
  }

  Future<LandingResponse?> loadLanding(
      String qrCode,
      ) async {
    state = state.copyWith(
      status: PublicStatus.loading,
      qrCode: qrCode,
      clearError: true,
    );

    try {
      final landing =
      await _repository.getLandingPage(
        qrCode,
      );

      state = state.copyWith(
        status: PublicStatus.success,
        landing: landing,
        clearError: true,
      );

      return landing;
    } catch (e) {
      state = state.copyWith(
        status: PublicStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return null;
    }
  }

  Future<MenuResponse?> loadMenu() async {
    final qrCode = state.qrCode;

    if (qrCode == null ||
        qrCode.trim().isEmpty) {
      state = state.copyWith(
        status: PublicStatus.error,
        errorMessage:
        'QR code is missing.',
      );

      return null;
    }

    state = state.copyWith(
      status: PublicStatus.loading,
      clearError: true,
    );

    try {
      final menu =
      await _repository.getMenu(
        qrCode,
      );

      state = state.copyWith(
        status: PublicStatus.success,
        menu: menu,
        clearError: true,
      );

      return menu;
    } catch (e) {
      state = state.copyWith(
        status: PublicStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return null;
    }
  }

  Future<PaymentResponse?> loadPayment() async {
    final qrCode = state.qrCode;

    if (qrCode == null ||
        qrCode.trim().isEmpty) {
      state = state.copyWith(
        status: PublicStatus.error,
        errorMessage:
        'QR code is missing.',
      );

      return null;
    }

    state = state.copyWith(
      status: PublicStatus.loading,
      clearError: true,
    );

    try {
      final payment =
      await _repository.getPaymentDetails(
        qrCode,
      );

      state = state.copyWith(
        status: PublicStatus.success,
        payment: payment,
        clearError: true,
      );

      return payment;
    } catch (e) {
      state = state.copyWith(
        status: PublicStatus.error,
        errorMessage:
        _messageFromException(e),
      );

      return null;
    }
  }

  Future<void> refreshLanding() async {
    final qrCode = state.qrCode;

    if (qrCode == null ||
        qrCode.trim().isEmpty) {
      return;
    }

    await loadLanding(qrCode);
  }

  Future<void> refreshMenu() async {
    await loadMenu();
  }

  Future<void> refreshPayment() async {
    await loadPayment();
  }

  void setQrCode(String qrCode) {
    final normalizedQrCode = qrCode.trim();

    if (normalizedQrCode.isEmpty) {
      return;
    }

    // Do not clear the already-loaded public data
    // when the same QR code is being used.
    if (state.qrCode == normalizedQrCode) {
      return;
    }

    state = state.copyWith(
      qrCode: normalizedQrCode,
      clearError: true,
      clearLanding: true,
      clearMenu: true,
      clearPayment: true,
      status: PublicStatus.initial,
    );
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

      if (message.startsWith(
        'Exception: ',
      )) {
        return message.substring(11);
      }

      return message;
    }

    return 'Something went wrong. Please try again.';
  }
}