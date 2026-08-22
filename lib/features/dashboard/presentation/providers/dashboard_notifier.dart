import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../menu/data/menu_repository.dart';
import '../../../qr/data/qr_repository.dart';
import '../../../subscription/data/subscription_repository.dart';
import 'dashboard_state.dart';

final dashboardNotifierProvider =
NotifierProvider<
    DashboardNotifier,
    DashboardState>(
  DashboardNotifier.new,
);

class DashboardNotifier
    extends Notifier<DashboardState> {
  late final MenuRepository _menuRepository;
  late final QrRepository _qrRepository;
  late final SubscriptionRepository
  _subscriptionRepository;

  @override
  DashboardState build() {
    _menuRepository =
        ref.read(menuRepositoryProvider);

    _qrRepository =
        ref.read(qrRepositoryProvider);

    _subscriptionRepository =
        ref.read(
          subscriptionRepositoryProvider,
        );

    return const DashboardState();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(
      status: DashboardStatus.loading,
      clearError: true,
    );

    try {
      final results = await Future.wait([
        _menuRepository.getCatalogs(),
        _menuRepository.getCategories(),
        _qrRepository.getMyQrCodes(),
        _subscriptionRepository
            .getMySubscription(),
      ]);

      final catalogs =
      results[0] as List;

      final categories =
      results[1] as List;

      final qrCodes =
      results[2] as List;

      final subscription =
      results[3]
      as dynamic;

      state = state.copyWith(
        status:
        DashboardStatus.success,

        menuItemCount:
        catalogs.length,

        categoryCount:
        categories.length,

        qrCount:
        qrCodes.length,

        aiImportUsed:
        subscription.aiImportUsed,

        aiImportLimit:
        subscription.aiImportLimit,

        subscription:
        subscription,

        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status:
        DashboardStatus.error,
        errorMessage:
        _messageFromException(e),
      );
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
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
        return message.substring(11);
      }

      return message;
    }

    return 'Unable to load dashboard.';
  }
}