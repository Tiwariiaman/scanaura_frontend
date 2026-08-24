import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/admin_repository.dart';
import '../../data/model/admin_dashboard_response.dart';
import '../../data/model/business_summary_response.dart';
import '../../data/model/qr_inventory_response.dart';

import 'admin_state.dart';

final adminNotifierProvider =
NotifierProvider<
    AdminNotifier,
    AdminState>(
  AdminNotifier.new,
);

class AdminNotifier
    extends Notifier<AdminState> {
  late final AdminRepository _repository;

  @override
  AdminState build() {
    _repository =
        ref.read(adminRepositoryProvider);

    return const AdminState();
  }

  Future<bool> loadQrDetails(
      String qrCode,
      ) async {
    final code = qrCode.trim();

    if (code.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Invalid QR code.',
        clearQrDetails: true,
      );

      return false;
    }

    state = state.copyWith(
      status: AdminStatus.loading,
      clearError: true,
      clearQrDetails: true,
    );

    try {
      final details =
      await _repository.getQrDetails(code);

      state = state.copyWith(
        status: AdminStatus.success,
        qrDetails: details,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage:
        _messageFromException(e),
        clearQrDetails: true,
      );

      return false;
    }
  }

  void clearQrDetails() {
    state = state.copyWith(
      clearQrDetails: true,
    );
  }

  Future<bool> assignQrToBusiness({
    required String businessId,
    required String qrCode,
  }) async {
    state = state.copyWith(
      businessActionInProgress: true,
      clearError: true,
    );

    try {
      await _repository.assignQrToBusiness(
        businessId: businessId,
        qrCode: qrCode,
      );

      // Refresh QR details so the details page
      // immediately shows the assigned business.
      await loadQrDetails(qrCode);

      // Refresh inventory/dashboard counts.
      await loadQrInventory();
      await loadDashboard();

      state = state.copyWith(
        businessActionInProgress: false,
        clearError: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        businessActionInProgress: false,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(
      status: AdminStatus.loading,
      clearError: true,
    );

    try {
      final dashboard =
      await _repository.getDashboard();

      state = state.copyWith(
        status: AdminStatus.success,
        dashboard: dashboard,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminStatus.error,
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> loadBusinesses() async {
    try {
      final businesses =
      await _repository.getBusinesses();

      state = state.copyWith(
        businesses: businesses,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> searchBusinesses(
      String keyword,
      ) async {
    final query = keyword.trim();

    state = state.copyWith(
      businessSearchQuery: keyword,
      clearError: true,
    );

    if (query.isEmpty) {
      await loadBusinesses();
      return;
    }

    try {
      final businesses =
      await _repository.searchBusinesses(
        query,
      );

      state = state.copyWith(
        businesses: businesses,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> loadQrInventory() async {
    try {
      final inventory =
      await _repository.getQrInventory();

      state = state.copyWith(
        qrInventory: inventory,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<bool> activateBusiness(
      String businessId,
      ) async {
    return _changeBusinessStatus(
      businessId,
      activate: true,
    );
  }

  Future<bool> deactivateBusiness(
      String businessId,
      ) async {
    return _changeBusinessStatus(
      businessId,
      activate: false,
    );
  }

  Future<bool> _changeBusinessStatus(
      String businessId, {
        required bool activate,
      }) async {
    state = state.copyWith(
      businessActionInProgress: true,
      clearError: true,
    );

    try {
      if (activate) {
        await _repository.activateBusiness(
          businessId,
        );
      } else {
        await _repository.deactivateBusiness(
          businessId,
        );
      }

      final updatedBusinesses =
      await _repository.getBusinesses();

      state = state.copyWith(
        businesses: updatedBusinesses,
        businessActionInProgress:
        false,
        clearError: true,
      );

      await loadDashboard();

      return true;
    } catch (e) {
      state = state.copyWith(
        businessActionInProgress: false,
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  Future<bool> generatePhysicalQr(
      int count,
      ) async {
    try {
      final generated =
      await _repository.generatePhysicalQr(
        count,
      );

      state = state.copyWith(
        generatedPhysicalQrs: generated,
        clearError: true,
      );

      await loadQrInventory();
      await loadDashboard();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  Future<bool> deactivateQr(
      String qrCode,
      ) async {
    try {
      await _repository.deactivateQr(
        qrCode,
      );

      await loadQrInventory();
      await loadDashboard();

      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        _messageFromException(e),
      );

      return false;
    }
  }

  Future<void> refreshAll() async {
    state = state.copyWith(
      status: AdminStatus.loading,
      clearError: true,
    );

    try {
      final results = await Future.wait([
        _repository.getDashboard(),
        _repository.getBusinesses(),
        _repository.getQrInventory(),
      ]);

      final dashboard =
      results[0] as AdminDashboardResponse;

      final businesses =
      results[1]
      as List<BusinessSummaryResponse>;

      final qrInventory =
      results[2] as QrInventoryResponse;

      state = state.copyWith(
        status: AdminStatus.success,
        dashboard: dashboard,
        businesses: businesses,
        qrInventory: qrInventory,
        businessSearchQuery: '',
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AdminStatus.error,
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