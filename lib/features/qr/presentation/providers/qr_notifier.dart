import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/qr_repository.dart';
import 'qr_state.dart';

final qrNotifierProvider =
NotifierProvider<QrNotifier, QrState>(
  QrNotifier.new,
);

class QrNotifier extends Notifier<QrState> {
  late final QrRepository _repository;

  @override
  QrState build() {
    _repository = ref.read(qrRepositoryProvider);

    return const QrState();
  }

  Future<void> loadQr() async {
    state = state.copyWith(
      status: QrStatus.loading,
      clearError: true,
    );

    try {
      final results = await Future.wait([
        _repository.getMyDigitalQr(),
        _repository.getMyQrCodes(),
      ]);

      state = state.copyWith(
        status: QrStatus.success,
        digitalQr: results[0] as dynamic,
        qrCodes: results[1] as dynamic,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: QrStatus.error,
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