import '../../data/models/qr_response.dart';

enum QrStatus {
  initial,
  loading,
  success,
  error,
}

class QrState {
  const QrState({
    this.status = QrStatus.initial,
    this.digitalQr,
    this.qrCodes = const [],
    this.errorMessage,
  });

  final QrStatus status;
  final QrResponse? digitalQr;
  final List<QrResponse> qrCodes;
  final String? errorMessage;


  QrState copyWith({
    QrStatus? status,
    QrResponse? digitalQr,
    List<QrResponse>? qrCodes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QrState(
      status: status ?? this.status,
      digitalQr: digitalQr ?? this.digitalQr,
      qrCodes: qrCodes ?? this.qrCodes,
      errorMessage:
      clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}