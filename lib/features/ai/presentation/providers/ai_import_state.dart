import '../../data/models/ai_menu_response.dart';

enum AiImportStatus {
  initial,
  analyzing,
  analyzed,
  importing,
  success,
  error,
}

class AiImportState {
  const AiImportState({
    this.status = AiImportStatus.initial,
    this.menuResponse,
    this.errorMessage,
    this.overwriteExistingMenu = false,
  });

  final AiImportStatus status;
  final AiMenuResponse? menuResponse;
  final String? errorMessage;
  final bool overwriteExistingMenu;

  bool get isAnalyzing =>
      status == AiImportStatus.analyzing;

  bool get isImporting =>
      status == AiImportStatus.importing;

  bool get hasResult =>
      menuResponse != null;

  AiImportState copyWith({
    AiImportStatus? status,
    AiMenuResponse? menuResponse,
    String? errorMessage,
    bool? overwriteExistingMenu,
    bool clearMenuResponse = false,
    bool clearError = false,
  }) {
    return AiImportState(
      status: status ?? this.status,
      menuResponse: clearMenuResponse
          ? null
          : menuResponse ?? this.menuResponse,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      overwriteExistingMenu:
      overwriteExistingMenu ??
          this.overwriteExistingMenu,
    );
  }
}